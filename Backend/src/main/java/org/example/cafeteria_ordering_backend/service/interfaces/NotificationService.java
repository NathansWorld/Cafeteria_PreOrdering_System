package org.example.cafeteria_ordering_backend.service.interfaces;

import org.example.cafeteria_ordering_backend.dto.requests.FCMTokenRequestDTO;
import org.example.cafeteria_ordering_backend.entity.Notification;
import org.example.cafeteria_ordering_backend.entity.Order;

import java.util.List;

public interface NotificationService {

    // Create a notification for a specific user
    Notification createUserNotification (
            Long userId, Long orderId, String type, String title, String message, String channel);

    // Get notifications for a specific user
    List<Notification> getNotificationsForUser (Long userId);

    // Mark a specific notificaiton as read
    void markNotificationAsRead (Long notificationId, Long userId);

    // Creates a notification for a specific order
    Notification createNotificationForOrder(Order order, String type, String title, String message);

    // Register/un FCM tokens for notifications outside of app
    void registerFcmToken(Long userId, FCMTokenRequestDTO tokenRequest);
    void unregisterFcmToken(String fcmToken);
}
