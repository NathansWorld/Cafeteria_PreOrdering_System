package org.example.cafeteria_ordering_backend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification {

    // Primary key, generated automatically by the database.
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notification_id")
    private Long notificationId;

    // ID of the user receiving the notification.
    @Column(name = "user_id", nullable = false)
    private Long userId;

    // ID of the associated order.
    @Column(name = "order_id", nullable = false)
    private Long orderId;

    // Type classification of the notification (e.g., ORDER_UPDATE).
    @Column(name = "type", nullable = false, length = 50)
    private String type;

    // Short title summarizing the notification.
    @Column(name = "title", nullable = false, length = 50)
    private String title;

    // Detailed message body of the notification.
    @Column(name = "message", nullable = false, columnDefinition = "TEXT")
    private String message;

    // Communication channel used (e.g., IN_APP, WEBSOCKET).
    @Column(name = "channel", length = 50)
    private String channel;

    // Delivery status tracking (e.g., SENT, PENDING).
    @Column(name = "delivery_status", length = 50)
    private String deliveryStatus;

    // Indicates whether the user has read the notification.
    @Column(name = "is_read", nullable = false)
    @Builder.Default
    private boolean isRead = false;

    // Timestamp recording when the notification was marked as read.
    @Column(name = "read_at")
    private LocalDateTime readAt;

    // Timestamp recording when the notification was dispatched.
    @Column(name = "sent_at")
    private LocalDateTime sentAt;

    // Timestamp recording when the notification record was created.
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    // Sets creation and dispatch timestamps before the entity is first saved.
    @PrePersist
    protected void onCreate () {
        createdAt = LocalDateTime.now();
        if (sentAt == null) {
            sentAt = LocalDateTime.now();
        }
    }
}