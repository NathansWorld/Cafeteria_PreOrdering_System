package org.example.cafeteria_ordering_backend.service;

import org.example.cafeteria_ordering_backend.component.OperatingHoursValidator;
import org.example.cafeteria_ordering_backend.component.OrderItemCalculator;
import org.example.cafeteria_ordering_backend.component.OrderNumberGenerator;
import org.example.cafeteria_ordering_backend.component.OrderSecurityEvaluator;
import org.example.cafeteria_ordering_backend.dto.requests.OrderRequestDTO;
import org.example.cafeteria_ordering_backend.entity.Order;
import org.example.cafeteria_ordering_backend.entity.OrderStatus;
import org.example.cafeteria_ordering_backend.entity.PaymentMethod;
import org.example.cafeteria_ordering_backend.entity.User;
import org.example.cafeteria_ordering_backend.mapper.OrderMapper;
import org.example.cafeteria_ordering_backend.repository.MenuItemRepository;
import org.example.cafeteria_ordering_backend.repository.OrderRepository;
import org.example.cafeteria_ordering_backend.repository.OrderStatusRepository;
import org.example.cafeteria_ordering_backend.service.implementation.PayFastServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PayFastServiceTest {

    @Mock private OrderRepository orderRepository;
    @Mock private OrderStatusRepository orderStatusRepository;
    @Mock private MenuItemRepository menuItemRepository;
    @Mock private OrderNumberGenerator orderNumberGenerator;
    @Mock private OrderItemCalculator orderItemCalculator;
    @Mock private OperatingHoursValidator operatingHoursValidator;
    @Mock private OrderSecurityEvaluator orderSecurityEvaluator;
    @Mock private ApplicationEventPublisher eventPublisher;
    @Mock private OrderMapper orderMapper;

    @InjectMocks
    private PayFastServiceImpl payFastService;

    @BeforeEach
    void setUp() {
        // Inject values for @Value fields since Spring context isn't fully loaded here
        ReflectionTestUtils.setField(payFastService, "merchantId", "10000100");
        ReflectionTestUtils.setField(payFastService, "merchantKey", "46f0cd6975815");
        ReflectionTestUtils.setField(payFastService, "passphrase", "secret");
        ReflectionTestUtils.setField(payFastService, "processUrl", "https://sandbox.payfast.co.za/eng/process");
        ReflectionTestUtils.setField(payFastService, "returnUrl", "http://localhost:8080/return");
        ReflectionTestUtils.setField(payFastService, "cancelUrl", "http://localhost:8080/cancel");
        ReflectionTestUtils.setField(payFastService, "itnUrl", "http://localhost:8080/itn");
    }

    @Test
    void testCreatePaymentPayload() {
        OrderRequestDTO requestDTO = new OrderRequestDTO();
        requestDTO.setPaymentMethod(PaymentMethod.PAYFAST);
        requestDTO.setItems(new ArrayList<>());

        User mockUser = new User();
        OrderStatus mockStatus = new OrderStatus();
        Order savedOrder = new Order();
        savedOrder.setOrderId(1L);
        savedOrder.setCustomerOrderNumber("ORD-11-03-TEST");
        savedOrder.setTotalPrice(BigDecimal.valueOf(50.00));

        when(orderSecurityEvaluator.getCurrentUser()).thenReturn(mockUser);
        when(orderStatusRepository.findByStatusName("Submitted")).thenReturn(Optional.of(mockStatus));
        when(orderNumberGenerator.generate()).thenReturn("ORD-11-03-TEST");
        when(orderItemCalculator.calculateAndBuildItems(any(), any()))
                .thenReturn(new OrderItemCalculator.CalculationResult(new ArrayList<>(), BigDecimal.valueOf(50.00)));
        when(orderRepository.save(any(Order.class))).thenReturn(savedOrder);

        Map<String, String> payload = payFastService.createPaymentPayload(requestDTO, "test@campus.edu");

        assertNotNull(payload);
        assertEquals("10000100", payload.get("merchant_id"));
        assertEquals("50.00", payload.get("amount"));
        assertEquals("1", payload.get("m_payment_id"));
        assertNotNull(payload.get("signature"));
    }

    @Test
    void testProcessPayFastITN_Complete() {
        Map<String, String> itnParams = new HashMap<>();
        itnParams.put("m_payment_id", "1");
        itnParams.put("payment_status", "COMPLETE");
        itnParams.put("pf_payment_id", "PF_12345");

        // --- ADD THIS TO PREVENT NULLPOINTEREXCEPTION ---
        OrderStatus mockStatus = new OrderStatus();
        mockStatus.setStatusName("Submitted");
        // -----------------------------------------------

        Order mockOrder = new Order();
        mockOrder.setOrderId(1L);
        mockOrder.setPaymentStatus("PENDING");
        mockOrder.setOrderStatus(mockStatus); // <-- Assign it here
        mockOrder.setOrderItems(new ArrayList<>());

        when(orderRepository.findByIdWithItems(1L)).thenReturn(Optional.of(mockOrder));

        payFastService.processPayFastITN(itnParams);

        assertEquals("PAID", mockOrder.getPaymentStatus());
        assertEquals("PF_12345", mockOrder.getPayFastPaymentId());
        verify(orderRepository, times(1)).save(mockOrder);
    }
}