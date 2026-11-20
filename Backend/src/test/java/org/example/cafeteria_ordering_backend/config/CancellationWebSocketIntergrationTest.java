package org.example.cafeteria_ordering_backend.config;

import org.example.cafeteria_ordering_backend.dto.requests.OrderRequestDTO;
import org.example.cafeteria_ordering_backend.dto.response.OrderResponseDTO;
import org.example.cafeteria_ordering_backend.entity.*;
import org.example.cafeteria_ordering_backend.repository.*;
import org.example.cafeteria_ordering_backend.security.CustomUserDetailsService;
import org.example.cafeteria_ordering_backend.security.JwtUtils;
import org.example.cafeteria_ordering_backend.service.interfaces.OrderService;
import org.junit.jupiter.api.AfterEach;
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
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.web.socket.WebSocketHttpHeaders;
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

@SpringBootTest(

        // Starts actual webserver on random port
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        // Overrides application properties for test
        properties = {
                "SPRING_DATASOURCE_URL=jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1",
                "SPRING_DATASOURCE_USERNAME=sa",
                "SPRING_DATASOURCE_PASSWORD=",
                "SPRING_DATASOURCE_DRIVER_CLASS_NAME=org.h2.Driver",
                "jwt.secret=VGhpcylzYXZlcnlzZWN1cmVzdGVudHNlY3JldGtleWZvcmNhZmV0ZXJpYWhzaTUxMg==",
                "jwt.expiration-ms=900000"
        }
)
// Use apps test configuration & profile
@ActiveProfiles("test")
class CancellationWebSocketIntegrationTest {

    // Stores random port assigned for test
    @LocalServerPort
    private int port;

    // @Autowired injects actual services
    @Autowired private OrderService orderService;
    @Autowired private CustomUserDetailsService customUserDetailsService;
    @Autowired private JwtUtils jwtUtils;
    @Autowired private UserRepository userRepository;
    @Autowired private RoleRepository roleRepository;
    @Autowired private CategoryRepository categoryRepository;
    @Autowired private MenuItemRepository menuItemRepository;
    @Autowired private OrderStatusRepository orderStatusRepository;

    // Clears Spring Security context after each test, prevents authentication context leaking into next test
    @AfterEach
    void clearSecurityContext () {SecurityContextHolder.clearContext();
    }

