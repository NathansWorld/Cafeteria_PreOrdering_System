package org.example.cafeteria_ordering_backend.component;

import org.example.cafeteria_ordering_backend.exception.ResourceUnavailableException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneId;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class OperatingHoursValidatorTest {

    // Defining operating hours
    private static final String DEFAULT_OPEN = "08:00";
    private static final String DEFAULT_CLOSE = "17:30";

    // Helper to create a fixed clock at a specific HH:mm (2026-10-09)
    private Clock fixedClockAt (String timeString) {

        return Clock.fixed(Instant.parse("2026-10-09T" + timeString + ":00Z"), ZoneId.of("UTC"));
    }

    // Validation group of operations in valid operating hours
    @Nested
    @DisplayName("Scheduled Hours Validation (08:00 - 17:30)")
    class ScheduledHoursTests {

        // Verifying cafeteria is indeed open/ closed in given csv source
        @ParameterizedTest(name = "Time {0} -> isOpen() should return {1}")
        @CsvSource({
                "12:00, true",
                "08:00, true",
                "17:30, false",
                "07:59, false",
                "18:00, false"
        })
        void isOpen_ScheduledHoursValidation (String time, boolean expected) {

            // Setup validator to allow testing
            OperatingHoursValidator validator = new OperatingHoursValidator(
                    DEFAULT_OPEN, DEFAULT_CLOSE, fixedClockAt(time));

            assertThat(validator.isOpen()).isEqualTo(expected);
        }

        // Customers should not be allowed to place order when closed
        @Test
        @DisplayName("validateOpenForOrders should throw ResourceUnavailableException when closed")
        void validateOpenForOrders_WhenClosed_ThrowsException () {

            OperatingHoursValidator validator = new OperatingHoursValidator(
                    DEFAULT_OPEN, DEFAULT_CLOSE, fixedClockAt("20:00"));

            assertThatThrownBy(validator::validateOpenForOrders)
                    .isInstanceOf(ResourceUnavailableException.class)
                    .hasMessageContaining("Cannot place order: The cafeteria is closed");
        }
    }

    // Test admin overrides on force open/closed
    @Nested
    @DisplayName("Admin Override Operations")
    class AdminOverrideTests {

        // Ensure force open overrides normal timing
        @Test
        @DisplayName("Should return true when force open is active, even after hours")
        void isOpen_WhenForceOpen_ReturnsTrue () {

            OperatingHoursValidator validator = new OperatingHoursValidator(DEFAULT_OPEN, DEFAULT_CLOSE, fixedClockAt("22:00"));
            validator.setForceOpen(true);

            assertThat(validator.isOpen()).isTrue();
            assertThat(validator.isOverridden()).isTrue();
        }

        // Ensure force close functions
        @Test
        @DisplayName("Should return false when force closed is active, even during operating hours (e.g., 12:00)")
        void isOpen_WhenForceClosed_ReturnsFalse () {

            OperatingHoursValidator validator = new OperatingHoursValidator(
                    DEFAULT_OPEN, DEFAULT_CLOSE, fixedClockAt("12:00"));

            validator.setForceOpen(false);

            assertThat(validator.isOpen()).isFalse();
            assertThat(validator.isOverridden()).isTrue();
        }

        // Ensure resetting override functions correctly
        @Test
        @DisplayName("Should revert to normal schedule when reset")
        void resetToScheduledHours_RestoresDefaultBehavior () {

            OperatingHoursValidator validator = new OperatingHoursValidator(
                    DEFAULT_OPEN, DEFAULT_CLOSE, fixedClockAt("22:00"));

            validator.setForceOpen(true);
            assertThat(validator.isOpen()).isTrue();

            validator.resetToScheduledHours();
            assertThat(validator.isOverridden()).isFalse();
            assertThat(validator.isOpen()).isFalse();
        }
    }

    // Test operations over through midnight
    @Nested
    @DisplayName("Overnight Crossover Operating Hours (e.g., 22:00 - 04:00)")
    class OvernightHoursTests {

        @ParameterizedTest(name = "Shift {0}-{1} at {2} -> isOpen() should return {3}")
        @CsvSource({
                "22:00, 04:00, 23:00, true",
                "22:00, 04:00, 02:00, true",
                "22:00, 04:00, 12:00, false"
        })
        void isOpen_OvernightShift (String open, String close, String time, boolean expected) {

            OperatingHoursValidator validator = new OperatingHoursValidator(open, close, fixedClockAt(time));

            assertThat(validator.isOpen()).isEqualTo(expected);
        }
    }
}