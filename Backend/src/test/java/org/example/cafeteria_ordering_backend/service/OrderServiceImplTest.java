package org.example.cafeteria_ordering_backend.service;

import org.example.cafeteria_ordering_backend.component.OperatingHoursValidator;
import org.example.cafeteria_ordering_backend.component.OrderItemCalculator;
import org.example.cafeteria_ordering_backend.component.OrderNumberGenerator;
import org.example.cafeteria_ordering_backend.component.OrderSecurityEvaluator;
import org.example.cafeteria_ordering_backend.dto.requests.OrderRequestDTO;
import org.example.cafeteria_ordering_backend.dto.response.OrderResponseDTO;
import org.example.cafeteria_ordering_backend.entity.*;
import org.example.cafeteria_ordering_backend.event.WebSocketMessageEvent;
import org.example.cafeteria_ordering_backend.exception.ResourceNotFoundException;
import org.example.cafeteria_ordering_backend.exception.ResourceUnavailableException;
import org.example.cafeteria_ordering_backend.mapper.OrderMapper;
import org.example.cafeteria_ordering_backend.repository.*;
import org.example.cafeteria_ordering_backend.service.implementation.OrderServiceImpl;
import org.example.cafeteria_ordering_backend.service.interfaces.NotificationService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.security.core.context.SecurityContextHolder;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class OrderServiceImplTest {

    @Mock private OrderRepository orderRepository;
    @Mock private OrderStatusRepository orderStatusRepository;
    @Mock private UserRepository userRepository;
    @Mock private OrderStatusHistoryRepository orderStatusHistoryRepository;
    @Mock private MenuItemRepository menuItemRepository;
    @Mock private ApplicationEventPublisher eventPublisher;
    @Mock private OperatingHoursValidator operatingHoursValidator;
    @Mock private OrderSecurityEvaluator orderSecurityEvaluator;
    @Mock private OrderNumberGenerator orderNumberGenerator;
    @Mock private OrderItemCalculator orderItemCalculator;
    @Mock private OrderMapper orderMapper;
    @Mock private NotificationService notificationService;

    @InjectMocks
    private OrderServiceImpl orderService;

    private User mockUser;
    private OrderStatus submittedStatus;
    private OrderStatus cancelledStatus;
    private OrderStatus completedStatus;
    private Order mockOrder;

    @BeforeEach
    void setUp () {

        mockUser = new User();
        mockUser.setUserId(1L);
        mockUser.setEmail("test@campus.edu");

        submittedStatus = new OrderStatus();
        submittedStatus.setStatusName("Submitted");

        cancelledStatus = new OrderStatus();
        cancelledStatus.setStatusName("Cancelled");

        completedStatus = new OrderStatus();
        completedStatus.setStatusName("Completed");

        mockOrder = new Order();
        mockOrder.setOrderId(50L);
        mockOrder.setUser(mockUser);
        mockOrder.setOrderStatus(submittedStatus);
        mockOrder.setCustomerOrderNumber("ORD-20260330-ABCD");
        mockOrder.setTotalPrice(new BigDecimal("30.00"));
        mockOrder.setCreatedAt(LocalDateTime.now());
        mockOrder.setOrderItems(new ArrayList<>());

        lenient().when(orderMapper.toResponseDTO(any(Order.class))).thenAnswer(invocation -> {
            Order order = invocation.getArgument(0);
            if (order == null) return null;

            OrderResponseDTO dto = new OrderResponseDTO();
            dto.setOrderId(order.getOrderId());
            dto.setCustomerOrderNumber(order.getCustomerOrderNumber());
            dto.setStatus(order.getOrderStatus() != null ? order.getOrderStatus().getStatusName() : null);
            dto.setTotalPrice(order.getTotalPrice());

            if (order.getOrderItems() != null) {
                List<OrderResponseDTO.OrderItemResponse> itemDTOs = order.getOrderItems().stream().map(item -> {
                    OrderResponseDTO.OrderItemResponse itemDTO = new OrderResponseDTO.OrderItemResponse();
                    itemDTO.setMenuItemName(item.getMenuItemNameAtPurchase());
                    itemDTO.setQuantity(item.getQuantity());
                    itemDTO.setPriceAtPurchase(item.getPriceAtPurchase());

                    if (item.getOrderItemModifiers() != null) {
                        itemDTO.setSelectedModifiers(
                                item.getOrderItemModifiers().stream()
                                        .map(OrderItemModifier::getModifierNameAtPurchase)
                                        .toList()
                        );
                    } else {
                        itemDTO.setSelectedModifiers(List.of());
                    }
                    return itemDTO;
                }).toList();
                dto.setItems(itemDTOs);
            } else {
                dto.setItems(List.of());
            }

            return dto;
        });
    }

    @AfterEach
    void clearSecurityContext () {SecurityContextHolder.clearContext();}

    private User createStaffUser () {

        User user = new User();
        Role role = new Role();
        role.setRoleName("STAFF");
        user.setRole(role);
        return user;
    }

    private User createAdminUser () {

        User user = new User();
        Role role = new Role();
        role.setRoleName("ADMIN");
        user.setRole(role);
        return user;
    }

    private OrderItem createMockOrderItem () {

        MenuItems mockMenuItem = new MenuItems();
        mockMenuItem.setMenuItemId(10L);

        OrderItemModifier mockOrderItemModifier = new OrderItemModifier();
        mockOrderItemModifier.setModifierNameAtPurchase("Extra Shot");
        mockOrderItemModifier.setPriceAtPurchase(new BigDecimal("5.00"));

        OrderItem mockOrderItem = new OrderItem();
        mockOrderItem.setMenuItem(mockMenuItem);
        mockOrderItem.setMenuItemNameAtPurchase("Espresso");
        mockOrderItem.setQuantity(2);
        mockOrderItem.setPriceAtPurchase(new BigDecimal("25.00"));
        mockOrderItem.setSpecialInstructions("Extra hot");
        mockOrderItem.setOrderItemModifiers(List.of(mockOrderItemModifier));

        return mockOrderItem;
    }

    private void verifyStandardOrderEventsPublished () {

        ArgumentCaptor<WebSocketMessageEvent<?>> eventCaptor = ArgumentCaptor.forClass(WebSocketMessageEvent.class);
        verify(eventPublisher, times(2)).publishEvent(eventCaptor.capture());

        List<WebSocketMessageEvent<?>> events = eventCaptor.getAllValues();
        assertThat(events).anyMatch(e -> e.getDestination().equals("/topic/orders/1"));
        assertThat(events).anyMatch(e -> e.getDestination().equals("/topic/orders/active"));
    }

    @Nested
    @DisplayName("Checkout Tests")
    class CheckoutTests {

        private OrderRequestDTO createValidRequestDTO () {

            OrderRequestDTO request = new OrderRequestDTO();
            request.setUserId(1L);

            OrderRequestDTO.OrderItemRequest itemRequest = new OrderRequestDTO.OrderItemRequest();
            itemRequest.setMenuItemId(10L);
            itemRequest.setQuantity(2);
            itemRequest.setSpecialInstructions("Extra hot");
            itemRequest.setModifierIds(List.of(100L));
            request.setItems(List.of(itemRequest));
            return request;
        }

        @Test
        @DisplayName("Should successfully process checkout, deduct stock, and publish WebSocket event")
        void checkout_Success () {

            when(orderSecurityEvaluator.getCurrentUser()).thenReturn(mockUser);
            when(orderNumberGenerator.generate()).thenReturn("ORD-20260330-ABCD");
            when(orderStatusRepository.findByStatusName("Submitted")).thenReturn(Optional.of(submittedStatus));

            OrderRequestDTO request = createValidRequestDTO();
            OrderItem mockOrderItem = createMockOrderItem();

            OrderItemCalculator.CalculationResult mockCalculationResult =
                    new OrderItemCalculator.CalculationResult(List.of(mockOrderItem), new BigDecimal("60.00"));

            when(orderItemCalculator.calculateAndBuildItems(eq(request.getItems()), any(Order.class)))
                    .thenAnswer(invocation -> {
                        Order order = invocation.getArgument(1);
                        order.setTotalPrice(mockCalculationResult.totalPrice());
                        order.setOrderItems(mockCalculationResult.orderItems());
                        return mockCalculationResult;
                    });

            when(menuItemRepository.deductStockAndAutoDisable(10L, 2)).thenReturn(1);
            when(orderRepository.save(any(Order.class)))
                    .thenAnswer(invocation -> {
                        Order saved = invocation.getArgument(0);
                        if (saved.getOrderId() == null) {
                            saved.setOrderId(50L);
                        }
                        return saved;
                    });

            OrderResponseDTO response = orderService.checkout(request);

            assertThat(response).isNotNull();
            assertThat(response.getOrderId()).isEqualTo(50L);
            assertThat(response.getCustomerOrderNumber()).isEqualTo("ORD-20260330-ABCD");
            assertThat(response.getStatus()).isEqualTo("Submitted");
            assertThat(response.getTotalPrice()).isEqualByComparingTo("60.00");

            verify(operatingHoursValidator).validateOpenForOrders();
            verify(orderItemCalculator).calculateAndBuildItems(eq(request.getItems()), any(Order.class));
            verify(menuItemRepository).deductStockAndAutoDisable(10L, 2);
            verify(orderRepository).save(any(Order.class));

            ArgumentCaptor<WebSocketMessageEvent<?>> eventCaptor = ArgumentCaptor.forClass(WebSocketMessageEvent.class);
            verify(eventPublisher, times(1)).publishEvent(eventCaptor.capture());
            assertThat(eventCaptor.getValue().getDestination()).isEqualTo("/topic/orders/active");
            assertThat(eventCaptor.getValue().getAction()).isEqualTo("CREATE");
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException when user does not exist")
        void checkout_UserNotFound_ThrowsException () {
            when(orderSecurityEvaluator.getCurrentUser())
                    .thenThrow(new ResourceNotFoundException("Current user not found."));

            OrderRequestDTO request = createValidRequestDTO();

            assertThatThrownBy(() -> orderService.checkout(request))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Current user not found");

            verify(orderItemCalculator, never()).calculateAndBuildItems(any(), any());
            verify(menuItemRepository, never()).deductStockAndAutoDisable(anyLong(), anyInt());
            verify(orderRepository, never()).save(any(Order.class));
            verifyNoInteractions(eventPublisher);
        }
    }

    @Nested
    @DisplayName("Update Order Status Tests")
    class UpdateOrderStatusTests {

        @Test
        @DisplayName("Should throw ResourceUnavailableException when staff provides invalid or missing pickup code for Collected status")
        void updateOrderStatus_Collected_InvalidSuffix_ThrowsException () {

            when(orderRepository.findByIdWithItems(50L)).thenReturn(Optional.of(mockOrder));

            assertThatThrownBy(() -> orderService.updateOrderStatus(50L, "Collected", "WRONG"))
                    .isInstanceOf(ResourceUnavailableException.class)
                    .hasMessageContaining("Invalid pickup code");

            assertThatThrownBy(() -> orderService.updateOrderStatus(50L, "Collected", null))
                    .isInstanceOf(ResourceUnavailableException.class)
                    .hasMessageContaining("Invalid pickup code");

            verify(orderRepository, never()).save(any());
            verifyNoInteractions(eventPublisher);
        }

        @Test
        @DisplayName("Should successfully update status to Collected when correct 4-character pickup code is provided")
        void updateOrderStatus_Collected_Success () {

            OrderStatus readyStatus = new OrderStatus();
            readyStatus.setStatusName("Ready");
            mockOrder.setOrderStatus(readyStatus);

            OrderStatus collectedStatus = new OrderStatus();
            collectedStatus.setStatusName("Collected");

            when(orderRepository.findByIdWithItems(50L)).thenReturn(Optional.of(mockOrder));
            when(orderStatusRepository.findByStatusName("Collected")).thenReturn(Optional.of(collectedStatus));
            when(orderSecurityEvaluator.getCurrentUser()).thenReturn(createStaffUser());
            when(orderRepository.save(any(Order.class))).thenAnswer(inv -> inv.getArgument(0));

            OrderResponseDTO response = orderService.updateOrderStatus(50L, "Collected", "abcd");

            assertThat(response).isNotNull();
            assertThat(response.getStatus()).isEqualTo("Collected");
            verify(orderRepository, times(1)).save(mockOrder);
            verify(eventPublisher, times(2)).publishEvent(any(WebSocketMessageEvent.class));
        }

        @Test
        @DisplayName("Should throw ResourceUnavailableException when staff attempts an invalid status jump")
        void updateOrderStatus_InvalidJump_ThrowsException () {

            when(orderRepository.findByIdWithItems(50L)).thenReturn(Optional.of(mockOrder));

            OrderStatus readyStatus = new OrderStatus();
            readyStatus.setStatusName("Ready");
            when(orderStatusRepository.findByStatusName("Ready")).thenReturn(Optional.of(readyStatus));
            when(orderSecurityEvaluator.getCurrentUser()).thenReturn(createStaffUser());

            assertThatThrownBy(() -> orderService.updateOrderStatus(50L, "Ready"))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Invalid status transition");

            verify(orderRepository, never()).save(any());
        }

        @Test
        @DisplayName("Should block staff from modifying an order in a terminal 'Collected' state")
        void updateOrderStatus_TerminalStateLocked_ThrowsException () {

            OrderStatus collectedStatus = new OrderStatus();
            collectedStatus.setStatusName("Collected");
            mockOrder.setOrderStatus(collectedStatus);

            when(orderRepository.findByIdWithItems(50L)).thenReturn(Optional.of(mockOrder));

            OrderStatus preparingStatus = new OrderStatus();
            preparingStatus.setStatusName("Preparing");
            when(orderStatusRepository.findByStatusName("Preparing")).thenReturn(Optional.of(preparingStatus));
            when(orderSecurityEvaluator.getCurrentUser()).thenReturn(createStaffUser());

            assertThatThrownBy(() -> orderService.updateOrderStatus(50L, "Preparing"))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Invalid status transition");

            verify(orderRepository, never()).save(any());
        }

        @Test
        @DisplayName("Should allow Admin to bypass terminal lock and override order status")
        void updateOrderStatus_AdminOverride_Success () {

            OrderStatus collectedStatus = new OrderStatus();
            collectedStatus.setStatusName("Collected");
            mockOrder.setOrderStatus(collectedStatus);

            OrderStatus preparingStatus = new OrderStatus();
            preparingStatus.setStatusName("Preparing");

            when(orderRepository.findByIdWithItems(50L)).thenReturn(Optional.of(mockOrder));
            when(orderSecurityEvaluator.getCurrentUser()).thenReturn(createAdminUser());
            when(orderStatusRepository.findByStatusName("Preparing")).thenReturn(Optional.of(preparingStatus));
            when(orderRepository.save(any(Order.class))).thenAnswer(inv -> inv.getArgument(0));

            OrderResponseDTO response = orderService.updateOrderStatus(50L, "Preparing");

            assertThat(response).isNotNull();
            assertThat(response.getStatus()).isEqualTo("Preparing");
            verify(orderRepository, times(1)).save(mockOrder);
        }

        @Test
        @DisplayName("Should successfully update status, create history log, and publish WebSocket events")
        void updateOrderStatus_Success () {

            Long orderId = 50L;
            OrderStatus acceptedStatus = new OrderStatus();
            acceptedStatus.setStatusName("Accepted");

            when(orderRepository.findByIdWithItems(orderId)).thenReturn(Optional.of(mockOrder));
            when(orderSecurityEvaluator.getCurrentUser()).thenReturn(createStaffUser());
            when(orderStatusRepository.findByStatusName("Accepted")).thenReturn(Optional.of(acceptedStatus));
            when(orderRepository.save(any(Order.class))).thenAnswer(inv -> inv.getArgument(0));

            OrderResponseDTO response = orderService.updateOrderStatus(orderId, "Accepted");

            assertThat(response).isNotNull();
            assertThat(response.getStatus()).isEqualTo("Accepted");

            verify(orderRepository, times(1)).save(mockOrder);
            verify(orderStatusHistoryRepository, times(1)).save(any(OrderStatusHistory.class));
            verifyStandardOrderEventsPublished();
        }

        @Test
        @DisplayName("Should throw ResourceNotFoundException when requested status name does not exist in DB")
        void updateOrderStatus_InvalidStatus_ThrowsException () {

            Long orderId = 50L;

            when(orderRepository.findByIdWithItems(orderId)).thenReturn(Optional.of(mockOrder));
            when(orderStatusRepository.findByStatusName("UnknownStatus"))
                    .thenReturn(Optional.empty());

            assertThatThrownBy(() -> orderService.updateOrderStatus(orderId, "UnknownStatus"))
                    .isInstanceOf(ResourceNotFoundException.class)
                    .hasMessageContaining("Invalid status name: 'UnknownStatus'");

            verify(orderStatusHistoryRepository, never()).save(any());
        }
    }

    @Nested
    @DisplayName("Cancel Order Tests")
    class CancelOrderTests {

        @Test
        @DisplayName("Should allow cancellation when order status is Submitted and publish events")
        void cancelOrder_SubmittedStatus_Success () {

            Long orderId = 50L;
            mockOrder.setOrderStatus(submittedStatus);

            when(orderRepository.findByIdWithItems(orderId)).thenReturn(Optional.of(mockOrder));
            when(orderSecurityEvaluator.getCurrentUser()).thenReturn(mockUser);
            when(orderStatusRepository.findByStatusName("Cancelled")).thenReturn(Optional.of(cancelledStatus));
            when(orderRepository.save(any(Order.class))).thenAnswer(inv -> inv.getArgument(0));

            orderService.cancelOrder(orderId);

            assertThat(mockOrder.getOrderStatus().getStatusName()).isEqualTo("Cancelled");
            verify(orderRepository, times(1)).save(mockOrder);
            verify(orderStatusHistoryRepository, times(1)).save(any(OrderStatusHistory.class));
            verifyStandardOrderEventsPublished();
        }

        @Test
        @DisplayName("Should allow cancellation when order status is Accepted and publish events")
        void cancelOrder_AcceptedStatus_Success () {

            Long orderId = 50L;
            OrderStatus acceptedStatus = new OrderStatus();
            acceptedStatus.setStatusName("Accepted");
            mockOrder.setOrderStatus(acceptedStatus);

            when(orderRepository.findByIdWithItems(orderId)).thenReturn(Optional.of(mockOrder));
            when(orderSecurityEvaluator.getCurrentUser()).thenReturn(mockUser);
            when(orderStatusRepository.findByStatusName("Cancelled")).thenReturn(Optional.of(cancelledStatus));
            when(orderRepository.save(any(Order.class))).thenAnswer(inv -> inv.getArgument(0));

            orderService.cancelOrder(orderId);

            assertThat(mockOrder.getOrderStatus().getStatusName()).isEqualTo("Cancelled");
            verify(orderRepository, times(1)).save(mockOrder);
            verify(orderStatusHistoryRepository, times(1)).save(any(OrderStatusHistory.class));
            verifyStandardOrderEventsPublished();
        }

        @Test
        @DisplayName("Should throw ResourceUnavailableException when order is beyond initial phases")
        void cancelOrder_CompletedStatus_ThrowsException () {

            Long orderId = 50L;
            mockOrder.setOrderStatus(completedStatus);

            when(orderRepository.findByIdWithItems(orderId)).thenReturn(Optional.of(mockOrder));
            when(orderSecurityEvaluator.getCurrentUser()).thenReturn(mockUser);

            assertThatThrownBy(() -> orderService.cancelOrder(orderId))
                    .isInstanceOf(ResourceUnavailableException.class)
                    .hasMessageContaining("Cannot cancel order: This order is already 'Completed'");

            verify(orderRepository, never()).save(any());
            verify(orderStatusHistoryRepository, never()).save(any());
            verifyNoInteractions(eventPublisher);
        }
    }

    @Nested
    @DisplayName("Query & Fetch Order Tests")
    class QueryOrderTests {

        @Test
        @DisplayName("Should fetch active orders for user excluding final statuses")
        void getActiveOrdersByUserId_Success () {

            Long userId = 1L;

            when(orderRepository.findByUserUserIdAndOrderStatusStatusNameNotInOrderByCreatedAtAsc(
                    eq(userId),
                    eq(List.of("Cancelled", "Collected"))
            )).thenReturn(List.of(mockOrder));

            List<OrderResponseDTO> results = orderService.getActiveOrdersByUserId(userId);

            assertThat(results).hasSize(1);
            assertThat(results.getFirst().getOrderId()).isEqualTo(50L);
        }

        @Test
        @DisplayName("Should prevent a customer from querying another user's order history")
        void getOrdersByUserId_UserNotAllowed_ThrowsException () {

            Long invalidUserId = 99L;

            doThrow(new ResourceUnavailableException("Access denied: You are not authorized to access this resource."))
                    .when(orderSecurityEvaluator).validateUserAccess(invalidUserId);

            assertThatThrownBy(() -> orderService.getOrdersByUserId(invalidUserId))
                    .isInstanceOf(ResourceUnavailableException.class)
                    .hasMessageContaining("Access denied");
        }

        @Test
        @DisplayName("Should successfully fetch all orders when user is staff or admin")
        void getAllOrders_StaffOrAdmin_Success () {

            when(orderSecurityEvaluator.isStaffOrAdmin()).thenReturn(true);
            when(orderRepository.findAll()).thenReturn(List.of(mockOrder));

            List<OrderResponseDTO> results = orderService.getAllOrders();

            assertThat(results).hasSize(1);
            assertThat(results.getFirst().getOrderId()).isEqualTo(50L);
            verify(orderSecurityEvaluator, times(1)).isStaffOrAdmin();
        }

        @Test
        @DisplayName("Should throw ResourceUnavailableException when non-staff attempts to fetch all orders")
        void getAllOrders_Unauthorized_ThrowsException () {

            when(orderSecurityEvaluator.isStaffOrAdmin()).thenReturn(false);

            assertThatThrownBy(() -> orderService.getAllOrders())
                    .isInstanceOf(ResourceUnavailableException.class)
                    .hasMessageContaining("Only staff or admin");

            verify(orderRepository, never()).findAll();
        }

        @Test
        @DisplayName("Should successfully fetch active orders when user is staff or admin")
        void getActiveOrders_StaffOrAdmin_Success () {

            when(orderSecurityEvaluator.isStaffOrAdmin()).thenReturn(true);
            when(orderRepository.findActiveOrdersWithItems(anyList())).thenReturn(List.of(mockOrder));

            List<OrderResponseDTO> results = orderService.getActiveOrders();

            assertThat(results).hasSize(1);
            assertThat(results.get(0).getOrderId()).isEqualTo(50L);
            verify(orderSecurityEvaluator, times(1)).isStaffOrAdmin();
        }

        @Test
        @DisplayName("Should throw ResourceUnavailableException when non-staff attempts to fetch active orders")
        void getActiveOrders_Unauthorized_ThrowsException () {

            when(orderSecurityEvaluator.isStaffOrAdmin()).thenReturn(false);

            assertThatThrownBy(() -> orderService.getActiveOrders())
                    .isInstanceOf(ResourceUnavailableException.class)
                    .hasMessageContaining("Only staff or admin");

            verify(orderRepository, never()).findByOrderStatusStatusNameNotInOrderByOrderIdAsc(any());
        }
    }

    @Nested
    @DisplayName("Expire Overdue Orders Tests")
    class ExpireOverdueOrdersTests {

        @Test
        @DisplayName("Should expire overdue orders and broadcast status updates")
        void expireOverdueOrders_Success () {

            when(orderRepository.findOverdueOrders(eq(List.of("Submitted")),any(LocalDateTime.class)))
                    .thenReturn(List.of(mockOrder));

            when(orderStatusRepository.findByStatusName("Cancelled")).thenReturn(Optional.of(cancelledStatus));
            when(orderRepository.save(any(Order.class))).thenAnswer(inv -> inv.getArgument(0));

            orderService.expireOverdueOrders();

            assertThat(mockOrder.getOrderStatus().getStatusName()).isEqualTo("Cancelled");
            verify(orderRepository, times(1)).save(mockOrder);
            verify(orderStatusHistoryRepository, times(1)).save(any(OrderStatusHistory.class));
            verifyStandardOrderEventsPublished();
        }

        @Test
        @DisplayName("Should do nothing when no overdue orders are found")
        void expireOverdueOrders_NoOverdueOrders_DoesNothing () {

            when(orderRepository.findOverdueOrders(eq(List.of("Submitted")), any(LocalDateTime.class)))
                    .thenReturn(List.of());

            orderService.expireOverdueOrders();

            verify(orderRepository, never()).save(any());
            verifyNoInteractions(eventPublisher);
        }
    }
}