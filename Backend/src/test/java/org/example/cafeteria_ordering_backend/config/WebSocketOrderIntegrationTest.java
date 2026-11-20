package org.example.cafeteria_ordering_backend.config;

import org.example.cafeteria_ordering_backend.dto.requests.OrderRequestDTO;
import org.example.cafeteria_ordering_backend.dto.response.OrderResponseDTO;
import org.example.cafeteria_ordering_backend.entity.*;
import org.example.cafeteria_ordering_backend.repository.*;
import org.example.cafeteria_ordering_backend.service.interfaces.OrderService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageHeaders;
import org.springframework.messaging.converter.MessageConverter;
import org.springframework.messaging.simp.stomp.StompFrameHandler;
import org.springframework.messaging.simp.stomp.StompHeaders;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.stomp.StompSessionHandlerAdapter;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;
import org.springframework.web.socket.messaging.WebSocketStompClient;

import java.lang.reflect.Type;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

import static org.assertj.core.api.Assertions.assertThat;

// Start app on random port
@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = { // Configuring an in-memory H2 DB and JWT settings for test
                "SPRING_DATASOURCE_URL=jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1",
                "SPRING_DATASOURCE_USERNAME=sa",
                "SPRING_DATASOURCE_PASSWORD=",
                "SPRING_DATASOURCE_DRIVER_CLASS_NAME=org.h2.Driver",
                "jwt.secret=VGhpcylzYXZlcnlzZWN1cmVzdGVudHNlY3JldGtleWZvcmNhZmV0ZXJpYWhzaTUxMg==",
                "jwt.expiration-ms=900000"
        }
)
@ActiveProfiles("test") // Run test on test profile
class WebSocketOrderIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired private OrderService orderService;
    @Autowired private UserRepository userRepository;
    @Autowired private RoleRepository roleRepository;
    @Autowired private CategoryRepository categoryRepository;
    @Autowired private MenuItemRepository menuItemRepository;
    @Autowired private OrderStatusRepository orderStatusRepository;

    private User testUser;
    private MenuItems menuItem;

    // Reusable setup so each test runs on fresh data
    @BeforeEach
    void setUpTestData () {

        // Ensure all relevant statuses exist
        List.of("Submitted", "Accepted", "Preparing", "Ready", "Collected", "Cancelled").forEach(name -> {
            orderStatusRepository.findByStatusName(name).orElseGet(() -> {
                OrderStatus status = new OrderStatus();
                status.setStatusName(name);
                status.setSortOrder(
                        name.equals("Submitted") ? 1 :
                                name.equals("Accepted") ? 2 :
                                        name.equals("Preparing") ? 3 :
                                                name.equals("Ready") ? 4 :
                                                        name.equals("Collected") ? 5 : 6
                );
                status.setIsFinal(name.equals("Collected") || name.equals("Cancelled"));
                return orderStatusRepository.saveAndFlush(status);
            });
        });

        // Check customer role exists
        Role customerRole = roleRepository.findByRoleName("CUSTOMER").orElseGet(() -> {
            Role newRole = new Role();
            newRole.setRoleName("CUSTOMER");
            return roleRepository.saveAndFlush(newRole);
        });

        // Prep test user
        testUser = userRepository.findByEmail("order-test@edu.com").orElseGet(() -> {
            User newUser = new User();
            newUser.setCustomerCode("CUST-ORD-01");
            newUser.setEmail("order-test@edu.com");
            newUser.setPasswordHash("Password123!");
            newUser.setFirstName("Order");
            newUser.setLastName("TestUser");
            newUser.setRole(customerRole);
            return userRepository.saveAndFlush(newUser);
        });

        // Prep menu category
        Category category = categoryRepository.findAll().stream().findFirst().orElseGet(() -> {
            Category newCat = new Category();
            newCat.setCategoryName("Test Category");
            return categoryRepository.saveAndFlush(newCat);
        });

        // Prep menu item
        menuItem = menuItemRepository.findAll().stream().findFirst().orElseGet(() -> {
            MenuItems newItem = new MenuItems();
            newItem.setName("Test Burger");
            newItem.setPrice(new BigDecimal("45.00"));
            newItem.setCategory(category);
            newItem.setStockQuantity(50);
            newItem.setAvailable(true);
            return menuItemRepository.saveAndFlush(newItem);
        });
    }

    // Clears Spring security after each test, clears all authorization info
    @AfterEach
    void clearSecurityContext() {SecurityContextHolder.clearContext();   }

    // Verifies order update is sent to both user and kitch
    @Test
    void orderStatusUpdateShouldBeSentToStudentAndKitchen () throws Exception {

        assertThat(testUser.getUserId()).isNotNull();

        // Create Spring Security token for user
        UsernamePasswordAuthenticationToken authentication =new UsernamePasswordAuthenticationToken(
                testUser.getEmail(),
                null,
                List.of(new SimpleGrantedAuthority("ROLE_CUSTOMER"))
                );
        // Place Sec token in current Security Context
        SecurityContextHolder.getContext().setAuthentication(authentication);

        // Store notifications sent to student and kitchens order topic
        BlockingQueue<String> studentMessages = new LinkedBlockingQueue<>();
        BlockingQueue<String> kitchenMessages = new LinkedBlockingQueue<>();
        CountDownLatch connectedLatch = new CountDownLatch(1); // Latch released when callback invoked

        StandardWebSocketClient webSocketClient = new StandardWebSocketClient();
        // Wrap websocket client in STOMP client supporting subscription to server topics
        WebSocketStompClient stompClient = new WebSocketStompClient(webSocketClient);

        // Config message conversion so byte[] payloads can be read as UTF-8 strings by tests STOMP frame handlers
        stompClient.setMessageConverter(new MessageConverter() {

            @Override
            public Object fromMessage (Message<?> message, Class<?> targetClass) {

                Object payload = message.getPayload();
                if (targetClass == String.class && payload instanceof byte[]) {
                    return new String((byte[]) payload, StandardCharsets.UTF_8); // Convert byte array
                }
                return null; // Unsupported conversions not handled
            }

            @Override
            public Message<?> toMessage (Object payload, MessageHeaders headers) {return null;} // not needed
        });

        // Connect to websocket endpoint
        // Random port assigned
        StompSession session = stompClient.connectAsync(
                "ws://localhost:" + port + "/ws-orders",
                new StompSessionHandlerAdapter() {

                    @Override
                    public void afterConnected (StompSession session, StompHeaders connectedHeaders) {

                        connectedLatch.countDown(); // Signal that websocket connection is established
                    }
                    @Override
                    public void handleException (
                            StompSession session,
                            org.springframework.messaging.simp.stomp.StompCommand command,
                            StompHeaders headers,
                            byte[] payload,
                            Throwable exception) {

                        exception.printStackTrace(); // Print STOMP processing errors to help debug
                    }
                    @Override
                    public void handleTransportError (StompSession session, Throwable exception) {
                        exception.printStackTrace(); // Print transport errors
                    }
                }
        ).get(5, TimeUnit.SECONDS);

        assertThat(connectedLatch.await(5, TimeUnit.SECONDS)).isTrue();

        // Subscribe to users personal order topic
        session.subscribe("/topic/orders/" + testUser.getUserId(), new StompFrameHandler() {

            // Tell STOMP client to convert payloads to strings
            @Override public Type getPayloadType (StompHeaders headers) { return String.class; }
            @Override public void handleFrame (StompHeaders headers, Object payload) {

                studentMessages.add((String) payload); // Store each received notification for later verification
            }
        });

        // Subscribe to kitchens topic to receive notifications about order changes
        session.subscribe("/topic/orders/active", new StompFrameHandler() {

            // Expect payloads as strings
            @Override public Type getPayloadType (StompHeaders headers) { return String.class; }
            @Override public void handleFrame (StompHeaders headers, Object payload) {

                kitchenMessages.add((String) payload); // Store
            }
        });

        Thread.sleep(1000); // Give serer time to register both subscriptions

        // Associate order req with test user
        OrderRequestDTO request = new OrderRequestDTO();
        request.setUserId(testUser.getUserId());

        // Create order item with preped menu item
        OrderRequestDTO.OrderItemRequest item = new OrderRequestDTO.OrderItemRequest();
        item.setMenuItemId(menuItem.getMenuItemId());
        item.setQuantity(1);
        item.setSpecialInstructions("Status update test");
        item.setModifierIds(List.of());
        request.setItems(List.of(item));

        // Create the order
        OrderResponseDTO createdOrder = orderService.checkout(request); // Checkout
        assertThat(createdOrder).isNotNull();

        Long orderId = createdOrder.getOrderId();
        String expectedOrderNumber = createdOrder.getCustomerOrderNumber();

        // Update order status
        orderService.updateOrderStatus(orderId, "Accepted");

        // Wait for status update
        String studentMessage = pollForStatus(studentMessages, orderId, "Accepted");
        String kitchenMessage = pollForStatus(kitchenMessages, orderId, "Accepted");

        assertThat(studentMessage).isNotNull().as("Student did not receive WebSocket message for Accepted status");
        assertThat(kitchenMessage).isNotNull().as("Kitchen did not receive WebSocket message for Accepted status");

        assertThat(studentMessage)
                .contains("\"orderId\":" + orderId)
                .contains("\"customerOrderNumber\":\"" + expectedOrderNumber + "\"")
                .contains("\"status\":\"Accepted\"");

        assertThat(kitchenMessage)
                .contains("\"orderId\":" + orderId)
                .contains("\"customerOrderNumber\":\"" + expectedOrderNumber + "\"")
                .contains("\"status\":\"Accepted\"");

        session.disconnect(); // Close STOMP session
        stompClient.stop(); // Stop Client
    }


    // Helper method to wait for websocket message containing specified order id and status
    private String pollForStatus (BlockingQueue<String> queue, Long orderId, String status)
            throws InterruptedException {

        long endTime = System.currentTimeMillis() + 5000;

        while (System.currentTimeMillis() < endTime) {
            String message = queue.poll(500, TimeUnit.MILLISECONDS);
            if (message != null && message.contains("\"orderId\":" + orderId) && message.contains("\"status\":\"" + status + "\"")) {
                return message;
            }
        }
        return null;
    }
}