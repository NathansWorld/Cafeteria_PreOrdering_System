// src/useSwipeDismiss.js
// NEW: swipe a message sideways to close it (phones and mouse).
// Returns { offset, handlers }: spread handlers on the element and move it by offset px.

import { useRef, useState } from "react";

const SWIPE_DISTANCE = 80; // px needed to close

export default function useSwipeDismiss(onDismiss) {
  const [offset, setOffset] = useState(0);
  const startX = useRef(null);

  const handlers = {
    onPointerDown: (event) => {
      if (event.target.closest("button")) return; // buttons still work normally
      startX.current = event.clientX;
      event.currentTarget.setPointerCapture?.(event.pointerId);
    },
    onPointerMove: (event) => {
      if (startX.current === null) return;
      setOffset(event.clientX - startX.current);
    },
    onPointerUp: () => {
      if (startX.current === null) return;
      startX.current = null;
      if (Math.abs(offset) > SWIPE_DISTANCE) onDismiss();
      else setOffset(0);
    },
    onPointerCancel: () => {
      startX.current = null;
      setOffset(0);
    },
  };

  return { offset, handlers };
}
