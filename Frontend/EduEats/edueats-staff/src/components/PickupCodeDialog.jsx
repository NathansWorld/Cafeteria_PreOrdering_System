// src/components/PickupCodeDialog.jsx
// NEW: before an order is marked Collected, staff type the customer's
// 4-character pickup code (the end of the order number, e.g. XZUR in
// ORD-10-26-XZUR). The customer shows it on their phone ("Show at counter").
// The backend checks it (providedSuffix) so the food goes to the right person.

import { useEffect, useRef, useState } from "react";
import "./ConfirmDialog.css";
import "./PickupCodeDialog.css";

const CODE_LENGTH = 4;
const clean = (value) => value.replace(/[^a-z0-9]/gi, "").toUpperCase().slice(0, CODE_LENGTH);

function PickupCodeDialog({ order, onSubmit, onCancel }) {
  const [code, setCode] = useState("");
  const [error, setError] = useState("");
  const [checking, setChecking] = useState(false);
  const inputRef = useRef(null);

  // Typing straight away, Escape closes, the page behind can't scroll
  useEffect(() => {
    inputRef.current?.focus();
    const onKey = (event) => {
      if (event.key === "Escape") onCancel();
    };
    window.addEventListener("keydown", onKey);
    document.body.style.overflow = "hidden";
    return () => {
      window.removeEventListener("keydown", onKey);
      document.body.style.overflow = "";
    };
  }, [onCancel]);

  const submit = async (event) => {
    event.preventDefault();
    if (code.length !== CODE_LENGTH) {
      setError(`Enter all ${CODE_LENGTH} characters of the pickup code.`);
      return;
    }
    setChecking(true);
    setError("");
    const problem = await onSubmit(code); // "" when it worked
    setChecking(false);
    if (problem) {
      setError(problem);
      setCode("");
      inputRef.current?.focus();
    }
  };

  return (
    <div className="confirm-overlay pickup-overlay" onClick={onCancel}>
      <form
        className="confirm-box"
        role="dialog"
        aria-modal="true"
        aria-labelledby="pickup-title"
        onClick={(event) => event.stopPropagation()}
        onSubmit={submit}
        noValidate
      >
        <div className="confirm-icon" aria-hidden="true">
          ✓
        </div>
        <h2 id="pickup-title">Hand over {order.id}?</h2>
        <p>
          Ask <strong>{order.customer}</strong> for the 4-character pickup code on their phone
          (the end of the order number).
        </p>

        <label className="pickup-label" htmlFor="pickup-code">
          Pickup code
        </label>
        <input
          id="pickup-code"
          ref={inputRef}
          className="pickup-input"
          value={code}
          onChange={(event) => {
            setCode(clean(event.target.value));
            setError("");
          }}
          inputMode="text"
          autoComplete="off"
          autoCapitalize="characters"
          spellCheck={false}
          placeholder="····"
          aria-invalid={Boolean(error)}
          aria-describedby={error ? "pickup-error" : undefined}
        />
        {error && (
          <p id="pickup-error" className="pickup-error" role="alert">
            {error}
          </p>
        )}

        <div className="confirm-actions">
          <button type="button" className="confirm-cancel" onClick={onCancel} disabled={checking}>
            Cancel
          </button>
          <button type="submit" className="confirm-ok" disabled={checking}>
            {checking ? "Checking…" : "Collected"}
          </button>
        </div>
      </form>
    </div>
  );
}

export default PickupCodeDialog;
