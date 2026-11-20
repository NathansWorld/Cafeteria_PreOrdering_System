package org.example.cafeteria_ordering_backend.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.example.cafeteria_ordering_backend.dto.requests.FCMTokenRequestDTO;
import org.example.cafeteria_ordering_backend.entity.Notification;
import org.example.cafeteria_ordering_backend.component.OrderSecurityEvaluator;
import org.example.cafeteria_ordering_backend.service.interfaces.NotificationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// Notification history retrieval and read status management for users. FCM func added at bottom
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;
    private final OrderSecurityEvaluator orderSecurityEvaluator;

    // Get all notifications for currently authed user
    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<Notification>> getMyNotifications () {

        Long currentUserId = orderSecurityEvaluator.getCurrentUser().getUserId();
        List<Notification> notifications = notificationService.getNotificationsForUser(currentUserId);

        return ResponseEntity.ok(notifications);
    }

    // Mark a specific notification as read
    @PatchMapping("/{id}/read")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Void> markAsRead (@PathVariable Long id) {

        Long currentUserId = orderSecurityEvaluator.getCurrentUser().getUserId();
        notificationService.markNotificationAsRead(id, currentUserId);

        return ResponseEntity.ok().build();
    }

    // Register or update browser FCM device token for push notifications
    @PostMapping("/fcm-token")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Void> registerFcmToken (@Valid @RequestBody FCMTokenRequestDTO tokenRequest) {
        Long currentUserId = orderSecurityEvaluator.getCurrentUser().getUserId();
        notificationService.registerFcmToken(currentUserId, tokenRequest);
        return ResponseEntity.ok().build();
    }

    // Unregister browser FCM token on logout or permission revocation
    @DeleteMapping("/fcm-token")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Void> unregisterFcmToken (@RequestParam String fcmToken) {
        notificationService.unregisterFcmToken(fcmToken);
        return ResponseEntity.noContent().build();
    }
}