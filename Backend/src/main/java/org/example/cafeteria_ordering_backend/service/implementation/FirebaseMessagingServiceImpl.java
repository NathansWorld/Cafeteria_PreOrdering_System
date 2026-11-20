package org.example.cafeteria_ordering_backend.service.implementation;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.RequiredArgsConstructor;
import org.example.cafeteria_ordering_backend.entity.UserDevice;
import org.example.cafeteria_ordering_backend.repository.UserDeviceRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FirebaseMessagingServiceImpl {

    private static final Logger logger = LoggerFactory.getLogger(FirebaseMessagingServiceImpl.class);
    private final UserDeviceRepository userDeviceRepository;

    // Send a push notification to all active devices registered by a specific user
    public void sendPushNotificationToUser (Long userId, String title, String body, String orderNumber) {
        List<UserDevice> devices = userDeviceRepository.findByUserUserId(userId);

        if (devices.isEmpty()) {
            logger.debug("No registered FCM devices found for user ID: {}", userId);
            return;
        }

        for (UserDevice device : devices) {
            try {
                Message message = Message.builder()
                        .setToken(device.getFcmToken())
                        .setNotification(Notification.builder()
                                .setTitle(title)
                                .setBody(body)
                                .build())
                        .putData("orderNumber", orderNumber != null ? orderNumber : "")
                        .putData("click_action", "/orders") // PWA route redirection target
                        .build();

                String response = FirebaseMessaging.getInstance().send(message);
                logger.info("FCM push notification sent successfully to device ID {} for user {}. Response: {}",
                        device.getDeviceId(), userId, response);

            } catch (FirebaseMessagingException e) {
                logger.error("Failed to send FCM push notification to token {}: {}",
                        device.getFcmToken(), e.getMessage());

                // Optional: If token is unregistered/invalid, you can auto-clean it up
                if (e.getMessagingErrorCode() != null &&
                        (e.getMessagingErrorCode().name().equals("UNREGISTERED") ||
                                e.getMessagingErrorCode().name().equals("INVALID_ARGUMENT"))) {
                    logger.warn("Removing invalid/expired FCM token: {}", device.getFcmToken());
                    userDeviceRepository.delete(device);
                }
            }
        }
    }
}