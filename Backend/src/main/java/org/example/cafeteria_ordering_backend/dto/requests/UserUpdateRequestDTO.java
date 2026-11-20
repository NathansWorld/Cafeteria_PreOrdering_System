
package org.example.cafeteria_ordering_backend.dto.requests;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Contains the details required to update an existing user account.
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserUpdateRequestDTO {

    // Stores an optional first name containing valid characters.
    @Size(max = 255, message = "First name must not exceed 255 characters")
    @Pattern(
            regexp = "^[\\p{L}][\\p{L} '\\-]*$",
            message = "First name contains invalid characters"
    )
    private String firstName;

    // Stores an optional last name containing valid characters.
    @Size(max = 255, message = "Last name must not exceed 255 characters")
    @Pattern(
            regexp = "^[\\p{L}][\\p{L} '\\-]*$",
            message = "Last name contains invalid characters"
    )
    private String lastName;

    // Stores an optional email address with a maximum length of 255 characters.
    @Email(message = "Invalid email format")
    @Size(max = 255, message = "Email must not exceed 255 characters")
    private String email;

    // Stores an optional phone number with a maximum length of 20 characters.
    @Pattern(
            regexp = "^\\+?[0-9()\\- ]*$",
            message = "Phone number contains invalid characters"
    )
    @Size(max = 20, message = "Phone number must not exceed 20 characters")
    private String phoneNumber;

    // Requires the current password to save account changes.
    @NotBlank(message = "Current password is required to save changes")
    @Size(min = 8, max = 100, message = "Password must be between 8 and 100 characters")
    private String currentPassword;

    // Stores an optional new password.
    @Size(min = 8, max = 100, message = "Password must be between 8 and 100 characters")
    private String newPassword;
}
