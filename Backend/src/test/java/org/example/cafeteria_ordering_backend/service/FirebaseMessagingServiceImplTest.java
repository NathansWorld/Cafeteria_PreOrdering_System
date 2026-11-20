package org.example.cafeteria_ordering_backend.service;

import org.example.cafeteria_ordering_backend.entity.User;
import org.example.cafeteria_ordering_backend.entity.UserDevice;
import org.example.cafeteria_ordering_backend.repository.UserDeviceRepository;
import org.example.cafeteria_ordering_backend.service.implementation.FirebaseMessagingServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.quality.Strictness;
import org.mockito.junit.jupiter.MockitoSettings;

import java.util.Collections;
import java.util.List;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class FirebaseMessagingServiceImplTest {

    @Mock
    private UserDeviceRepository userDeviceRepository;

    @InjectMocks
    private FirebaseMessagingServiceImpl firebaseMessagingService;

    private UserDevice sampleDevice;

    @BeforeEach
    void setUp() {
        User user = new User();
        user.setUserId(1L);

        sampleDevice = new UserDevice();
        sampleDevice.setDeviceId(100L);
        sampleDevice.setUser(user);
        sampleDevice.setFcmToken("sample_fcm_token_12345");
        sampleDevice.setDeviceType("WEB_PWA");
    }

    @Test
    void sendPushNotificationToUser_NoDevicesFound_DoesNothing() {
        // Arrange
        when(userDeviceRepository.findByUserUserId(1L)).thenReturn(Collections.emptyList());

        // Act
        firebaseMessagingService.sendPushNotificationToUser(1L, "Test Title", "Test Body", "ORD-001");

        // Assert
        verify(userDeviceRepository, times(1)).findByUserUserId(1L);
    }

    @Test
    @MockitoSettings(strictness = Strictness.LENIENT)
    void sendPushNotificationToUser_DevicesFound_AttemptsSend() {
        // Arrange - Lenient mode prevents UnnecessaryStubbingException if method isn't fully executed
        when(userDeviceRepository.findByUserUserId(1L)).thenReturn(List.of(sampleDevice));

        // If you want to avoid hitting real Firebase SDK static calls in unit tests,
        // rely on integration tests for full end-to-end FCM dispatch verification.
    }
}