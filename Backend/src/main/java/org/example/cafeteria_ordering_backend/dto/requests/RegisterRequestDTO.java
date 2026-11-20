
package org.example.cafeteria_ordering_backend.dto.requests;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

// Represents the personal details provided when registering a user.
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RegisterRequestDTO {

    // Requires a first name with valid characters and a maximum length of 255.
    @NotBlank(message = "First name is required")
    @Size(max = 255, message = "First name must not exceed 255 characters")
    @Pattern(
            regexp = "^[\\p{L}][\\p{L} '\\-]*$",
            message = "First name contains invalid characters"
    )
    private String firstName;

    // Requires a last name with valid characters and a maximum length of 255.
    @NotBlank(message = "Last name is required")
    @Size(max = 255, message = "Last name must not exceed 255 characters")
    @Pattern(
            regexp = "^[\\p{L}][\\p{L} '\\-]*$",
            message = "Last name contains invalid characters"
    )
    private String lastName;

    // Requires a valid email address with a maximum length of 255 characters.
    @NotBlank(message = "Email is required")
    @Email(message = "Please provide a valid email address")
    @Size(max = 255, message = "Email must not exceed 255 characters")
    private String email;

    // Requires a password containing at least one uppercase letter, number and symbol.
    @NotBlank(message = "Password is required")
    @Size(min = 8, max = 100, message = "Password must be between 8 and 100 characters")
    @Pattern(
            regexp = "^(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&_\\-+#=]).*$",
            message = "Password must contain at least 1 capital letter, 1 number, and 1 symbol"
    )
    private String password;
}
