import { useEffect, useRef, useState } from "react";
import "./Login.css";
import {
  API_BASE_URL,
  SERVER_ERROR_MESSAGE,
  SERVER_UNREACHABLE_MESSAGE,
  isServerDownStatus,
} from "../../api";
import PasswordInput from "../../components/PasswordInput";
import { LIMITS, validateEmail, cleanEmail } from "../../validation";

// NEW: shown when an admin has suspended the account
const SUSPENDED_MESSAGE =
  "Your account has been suspended. Please speak to the cafeteria or campus admin.";

// NEW: the backend's error text ({ message } or { error }), or "" if none
async function readErrorMessage(response) {
  try {
    const data = await response.clone().json();
    return `${data?.message || ""} ${data?.error || ""}`.trim();
  } catch {
    return "";
  }
}

// NEW: after 5 wrong passwords the backend pauses sign-in for that account
// for 15 minutes. We remember until when (per email, on this device) so the
// page can show a countdown and stop the student from trying again too early.
const LOCK_MINUTES = 15;
const LOCK_STORAGE_KEY = "loginLocks";

function loadLocks() {
  try {
    const saved = JSON.parse(localStorage.getItem(LOCK_STORAGE_KEY) || "{}");
    return saved && typeof saved === "object" ? saved : {};
  } catch {
    return {};
  }
}

function saveLocks(locks) {
  try {
    localStorage.setItem(LOCK_STORAGE_KEY, JSON.stringify(locks));
  } catch {
    // storage blocked: the countdown just won't survive a refresh
  }
}

const lockKey = (value) => value.trim().toLowerCase();

// Is this reply the "too many attempts" lock?
function isLockedReply(status, reason) {
  return (
    status === 423 ||
    status === 429 ||
    /lock|too many|temporarily|cool\s?down|try again (later|in)/i.test(reason)
  );
}

// "Try again in 12 minutes" -> 12 (falls back to 15)
function minutesFrom(reason) {
  const match = reason.match(/(\d+)\s*(?:min|minute)/i);
  return match ? Number(match[1]) : LOCK_MINUTES;
}

// "3 attempts remaining" / "remaining attempts: 3" -> 3 (or null if not sent)
function attemptsLeftFrom(reason) {
  const match =
    reason.match(/(\d+)\s*(?:more\s*)?(?:attempts?|tries)\s*(?:left|remaining)/i) ||
    reason.match(/remaining\s*(?:attempts?)?\s*[:=]?\s*(\d+)/i);
  return match ? Number(match[1]) : null;
}

const formatCountdown = (ms) => {
  const totalSeconds = Math.max(0, Math.ceil(ms / 1000));
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = String(totalSeconds % 60).padStart(2, "0");
  return `${minutes}:${seconds}`;
};

class LockedError extends Error {}

