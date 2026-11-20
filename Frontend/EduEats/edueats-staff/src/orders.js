// src/orders.js
// Turns the backend's orders into what the staff board shows,
// plus small time helpers.

// The four board columns, in order
export const STATUSES = ["New", "In Progress", "Ready", "Completed"];

// Backend status -> board column (cancelled orders sit under Completed)
const COLUMN_FOR_STATUS = {
  submitted: "New",
  accepted: "New",
  preparing: "In Progress",
  ready: "Ready",
  collected: "Completed",
  completed: "Completed",
  cancelled: "Completed",
};

// The backend cancels orders that stay "Submitted" this long
// (app.orders.expiration-timeout-minutes in application.properties)
export const AUTO_CANCEL_MINUTES = 15;

// Manual orders store the walk-in customer's name at the start of the
// first item's note, e.g. "Walk in for Thabo !! no onions".
// CHANGED: the backend only allows letters, spaces and . , ! & in notes,
// so the old "Walk-in: Thabo | no onions" format was rejected.
export const WALK_IN_PREFIX = "Walk in for ";
const WALK_IN_SEPARATOR = " !! ";
// Older orders were saved in this format - still read them
const OLD_WALK_IN_PREFIX = "Walk-in: ";
const OLD_WALK_IN_SEPARATOR = " | ";

// NEW: removes anything the backend's note rule doesn't allow
// (numbers, - ' ? : | etc.) so a manual order is never rejected.
export function safeNoteText(text) {
  return String(text || "")
    .replace(/[^a-zA-Z\s.,!&]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

export function walkInNote(customerName, note) {
  const name = safeNoteText(customerName);
  const rest = safeNoteText(note);
  if (!name) return rest;
  return rest ? `${WALK_IN_PREFIX}${name}${WALK_IN_SEPARATOR}${rest}` : `${WALK_IN_PREFIX}${name}`;
}

function splitWalkIn(note, prefix, separator) {
  const rest = note.slice(prefix.length);
  const split = rest.indexOf(separator);
  return split === -1
    ? { name: rest, note: "" }
    : { name: rest.slice(0, split), note: rest.slice(split + separator.length) };
}

function readWalkIn(note) {
  if (!note) return { name: "", note: "" };
  if (note.startsWith(WALK_IN_PREFIX)) return splitWalkIn(note, WALK_IN_PREFIX, WALK_IN_SEPARATOR);
  if (note.startsWith(OLD_WALK_IN_PREFIX)) {
    return splitWalkIn(note, OLD_WALK_IN_PREFIX, OLD_WALK_IN_SEPARATOR);
  }
  return { name: "", note };
}

// FIX: live messages come in different shapes:
//   a plain order                                   { orderId, status, ... }
//   the auto-cancel                                 { eventType, message, payload }
//   the new post-commit events (WebSocketMessageEvent) { action, entityType, payload }
// Returns the order inside, or null if it isn't an order.
export function unwrapLiveOrder(message) {
  if (!message || typeof message !== "object") return null;
  if (message.orderId) return message;
  const inner = message.payload ?? message.data ?? message.body ?? message.order;
  if (inner && typeof inner === "object" && inner.orderId) {
    return { ...inner, status: inner.status || inner.statusName };
  }
  return null;
}

export function toBoardOrder(order) {
  // status is sometimes sent as statusName (e.g. in live messages)
  const statusKey = String(order.status || order.statusName || "Submitted").trim().toLowerCase();
  let walkInName = "";

  const lines = (order.items || []).map((item, index) => {
    let note = item.specialInstructions || "";
    if (index === 0) {
      const walkIn = readWalkIn(note);
      walkInName = walkIn.name;
      note = walkIn.note;
    }
    return {
      quantity: item.quantity,
      name: item.menuItemName,
      extras: item.selectedModifiers || [],
      note,
    };
  });

  const customer = walkInName || order.customerName || `Order #${order.orderId}`;
  const id = order.customerOrderNumber || `#${order.orderId}`;

  // NEW (PayFast): card orders come in as PENDING until PayFast confirms the
  // payment. Unpaid (PENDING) or failed card orders stay off the board, so staff
  // only make food that has been paid for. Counter orders have no payment status.
  const paymentStatus = String(order.paymentStatus || "").trim().toUpperCase();
  const unpaidCard = paymentStatus === "PENDING" || paymentStatus === "FAILED";

  return {
    id,
    backendId: order.orderId,
    backendStatus: order.status || order.statusName || "Submitted",
    statusKey,
    status: unpaidCard ? undefined : COLUMN_FOR_STATUS[statusKey],
    cancelled: statusKey.includes("cancel"),
    paymentStatus,
    customer,
    userId: order.userId ?? order.user?.userId ?? order.customerId ?? null,
    walkIn: Boolean(walkInName),
    lines,
    // Everything the search box looks through
    searchText: [
      id,
      customer,
      ...lines.map((line) => `${line.name} ${line.extras.join(" ")} ${line.note}`),
    ]
      .join(" ")
      .toLowerCase(),
    total: Number(order.totalPrice ?? 0),
    createdAt: order.createdAt,
  };
}

// Short summary of the items, e.g. for the list view
export const itemsSummary = (order) =>
  order.lines
    .map((line) => {
      const extras = [...line.extras, line.note ? `"${line.note}"` : ""].filter(Boolean);
      return `${line.quantity}x ${line.name}${extras.length ? ` (${extras.join(", ")})` : ""}`;
    })
    .join(", ");

export function minutesSince(dateValue, now) {
  const time = new Date(dateValue).getTime();
  return Number.isNaN(time) ? 0 : Math.max(0, Math.floor((now - time) / 60000));
}

export function timeAgo(dateValue, now) {
  if (!dateValue) return "";
  const minutes = minutesSince(dateValue, now);

  if (minutes < 1) return "just now";
  if (minutes < 60) return `${minutes}m ago`;

  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;

  return `${Math.floor(hours / 24)}d ago`;
}

// "12:04" for today, "14 Oct 12:04" for older orders
export function clockTime(dateValue, now) {
  const date = new Date(dateValue);
  if (Number.isNaN(date.getTime())) return "";
  const time = date.toLocaleTimeString("en-ZA", { hour: "2-digit", minute: "2-digit" });
  return isToday(dateValue, now)
    ? time
    : `${date.toLocaleDateString("en-ZA", { day: "numeric", month: "short" })} ${time}`;
}

export function isToday(dateValue, now = Date.now()) {
  if (!dateValue) return false;
  const date = new Date(dateValue);
  if (Number.isNaN(date.getTime())) return false;
  const today = new Date(now);
  return (
    date.getFullYear() === today.getFullYear() &&
    date.getMonth() === today.getMonth() &&
    date.getDate() === today.getDate()
  );
}

export const formatPrice = (price) => `R${Number(price || 0).toFixed(2)}`;

// NEW (PayFast): paid online by card, and the money hasn't been given back yet
export function isPaidByCard(order) {
  return order.paymentStatus === "PAID";
}

export function isRefunded(order) {
  return order.paymentStatus === "REFUNDED";
}
