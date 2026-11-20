package org.example.cafeteria_ordering_backend.dto.requests;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.cafeteria_ordering_backend.entity.PaymentMethod;
import java.util.List;

// Represents an order submitted by a user.
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderRequestDTO {

    // Identifies the user placing the order.
    @NotNull(message = "User ID is required")
    private Long userId;

    // Forces the client to explicitly supply a valid payment method
    @NotNull(message = "Payment method is required")
    private PaymentMethod paymentMethod;

    // Contains the menu items included in the order.
    @NotEmpty(message = "Order must contain at least one item")
    private List<@Valid OrderItemRequest> items;

    // Represents an individual item included in an order.
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OrderItemRequest {

        // Identifies the menu item being ordered.
        @NotNull(message = "Menu item ID is required")
        private Long menuItemId;

        // Specifies the number of units being ordered.
        @NotNull(message = "Quantity is required")
        @Min(value = 1, message = "Quantity must be at least 1")
        private Integer quantity;

        // Stores preparation instructions using permitted characters.
        @Size(max = 255, message = "Special instructions must not exceed 255 characters")
        @Pattern(
                regexp = "^[a-zA-Z\\s.,!&]*$",
                message = "Special instructions may only contain letters, spaces, full stops, commas, ! and &"
        )
        private String specialInstructions;

        // Contains the IDs of the modifiers selected for the item.
        private List<Long> modifierIds;
    }
}