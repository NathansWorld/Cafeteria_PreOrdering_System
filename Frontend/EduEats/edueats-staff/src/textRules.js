// src/textRules.js
// NEW (item 9): symbols that are never needed in names, notes or searches
// and could be used to inject code: < > { } [ ] \ ` $ |
// ("|" is also used to separate the walk-in name from the note.)
// They are simply left out as the user types.

const UNSAFE_CHARACTERS = /[<>{}[\]\\`$|]/g;

export const cleanText = (value) => String(value ?? "").replace(UNSAFE_CHARACTERS, "");

export const SYMBOLS_HINT = "Symbols like < > { } [ ] are not allowed.";

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
