package org.example.cafeteria_ordering_backend.service;

import org.example.cafeteria_ordering_backend.entity.Notification;
import org.example.cafeteria_ordering_backend.entity.Order;
import org.example.cafeteria_ordering_backend.entity.User;
import org.example.cafeteria_ordering_backend.event.WebSocketMessageEvent;
import org.example.cafeteria_ordering_backend.exception.ResourceNotFoundException;
import org.example.cafeteria_ordering_backend.mapper.NotificationMapper;
import org.example.cafeteria_ordering_backend.repository.NotificationRepository;
import org.example.cafeteria_ordering_backend.repository.UserDeviceRepository;
import org.example.cafeteria_ordering_backend.repository.UserRepository;
import org.example.cafeteria_ordering_backend.service.implementation.FirebaseMessagingServiceImpl;
import org.example.cafeteria_ordering_backend.service.implementation.NotificationServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class NotificationServiceImplTest {

    @Mock private NotificationRepository notificationRepository;
    @Mock private NotificationMapper notificationMapper;
    @Mock private ApplicationEventPublisher eventPublisher;
    @Mock private UserDeviceRepository userDeviceRepository;
    @Mock private UserRepository userRepository;
    @Mock private FirebaseMessagingServiceImpl firebaseMessagingService;

    @InjectMocks
    private NotificationServiceImpl notificationService;

    private Notification sampleNotification;
    private Order sampleOrder;

    @BeforeEach
    void setUp() {
        User sampleUser = new User();
        sampleUser.setUserId(5L);

        sampleOrder = new Order();
        sampleOrder.setOrderId(10L);
        sampleOrder.setUser(sampleUser);

        sampleNotification = Notification.builder()
                .notificationId(1L)
                .userId(5L)
                .orderId(10L)
                .type("ORDER_PLACED")
                .title("Order Placed")
                .message("Your order has been placed.")
                .channel("IN_APP")
                .isRead(false)
                .build();
    }

    @Test
    @DisplayName("Should successfully create order notification and publish WebSocket event")
    void createNotificationForOrder_Success () {

        when(notificationMapper.toOrderNotification(sampleOrder, "ORDER_PLACED", "Title", "Message"))
                .thenReturn(sampleNotification);
        when(notificationRepository.save(any(Notification.class))).thenReturn(sampleNotification);

        Notification result = notificationService.createNotificationForOrder(sampleOrder, "ORDER_PLACED", "Title", "Message");

        assertThat(result).isNotNull();
        assertThat(result.getNotificationId()).isEqualTo(1L);

        verify(notificationRepository).save(sampleNotification);

        // Verify WebSocket event broadcast to user topic
        ArgumentCaptor<WebSocketMessageEvent<?>> eventCaptor = ArgumentCaptor.forClass(WebSocketMessageEvent.class);
        verify(eventPublisher).publishEvent(eventCaptor.capture());
        assertThat(eventCaptor.getValue().getDestination()).isEqualTo("/topic/user/5/notifications");
        assertThat(eventCaptor.getValue().getAction()).isEqualTo("CREATE");
    }

    @Test
    @DisplayName("Should successfully create user notification and publish WebSocket event")
    void createUserNotification_Success () {

        when(notificationMapper.toUserNotification(5L, "SYSTEM", "Title", "Message", "IN_APP"))
                .thenReturn(sampleNotification);
        when(notificationRepository.save(any(Notification.class))).thenReturn(sampleNotification);

        Notification result = notificationService.createUserNotification(5L, 10L, "SYSTEM", "Title", "Message", "IN_APP");

        assertThat(result).isNotNull();
        verify(notificationRepository).save(sampleNotification);

        ArgumentCaptor<WebSocketMessageEvent<?>> eventCaptor = ArgumentCaptor.forClass(WebSocketMessageEvent.class);
        verify(eventPublisher).publishEvent(eventCaptor.capture());
        assertThat(eventCaptor.getValue().getDestination()).isEqualTo("/topic/user/5/notifications");
    }

    @Test
    @DisplayName("Should retrieve notifications for user ordered by creation date")
    void getNotificationsForUser_Success () {

        when(notificationRepository.findByUserIdOrderByCreatedAtDesc(5L)).thenReturn(List.of(sampleNotification));

        List<Notification> results = notificationService.getNotificationsForUser(5L);

        assertThat(results).hasSize(1);
        verify(notificationRepository).findByUserIdOrderByCreatedAtDesc(5L);
        verifyNoInteractions(eventPublisher);
    }

    @Test
    @DisplayName("Should mark notification as read and publish update event")
    void markNotificationAsRead_Success () {

        when(notificationRepository.findById(1L)).thenReturn(Optional.of(sampleNotification));
        when(notificationRepository.save(any(Notification.class))).thenReturn(sampleNotification);

        notificationService.markNotificationAsRead(1L, 5L);

        assertTrue(sampleNotification.isRead());
        assertNotNull(sampleNotification.getReadAt());
        verify(notificationRepository).save(sampleNotification);

        // Verify update broadcast over WebSocket
        ArgumentCaptor<WebSocketMessageEvent<?>> eventCaptor = ArgumentCaptor.forClass(WebSocketMessageEvent.class);
        verify(eventPublisher).publishEvent(eventCaptor.capture());
        assertThat(eventCaptor.getValue().getAction()).isEqualTo("UPDATE");
        assertThat(eventCaptor.getValue().getDestination()).isEqualTo("/topic/user/5/notifications");
    }

    @Test
    @DisplayName("Should throw ResourceNotFoundException and prevent action when user is unauthorized")
    void markNotificationAsRead_UnauthorizedUser_ThrowsException () {

        when(notificationRepository.findById(1L)).thenReturn(Optional.of(sampleNotification));

        // User ID 99 attempts to modify User ID 5's notification
        ResourceNotFoundException exception = assertThrows(
                ResourceNotFoundException.class,
                () -> notificationService.markNotificationAsRead(1L, 99L)
        );

        assertTrue(exception.getMessage().contains("Notification not found"));
        assertFalse(sampleNotification.isRead());
        verify(notificationRepository, never()).save(any(Notification.class));
        verify(eventPublisher, never()).publishEvent(any());
    }
}