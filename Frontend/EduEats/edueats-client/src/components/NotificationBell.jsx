// src/components/NotificationBell.jsx
// NEW: 🔔 bell in the top bar with the number of unread notifications.
// Tapping it opens a list of all the student's notifications (newest first),
// so nothing is lost when several arrive at once. Tapping one marks it read
// and opens My Orders when it's about an order.

import { useEffect, useRef, useState, useSyncExternalStore } from "react";
import "./NotificationBell.css";
import {
  getNotifications,
  markAllNotificationsRead,
  markNotificationRead,
  notificationsLoaded,
  refreshNotifications,
  subscribeNotifications,
} from "../notificationsStore";

const timeAgo = (value) => {
  if (!value) return "";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "";
  const minutes = Math.round((Date.now() - date.getTime()) / 60000);
  if (minutes < 1) return "just now";
  if (minutes < 60) return `${minutes} min ago`;
  const hours = Math.round(minutes / 60);
  if (hours < 24) return `${hours} h ago`;
  return date.toLocaleDateString(undefined, { day: "numeric", month: "short" });
};

const iconFor = (item) => {
  const text = `${item.type} ${item.title} ${item.message}`.toLowerCase();
  if (/ready/.test(text)) return "✅";
  if (/cancel/.test(text)) return "❌";
  if (/refund/.test(text)) return "💸";
  if (/paid|payment/.test(text)) return "💳";
  if (/prepar|progress|accept/.test(text)) return "👩‍🍳";
  return "🔔";
};

function NotificationBell({ onNavigate }) {
  const items = useSyncExternalStore(subscribeNotifications, getNotifications);
  const loaded = useSyncExternalStore(subscribeNotifications, notificationsLoaded);
  const [open, setOpen] = useState(false);
  const boxRef = useRef(null);
  const unread = items.filter((item) => !item.read).length;

  // Close when tapping outside or pressing Escape
  useEffect(() => {
    if (!open) return undefined;
    const onDown = (event) => {
      if (boxRef.current && !boxRef.current.contains(event.target)) setOpen(false);
    };
    const onKey = (event) => {
      if (event.key === "Escape") setOpen(false);
    };
    document.addEventListener("pointerdown", onDown);
    window.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("pointerdown", onDown);
      window.removeEventListener("keydown", onKey);
    };
  }, [open]);

  const toggle = () => {
    if (!open) refreshNotifications(true);
    setOpen((value) => !value);
  };

  const openItem = (item) => {
    markNotificationRead(item.id);
    setOpen(false);
    if (onNavigate && (item.orderId || /order/i.test(`${item.title} ${item.message}`))) {
      onNavigate("orders");
    }
  };

  return (
    <div className="notify-bell" ref={boxRef}>
      <button
        type="button"
        className="notify-bell-button"
        onClick={toggle}
        aria-label={unread > 0 ? `Notifications, ${unread} unread` : "Notifications"}
        aria-expanded={open}
      >
        <span aria-hidden="true">🔔</span>
        {unread > 0 && (
          <em key={unread} className="notify-bell-count">
            {unread > 9 ? "9+" : unread}
          </em>
        )}
      </button>

      {open && (
        <div className="notify-panel" role="dialog" aria-label="Notifications">
          <div className="notify-panel-head">
            <strong>Notifications</strong>
            {unread > 0 && (
              <button type="button" onClick={markAllNotificationsRead}>
                Mark all as read
              </button>
            )}
          </div>

          <div className="notify-panel-list">
            {!loaded && <p className="notify-panel-empty">Loading…</p>}
            {loaded && items.length === 0 && (
              <p className="notify-panel-empty">No notifications yet. We'll let you know when your order changes.</p>
            )}
            {items.map((item) => (
              <button
                type="button"
                key={item.id}
                className={`notify-item ${item.read ? "" : "unread"}`}
                onClick={() => openItem(item)}
              >
                <span className="notify-item-icon" aria-hidden="true">{iconFor(item)}</span>
                <span className="notify-item-text">
                  {item.title && <strong>{item.title}</strong>}
                  {item.message && <span>{item.message}</span>}
                  <small>{timeAgo(item.createdAt)}</small>
                </span>
                {!item.read && <span className="notify-item-dot" aria-label="Unread" />}
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

export default NotificationBell;
