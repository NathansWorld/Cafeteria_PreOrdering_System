package org.example.cafeteria_ordering_backend.service.implementation;

import lombok.RequiredArgsConstructor;
import org.example.cafeteria_ordering_backend.dto.requests.FCMTokenRequestDTO;
import org.example.cafeteria_ordering_backend.entity.Notification;
import org.example.cafeteria_ordering_backend.entity.Order;
import org.example.cafeteria_ordering_backend.entity.User;
import org.example.cafeteria_ordering_backend.entity.UserDevice;
import org.example.cafeteria_ordering_backend.event.WebSocketMessageEvent;
import org.example.cafeteria_ordering_backend.exception.ResourceNotFoundException;
import org.example.cafeteria_ordering_backend.mapper.NotificationMapper;
import org.example.cafeteria_ordering_backend.repository.NotificationRepository;
import org.example.cafeteria_ordering_backend.repository.UserDeviceRepository;
import org.example.cafeteria_ordering_backend.repository.UserRepository;
import org.example.cafeteria_ordering_backend.service.interfaces.NotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private static final Logger logger = LoggerFactory.getLogger(NotificationServiceImpl.class);

    private final NotificationRepository notificationRepository;
    private final NotificationMapper notificationMapper;
    private final ApplicationEventPublisher eventPublisher;
    private final UserDeviceRepository userDeviceRepository;
    private final UserRepository userRepository;
    private final FirebaseMessagingServiceImpl firebaseMessagingService;

    // Clean method using mapper
    @Override
    @Transactional
    public Notification createNotificationForOrder (Order order, String type, String title, String message) {

        Notification notification = notificationMapper.toOrderNotification(order, type, title, message);
        Notification saved = notificationRepository.save(notification);

        Long userId = order.getUser().getUserId();
        logger.info("Created order notification ID: {} for user ID: {}", saved.getNotificationId(), userId);

        // Broadcast real-time notification users STOMP topic
        eventPublisher.publishEvent(new WebSocketMessageEvent<>(
                "/topic/user/" + userId + "/notifications", "CREATE", "NOTIFICATION", saved
        ));

        firebaseMessagingService.sendPushNotificationToUser(
                userId,
                title,
                message,
                order.getCustomerOrderNumber()
        );

        return saved;
    }

    @Override
    @Transactional
    public Notification createUserNotification (
            Long userId, Long orderId, String type, String title, String message, String channel) {

        // Delegating entity creation to the mapper
        Notification notification = notificationMapper.toUserNotification(userId, type, title, message, channel);
        Notification saved = notificationRepository.save(notification);

        logger.info("Created user notification ID: {} for user ID: {}", saved.getNotificationId(), userId);

        eventPublisher.publishEvent(new WebSocketMessageEvent<>(
                "/topic/user/" + userId + "/notifications", "CREATE", "NOTIFICATION", saved
        ));

        firebaseMessagingService.sendPushNotificationToUser(
                userId,
                title,
                message,
                null // TODO: Pass null or order number if available
        );

        return saved;
    }

    @Override
    @Transactional(readOnly = true)
    public List<Notification> getNotificationsForUser (Long userId) {

        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Override
    @Transactional
    public void markNotificationAsRead (Long notificationId, Long userId) {

        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification not found with ID: " + notificationId));

        // Security check to ensure notification actually belongs to requesting user
        if (!notification.getUserId().equals(userId)) {
            logger.warn("User ID: {} attempted to mark notification ID: {} belonging to user ID: {} as read.",
                    userId, notificationId, notification.getUserId());

            throw new ResourceNotFoundException("Notification not found with ID: " + notificationId);
        }

        if (!notification.isRead()) {
            notification.setRead(true);
            notification.setReadAt(LocalDateTime.now());
            Notification updated = notificationRepository.save(notification);

            logger.info("Marked notification ID: {} as read for user ID: {}", notificationId, userId);

            // Broadcast read status update so user's other open UI sessions sync instantly
            eventPublisher.publishEvent(new WebSocketMessageEvent<>(
                    "/topic/user/" + userId + "/notifications", "UPDATE", "NOTIFICATION", updated
            ));
        }
    }

    @Override
    @Transactional
    public void registerFcmToken(Long userId, FCMTokenRequestDTO tokenRequest) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + userId));

        Optional<UserDevice> existingDevice = userDeviceRepository.findByFcmToken(tokenRequest.getFcmToken());

        if (existingDevice.isPresent()) {
            UserDevice device = existingDevice.get();
            device.setUser(user); // Re-assign if logged in on a different account in the same browser
            device.setDeviceType(tokenRequest.getDeviceType());
            userDeviceRepository.save(device);
            logger.info("Updated FCM token device mapping for user ID: {}", userId);
        } else {
            UserDevice device = new UserDevice();
            device.setUser(user);
            device.setFcmToken(tokenRequest.getFcmToken());
            device.setDeviceType(tokenRequest.getDeviceType() != null ? tokenRequest.getDeviceType() : "WEB_PWA");
            userDeviceRepository.save(device);
            logger.info("Registered new FCM token for user ID: {}", userId);
        }
    }

    @Override
    @Transactional
    public void unregisterFcmToken(String fcmToken) {
        userDeviceRepository.deleteByFcmToken(fcmToken);
        logger.info("Unregistered FCM token successfully");
    }
}
