// src/push.js
// NEW: real push notifications (FCM), so a student is told "Your order is
// ready!" even when EduEats is closed.
//
// How it works:
// 1. The student allows notifications (🔔 Notify me button).
// 2. We register /firebase-messaging-sw.js (a small background helper).
// 3. Firebase gives this device a token, which we send to the backend:
//    POST /api/notifications/fcm-token
// 4. The backend sends notifications to that token through Firebase.
// 5. On logout we remove it again: DELETE /api/notifications/fcm-token?fcmToken=...
//
// Browser rules: needs localhost or https (a Cloudflare tunnel works, plain
// http://192.168.x.x doesn't). iPhones only if EduEats is on the Home Screen.

import { apiFetch } from "./api";
import { getDeviceToken, removeDeviceToken } from "./firebase";

const SAVED_TOKEN_KEY = "fcmToken";
const WORKER_URL = "/firebase-messaging-sw.js";
// Its own scope, so it doesn't clash with the app's offline service worker
const WORKER_SCOPE = "/firebase-cloud-messaging-push-scope";

function pushPossible() {
  return (
    typeof window !== "undefined" &&
    window.isSecureContext &&
    "serviceWorker" in navigator &&
    "PushManager" in window &&
    "Notification" in window
  );
}

function savedToken() {
  try {
    return localStorage.getItem(SAVED_TOKEN_KEY) || "";
  } catch {
    return "";
  }
}

function saveToken(token) {
  try {
    if (token) localStorage.setItem(SAVED_TOKEN_KEY, token);
    else localStorage.removeItem(SAVED_TOKEN_KEY);
  } catch {
    // storage blocked
  }
}

// Waits until the background helper is running (Firebase needs it active)
function whenActive(registration) {
  if (registration.active) return Promise.resolve(registration);
  const worker = registration.installing || registration.waiting;
  return new Promise((resolve) => {
    if (!worker) {
      resolve(registration);
      return;
    }
    worker.addEventListener("statechange", () => {
      if (worker.state === "activated") resolve(registration);
    });
  });
}

let enabling = null;

// Call when logged in and notifications are allowed. Safe to call often.
export function enablePush() {
  if (!pushPossible() || Notification.permission !== "granted") return Promise.resolve(false);
  if (enabling) return enabling;

  enabling = (async () => {
    try {
      const registration = await whenActive(
        await navigator.serviceWorker.register(WORKER_URL, { scope: WORKER_SCOPE })
      );
      const token = await getDeviceToken(registration);
      if (!token) return false;

      // Tell the backend which device to send to (every login, in case the
      // backend lost it or another student used this phone before)
      const response = await apiFetch("/api/notifications/fcm-token", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ fcmToken: token, deviceType: "WEB_PWA" }),
      });

      if (!response.ok) {
        const text = await response.text().catch(() => "");
        console.warn(`Could not save the push token (${response.status})`, text);
        return false;
      }

      saveToken(token);
      return true;
    } catch (error) {
      console.warn("Push notifications could not be turned on:", error);
      return false;
    } finally {
      enabling = null;
    }
  })();

  return enabling;
}

// Call BEFORE the login is cleared, so the backend stops sending to this device
export async function disablePush() {
  const token = savedToken();
  if (!token) return;
  saveToken("");
  try {
    await apiFetch(`/api/notifications/fcm-token?fcmToken=${encodeURIComponent(token)}`, {
      method: "DELETE",
    });
  } catch {
    // offline - the backend will drop the token when sending fails
  }
  removeDeviceToken();
}
