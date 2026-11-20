// src/useMenuUpdates.js
// NEW: live menu changes. The backend sends a message to /topic/menu/updates
// after an admin creates, edits or deletes a category, item or option
// (e.g. { action: "UPDATE", entityType: "CATEGORY", payload }).
// We don't need the details: onChange() just reloads the menu.
// The regular 10-second check still runs as a backup.

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

function useMenuUpdates(enabled, onChange) {
  const onChangeRef = useRef(onChange);
  useEffect(() => {
    onChangeRef.current = onChange;
  }, [onChange]);

  useEffect(() => {
    if (!enabled) return undefined;

    let timer = null;
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
        client.subscribe("/topic/menu/updates", () => {
          // several changes at once (e.g. a category and its items): reload once
          clearTimeout(timer);
          timer = setTimeout(() => onChangeRef.current?.(), 300);
        });
      },
    });

    client.activate();
    return () => {
      clearTimeout(timer);
      client.deactivate();
    };
  }, [enabled]);
}

export default useMenuUpdates;
