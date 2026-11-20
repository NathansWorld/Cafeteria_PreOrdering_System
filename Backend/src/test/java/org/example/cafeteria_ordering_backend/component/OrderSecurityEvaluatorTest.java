package org.example.cafeteria_ordering_backend.component;

import org.example.cafeteria_ordering_backend.entity.User;
import org.example.cafeteria_ordering_backend.exception.ResourceUnavailableException;
import org.example.cafeteria_ordering_backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class OrderSecurityEvaluatorTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private SecurityContext securityContext;

    @Mock
    private Authentication authentication;

    @InjectMocks
    private OrderSecurityEvaluator securityEvaluator;

    // Initialize test data before each test
    @BeforeEach
    void setUp () {SecurityContextHolder.setContext(securityContext);
    }

    // Helper method configures simulated authenticated user
    private void mockAuthenticatedUser (String email) {

        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.isAuthenticated()).thenReturn(true);
        when(authentication.getName()).thenReturn(email);
    }

    // Ensures getCurrentUser() returns correct user, when users email matches repo record
    @Test
    @DisplayName("getCurrentUser returns user when authenticated")
    void testGetCurrentUserSuccess () {

        mockAuthenticatedUser("student@eduvos.com");

        User mockUser = new User();
        mockUser.setUserId(100L);
        mockUser.setEmail("student@eduvos.com");

        when(userRepository.findByEmail("student@eduvos.com")).thenReturn(Optional.of(mockUser));

        User result = securityEvaluator.getCurrentUser();

        assertThat(result).isNotNull();
        assertThat(result.getUserId()).isEqualTo(100L);
    }

    // Verifies users with staff/admin role are recognized as sufficiently privileged
    @ParameterizedTest
    @ValueSource(strings = {"ROLE_STAFF", "ROLE_ADMIN"})
    @DisplayName("isStaffOrAdmin returns true for ROLE_STAFF or ROLE_ADMIN")
    void testIsStaffOrAdminTrue (String role) {

        when(securityContext.getAuthentication()).thenReturn(authentication);
        doReturn(List.of(new SimpleGrantedAuthority(role))).when(authentication).getAuthorities();

        assertThat(securityEvaluator.isStaffOrAdmin()).isTrue();
    }

    // Ensures cust can access their own data
    @Test
    @DisplayName("validateUserAccess allows customer accessing their own data")
    void testValidateUserAccessOwnDataSuccess () {

        mockAuthenticatedUser("student@eduvos.com");
        doReturn(List.of(new SimpleGrantedAuthority("ROLE_CUSTOMER"))).when(authentication).getAuthorities();

        User mockUser = new User();
        mockUser.setUserId(5L);

        when(userRepository.findByEmail("student@eduvos.com")).thenReturn(Optional.of(mockUser));

        assertThatCode(() -> securityEvaluator.validateUserAccess(5L)).doesNotThrowAnyException();
    }

    // Checks cust cannot access another users data
    @Test
    @DisplayName("validateUserAccess throws ResourceUnavailableException when customer accesses another user's data")
    void testValidateUserAccessOtherDataDenied () {

        mockAuthenticatedUser("student@eduvos.com");
        doReturn(List.of(new SimpleGrantedAuthority("ROLE_CUSTOMER")))
                .when(authentication).getAuthorities();

        User mockUser = new User();
        mockUser.setUserId(5L);

        when(userRepository.findByEmail("student@eduvos.com")).thenReturn(Optional.of(mockUser));

        assertThatThrownBy(() -> securityEvaluator.validateUserAccess(99L))
                .isInstanceOf(ResourceUnavailableException.class);
    }
}