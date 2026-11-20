// src/components/NotifyPrompt.jsx
// "🔔 Notify me when it's ready" button. Only shows when the browser
// supports notifications and the student hasn't answered the question yet.

import { useState } from "react";
import "./NotifyPrompt.css";
import { askNotificationPermission, notificationPermission } from "../readyNotifications";
import { enablePush } from "../push";

function NotifyPrompt() {
  const [permission, setPermission] = useState(notificationPermission);

  if (permission === "granted") {
    return <p className="notify-prompt-done">🔔 We'll notify you when your order is ready, even if EduEats is closed.</p>;
  }

  // Not supported here, or the student said no: don't nag
  if (permission !== "default") return null;

  return (
    <button
      type="button"
      className="notify-prompt"
      onClick={async () => {
        const answer = await askNotificationPermission();
        setPermission(answer);
        // NEW: also notify when EduEats is closed (push through Firebase)
        if (answer === "granted") enablePush();
      }}
    >
      🔔 Notify me when it's ready
    </button>
  );
}

export default NotifyPrompt;
