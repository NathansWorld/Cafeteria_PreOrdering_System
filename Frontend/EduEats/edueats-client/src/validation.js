// src/validation.js
// Shared rules for the login and register forms.
// Each function returns an error message, or "" if the value is fine.

export const LIMITS = {
  nameMax: 50,
  emailMax: 100,
  passwordMin: 8,
  passwordMax: 64,
};

// Letters (including accented ones like é), spaces, hyphens and
// apostrophes only, so "Mary-Jane" and "O'Neil" are allowed,
// but numbers and symbols like { } [ ] " are not.
const NAME_PATTERN = /^[A-Za-zÀ-ÖØ-öø-ÿ]+([ '-][A-Za-zÀ-ÖØ-öø-ÿ]+)*$/;

// A normal email: letters, numbers and . _ % + - before the @,
// a domain after it, and no characters like { } [ ] " < > or spaces.
const EMAIL_PATTERN = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;

export function validateName(value, label) {
  const name = value.trim();

  if (!name) return `${label} is required.`;
  if (name.length > LIMITS.nameMax) {
    return `${label} can be at most ${LIMITS.nameMax} characters.`;
  }
  if (!NAME_PATTERN.test(name)) {
    return `${label} can only contain letters, spaces, - and '.`;
  }
  return "";
}

export function validateEmail(value) {
  const email = value.trim();

  if (!email) return "Email address is required.";
  if (email.length > LIMITS.emailMax) {
    return `Email can be at most ${LIMITS.emailMax} characters.`;
  }
  if (!EMAIL_PATTERN.test(email)) {
    return "Please enter a valid email address (no spaces or symbols like { } [ ] \").";
  }
  return "";
}

// CHANGED: same rules as the backend (8+ characters, a capital letter,
// a number and a symbol). Used for new passwords, not for logging in,
// so older passwords still work on the login page.
export const PASSWORD_RULES = [
  { key: "length", label: `At least ${LIMITS.passwordMin} characters`, test: (v) => v.length >= LIMITS.passwordMin },
  { key: "capital", label: "A capital letter (A–Z)", test: (v) => /[A-Z]/.test(v) },
  { key: "number", label: "A number (0–9)", test: (v) => /[0-9]/.test(v) },
  { key: "symbol", label: "A symbol, e.g. ! @ # ?", test: (v) => /[^A-Za-z0-9\s]/.test(v) },
];

export function validatePassword(value) {
  if (!value) return "Password is required.";
  if (value.length > LIMITS.passwordMax) {
    return `Password can be at most ${LIMITS.passwordMax} characters.`;
  }
  if (value.length < LIMITS.passwordMin) {
    return `Password must be at least ${LIMITS.passwordMin} characters.`;
  }
  if (PASSWORD_RULES.some((rule) => !rule.test(value))) {
    return "Password must contain at least 1 capital letter, 1 number and 1 symbol.";
  }
  return "";
}
// NEW (item 9): symbols that are never needed in a kitchen note or a search
// and could be used to inject code: < > { } [ ] \ ` $ |
// They are simply left out as the student types.
const UNSAFE_CHARACTERS = /[<>{}[\]\\`$|]/g;

export const cleanText = (value) => String(value ?? "").replace(UNSAFE_CHARACTERS, "");

// Names: letters (also é, ü ...), spaces, hyphen and apostrophe only
export const cleanName = (value) => String(value ?? "").replace(/[^A-Za-zÀ-ÖØ-öø-ÿ \x27-]/g, "");

// Email: letters, numbers and . _ % + - @ only (no spaces or other symbols)
export const cleanEmail = (value) => String(value ?? "").replace(/[^A-Za-z0-9._%+@-]/g, "");

// Phone: numbers, + and spaces only
export const cleanPhone = (value) => String(value ?? "").replace(/[^0-9+ ]/g, "");

// Whole numbers (stock, position, min/max): digits only
export const cleanWholeNumber = (value) => String(value ?? "").replace(/\D/g, "");

// Prices: digits and one decimal point, at most 2 decimals (e.g. 35.50)
export function cleanPrice(value) {
  const digits = String(value ?? "").replace(/[^0-9.]/g, "");
  const [whole, ...rest] = digits.split(".");
  return rest.length ? `${whole}.${rest.join("").slice(0, 2)}` : whole;
}

// NEW: kitchen notes - must match the backend's rule exactly
// (OrderRequestDTO: ^[a-zA-Z\\s.,!&]*$): letters, spaces and , . ! & only.
// Anything else is listed so the student knows what to remove.
export const NOTE_ALLOWED_TEXT = "letters, spaces and , . ! &";
const NOTE_NOT_ALLOWED = /[^A-Za-z\s.,!&]/g;

export function noteProblem(value) {
  const found = String(value ?? "").match(NOTE_NOT_ALLOWED) || [];
  if (!found.length) return "";
  // digits are shown once as "numbers", other characters as themselves
  const shown = [...new Set(found.map((ch) => (/\d/.test(ch) ? "numbers" : ch)))].join(" ");
  return `Not allowed: ${shown}  (notes can only use ${NOTE_ALLOWED_TEXT})`;
}
