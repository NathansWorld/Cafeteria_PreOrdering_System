// src/newOrderSound.js
// A short two-tone "ding" when a new order arrives, made with the
// browser's Web Audio API (no sound file needed).
// Browsers only allow sound after the user has clicked on the page once;
// signing in counts, so this works on the board.

const SOUND_KEY = "staffSoundOn";

export function isSoundOn() {
  try {
    return localStorage.getItem(SOUND_KEY) !== "false";
  } catch {
    return true;
  }
}

export function saveSoundOn(on) {
  try {
    localStorage.setItem(SOUND_KEY, on ? "true" : "false");
  } catch {
    // not saved - the setting resets after a refresh
  }
}

let audioContext = null;

// FIX: when the app opens already logged in (e.g. the admin's saved login),
// nobody has clicked yet, so the browser keeps the sound blocked.
// The first click or key press anywhere (Admin Panel too) unlocks it.
export function unlockSoundOnFirstTap() {
  const unlock = () => {
    try {
      const AudioContextClass = window.AudioContext || window.webkitAudioContext;
      if (!AudioContextClass) return;
      audioContext = audioContext || new AudioContextClass();
      if (audioContext.state === "suspended") audioContext.resume();
    } catch {
      // no sound available
    }
    if (audioContext && audioContext.state !== "suspended") stop();
  };
  const stop = () => {
    window.removeEventListener("pointerdown", unlock);
    window.removeEventListener("keydown", unlock);
  };
  window.addEventListener("pointerdown", unlock);
  window.addEventListener("keydown", unlock);
  return stop;
}

export function playNewOrderSound() {
  try {
    const AudioContextClass = window.AudioContext || window.webkitAudioContext;
    if (!AudioContextClass) return;
    audioContext = audioContext || new AudioContextClass();
    if (audioContext.state === "suspended") audioContext.resume();

    const start = audioContext.currentTime;
    [880, 1320].forEach((frequency, index) => {
      const oscillator = audioContext.createOscillator();
      const gain = audioContext.createGain();
      const at = start + index * 0.18;

      oscillator.type = "sine";
      oscillator.frequency.value = frequency;
      gain.gain.setValueAtTime(0.0001, at);
      gain.gain.exponentialRampToValueAtTime(0.25, at + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.0001, at + 0.3);

      oscillator.connect(gain).connect(audioContext.destination);
      oscillator.start(at);
      oscillator.stop(at + 0.32);
    });
  } catch {
    // no sound available - the card highlight still shows the new order
  }
}
