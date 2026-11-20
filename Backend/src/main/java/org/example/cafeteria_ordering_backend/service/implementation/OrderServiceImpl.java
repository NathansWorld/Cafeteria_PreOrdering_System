package org.example.cafeteria_ordering_backend.service.implementation;

import org.example.cafeteria_ordering_backend.component.OperatingHoursValidator;
import org.example.cafeteria_ordering_backend.component.OrderItemCalculator;
import org.example.cafeteria_ordering_backend.component.OrderNumberGenerator;
import org.example.cafeteria_ordering_backend.component.OrderSecurityEvaluator;
import org.example.cafeteria_ordering_backend.dto.requests.OrderRequestDTO;
import org.example.cafeteria_ordering_backend.dto.response.OrderResponseDTO;
import org.example.cafeteria_ordering_backend.dto.response.WebSocketMessageResponseDTO;
import org.example.cafeteria_ordering_backend.entity.*;
import org.example.cafeteria_ordering_backend.event.WebSocketMessageEvent;
import org.example.cafeteria_ordering_backend.exception.ResourceNotFoundException;
import org.example.cafeteria_ordering_backend.exception.ResourceUnavailableException;
import org.example.cafeteria_ordering_backend.mapper.OrderMapper;
import org.example.cafeteria_ordering_backend.repository.*;
import org.example.cafeteria_ordering_backend.service.interfaces.NotificationService;
import org.example.cafeteria_ordering_backend.service.interfaces.OrderService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class OrderServiceImpl implements OrderService {

    private static final Logger logger = LoggerFactory.getLogger(OrderServiceImpl.class);

    private final MenuItemRepository menuItemRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final OrderRepository orderRepository;
    private final OrderStatusRepository orderStatusRepository;
    private final UserRepository userRepository;
    private final OrderMapper orderMapper;
    private final OrderStatusHistoryRepository orderStatusHistoryRepository;
    private final OperatingHoursValidator operatingHoursValidator;
    private final OrderSecurityEvaluator orderSecurityEvaluator;
    private final OrderNumberGenerator orderNumberGenerator;
    private final OrderItemCalculator orderItemCalculator;
    private final NotificationService notificationService;

    // Injects the repositories and components required to manage orders.
    public OrderServiceImpl (
            OrderRepository orderRepository,
            OrderStatusRepository orderStatusRepository,
            UserRepository userRepository,
            OrderStatusHistoryRepository orderStatusHistoryRepository,
            ApplicationEventPublisher eventPublisher,
            OperatingHoursValidator operatingHoursValidator,
            OrderSecurityEvaluator orderSecurityEvaluator,
            OrderNumberGenerator orderNumberGenerator,
            OrderItemCalculator orderItemCalculator,
            OrderMapper orderMapper,
            MenuItemRepository menuItemRepository,
            NotificationService notificationService) {

        this.orderRepository = orderRepository;
        this.orderStatusRepository = orderStatusRepository;
        this.userRepository = userRepository;
        this.orderStatusHistoryRepository = orderStatusHistoryRepository;
        this.eventPublisher = eventPublisher;
        this.operatingHoursValidator = operatingHoursValidator;
        this.orderSecurityEvaluator = orderSecurityEvaluator;
        this.orderNumberGenerator = orderNumberGenerator;
        this.orderItemCalculator = orderItemCalculator;
        this.orderMapper = orderMapper;
        this.menuItemRepository = menuItemRepository;
        this.notificationService = notificationService;
    }

    // Sets the time limit for submitted orders before they expire.
    @Value("${app.orders.expiration-timeout-minutes:15}")
    private int expirationTimeoutMinutes;

    // Retrieves a user's orders that have not reached a final status.
    @Override
    @Transactional(readOnly = true)
    public List<OrderResponseDTO> getActiveOrdersByUserId (Long userId) {

        // Ensures the current user is authorised to access these orders.
        orderSecurityEvaluator.validateUserAccess(userId);

        List<String> finalStatuses = List.of("Cancelled", "Collected");

        return orderRepository.findByUserUserIdAndOrderStatusStatusNameNotInOrderByCreatedAtAsc(
                        userId,
                        finalStatuses
                ).stream().map(orderMapper::toResponseDTO).toList();
    }

    @Override
    @Transactional
    public OrderResponseDTO checkout (OrderRequestDTO request) {

        // Prevents orders from being placed outside operating hours.
        operatingHoursValidator.validateOpenForOrders();
        // Retrieves the currently authenticated user.
        User user = orderSecurityEvaluator.getCurrentUser();

        logger.info("Checkout attempt for user ID: {} with payment method: {}",
                user.getUserId(), request.getPaymentMethod());

        // Retrieves the initial status assigned to newly submitted orders.
        OrderStatus submittedStatus = orderStatusRepository.findByStatusName("Submitted")
                .orElseThrow(() -> new RuntimeException(
                        "Initial 'Submitted' status configuration missing in database."
                ));

        // Creates the order and assigns its customer and initial status.
        Order order = new Order();
        order.setUser(user);
        order.setOrderStatus(submittedStatus);
        order.setCustomerOrderNumber(orderNumberGenerator.generate());

        // Dynamically set payment status based on user selection
        if (request.getPaymentMethod() == PaymentMethod.PAYFAST) {
            order.setPaymentStatus("PENDING");
        } else {
            order.setPaymentStatus("CASH");
        }

        // Validates the requested items and calculates the order total.
        OrderItemCalculator.CalculationResult result =
                orderItemCalculator.calculateAndBuildItems(request.getItems(), order);

        order.setOrderItems(result.orderItems());
        order.setTotalPrice(result.totalPrice());

        // Combines quantities when the same menu item appears on multiple order lines.
        Map<Long, Integer> quantitiesByMenuItem = order.getOrderItems()
                .stream()
                .collect(Collectors.groupingBy(
                        item -> item.getMenuItem().getMenuItemId(),
                        Collectors.summingInt(OrderItem::getQuantity)
                ));

        // Deducts stock only when sufficient stock is available.
        for (Map.Entry<Long, Integer> entry : quantitiesByMenuItem.entrySet()) {
            Long menuItemId = entry.getKey();
            Integer quantity = entry.getValue();

            int updatedRows = menuItemRepository.deductStockAndAutoDisable(menuItemId, quantity);

            if (updatedRows == 0) {
                logger.warn(
                        "Checkout failed: insufficient stock or menu item unavailable. "
                                + "Menu item ID: {}, requested quantity: {}, user ID: {}",
                        menuItemId,
                        quantity,
                        user.getUserId()
                );

                throw new ResourceUnavailableException(
                        "Insufficient stock or menu item unavailable for menu item ID: "
                                + menuItemId
                );
            }
        }

        // Saves the order after stock has been successfully deducted.
        Order savedOrder = orderRepository.save(order);

        logger.info(
                "Order created successfully: {} for user ID: {}, total: {}, payment status: {}",
                savedOrder.getCustomerOrderNumber(),
                user.getUserId(),
                savedOrder.getTotalPrice(),
                savedOrder.getPaymentStatus()
        );

        // Automatically create an in-app notification for the customer
        notificationService.createNotificationForOrder(
                savedOrder,
                "ORDER_PLACED",
                "Order Placed",
                "Your order #" + savedOrder.getCustomerOrderNumber() + " has been successfully placed."
        );

        // Converts the saved order to a response DTO.
        OrderResponseDTO response = orderMapper.toResponseDTO(savedOrder);

        // Notifies the kitchen of the new order.
        logger.info(
                "Sending new order {} to kitchen topic /topic/orders/active",
                savedOrder.getCustomerOrderNumber()
        );

        eventPublisher.publishEvent(new WebSocketMessageEvent<>(
                "/topic/orders/active", "CREATE", "ORDER", response
        ));

        return response;
    }

    // Get all orders
    @Override
    @Transactional(readOnly = true)
    public List<OrderResponseDTO> getAllOrders () {

        // Prevents customers from accessing the complete order list.
        if (!orderSecurityEvaluator.isStaffOrAdmin()) {
            throw new ResourceUnavailableException("Only staff or admin can access all orders.");
        }
        return orderRepository.findAll().stream().map(orderMapper::toResponseDTO).toList();
    }

    // Get Order by ID
    @Override
    @Transactional(readOnly = true)
    public OrderResponseDTO getOrderById (Long id) {

        Order order = orderRepository.findByIdWithItems(id)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found with ID: " + id));

        // Ensures users can only access orders they are authorised to view.
        orderSecurityEvaluator.validateOrderOwnership(order.getUser().getUserId());

        return orderMapper.toResponseDTO(order);
    }

    // Get orders by user ID
    @Override
    @Transactional(readOnly = true)
    public List<OrderResponseDTO> getOrdersByUserId (Long userId) {

        // Checks that the current user may access the requested user's orders.
        orderSecurityEvaluator.validateUserAccess(userId);

        // Confirms that the requested user exists.
        if (!userRepository.existsById(userId)) {
            throw new ResourceNotFoundException("User not found with ID: " + userId);
        }

        return orderRepository
                .findByUserUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(orderMapper::toResponseDTO)
                .toList();
    }

    @Override
    @Transactional
    public OrderResponseDTO updateOrderStatus (Long orderId, String statusName) {

        return updateOrderStatus(orderId, statusName, null);
    }

    // Changes an order's status and notifies the customer and kitchen.
    @Override
    @Transactional
    public OrderResponseDTO updateOrderStatus (Long orderId, String statusName, String providedSuffix) {

        Order order = orderRepository.findByIdWithItems(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found with ID: " + orderId));

        String currentStatusName = order.getOrderStatus().getStatusName();

        // Ensure last 4 digits of order number are entered before order marked as collected
        if ("Collected".equalsIgnoreCase(statusName)) {
            String expectedSuffix = order.getCustomerOrderNumber().substring(order.getCustomerOrderNumber().lastIndexOf('-') + 1);

            if (providedSuffix == null || !expectedSuffix.equalsIgnoreCase(providedSuffix.trim())) {
                throw new ResourceUnavailableException("Invalid pickup code. Please check the 4-character code and try again.");
            }
        }

        // Use the existing cancellation process when an order is cancelled.
        if ("Cancelled".equalsIgnoreCase(statusName)) {
            cancelOrder(orderId);

            // Retrieve the canceled order for the response.
            Order cancelledOrder = orderRepository.findByIdWithItems(orderId)
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Order not found with ID: " + orderId
                    ));

            return orderMapper.toResponseDTO(cancelledOrder);
        }

        // Retrieves the requested status or rejects an invalid status name first.
        OrderStatus newStatus = orderStatusRepository.findByStatusName(statusName)
                .orElseThrow(() -> new ResourceNotFoundException("Invalid status name: '" + statusName
                        + "'. Make sure this status exists in the database."));

        // Check if current user is admin
        boolean isAdmin = orderSecurityEvaluator.getCurrentUser().getRole().getRoleName().equals("ADMIN");

        // Enforce state transition
        if (!isValidTransition(currentStatusName, newStatus.getStatusName(), isAdmin)) {
            throw new ResourceNotFoundException("Invalid status transition: Cannot change order status from: " +
                    currentStatusName + " to: " + newStatus.getStatusName() + "."
            );
        }

        logger.info(
                "Updating order {} status from {} to {}",
                order.getCustomerOrderNumber(),
                currentStatusName,
                newStatus.getStatusName()
        );

        order.setOrderStatus(newStatus);

        // Set collectedAt when the status changes to Collected
        if ("Collected".equalsIgnoreCase(newStatus.getStatusName())) {
            order.setCollectedAt(LocalDateTime.now());
        }

        // Saves the updated order status.
        Order updatedOrder = orderRepository.save(order);

        logger.info("Order {} status successfully changed to {}",
                updatedOrder.getCustomerOrderNumber(),
                newStatus.getStatusName()
        );

        // Get currently authenticated user
        User currentUser = orderSecurityEvaluator.getCurrentUser();

        // Save status history
        OrderStatusHistory history = new OrderStatusHistory();
        history.setOrder(updatedOrder);
        history.setStatus(newStatus);
        history.setChangedByUser(currentUser);
        orderStatusHistoryRepository.save(history);

        // Re-fetch to guarantee fully loaded relationships for DTO mapping
        Order fullyLoadedOrder = orderRepository.findByIdWithItems(updatedOrder.getOrderId())
                .orElse(updatedOrder);

        // Automatically create an in-app notification for status updates (e.g., Accepted, Ready, Collected)
        notificationService.createNotificationForOrder(
                fullyLoadedOrder,
                "ORDER_STATUS_UPDATE",
                "Order " + newStatus.getStatusName(),
                "Your order #" + fullyLoadedOrder.getCustomerOrderNumber() + " is now " + newStatus.getStatusName() + "."
        );

        // Convert to DTO
        OrderResponseDTO response = orderMapper.toResponseDTO(fullyLoadedOrder);

        // Customer Websocket
        logger.debug(
                "Sending WebSocket update for order {} to topic /topic/orders/{}",
                fullyLoadedOrder.getCustomerOrderNumber(),
                fullyLoadedOrder.getUser().getUserId()
        );

        eventPublisher.publishEvent(new WebSocketMessageEvent<>(
                "/topic/orders/" + fullyLoadedOrder.getUser().getUserId(), "UPDATE", "ORDER", response
        ));

        // Kitchen Websocket
        logger.debug(
                "Sending order {} status update to kitchen topic /topic/orders/active",
                fullyLoadedOrder.getCustomerOrderNumber()
        );

        eventPublisher.publishEvent(new WebSocketMessageEvent<>(
                "/topic/orders/active", "UPDATE", "ORDER", response
        ));

        return response;
    }

    // Get active orders (for staff dashboard)
    @Override
    @Transactional(readOnly = true)
    public List<OrderResponseDTO> getActiveOrders () {

        // Restricts the kitchen order list to staff and administrators.
        if (!orderSecurityEvaluator.isStaffOrAdmin()) {
            throw new ResourceUnavailableException("Only staff or admin can access active kitchen orders.");
        }

        List<String> excludedStatuses = List.of("Completed", "Cancelled");

        return orderRepository
                .findActiveOrdersWithItems(excludedStatuses)
                .stream()
                .map(orderMapper::toResponseDTO)
                .toList();
    }

    // Cancel orders
    @Override
    @Transactional
    public void cancelOrder (Long orderId) {

        // Fetch Order
        Order order = orderRepository.findByIdWithItems(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found with ID: " + orderId));

        // Security & Ownership Check (Replaces ~30 lines of manual auth logic)
        orderSecurityEvaluator.validateOrderOwnership(order.getUser().getUserId());
        User currentUser = orderSecurityEvaluator.getCurrentUser();

        // Status Validation
        String currentStatus = order.getOrderStatus().getStatusName();

        logger.info("Cancellation requested for order {} by {} with current status {}",
                order.getCustomerOrderNumber(), currentUser.getEmail(), currentStatus);

        // Only submitted or accepted orders can be cancelled by the customer.
        if (!currentStatus.equalsIgnoreCase("Submitted") && !currentStatus.equalsIgnoreCase("Accepted")) {
            throw new ResourceUnavailableException(
                    "Cannot cancel order: This order is already '" + currentStatus + "' and cannot be cancelled."
            );
        }

        OrderStatus cancelledStatus = orderStatusRepository.findByStatusName("Cancelled")
                .orElseThrow(() -> new RuntimeException("Configuration error: 'Cancelled' status entity missing in database."));

        // Restores stock before changing the order status.
        restoreStockForOrder(order);

        // If the order was already paid online via PayFast, mark the payment as REFUNDED
        if ("PAID".equalsIgnoreCase(order.getPaymentStatus())) {
            order.setPaymentStatus("REFUNDED");
            logger.info("Order {} payment status updated to REFUNDED", order.getCustomerOrderNumber());
        } else if ("PENDING".equalsIgnoreCase(order.getPaymentStatus())) {
            order.setPaymentStatus("CANCELLED");
            logger.info("Order {} payment status updated to CANCELLED due to user cancellation", order.getCustomerOrderNumber());
        }

        order.setOrderStatus(cancelledStatus);
        Order savedOrder = orderRepository.save(order);

        logger.info("Order {} cancelled successfully by {}", savedOrder.getCustomerOrderNumber(), currentUser.getEmail());

        // Automatically create an in-app notification for the cancellation
        notificationService.createNotificationForOrder(
                savedOrder,
                "ORDER_CANCELLED",
                "Order Cancelled",
                "Your order #" + savedOrder.getCustomerOrderNumber() + " has been cancelled."
        );

        // Save Status History
        OrderStatusHistory history = new OrderStatusHistory();
        history.setOrder(savedOrder);
        history.setStatus(cancelledStatus);
        history.setChangedByUser(currentUser);
        orderStatusHistoryRepository.save(history);

        // WebSocket Notifications
        OrderResponseDTO response = orderMapper.toResponseDTO(savedOrder);

        eventPublisher.publishEvent(new WebSocketMessageEvent<>(
                "/topic/orders/" + savedOrder.getUser().getUserId(), "UPDATE", "ORDER", response
        ));

        // Removes the canceled order from active kitchen work.
        logger.info("Sending cancelled order {} to kitchen topic /topic/orders/active",
                savedOrder.getCustomerOrderNumber());

        eventPublisher.publishEvent(new WebSocketMessageEvent<>(
                "/topic/orders/active", "UPDATE", "ORDER", response
        ));
    }

    // Automatically cancels submitted orders that have exceeded the time limit.
    @Scheduled(fixedRate = 60000)
    @Transactional
    @Override
    public void expireOverdueOrders () {

        logger.info("--- Running scheduled task: Checking for overdue orders ---");

        // Calculates the cutoff time for orders that have expired.
        LocalDateTime cutoffTime = LocalDateTime.now().minusMinutes(expirationTimeoutMinutes);
        // Retrieves submitted orders older than the configured time limit.
        List<Order> overdueOrders = orderRepository.findOverdueOrders(List.of("Submitted"), cutoffTime);

        // Skips processing when no overdue orders are found.
        if (overdueOrders.isEmpty()) {return;}

        logger.info("Found {} overdue order(s) to expire.", overdueOrders.size());

        // Retrieves the status used to mark expired orders as cancelled.
        OrderStatus cancelledStatus = orderStatusRepository.findByStatusName("Cancelled")
                .orElseThrow(() -> new ResourceNotFoundException("OrderStatus Cancelled not found"));

        // Cancels each overdue order and records its status change.
        for (Order order : overdueOrders) {
            // Restores stock before changing the order status.
            restoreStockForOrder(order);

            order.setOrderStatus(cancelledStatus);

            // Track the timeout/expiration inside the Payment Status
            if ("PENDING".equalsIgnoreCase(order.getPaymentStatus())) {
                order.setPaymentStatus("EXPIRED");
            } else if ("CASH".equalsIgnoreCase(order.getPaymentStatus())) {
                order.setPaymentStatus("EXPIRED");
            }

            Order savedOrder = orderRepository.save(order);

            OrderStatusHistory history = new OrderStatusHistory();
            history.setOrder(savedOrder);
            history.setStatus(cancelledStatus);
            orderStatusHistoryRepository.save(history);

            // Reloads the order and its items before creating the response.
            Order fullyLoadedOrder = orderRepository.findByIdWithItems(savedOrder.getOrderId())
                    .orElse(savedOrder);

            // Automatically create an in-app notification for the timeout expiration
            notificationService.createNotificationForOrder(
                    fullyLoadedOrder,
                    "ORDER_TIMEOUT",
                    "Order Expired",
                    "Your order (" + fullyLoadedOrder.getCustomerOrderNumber() + ") was automatically cancelled because the cafeteria did not accept within 15 minutes."
            );

            OrderResponseDTO responseDTO = orderMapper.toResponseDTO(fullyLoadedOrder);

            // Wraps response in WebSocketMessageResponseDTO
            WebSocketMessageResponseDTO<OrderResponseDTO> customerNotification = new WebSocketMessageResponseDTO<>(
                    "ORDER_TIMEOUT",
                    "Your order (" + fullyLoadedOrder.getCustomerOrderNumber() +
                            ") was automatically cancelled because the cafeteria did not accept within 15 minutes.",
                    responseDTO
            );

            eventPublisher.publishEvent(new WebSocketMessageEvent<>(
                    "/topic/orders/" + fullyLoadedOrder.getUser().getUserId(), "UPDATE", "ORDER", customerNotification
            ));

            eventPublisher.publishEvent(new WebSocketMessageEvent<>(
                    "/topic/orders/active", "UPDATE", "ORDER", responseDTO
            ));

            logger.info("Successfully expired and cancelled order: {}", savedOrder.getCustomerOrderNumber());
        }
        logger.info(
                "Finished overdue order check. Processed {} expired order(s).",
                overdueOrders.size()
        );
    }

    // Restores stock for all menu items in an order.
    private void restoreStockForOrder (Order order) {

        // Skip stock restoration if Payfast order that never completed
        if ("PENDING".equalsIgnoreCase(order.getPaymentStatus())) {
            logger.info("Skipping stock restoration for order {} as payment was PENDING (stock was never deducted).",
                    order.getCustomerOrderNumber());
            return;
        }

        if (order.getOrderItems() == null || order.getOrderItems().isEmpty()) {
            return;
        }

        // Combines quantities when the same menu item appears on multiple lines.
        Map<Long, Integer> quantitiesByMenuItem = order.getOrderItems()
                .stream()
                .collect(Collectors.groupingBy(
                        item -> item.getMenuItem().getMenuItemId(),
                        Collectors.summingInt(OrderItem::getQuantity)
                ));

        // Restores the quantity for each menu item.
        for (Map.Entry<Long, Integer> entry : quantitiesByMenuItem.entrySet()) {

            Long menuItemId = entry.getKey();
            Integer quantity = entry.getValue();

            int updatedRows = menuItemRepository.restoreStock(
                    menuItemId,
                    quantity
            );

            if (updatedRows == 0) {
                throw new ResourceNotFoundException(
                        "Could not restore stock for menu item ID: " + menuItemId
                );
            }

            // Fetch the updated menu item and broadcast the change
            MenuItems updatedItem = menuItemRepository.findById(menuItemId).orElse(null);
            if (updatedItem != null) {
                eventPublisher.publishEvent(new WebSocketMessageEvent<>(
                        "/topic/menu/updates", "UPDATE", "MENU_ITEM", updatedItem
                ));
            }
        }
    }

    // Helper methods

    // Validates status change, must follow logical flow, only admin can override
    private boolean isValidTransition (String currentStatus, String newStatus, boolean isAdmin) {

        if (currentStatus == null || newStatus == null) {return false;}

        // Admin override
        if (isAdmin) {return true;}

        String current = currentStatus.trim();
        String target = newStatus.trim();

        // Status cannot be changed by staff once they become the Collected/Concelled
        if (current.equalsIgnoreCase("Collected") || current.equalsIgnoreCase("Cancelled")) {
            return false;
        }

        // Controlled flow
        if (current.equalsIgnoreCase("Submitted")) {
            return target.equalsIgnoreCase("Accepted") || target.equalsIgnoreCase("Cancelled");
        }
        if (current.equalsIgnoreCase("Accepted")) {
            return target.equalsIgnoreCase("Preparing") || target.equalsIgnoreCase("Cancelled");
        }
        if (current.equalsIgnoreCase("Preparing")) {
            return target.equalsIgnoreCase("Ready") || target.equalsIgnoreCase("Cancelled");
        }
        if (current.equalsIgnoreCase("Ready")) {
            return target.equalsIgnoreCase("Collected") || target.equalsIgnoreCase("Cancelled");
        }

        return false;
    }

    // Manual refund / reversal handler for Staff or Admins
    @Override
    @Transactional
    public OrderResponseDTO refundOrder (Long orderId) {

        if (!orderSecurityEvaluator.isStaffOrAdmin()) {
            throw new ResourceUnavailableException("Only staff or admin can process refunds.");
        }

        Order order = orderRepository.findByIdWithItems(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found with ID: " + orderId));

        String currentPaymentStatus = order.getPaymentStatus();

        // Ensure the order is actually eligible for a refund (was PAID)
        if (!"PAID".equalsIgnoreCase(currentPaymentStatus)) {
            throw new ResourceUnavailableException(
                    "Cannot refund order: Payment status is '" + currentPaymentStatus + "', not 'PAID'."
            );
        }

        logger.info("Processing manual refund for order {} by staff/admin", order.getCustomerOrderNumber());

        restoreStockForOrder(order);
        order.setPaymentStatus("REFUNDED");

        // Ensure order status is set to Cancelled
        OrderStatus cancelledStatus = orderStatusRepository.findByStatusName("Cancelled")
                .orElseThrow(() -> new RuntimeException("Configuration error: 'Cancelled' status missing."));
        order.setOrderStatus(cancelledStatus);

        Order savedOrder = orderRepository.save(order);

        // Notify the customer in-app via notification service
        notificationService.createNotificationForOrder(
                savedOrder,
                "ORDER_REFUNDED",
                "Order Refunded",
                "Your payment for order #" + savedOrder.getCustomerOrderNumber() + " has been refunded."
        );

        OrderResponseDTO response = orderMapper.toResponseDTO(savedOrder);

        // Push WebSocket update to the customer
        eventPublisher.publishEvent(new WebSocketMessageEvent<>(
                "/topic/orders/" + savedOrder.getUser().getUserId(), "UPDATE", "ORDER", response
        ));

        // Push WebSocket update to the active kitchen/staff board
        eventPublisher.publishEvent(new WebSocketMessageEvent<>(
                "/topic/orders/active", "UPDATE", "ORDER", response
        ));

        logger.info("Successfully processed manual refund for order {}", savedOrder.getCustomerOrderNumber());

        return response;
    }
}