package org.example.cafeteria_ordering_backend.service.implementation;

import lombok.RequiredArgsConstructor;
import org.example.cafeteria_ordering_backend.component.OperatingHoursValidator;
import org.example.cafeteria_ordering_backend.component.OrderItemCalculator;
import org.example.cafeteria_ordering_backend.component.OrderNumberGenerator;
import org.example.cafeteria_ordering_backend.component.OrderSecurityEvaluator;
import org.example.cafeteria_ordering_backend.dto.requests.OrderRequestDTO;
import org.example.cafeteria_ordering_backend.dto.response.OrderResponseDTO;
import org.example.cafeteria_ordering_backend.entity.*;
import org.example.cafeteria_ordering_backend.event.WebSocketMessageEvent;
import org.example.cafeteria_ordering_backend.exception.ResourceUnavailableException;
import org.example.cafeteria_ordering_backend.mapper.OrderMapper;
import org.example.cafeteria_ordering_backend.repository.MenuItemRepository;
import org.example.cafeteria_ordering_backend.repository.OrderRepository;
import org.example.cafeteria_ordering_backend.repository.OrderStatusRepository;
import org.example.cafeteria_ordering_backend.service.interfaces.PayFastService;
import org.example.cafeteria_ordering_backend.util.PayFastSignatureUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PayFastServiceImpl implements PayFastService {

    private static final Logger logger = LoggerFactory.getLogger(PayFastServiceImpl.class);

    private final OrderRepository orderRepository;
    private final OrderStatusRepository orderStatusRepository;
    private final MenuItemRepository menuItemRepository;
    private final OrderNumberGenerator orderNumberGenerator;
    private final OrderItemCalculator orderItemCalculator;
    private final OperatingHoursValidator operatingHoursValidator;
    private final OrderSecurityEvaluator orderSecurityEvaluator;
    private final ApplicationEventPublisher eventPublisher;
    private final OrderMapper orderMapper;

    @Value("${payfast.merchant-id}") private String merchantId;
    @Value("${payfast.merchant-key}") private String merchantKey;
    @Value("${payfast.passphrase}") private String passphrase;
    @Value("${payfast.process-url}") private String processUrl;
    @Value("${payfast.return-url}") private String returnUrl;
    @Value("${payfast.cancel-url}") private String cancelUrl;
    @Value("${payfast.itn-url}") private String itnUrl;

    @Transactional
    public Map<String, String> createPaymentPayload (OrderRequestDTO orderRequest, String userEmail) {

        // Ensure the client explicitly selected PAYFAST for this endpoint
        if (orderRequest.getPaymentMethod() != PaymentMethod.PAYFAST) {
            throw new IllegalArgumentException("Invalid payment method. Pay online required for this endpoint.");
        }

        operatingHoursValidator.validateOpenForOrders();
        User user = orderSecurityEvaluator.getCurrentUser();

        OrderStatus submittedStatus = orderStatusRepository.findByStatusName("Submitted")
                .orElseThrow(() -> new RuntimeException("Initial 'Submitted' status configuration missing."));

        Order order = new Order();
        order.setUser(user);
        order.setOrderStatus(submittedStatus);
        order.setCustomerOrderNumber(orderNumberGenerator.generate());
        order.setPaymentStatus("PENDING");

        OrderItemCalculator.CalculationResult result =
                orderItemCalculator.calculateAndBuildItems(orderRequest.getItems(), order);

        order.setOrderItems(result.orderItems());
        order.setTotalPrice(result.totalPrice());

        // Save order as PENDING without deducting stock yet
        Order savedOrder = orderRepository.save(order);

        Map<String, String> payfastData = new LinkedHashMap<>();
        payfastData.put("merchant_id", merchantId);
        payfastData.put("merchant_key", merchantKey);
        payfastData.put("return_url", returnUrl);
        payfastData.put("cancel_url", cancelUrl);
        payfastData.put("notify_url", itnUrl);
        payfastData.put("email_address", userEmail);
        payfastData.put("m_payment_id", savedOrder.getOrderId().toString());
        payfastData.put("amount", savedOrder.getTotalPrice().setScale(2).toString());
        payfastData.put("item_name", "EduEats Order #" + savedOrder.getCustomerOrderNumber());

        String signature = PayFastSignatureUtil.generateSignature(payfastData, passphrase);
        payfastData.put("signature", signature);
        payfastData.put("payfast_url", processUrl);

        return payfastData;
    }

    @Transactional
    public void processPayFastITN (Map<String, String> itnParams) {

        String orderIdStr = itnParams.get("m_payment_id");
        String paymentStatus = itnParams.get("payment_status");
        String pfPaymentId = itnParams.get("pf_payment_id");

        if (orderIdStr == null) return;

        Long orderId = Long.valueOf(orderIdStr);
        Order order = orderRepository.findByIdWithItems(orderId).orElse(null);

        if (order == null || "PAID".equals(order.getPaymentStatus())) {
            return;
        }

        // Guard against zombie orders: check both Order Status and Payment Status
        String orderStatus = order.getOrderStatus().getStatusName();
        String currentPaymentStatus = order.getPaymentStatus();

        if ("Cancelled".equalsIgnoreCase(orderStatus) ||
                "EXPIRED".equalsIgnoreCase(currentPaymentStatus) ||
                "REFUNDED".equalsIgnoreCase(currentPaymentStatus)) {

            logger.warn("Received ITN COMPLETE for order {} which is already Cancelled/Expired (Order Status: {}, Payment Status: {}). Rejecting payment processing.",
                    order.getCustomerOrderNumber(), orderStatus, currentPaymentStatus);
            return;
        }

        if ("COMPLETE".equalsIgnoreCase(paymentStatus)) {
            order.setPaymentStatus("PAID");
            order.setPayFastPaymentId(pfPaymentId);
            order.setPaidAt(LocalDateTime.now());

            // Deduct stock now that payment is successful
            deductStockForOrder(order);
            orderRepository.save(order);

            logger.info("Payment confirmed via PayFast ITN for order: {}", order.getCustomerOrderNumber());

            OrderResponseDTO response = orderMapper.toResponseDTO(order);
            eventPublisher.publishEvent(new WebSocketMessageEvent<>(
                    "/topic/orders/active", "CREATE", "ORDER", response
            ));
        } else if ("FAILED".equalsIgnoreCase(paymentStatus) || "CANCELLED".equalsIgnoreCase(paymentStatus)) {
            logger.info("PayFast reported non-complete status '{}' for order {}", paymentStatus, order.getCustomerOrderNumber());
            order.setPaymentStatus("FAILED");
            orderRepository.save(order);
        }
    }

    private void deductStockForOrder (Order order) {

        Map<Long, Integer> quantitiesByMenuItem = order.getOrderItems()
                .stream()
                .collect(Collectors.groupingBy(
                        item -> item.getMenuItem().getMenuItemId(),
                        Collectors.summingInt(OrderItem::getQuantity)
                ));

        for (Map.Entry<Long, Integer> entry : quantitiesByMenuItem.entrySet()) {
            int updatedRows = menuItemRepository.deductStockAndAutoDisable(entry.getKey(), entry.getValue());
            if (updatedRows == 0) {
                throw new ResourceUnavailableException("Stock depleted during checkout payment confirmation.");
            }
        }
    }
}