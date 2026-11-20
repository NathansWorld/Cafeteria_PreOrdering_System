package org.example.cafeteria_ordering_backend.controller;

import io.github.bucket4j.Bucket;
import org.example.cafeteria_ordering_backend.config.SecurityConfig;
import org.example.cafeteria_ordering_backend.dto.requests.OrderStatusUpdateRequestDTO;
import org.example.cafeteria_ordering_backend.security.CustomUserDetailsService;
import org.example.cafeteria_ordering_backend.security.JwtUtils;
import org.example.cafeteria_ordering_backend.security.TokenBlacklistService;
import org.example.cafeteria_ordering_backend.service.interfaces.OrderService;
import org.example.cafeteria_ordering_backend.service.interfaces.RateLimitService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import tools.jackson.databind.ObjectMapper;

import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// Loads order controller and its MVC dependencies for controller testing
@WebMvcTest(OrderController.class)
@Import(SecurityConfig.class)
class OrderSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private OrderService orderService;

    @MockitoBean
    private JwtUtils jwtUtils;

    @MockitoBean
    private CustomUserDetailsService customUserDetailsService;

    @MockitoBean
    private TokenBlacklistService tokenBlacklistService;

    @MockitoBean
    private RateLimitService rateLimitService;

    @BeforeEach
    void setUp () {
        // Create a mock bucket that always allows requests
        Bucket mockBucket = mock(Bucket.class);
        when(mockBucket.tryConsume(anyLong())).thenReturn(true);

        // Whenever any client key requests a bucket, return our mock bucket
        when(rateLimitService.resolveBucket(anyString())).thenReturn(mockBucket);
    }

    // Groups tests verifying access authentication is required to protected order endpoints.
    @Nested
    @DisplayName("Authentication Requirements")
    class UnauthenticatedAccessTests {

        @Test
        @DisplayName("Should return 401 Unauthorized when unauthenticated user attempts checkout")
        void checkout_Unauthenticated () throws Exception {

            mockMvc.perform(post("/api/orders/checkout")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{}"))
                    .andExpect(status().isUnauthorized());

            verifyNoInteractions(orderService);
        }

        @Test
        @DisplayName("Should return 401 Unauthorized when unauthenticated user accesses order history")
        void getOrders_Unauthenticated () throws Exception {

            mockMvc.perform(get("/api/orders"))
                    .andExpect(status().isUnauthorized());

            verifyNoInteractions(orderService);
        }
    }

    // Groups tests verifying role-based authorization
    @Nested
    @DisplayName("Role-Based Authorization (403 Forbidden)")
    class RoleBasedAccessTests {

        @Test
        @DisplayName("Should return 403 Forbidden when a customer attempts to update order status")
        void updateStatus_ForbiddenForCustomer () throws Exception {

            OrderStatusUpdateRequestDTO dto = new OrderStatusUpdateRequestDTO("COMPLETED");

            mockMvc.perform(put("/api/orders/100/status")
                            .with(user("customer@campus.edu").roles("CUSTOMER"))
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(dto)))
                    .andExpect(status().isForbidden());

            verifyNoInteractions(orderService);
        }

        @Test
        @DisplayName("Should return 403 Forbidden when a student attempts to update order status")
        void updateStatus_ForbiddenForStudent () throws Exception {

            OrderStatusUpdateRequestDTO dto = new OrderStatusUpdateRequestDTO("COMPLETED");

            mockMvc.perform(put("/api/orders/100/status")
                            .with(user("student@eduvos.com").roles("STUDENT"))
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(dto)))
                    .andExpect(status().isForbidden());

            verifyNoInteractions(orderService);
        }

        @Test
        @DisplayName("Should allow ADMIN to update order status")
        void updateStatus_AllowForAdmin () throws Exception {

            OrderStatusUpdateRequestDTO dto = new OrderStatusUpdateRequestDTO("COMPLETED");

            mockMvc.perform(put("/api/orders/100/status")
                            .with(user("admin@campus.edu").roles("ADMIN"))
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(dto)))
                    .andExpect(status().isOk());

            verify(orderService).updateOrderStatus(eq(100L), eq("COMPLETED"), eq(null));
        }

        @Test
        @DisplayName("Should allow STAFF role to update order status")
        void updateStatus_AllowedForStaff () throws Exception {

            OrderStatusUpdateRequestDTO dto = new OrderStatusUpdateRequestDTO("COMPLETED");

            mockMvc.perform(put("/api/orders/100/status")
                            .with(user("staff@eduvos.com").roles("STAFF"))
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(dto)))
                    .andExpect(status().isOk());

            verify(orderService).updateOrderStatus(eq(100L), eq("COMPLETED"), eq(null));
        }
    }
}