// src/useCafeteriaStatus.js
// Asks the backend whether the cafeteria is open (GET /api/cafeteria-status)
// and whether the app can reach the server. Checks again every minute,
// CHANGED: every 10 seconds while the server can't be reached, so the
// "Offline" banner appears and disappears quickly.

import { useEffect, useState } from "react";
import { apiFetch } from "./api";

// CHANGED: every 30 seconds (was 10) - the backend now limits how many
// requests one device can make (rate limiting), and opening the app or
// coming back to it still checks straight away
const CHECK_EVERY_MS = 30000;
const CHECK_OFFLINE_MS = 10000;

// "17:30:00" -> "17:30"
const shortTime = (value) => (value ? String(value).slice(0, 5) : "");

export default function useCafeteriaStatus() {
  const [status, setStatus] = useState({
    loaded: false,
    connected: true,
    isOpen: null,
    isOverridden: false,
    openingTime: "",
    closingTime: "",
  });

  useEffect(() => {
    let cancelled = false;
    let reachable = true; // last result, decides how soon to check again
    let timer = null;

    const check = async () => {
      try {
        const response = await apiFetch("/api/cafeteria-status");

        // The server answered, so we ARE connected - we just don't know
        // the opening hours (e.g. 404 if the backend hasn't been restarted)
        reachable = true;

        if (!response.ok) {
          console.warn("Cafeteria status returned", response.status);
          if (!cancelled) {
            setStatus((current) => ({
              ...current,
              loaded: true,
              connected: true,
              isOpen: null,
            }));
          }
          return;
        }

        const data = await response.json();

        if (!cancelled) {
          setStatus({
            loaded: true,
            connected: true,
            isOpen: Boolean(data.isOpen),
            // NEW: true when an admin opened/closed it by hand
            isOverridden: Boolean(data.isOverridden),
            openingTime: shortTime(data.openingTime),
            closingTime: shortTime(data.closingTime),
          });
        }
      } catch (error) {
        // fetch only throws when the server can't be reached at all
        console.error("Cafeteria status error:", error);
        reachable = false;

        if (!cancelled) {
          setStatus((current) => ({
            ...current,
            loaded: true,
            connected: false,
          }));
        }
      }
    };

    // Check, then plan the next check (sooner while offline)
    const loop = async () => {
      if (document.visibilityState === "visible") await check();
      if (!cancelled) timer = setTimeout(loop, reachable ? CHECK_EVERY_MS : CHECK_OFFLINE_MS);
    };
    loop();

    window.addEventListener("online", check);
    window.addEventListener("offline", check);
    window.addEventListener("focus", check);
    const onVisible = () => {
      if (document.visibilityState === "visible") check();
    };
    document.addEventListener("visibilitychange", onVisible);

    return () => {
      cancelled = true;
      clearTimeout(timer);
      window.removeEventListener("online", check);
      window.removeEventListener("offline", check);
      window.removeEventListener("focus", check);
      document.removeEventListener("visibilitychange", onVisible);
    };
  }, []);

  return status;
}