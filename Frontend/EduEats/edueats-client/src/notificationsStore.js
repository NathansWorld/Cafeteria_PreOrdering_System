// src/notificationsStore.js
// NEW: the student's notifications for the 🔔 bell (flyout list).
// Loaded from GET /api/notifications and refreshed whenever a live
// NOTIFICATION message arrives, so older ones stay in the list instead of
// only flashing past as a toast.

import { apiFetch } from "./api";

let items = [];
let loaded = false;
const listeners = new Set();

const emit = () => listeners.forEach((listener) => listener());

export function subscribeNotifications(listener) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

export const getNotifications = () => items;
export const notificationsLoaded = () => loaded;
export const unreadCount = () => items.filter((item) => !item.read).length;

// The backend sends the Notification entity - accept the likely field names
function normalise(raw) {
  return {
    id: raw.notificationId ?? raw.id,
    title: raw.title || "",
    message: raw.message || "",
    type: String(raw.type || ""),
    read: Boolean(raw.isRead ?? raw.read ?? false),
    createdAt: raw.createdAt || raw.sentAt || null,
    orderId: raw.orderId ?? raw.order?.orderId ?? null,
  };
}

let loading = null;
let lastLoad = 0;
const MIN_GAP_MS = 5000; // several live messages at once = one request

// force: the student opened the 🔔 list
export function refreshNotifications(force = false) {
  if (loading) return loading;
  if (!force && Date.now() - lastLoad < MIN_GAP_MS) {
    setTimeout(() => refreshNotifications(true), MIN_GAP_MS);
    return Promise.resolve();
  }
  lastLoad = Date.now();
  loading = (async () => {
    try {
      const response = await apiFetch("/api/notifications");
      if (!response.ok) return;
      const data = await response.json();
      const list = Array.isArray(data) ? data : data?.content || [];
      items = list
        .map(normalise)
        .filter((item) => item.id != null && (item.title || item.message))
        .sort((a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0));
      loaded = true;
      emit();
    } catch {
      // offline - keep the old list
    } finally {
      loading = null;
    }
  })();
  return loading;
}

export async function markNotificationRead(id) {
  const item = items.find((entry) => entry.id === id);
  if (!item || item.read) return;
  items = items.map((entry) => (entry.id === id ? { ...entry, read: true } : entry));
  emit();
  try {
    await apiFetch(`/api/notifications/${id}/read`, { method: "PATCH" });
  } catch {
    // marked again next time
  }
}

export async function markAllNotificationsRead() {
  const unread = items.filter((item) => !item.read);
  if (unread.length === 0) return;
  items = items.map((item) => ({ ...item, read: true }));
  emit();
  await Promise.allSettled(
    unread.map((item) => apiFetch(`/api/notifications/${item.id}/read`, { method: "PATCH" }))
  );
}

export function clearNotifications() {
  items = [];
  loaded = false;
  emit();
}
