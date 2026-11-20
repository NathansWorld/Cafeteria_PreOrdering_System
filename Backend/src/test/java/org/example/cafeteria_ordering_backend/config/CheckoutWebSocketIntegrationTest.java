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

// Integration test for checkout WebSocket notification workflow.
// Verifies successfully created order generates notification for kitchen active-orders topic
@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT, // Starts SpringBoot with random port
        properties = { // Overrides JWT properties for test
                "jwt.secret=test-only-secret-key-for-cafeteria-integration-tests-2026",
                "jwt.expiration-ms=900000"
        }
)
@ActiveProfiles("test") // Use applications test profile
class CheckoutWebSocketIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired private OrderService orderService;
    @Autowired private UserRepository userRepository;
    @Autowired private MenuItemRepository menuItemRepository;
    @Autowired private CategoryRepository categoryRepository;
    @Autowired private RoleRepository roleRepository;
    @Autowired private OrderStatusRepository orderStatusRepository;

    private User testUser;
    private MenuItems menuItem;

    // Prep DB records before each test
    @BeforeEach
    void setUpTestData () {

        // Prep customer role
        Role customerRole = roleRepository.findByRoleName("CUSTOMER").orElseGet(() -> {
            Role newRole = new Role();
            newRole.setRoleName("CUSTOMER");
            return roleRepository.save(newRole);
        });

        // Prep test user
        testUser = userRepository.findAll().stream()
                .filter(u -> "testcustomer@edu.com".equals(u.getEmail()))
                .findFirst()
                .orElseGet(() -> {
                    User newUser = new User();
                    newUser.setCustomerCode("CUST-001");
                    newUser.setEmail("testcustomer@edu.com");
                    newUser.setPasswordHash("Password123!");
                    newUser.setFirstName("Test");
                    newUser.setLastName("Customer");
                    newUser.setRole(customerRole);
                    return userRepository.save(newUser);
                });

        // Ensure correct statuses exist
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
                return orderStatusRepository.save(status);
            });
        });

        // Prep menu category
        Category category = categoryRepository.findAll().stream().findFirst().orElseGet(() -> {
            Category newCat = new Category();
            newCat.setCategoryName("Test Category");
            return categoryRepository.save(newCat);
        });

        // Prep menu item
        menuItem = menuItemRepository.findAll().stream()
                .filter(m -> "Test Burger".equals(m.getName()))
                .findFirst()
                .orElseGet(() -> {
                    MenuItems newItem = new MenuItems();
                    newItem.setName("Test Burger");
                    newItem.setPrice(new BigDecimal("45.00"));
                    newItem.setCategory(category);
                    newItem.setStockQuantity(50);
                    newItem.setAvailable(true);
                    return menuItemRepository.save(newItem);
                });

        menuItem.setName("Test Burger");
        menuItem.setPrice(new BigDecimal("45.00"));
        menuItem.setCategory(category);
        menuItem.setStockQuantity(50);
        menuItem.setAvailable(true);
        menuItem = menuItemRepository.save(menuItem);
    }

    // Clears Spring Security after each test
    @AfterEach
    void clearSecurityContext () {SecurityContextHolder.clearContext();}

    // Ensures successful order check yields the correct notification
    @Test
    void checkoutShouldSendNewOrderToKitchen () throws Exception {

        // Is test data there
        assertThat(testUser.getUserId()).isNotNull();
        assertThat(testUser.getEmail()).isNotNull();
        assertThat(menuItem.getMenuItemId()).isNotNull();

        // Authenticate test customer
        UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                testUser.getEmail(), null, List.of(new SimpleGrantedAuthority("ROLE_CUSTOMER"))
        );
        SecurityContextHolder.getContext().setAuthentication(authentication);

        // Prep asynchronous WebSocket message handling
        // Blocking queue allows tests to wait for asynchronous messages
        BlockingQueue<String> kitchenMessages = new LinkedBlockingQueue<>();
        CountDownLatch connectedLatch = new CountDownLatch(1); // Counter reaches zero on connection established

        StandardWebSocketClient webSocketClient = new StandardWebSocketClient();
        // subscriptions to applications messaging topics
        WebSocketStompClient stompClient = new WebSocketStompClient(webSocketClient);

        // Config WebSocket message conversion
        // Convert incoming byte[] payloads to UTF-8 Strings, allowing test to inspect the JSON notification content
        stompClient.setMessageConverter(new MessageConverter() {

            @Override
            public Object fromMessage (Message<?> message, Class<?> targetClass) {

                Object payload = message.getPayload(); // Get raw incoming message payload
                if (targetClass == String.class && payload instanceof byte[]) {
                    return new String((byte[]) payload, StandardCharsets.UTF_8); // convert byte array
                }
                return null;
            }

            @Override
            public Message<?> toMessage (Object payload, MessageHeaders headers) {return null;} //not required
        });

        // Establish WebSocket connection
        // Construct WebSocket URL using random server port
        String url = "ws://localhost:" + port + "/ws-orders";
        WebSocketHttpHeaders handshakeHeaders = new WebSocketHttpHeaders(); // Prep HTTP headers used during handshake
        // Supply frontend origin
        handshakeHeaders.add("Origin", "http://localhost:5173");
        // Connect to WebSocket endpoint, runs asynchronously, get waits for max 5 sec
        StompSession session = stompClient.connectAsync(
                url,
                handshakeHeaders,
                new StompHeaders(),
                new StompSessionHandlerAdapter() {

                    @Override
                    public void afterConnected (StompSession session, StompHeaders connectedHeaders) {

                        connectedLatch.countDown();
                    }
                    @Override
                    public void handleException (
                            StompSession session,
                            org.springframework.messaging.simp.stomp.StompCommand command,
                            StompHeaders headers, byte[] payload, Throwable exception) {

                        exception.printStackTrace();
                    }
                    @Override
                    public void handleTransportError (StompSession session, Throwable exception) {

                        exception.printStackTrace();
                    }
                }
        ).get(5, TimeUnit.SECONDS);

        assertThat(connectedLatch.await(5, TimeUnit.SECONDS)).isTrue();

        // Subscribe to kitchens active-orders topic
        // Listen for order notifications published
        session.subscribe("/topic/orders/active", new StompFrameHandler() {
            @Override public Type getPayloadType (StompHeaders headers) { return String.class; }
            @Override public void handleFrame (StompHeaders headers, Object payload) {

                kitchenMessages.add((String) payload);
            }
        });

        Thread.sleep(1000);

        // Construct checkout request
        OrderRequestDTO request = new OrderRequestDTO();
        request.setUserId(testUser.getUserId());

        OrderRequestDTO.OrderItemRequest item = new OrderRequestDTO.OrderItemRequest();
        item.setMenuItemId(menuItem.getMenuItemId());
        item.setQuantity(1);
        item.setSpecialInstructions("WebSocket checkout test");
        item.setModifierIds(List.of());
        request.setItems(List.of(item));

        // Execute checkout
        OrderResponseDTO response = orderService.checkout(request);
        assertThat(response).isNotNull();

        // Wait for kitchen topic for 5 sec
        String kitchenMessage = kitchenMessages.poll(5, TimeUnit.SECONDS);
        assertThat(kitchenMessage).isNotNull();

        assertThat(kitchenMessage).contains("\"orderId\":" + response.getOrderId());
        assertThat(kitchenMessage).contains("\"customerOrderNumber\":\"" + response.getCustomerOrderNumber() + "\"");
        assertThat(kitchenMessage).contains("\"status\":\"Submitted\"");

        session.disconnect();
        stompClient.stop();
    }
}