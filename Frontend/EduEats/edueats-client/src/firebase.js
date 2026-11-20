// src/firebase.js
// Firebase Cloud Messaging (FCM) setup for push notifications.
// The settings come from the .env file (VITE_FIREBASE_...), never from Git.
//
// CHANGED: Firebase is only started when it's actually needed, and only on
// browsers that support web push. On an unsupported browser (e.g. iPhone
// Safari when EduEats isn't installed, or http://192.168.x.x) the rest of the
// app keeps working normally - there just are no push notifications.

import { initializeApp } from "firebase/app";
import { getMessaging, getToken, deleteToken, isSupported } from "firebase/messaging";

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
};

const VAPID_KEY = import.meta.env.VITE_FIREBASE_VAPID_KEY;

let messagingPromise = null;

// The Firebase messaging object, or null when push isn't possible here
export function getFirebaseMessaging() {
  if (!messagingPromise) {
    messagingPromise = (async () => {
      try {
        if (!firebaseConfig.apiKey || !VAPID_KEY) {
          console.warn("Push notifications are off: the VITE_FIREBASE_ settings are missing from .env");
          return null;
        }
        if (!(await isSupported())) return null;
        return getMessaging(initializeApp(firebaseConfig));
      } catch (error) {
        console.warn("Push notifications aren't available here:", error);
        return null;
      }
    })();
  }
  return messagingPromise;
}

// Gets this device's FCM token, using our own background helper (service worker)
export async function getDeviceToken(serviceWorkerRegistration) {
  const messaging = await getFirebaseMessaging();
  if (!messaging) return null;
  return getToken(messaging, { vapidKey: VAPID_KEY, serviceWorkerRegistration });
}

// Stops push for this device (used when logging out)
export async function removeDeviceToken() {
  const messaging = await getFirebaseMessaging();
  if (!messaging) return;
  try {
    await deleteToken(messaging);
  } catch {
    // already removed
  }
}
