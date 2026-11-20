// src/components/NotificationToasts.jsx
// NEW: notifications from the backend (/topic/user/{id}, type NOTIFICATION)
// shown on every page (Menu, Cart, My Orders, Profile). Each one closes by
// itself after a few seconds, with ×, or by swiping it sideways.

import { useEffect } from "react";
import "./NotificationToasts.css";
import useSwipeDismiss from "../useSwipeDismiss";

const SHOW_FOR_MS = 7000;

function Toast({ toast, onClose }) {
  const { offset, handlers } = useSwipeDismiss(() => onClose(toast.id));

  useEffect(() => {
    const timer = setTimeout(() => onClose(toast.id), SHOW_FOR_MS);
    return () => clearTimeout(timer);
  }, [toast.id, onClose]);

  return (
    <div
      className="notify-toast"
      role="status"
      style={{
        transform: `translateX(${offset}px)`,
        opacity: Math.max(0.2, 1 - Math.abs(offset) / 240),
      }}
      {...handlers}
    >
      <span className="notify-toast-icon" aria-hidden="true">🔔</span>
      <span className="notify-toast-text">
        {toast.title && <strong>{toast.title}</strong>}
        <span>{toast.message}</span>
      </span>
      <button type="button" className="notify-toast-close" onClick={() => onClose(toast.id)} aria-label="Close notification">
        ×
      </button>
    </div>
  );
}

function NotificationToasts({ toasts, onClose }) {
  if (toasts.length === 0) return null;
  return (
    <div className="notify-toasts">
      {toasts.map((toast) => (
        <Toast key={toast.id} toast={toast} onClose={onClose} />
      ))}
    </div>
  );
}

export default NotificationToasts;
