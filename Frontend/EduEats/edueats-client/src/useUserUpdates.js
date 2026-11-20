// src/useUserUpdates.js
// NEW: personal live messages for the logged-in user on /topic/user/{userId}:
//   { type: "NOTIFICATION", payload: Notification }     - a new notification
//   { type: "USER_STATUS",  payload: UserResponseDTO }  - account suspended / reactivated
// onMessage({ type, payload, title, message }) is called for each one.

import { useEffect, useRef } from "react";
import { Client } from "@stomp/stompjs";
import { API_BASE_URL, getFreshToken } from "./api";

function getSocketUrl() {
  if (API_BASE_URL) {
    return `${API_BASE_URL.replace(/^http/, "ws")}/ws-orders`;
  }
  const protocol = window.location.protocol === "https:" ? "wss" : "ws";
  return `${protocol}://${window.location.host}/ws-orders`;
}

// The message type can be in type, eventType, action or entityType
export function messageType(data) {
  return String(data?.type || data?.eventType || data?.entityType || data?.action || "").toUpperCase();
}

// Is this user status message saying the account is suspended?
export function isSuspendedStatus(data) {
  const user = data?.payload || data?.data || data || {};
  if (user.active === false || user.isActive === false || user.enabled === false) return true;
  return /suspend/i.test(String(user.status || user.accountStatus || data?.message || ""));
}

function useUserUpdates(userId, onMessage) {
  const onMessageRef = useRef(onMessage);
  useEffect(() => {
    onMessageRef.current = onMessage;
  }, [onMessage]);

  useEffect(() => {
    if (!userId) return undefined;

    const client = new Client({
      brokerURL: getSocketUrl(),
      reconnectDelay: 5000,
      heartbeatIncoming: 10000,
      heartbeatOutgoing: 10000,
      debug: () => {},
      beforeConnect: async () => {
        const token = await getFreshToken();
        client.connectHeaders = token ? { Authorization: `Bearer ${token}` } : {};
      },
      onConnect: () => {
        client.subscribe(`/topic/user/${userId}`, (message) => {
          try {
            onMessageRef.current?.(JSON.parse(message.body));
          } catch {
            // not JSON - ignore
          }
        });
      },
    });

    client.activate();
    return () => {
      client.deactivate();
    };
  }, [userId]);
}

export default useUserUpdates;