function Login({ onGoToRegister, onLoginSuccess }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [emailHint, setEmailHint] = useState(""); // NEW: "{ can't be used in an email"
  const emailHintTimer = useRef(null);
  const [loading, setLoading] = useState(false);

  // NEW: login lock countdown
  const [locks, setLocks] = useState(loadLocks);
  const [now, setNow] = useState(() => Date.now());
  const lockedUntil = locks[lockKey(email)] || 0;
  const lockRemaining = lockedUntil - now;
  const isLocked = lockRemaining > 0;

  // tick every second while this email is locked
  useEffect(() => {
    if (!isLocked) return undefined;
    const timer = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(timer);
  }, [isLocked]);

  const lockAccount = (minutes) => {
    const until = Date.now() + minutes * 60 * 1000;
    const next = { ...loadLocks(), [lockKey(email)]: until };
    saveLocks(next);
    setLocks(next);
    setNow(Date.now());
  };

  // NEW: shows the "contact admin" note when "Forgot password?" is clicked
  const [showForgotHelp, setShowForgotHelp] = useState(false);

  const handleSubmit = async (event) => {
    event.preventDefault();

    setError("");

    // NEW: still locked on this device - don't send another attempt
    if (isLocked) return;

    // NEW: check the email before sending anything to the backend
    const emailError = validateEmail(email);

    if (emailError) {
      setError(emailError);
      return;
    }

    if (password.length > LIMITS.passwordMax) {
      setError(`Password can be at most ${LIMITS.passwordMax} characters.`);
      return;
    }

    setLoading(true);

    try {
      // 1. Log the user in
      // CHANGED: credentials: "include" lets the browser save the
      // refresh-token cookie, which keeps the student logged in
      let loginResponse;

      try {
        loginResponse = await fetch(`${API_BASE_URL}/api/auth/login`, {
          method: "POST",
          credentials: "include",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            email: email.trim(),
            password,
          }),
        });
      } catch {
        // No answer at all: no internet, or the server is off
        throw new Error(SERVER_UNREACHABLE_MESSAGE);
      }

      // CHANGED: only say "invalid email or password" when that's really the problem
      if (isServerDownStatus(loginResponse.status)) {
        throw new Error(SERVER_UNREACHABLE_MESSAGE);
      }

      if (loginResponse.status >= 500) {
        throw new Error(SERVER_ERROR_MESSAGE);
      }

      // NEW: suspended accounts get a clear message (backend sends 400 or 403
      // with "User account has been suspended.")
      if (!loginResponse.ok) {
        const reason = await readErrorMessage(loginResponse);

        if (/suspend|inactive|disabled/i.test(reason)) {
          throw new Error(SUSPENDED_MESSAGE);
        }

        // NEW: 5 wrong passwords -> sign-in paused for 15 minutes
        if (isLockedReply(loginResponse.status, reason)) {
          lockAccount(minutesFrom(reason));
          throw new LockedError("locked");
        }

        // NEW: warn the student before they get locked out
        const attemptsLeft = attemptsLeftFrom(reason);
        if (loginResponse.status === 401 && attemptsLeft !== null) {
          throw new Error(
            attemptsLeft > 0
              ? `Invalid email or password. ${attemptsLeft} ${
                  attemptsLeft === 1 ? "attempt" : "attempts"
                } left before sign-in is paused for ${LOCK_MINUTES} minutes.`
              : "Invalid email or password."
          );
        }
      }

      // 403 = correct password, but a staff/admin account (they use the staff app)
      if (loginResponse.status === 403) {
        throw new Error("This is a staff account. Please sign in on the staff app instead.");
      }

      if (!loginResponse.ok) {
        throw new Error("Invalid email or password.");
      }

      const loginData = await loginResponse.json();
      const token = loginData.token;

      if (!token) {
        throw new Error("No authentication token was returned.");
      }

      // 2. Store JWT token
      localStorage.setItem("token", token);

      // 3. Retrieve the logged-in user's profile
      let profileResponse;

      try {
        profileResponse = await fetch(`${API_BASE_URL}/api/auth/me`, {
          method: "GET",
          credentials: "include",
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });
      } catch {
        throw new Error(SERVER_UNREACHABLE_MESSAGE);
      }

      if (isServerDownStatus(profileResponse.status)) {
        throw new Error(SERVER_UNREACHABLE_MESSAGE);
      }

      if (!profileResponse.ok) {
        throw new Error("Could not retrieve your user profile.");
      }

      const user = await profileResponse.json();

      // 4. Store user information
      localStorage.setItem("user", JSON.stringify(user));

      // 5. Tell App.jsx that login succeeded
      if (onLoginSuccess) {
        onLoginSuccess(user, token);
      }
    } catch (error) {
      localStorage.removeItem("token");
      localStorage.removeItem("user");

      // the lock has its own box below, so no red error as well
      if (error instanceof LockedError) return;

      console.error("Login error:", error);
      setError(error.message || "Login failed. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-page">
      <div className="login-card">
        {/* CHANGED: brand row with "E" logo tile, matching the staff app */}
        <div className="auth-brand">
          <div className="auth-logo">E</div>

          <div className="auth-brand-text">
            <strong>EduEats</strong>
            <span>Campus Cafeteria Ordering</span>
          </div>
        </div>

        <h2 className="auth-title">Welcome Back</h2>

        <p className="auth-subtitle">
          Sign in to order your favourite meals.
        </p>

        {/* CHANGED: error message uses a CSS class instead of inline styles */}
        {/* NEW: sign-in paused after too many wrong passwords */}
        {isLocked ? (
          <div className="auth-locked" role="alert">
            <span className="auth-locked-icon" aria-hidden="true">🔒</span>
            <div>
              <strong>Too many sign-in attempts</strong>
              <p>
                For your security, sign-in for this account is paused. Please try
                again in <b>{formatCountdown(lockRemaining)}</b>.
              </p>
              <p className="auth-locked-help">
                Forgot your password? Speak to the cafeteria admin to reset it.
              </p>
            </div>
          </div>
        ) : (
          error && <p className="auth-error">{error}</p>
        )}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="email">Email Address</label>

            <input
              id="email"
              type="email"
              placeholder="Enter your email"
              value={email}
              maxLength={LIMITS.emailMax}
              autoComplete="email"
              onChange={(event) => {
                // NEW: say which character was left out instead of silently ignoring it
                const typed = event.target.value;
                const cleaned = cleanEmail(typed);
                const removed = [...new Set(typed.replace(/[A-Za-z0-9._%+@-]/g, ""))];
                if (removed.length) {
                  setEmailHint(
                    `${removed.map((ch) => (ch === " " ? "Spaces" : `"${ch}"`)).join(", ")} can't be used in an email address.`
                  );
                  clearTimeout(emailHintTimer.current);
                  emailHintTimer.current = setTimeout(() => setEmailHint(""), 4000);
                }
                setEmail(cleaned);
              }}
              required
            />

            {emailHint && (
              <p className="field-hint" role="status">
                {emailHint}
              </p>
            )}
          </div>

          <div className="form-group">
            <div className="label-row">
              <label htmlFor="password">Password</label>

              {/* NEW: forgot password link */}
              <a
                href="#"
                className="forgot-link"
                onClick={(event) => {
                  event.preventDefault();
                  setShowForgotHelp((current) => !current);
                }}
              >
                Forgot password?
              </a>
            </div>

            {/* NEW: our own Show / Hide button */}
            <PasswordInput
              id="password"
              placeholder="Enter your password"
              value={password}
              maxLength={LIMITS.passwordMax}
              onChange={(event) => setPassword(event.target.value)}
            />
          </div>

          {showForgotHelp && (
            <p className="auth-info">
              Please contact the cafeteria admin to reset your password.
            </p>
          )}

          <button
            type="submit"
            className="auth-button"
            disabled={loading || isLocked}
          >
            {loading
              ? "Signing In..."
              : isLocked
                ? `Try again in ${formatCountdown(lockRemaining)}`
                : "Sign In"}
          </button>
        </form>

        <p className="auth-switch">
          Don't have an account?{" "}
          <a
            href="#"
            onClick={(event) => {
              event.preventDefault();

              if (onGoToRegister) {
                onGoToRegister();
              }
            }}
          >
            Create an account
          </a>
        </p>
      </div>
    </div>
  );
}

export default Login;
