package org.example.cafeteria_ordering_backend.dto.requests;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class FCMTokenRequestDTO {

    @NotBlank(message = "FCM token cannot be blank")
    private String fcmToken;

    private String deviceType = "WEB_PWA";
}