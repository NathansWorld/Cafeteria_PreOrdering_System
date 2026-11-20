// src/installPrompt.js
// NEW (item 12): remembers the browser's "install this app" offer so we can
// show our own pop-up after login. Chrome/Edge/Android send it as the
// "beforeinstallprompt" event (only on https or localhost). iPhones don't
// have it, so there we explain "Share -> Add to Home Screen" instead.

let deferredPrompt = null;
const listeners = new Set();

const notify = () => listeners.forEach((listener) => listener());

if (typeof window !== "undefined") {
  window.addEventListener("beforeinstallprompt", (event) => {
    event.preventDefault(); // we show our own pop-up instead
    deferredPrompt = event;
    notify();
  });
  window.addEventListener("appinstalled", () => {
    deferredPrompt = null;
    notify();
  });
}

// Already opened as the installed app?
export function isInstalledApp() {
  return (
    window.matchMedia?.("(display-mode: standalone)").matches ||
    window.navigator.standalone === true
  );
}

export function isIPhoneSafari() {
  const agent = window.navigator.userAgent || "";
  return /iphone|ipad|ipod/i.test(agent) && !/crios|fxios|edgios/i.test(agent);
}

export const canInstall = () => Boolean(deferredPrompt);

export function onInstallChange(listener) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

// Shows the browser's own install box. Returns true if the student accepted.
export async function installApp() {
  if (!deferredPrompt) return false;
  const prompt = deferredPrompt;
  deferredPrompt = null;
  prompt.prompt();
  try {
    const choice = await prompt.userChoice;
    notify();
    return choice?.outcome === "accepted";
  } catch {
    notify();
    return false;
  }
}
