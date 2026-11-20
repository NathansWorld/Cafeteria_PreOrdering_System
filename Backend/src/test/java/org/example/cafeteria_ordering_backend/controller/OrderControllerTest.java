package org.example.cafeteria_ordering_backend.controller;

import io.github.bucket4j.Bucket;
import org.example.cafeteria_ordering_backend.dto.requests.OrderRequestDTO;
import org.example.cafeteria_ordering_backend.dto.requests.OrderStatusUpdateRequestDTO;
import org.example.cafeteria_ordering_backend.dto.response.OrderResponseDTO;
import org.example.cafeteria_ordering_backend.entity.PaymentMethod; // <-- Import your PaymentMethod enum
import org.example.cafeteria_ordering_backend.exception.ResourceNotFoundException;
import org.example.cafeteria_ordering_backend.security.JwtAuthenticationFilter;
import org.example.cafeteria_ordering_backend.security.JwtUtils;
import org.example.cafeteria_ordering_backend.service.interfaces.OrderService;
import org.example.cafeteria_ordering_backend.service.interfaces.RateLimitService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import tools.jackson.databind.ObjectMapper;

import java.math.BigDecimal;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// Tests HTTP endpoints exposed by OrderController
@WebMvcTest(OrderController.class)
@AutoConfigureMockMvc(addFilters = false)
class OrderControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private OrderService orderService;

    @MockitoBean
    private JwtUtils jwtUtils;

    @MockitoBean
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @MockitoBean
    private RateLimitService rateLimitService;

    private OrderRequestDTO validOrderRequest;
    private OrderResponseDTO sampleOrderResponse;

    // Reusable test data
    @BeforeEach
    void setUp () {

        // Create a mock bucket that always allows requests
        Bucket mockBucket = mock(Bucket.class);
        when(mockBucket.tryConsume(anyLong())).thenReturn(true);

        // Whenever any client key requests a bucket, return our mock bucket
        when(rateLimitService.resolveBucket(anyString())).thenReturn(mockBucket);

        OrderRequestDTO.OrderItemRequest itemRequest = new OrderRequestDTO.OrderItemRequest(
                1L, 2, "Extra Crispy", List.of(10L, 11L)
        );

        // Updated constructor or builder to include PaymentMethod so validation passes
        validOrderRequest = new OrderRequestDTO(1L, PaymentMethod.CASH, List.of(itemRequest));

        sampleOrderResponse = new OrderResponseDTO();
        sampleOrderResponse.setOrderId(100L);
        sampleOrderResponse.setStatus("PENDING");
        sampleOrderResponse.setTotalPrice(new BigDecimal("45.50"));
    }

    // Checkout order tests (/api/orders/checkout)
    @Nested
    @DisplayName("POST /api/orders/checkout - Checkout Order")
    class CheckoutOrderTests {

        // Verifies successful checkout returns HTTP 201 Created
        @Test
        @DisplayName("Should return 201 Created and checkout order successfully")
        @WithMockUser(username = "student@eduvos.com", roles = {"STUDENT"})
        void checkout_Success () throws Exception {

            // Config mocked service to return the sample response when checkout is called
            when(orderService.checkout(any(OrderRequestDTO.class))).thenReturn(sampleOrderResponse);

            // Simulate an HTTP Post request to checkout endpoint
            mockMvc.perform(post("/api/orders/checkout")
                            .with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(validOrderRequest)))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$.orderId").value(100))
                    .andExpect(jsonPath("$.status").value("PENDING"))
                    .andExpect(jsonPath("$.totalPrice").value(45.50));

            verify(orderService).checkout(any(OrderRequestDTO.class)); // Ensure controller called checkout
        }
    }

    // Groups tests for endpoints that get orders and order histories
    @Nested
    @DisplayName("GET /api/orders - Fetch All & Filter Orders")
    class GetOrderTests {

        // Verifies staff can get list of all orders
        @Test
        @DisplayName("Should return 200 OK with list of all orders")
        @WithMockUser(username = "staff@eduvos.com", roles = {"STAFF"})
        void getAllOrders_Success () throws Exception {


            when(orderService.getAllOrders()).thenReturn(List.of(sampleOrderResponse));

            mockMvc.perform(get("/api/orders")) // Get req to get all orders
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.length()").value(1))
                    .andExpect(jsonPath("$[0].orderId").value(100));

            verify(orderService).getAllOrders(); // Verify correct method call
        }

        // Verify existing order can be fetched by ID
        @Test
        @DisplayName("Should return 200 OK and order details when valid numeric ID is passed")
        @WithMockUser(username = "student@eduvos.com")
        void getOrderById_Success () throws Exception {

            when(orderService.getOrderById(100L)).thenReturn(sampleOrderResponse);

            mockMvc.perform(get("/api/orders/{id}", 100L))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.orderId").value(100))
                    .andExpect(jsonPath("$.status").value("PENDING"));

            verify(orderService).getOrderById(100L);
        }

        // Ensures requesting non-existent order returns 404
        @Test
        @DisplayName("Should return 404 Not Found when order ID does not exist")
        @WithMockUser(username = "student@eduvos.com")
        void getOrderById_NotFound () throws Exception {

            when(orderService.getOrderById(999L))
                    .thenThrow(new ResourceNotFoundException("Order not found with ID: 999"));

            mockMvc.perform(get("/api/orders/{id}", 999L))
                    .andExpect(status().isNotFound());
        }

        // Ensure users order history can be retrieved
        @Test
        @DisplayName("Should return 200 OK for user's order history")
        @WithMockUser(username = "student@eduvos.com")
        void getOrdersByUserId_Success () throws Exception {

            when(orderService.getOrdersByUserId(1L)).thenReturn(List.of(sampleOrderResponse));

            mockMvc.perform(get("/api/orders/user/{userId}", 1L))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.length()").value(1))
                    .andExpect(jsonPath("$[0].orderId").value(100));

            verify(orderService).getOrdersByUserId(1L);
        }

        // Ensures active-orders endpoint returns current list of orders
        @Test
        @DisplayName("Should return 200 OK for active cafeteria orders board")
        @WithMockUser(username = "staff@eduvos.com")
        void getActiveOrders_Success () throws Exception {

            when(orderService.getActiveOrders()).thenReturn(List.of(sampleOrderResponse));

            mockMvc.perform(get("/api/orders/active"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.length()").value(1));

            verify(orderService).getActiveOrders();
        }

        // Ensures users can get their onw orders
        @Test
        @DisplayName("Should return 200 OK for user's current active orders")
        @WithMockUser(username = "student@eduvos.com")
        void getActiveOrdersByUserId_Success () throws Exception {

            when(orderService.getActiveOrdersByUserId(1L)).thenReturn(List.of(sampleOrderResponse));

            mockMvc.perform(get("/api/orders/user/{userId}/current", 1L))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.length()").value(1));

            verify(orderService).getActiveOrdersByUserId(1L);
        }
    }

    // Groups tests for PUT /api/orders/{id}/status
    @Nested
    @DisplayName("PUT /api/orders/{id}/status - Update Order Status")
    class UpdateOrderStatusTests {

        // Verify staffs ability to update order status
        @Test
        @DisplayName("Should return 200 OK when staff updates order status using OrderStatusUpdateRequestDTO")
        @WithMockUser(username = "staff@eduvos.com", roles = {"STAFF"})
        void updateOrderStatus_Success () throws Exception {

            OrderStatusUpdateRequestDTO statusDTO = new OrderStatusUpdateRequestDTO("IN_PREPARATION");
            sampleOrderResponse.setStatus("IN_PREPARATION");

            when(orderService.updateOrderStatus(eq(100L), eq("IN_PREPARATION"), eq(null)))
                    .thenReturn(sampleOrderResponse);

            mockMvc.perform(put("/api/orders/{id}/status", 100L).with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(statusDTO)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.status").value("IN_PREPARATION"));

            verify(orderService).updateOrderStatus(100L, "IN_PREPARATION", null);
        }

        // Verify staff can mark order as collected while supplying last 4 digits of order
        @Test
        @DisplayName("Should return 200 OK when staff provides 4-character pickup suffix for Collected status")
        @WithMockUser(username = "staff@eduvos.com", roles = {"STAFF"})
        void updateOrderStatus_Collected_WithSuffix_Success () throws Exception {

            OrderStatusUpdateRequestDTO statusDTO = new OrderStatusUpdateRequestDTO("COLLECTED", "1234");
            sampleOrderResponse.setStatus("COLLECTED");

            when(orderService.updateOrderStatus(eq(100L), eq("COLLECTED"), eq("1234")))
                    .thenReturn(sampleOrderResponse);

            mockMvc.perform(put("/api/orders/{id}/status", 100L).with(csrf())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(statusDTO)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.status").value("COLLECTED"));

            verify(orderService).updateOrderStatus(100L, "COLLECTED", "1234");
        }
    }
}