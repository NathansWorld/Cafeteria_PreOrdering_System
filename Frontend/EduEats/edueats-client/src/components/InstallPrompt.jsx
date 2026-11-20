// src/components/InstallPrompt.jsx
// NEW (item 12): after logging in, offers to install EduEats as an app
// (home screen / taskbar) if it isn't installed yet. "Not now" hides it
// until the next login.

import { useEffect, useState } from "react";
import "./InstallPrompt.css";
import {
  canInstall,
  installApp,
  isInstalledApp,
  isIPhoneSafari,
  onInstallChange,
} from "../installPrompt";

const HIDDEN_KEY = "installPromptHidden";

function readHidden() {
  try {
    return sessionStorage.getItem(HIDDEN_KEY) === "true";
  } catch {
    return false;
  }
}

function InstallPrompt() {
  const [available, setAvailable] = useState(canInstall);
  const [hidden, setHidden] = useState(readHidden);

  useEffect(() => onInstallChange(() => setAvailable(canInstall())), []);

  const hide = () => {
    setHidden(true);
    try {
      sessionStorage.setItem(HIDDEN_KEY, "true");
    } catch {
      // shows again after a refresh
    }
  };

  if (hidden || isInstalledApp()) return null;
  const iPhone = isIPhoneSafari();
  if (!available && !iPhone) return null;

  return (
    <div className="install-prompt" role="dialog" aria-label="Install EduEats">
      <div className="install-prompt-icon" aria-hidden="true">E</div>
      <div className="install-prompt-text">
        <strong>Get the EduEats app</strong>
        <span>
          {iPhone && !available
            ? "Tap Share, then “Add to Home Screen” to order in one tap."
            : "Install it on your phone or laptop to order in one tap and get updates."}
        </span>
      </div>
      <div className="install-prompt-buttons">
        {available && (
          <button
            type="button"
            className="install-prompt-yes"
            onClick={async () => {
              await installApp();
              hide();
            }}
          >
            Install
          </button>
        )}
        <button type="button" className="install-prompt-no" onClick={hide}>
          {available ? "Not now" : "OK"}
        </button>
      </div>
    </div>
  );
}

export default InstallPrompt;
