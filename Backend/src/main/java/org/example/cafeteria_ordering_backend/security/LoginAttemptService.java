
package org.example.cafeteria_ordering_backend.security;

import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class LoginAttemptService {

    private static final int MAX_ATTEMPTS = 5;
    private static final Duration COOLDOWN_PERIOD = Duration.ofMinutes(15);

    // Stores failed login attempts for each email address.
    private final ConcurrentHashMap<String, LoginAttempt> attempts =
            new ConcurrentHashMap<>();

    // Checks whether an account is currently locked.
    public boolean isBlocked(String email) {

        LoginAttempt attempt = attempts.get(email.toLowerCase());

        if (attempt == null || attempt.lockedUntil == null) {
            return false;
        }

        // Checks whether the cooldown period has expired.
        if (Instant.now().isAfter(attempt.lockedUntil)) {
            attempts.remove(email.toLowerCase(), attempt);
            return false;
        }

        return true;
    }

    // Records an unsuccessful login attempt.
    public void loginFailed(String email) {

        String key = email.toLowerCase();

        attempts.compute(key, (ignored, attempt) -> {

            if (attempt == null) {
                attempt = new LoginAttempt();
            }

            attempt.failedAttempts++;

            // Locks the account after five unsuccessful attempts.
            if (attempt.failedAttempts >= MAX_ATTEMPTS) {
                attempt.lockedUntil = Instant.now().plus(COOLDOWN_PERIOD);
            }

            return attempt;
        });
    }

    // Resets failed attempts after a successful login.
    public void loginSucceeded(String email) {
        attempts.remove(email.toLowerCase());
    }

    // Returns the remaining cooldown time in seconds.
    public long getRemainingCooldown(String email) {

        LoginAttempt attempt = attempts.get(email.toLowerCase());

        if (attempt == null || attempt.lockedUntil == null) {
            return 0;
        }

        long remaining = Duration.between(
                Instant.now(), attempt.lockedUntil
        ).getSeconds();

        return Math.max(0, remaining);
    }

    // Holds the failed attempt count and account lockout expiry.
    private static class LoginAttempt {
        private int failedAttempts = 0;
        private Instant lockedUntil;
    }
}
