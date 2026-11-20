
package org.example.cafeteria_ordering_backend.dto.requests;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// Contains the details required to create a new user account.
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserCreateRequestDTO {

    // Requires a first name containing valid characters, with a maximum length of 255.
    @NotBlank(message = "First name is required")
    @Size(max = 255, message = "First name must not exceed 255 characters")
    @Pattern(
            regexp = "^[\\p{L}][\\p{L} '\\-]*$",
            message = "First name contains invalid characters"
    )
    private String firstName;

    // Requires a last name containing valid characters, with a maximum length of 255.
    @NotBlank(message = "Last name is required")
    @Size(max = 255, message = "Last name must not exceed 255 characters")
    @Pattern(
            regexp = "^[\\p{L}][\\p{L} '\\-]*$",
            message = "Last name contains invalid characters"
    )
    private String lastName;

    // Requires a valid email address with a maximum length of 255 characters.
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    @Size(max = 255, message = "Email must not exceed 255 characters")
    private String email;

    // Requires a password between 8 and 100 characters.
    @NotBlank(message = "Password is required")
    @Size(min = 8, max = 100, message = "Password must be between 8 and 100 characters")
    private String passwordHash;

    // Stores an optional phone number with a maximum length of 20 characters.
    @Size(max = 20, message = "Phone number must not exceed 20 characters")
    @Pattern(
            regexp = "^[0-9+()\\- ]*$",
            message = "Phone number contains invalid characters"
    )
    private String phoneNumber;

    // Stores an optional customer code with a maximum length of 255 characters.
    @Size(max = 255, message = "Customer code must not exceed 255 characters")
    @Pattern(
            regexp = "^[a-zA-Z0-9]*$",
            message = "Customer code may only contain letters and numbers"
    )
    private String customerCode;
}
