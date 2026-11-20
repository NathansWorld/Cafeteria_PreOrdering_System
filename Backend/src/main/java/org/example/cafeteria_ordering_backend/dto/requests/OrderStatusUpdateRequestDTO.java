package org.example.cafeteria_ordering_backend.dto.requests;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.*;

// Represents a request to update an order's status.
@Data
@NoArgsConstructor
public class OrderStatusUpdateRequestDTO {

    // Requires a valid status name with a maximum length of 50 characters.
    @NotBlank(message = "Status name is required")
    @Size(max = 50, message = "Status name must not exceed 50 characters")
    @Pattern(
            regexp = "^[a-zA-Z_]+$",
            message = "Status name may only contain letters and underscores"
    )
    private String statusName;

    // Optional for general status changes, but required in the service layer when collecting an order.
    // Stores the last 4 digits of the customer's order number.
    @Size(max = 4, message = "Must provide the last 4 digits of the customer order number")
    @Pattern(
            regexp = "^[A-Za-z0-9]{4}$",
            message = "Order number suffix must contain exactly 4 digits"
    )
    private String providedSuffix;

    // Constructor for general status updates.
    public OrderStatusUpdateRequestDTO(String statusName) {
        this.statusName = statusName;
        this.providedSuffix = null;
    }

    // Constructor for status updates requiring a pickup suffix.
    public OrderStatusUpdateRequestDTO(String statusName, String providedSuffix) {
        this.statusName = statusName;
        this.providedSuffix = providedSuffix;
    }
}