    // Ensures cancelling order sends correct cancellation notification to student and ktichen topics
    @Test
    void cancellationShouldSendUpdateToStudentAndKitchen () throws Exception {

        // Prepare customer role
        Role customerRole = roleRepository.findByRoleName("CUSTOMER").orElseGet(() -> {
            Role newRole = new Role();
            newRole.setRoleName("CUSTOMER");
            return roleRepository.saveAndFlush(newRole);
        });

        // Prep user role
        User testUser = userRepository.findByEmail("student@eduvos.com").orElseGet(() -> {
            User newUser = new User();
            newUser.setCustomerCode("CUST-001");
            newUser.setEmail("student@eduvos.com");
            newUser.setPasswordHash("Password123!");
            newUser.setFirstName("Alice");
            newUser.setLastName("Campus");
            newUser.setRole(customerRole);
            return userRepository.saveAndFlush(newUser);
        });

        // Populate required order statuses
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

        // Prepare menu category
        Category category = categoryRepository.findAll().stream().findFirst().orElseGet(() -> {
            Category newCat = new Category();
            newCat.setCategoryName("Test Category");
            return categoryRepository.saveAndFlush(newCat);
        });

        // Prepare an available menu item
        MenuItems menuItem = menuItemRepository.findById(1L).orElseGet(() -> {
            MenuItems newItem = new MenuItems();
            newItem.setName("Test Burger");
            newItem.setPrice(new BigDecimal("45.00"));
            newItem.setCategory(category);
            newItem.setStockQuantity(50);
            newItem.setAvailable(true);
            return menuItemRepository.saveAndFlush(newItem);
        });

        menuItem.setStockQuantity(50);
        menuItem.setAvailable(true);
        menuItemRepository.saveAndFlush(menuItem);

        // Authenticate student and generate a JWT
        UserDetails userDetails = customUserDetailsService.loadUserByUsername(testUser.getEmail());
        // Set authed user in current security context
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities())
        );

        // Generate new JWT containing users identity
        String token = jwtUtils.generateToken(userDetails.getUsername());

        // Build order request
        OrderRequestDTO request = new OrderRequestDTO();
        request.setUserId(testUser.getUserId());

        OrderRequestDTO.OrderItemRequest item = new OrderRequestDTO.OrderItemRequest();
        item.setMenuItemId(menuItem.getMenuItemId());
        item.setQuantity(1);
        item.setSpecialInstructions("WebSocket cancellation test");
        item.setModifierIds(List.of());
        request.setItems(List.of(item));

        // Prep queues for incoming websocket messages
        // Store messages sent to the student and kitchens order topics
        BlockingQueue<String> studentMessages = new LinkedBlockingQueue<>();
        BlockingQueue<String> kitchenMessages = new LinkedBlockingQueue<>();
        // Coordinate test with asynchronous websocket connection, counter hits zero on established connection
        CountDownLatch connectedLatch = new CountDownLatch(1);

        // Create STOMP client over standard websocket connection
        WebSocketStompClient stompClient = new WebSocketStompClient(new StandardWebSocketClient());

        // Configure websocket message converter
        // Setup client to convert byte[] payloads into UTF-8 strings
        // this allows tests STOMP frame handlers to process incoming notification messages as strings
        stompClient.setMessageConverter(new MessageConverter() {

            @Override
            public Object fromMessage (Message<?> message, Class<?> targetClass) {
                // Gets raw message payload
                Object payload = message.getPayload();
                // Convert byte array to strings when a string is requested
                if (targetClass == String.class && payload instanceof byte[]) {
                    return new String((byte[]) payload, StandardCharsets.UTF_8);
                }
                return null; // for unsupported conversion req
            }

            // Outgoing message conversion not required
            @Override
            public Message<?> toMessage (Object payload, MessageHeaders headers) {return null;}
        });

        // Config authenticated Websocket connection headers
        // Add JWT bearer token in STOMP CONNECT headers
        StompHeaders connectHeaders = new StompHeaders();
        connectHeaders.add("Authorization", "Bearer " + token);

        // Connect apps WebSocket endpoint, port supplied by SpringBoot
        // connection attempt is asynchronous therefore get waits for connection result, max wait 5sec.
        StompSession session = stompClient.connectAsync(
                "ws://localhost:" + port + "/ws-orders",
                new WebSocketHttpHeaders(),
                connectHeaders,
                // Handles connection events and WebsSocket errors
                new StompSessionHandlerAdapter() {

                    @Override
                    public void afterConnected (StompSession session, StompHeaders connectedHeaders) {
                        connectedLatch.countDown(); // Signal connection established
                    }

                    @Override
                    public void handleException (
                            StompSession session,
                            org.springframework.messaging.simp.stomp.StompCommand command,
                            StompHeaders headers,
                            byte[] payload,
                            Throwable exception) {

                        exception.printStackTrace(); // Print STOMP processing errors for debugging
                    }
                    @Override
                    public void handleTransportError(StompSession session, Throwable exception) {
                        exception.printStackTrace(); // Print transport errors
                    }
                }
        ).get(5, TimeUnit.SECONDS);

        // Verify connection was established within 5 seconds
        assertThat(connectedLatch.await(5, TimeUnit.SECONDS)).isTrue();

        // Subscribe to students personal order topic
        // Listens for notification associated with users ID, incomming payloads store in message queue
        session.subscribe("/topic/orders/" + testUser.getUserId(), new StompFrameHandler() {

            @Override public Type getPayloadType (StompHeaders headers) { return String.class; }

            @Override public void handleFrame (StompHeaders headers, Object payload) {

                studentMessages.add((String) payload);
            }
        });

        // Subscribe to kitchens active-orders topic
        // Listen for notification
        session.subscribe("/topic/orders/active", new StompFrameHandler() {
            @Override public Type getPayloadType (StompHeaders headers) { return String.class; }
            @Override public void handleFrame (StompHeaders headers, Object payload) {

                kitchenMessages.add((String) payload);
            }
        });

        // Time for both subscriptions to register before order creation and cancellation
        Thread.sleep(1000);

        // Create order and cancel
        OrderResponseDTO createdOrder = orderService.checkout(request); // order creation
        assertThat(createdOrder).isNotNull();

        Long orderId = createdOrder.getOrderId();
        orderService.cancelOrder(orderId);

        assertThat(pollForStatus(studentMessages, orderId, "Cancelled", 5000))
                .isNotNull()
                .as("Student did not receive Cancelled status for order " + orderId);

        assertThat(pollForStatus(kitchenMessages, orderId, "Cancelled", 5000))
                .isNotNull()
                .as("Kitchen did not receive Cancelled status for order " + orderId);

        // Close websocket connection and client
        session.disconnect();
        stompClient.stop();
    }

    // Search queue of websocket messages for given order ID and status
    private String pollForStatus (BlockingQueue<String> queue, Long orderId, String expectedStatus, long timeoutMillis)
            throws InterruptedException {

        // Deadline time
        long endTime = System.currentTimeMillis() + timeoutMillis;
        // Build JSON fragments expected for order ID and status
        String targetOrderId = "\"orderId\":" + orderId;
        String targetStatus = "\"status\":\"" + expectedStatus + "\"";

        while (System.currentTimeMillis() < endTime) {
            String message = queue.poll(200, TimeUnit.MILLISECONDS); // wait up to 200ms
            if (message != null && message.contains(targetOrderId) && message.contains(targetStatus)) {
                return message;
            }
        }
        return null;
    }
}