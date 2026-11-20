package org.example.cafeteria_ordering_backend.mapper;

import org.example.cafeteria_ordering_backend.entity.Notification;
import org.example.cafeteria_ordering_backend.entity.Order;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class NotificationMapper {

    // Notifications linked to an order
    public Notification toOrderNotification (Order order, String type, String title, String message) {
        if (order == null) return null;
        Long userId = (order.getUser() != null) ? order.getUser().getUserId() : null;

        return buildBaseNotification(userId, order.getOrderId(), type, title, message, "IN_APP");
    }

    // General notifications linked directly to a user (no order required)
    public Notification toUserNotification (Long userId, String type, String title, String message, String channel) {
        return buildBaseNotification(userId, null, type, title, message, channel);
    }

    // Private helper to keep the default mapping logic from being repetitive
    private Notification buildBaseNotification(Long userId, Long orderId, String type, String title, String message, String channel) {
        return Notification.builder()
                .userId(userId)
                .orderId(orderId)
                .type(type)
                .title(title)
                .message(message)
                .channel(channel != null ? channel : "IN_APP")
                .deliveryStatus("SENT")
                .isRead(false)
                .sentAt(LocalDateTime.now())
                .build();
    }
}