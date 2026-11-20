import { useCallback, useEffect, useState } from "react";
import "./CafeteriaStatusCard.css";
import { apiFetch } from "../api";
import { readError } from "./adminData";
import ConfirmDialog from "../components/ConfirmDialog";

// NEW: lets an ADMIN open or close the cafeteria by hand
// (e.g. keep it open for the IT showcase after 17:30), then go back to the normal hours.
// Uses Chaz's endpoints:
//   GET  /api/cafeteria-status                -> { isOpen, isOverridden, overrideState, openingTime, closingTime }
//   POST /api/cafeteria-status/force-open
//   POST /api/cafeteria-status/force-close
//   POST /api/cafeteria-status/reset-schedule

const ACTIONS = {
  open: { path: "force-open", done: "The cafeteria is now open. Students can place orders." },
  close: { path: "force-close", done: "The cafeteria is now closed. Students can't place new orders." },
  reset: { path: "reset-schedule", done: "Back to the normal opening hours." },
};

// "08:00:00" -> "08:00"
const shortTime = (time) => (time ? String(time).slice(0, 5) : "--:--");

function describeOverride(status) {
  if (!status.isOverridden) return "Following the normal hours";
  return status.isOpen ? "Opened by an admin (ignores the hours)" : "Closed by an admin (ignores the hours)";
}

function CafeteriaStatusCard() {
  const [status, setStatus] = useState(null);
  const [loadError, setLoadError] = useState("");
  const [busy, setBusy] = useState("");
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [confirmClose, setConfirmClose] = useState(false);

  const loadStatus = useCallback(async () => {
    try {
      const response = await apiFetch("/api/cafeteria-status");
      if (!response.ok) throw new Error(await readError(response, "Could not load the cafeteria status"));
      setStatus(await response.json());
      setLoadError("");
    } catch (err) {
      setLoadError(err.message === "Failed to fetch" ? "Cannot reach the server." : err.message);
    }
  }, []);

  // Load now, then every 30 seconds (the schedule can open/close it by itself)
  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    loadStatus();
    const timer = setInterval(loadStatus, 30000);
    return () => clearInterval(timer);
  }, [loadStatus]);

  const run = async (key) => {
    setConfirmClose(false);
    setBusy(key);
    setError("");
    setNotice("");
    try {
      const response = await apiFetch(`/api/cafeteria-status/${ACTIONS[key].path}`, { method: "POST" });
      if (!response.ok) throw new Error(await readError(response, "Could not change the cafeteria status"));
      setNotice(ACTIONS[key].done);
      await loadStatus();
    } catch (err) {
      setError(err.message === "Failed to fetch" ? "Cannot reach the server." : err.message);
    } finally {
      setBusy("");
    }
  };

  const isOpen = status?.isOpen === true;
  const overridden = status?.isOverridden === true;

  return (
    <section className="cafe-status-card" aria-labelledby="cafe-status-title">
      <div className="cafe-status-main">
        <div>
          <span className="cafe-status-label" id="cafe-status-title">Cafeteria status</span>
          {status ? (
            <>
              <div className={`cafe-status-state ${isOpen ? "is-open" : "is-closed"}`}>
                <span className="cafe-status-dot" />
                {isOpen ? "Open" : "Closed"}
                {overridden && <span className="cafe-status-badge">Manual</span>}
              </div>
              <p className="cafe-status-detail">
                Normal hours {shortTime(status.openingTime)} – {shortTime(status.closingTime)} · {describeOverride(status)}
              </p>
            </>
          ) : (
            <p className="cafe-status-detail">{loadError || "Loading status..."}</p>
          )}
        </div>

        <div className="cafe-status-buttons">
          <button
            type="button"
            className="cafe-btn cafe-btn-open"
            onClick={() => run("open")}
            disabled={!status || !!busy || (overridden && isOpen)}
          >
            {busy === "open" ? "Opening..." : "Force Open"}
          </button>
          <button
            type="button"
            className="cafe-btn cafe-btn-close"
            onClick={() => setConfirmClose(true)}
            disabled={!status || !!busy || (overridden && !isOpen)}
          >
            {busy === "close" ? "Closing..." : "Force Close"}
          </button>
          <button
            type="button"
            className="cafe-btn"
            onClick={() => run("reset")}
            disabled={!status || !!busy || !overridden}
            title={overridden ? "" : "Already following the normal hours"}
          >
            {busy === "reset" ? "Saving..." : "Back to normal hours"}
          </button>
        </div>
      </div>

      {error && <p className="cafe-status-message cafe-status-error" role="alert">{error}</p>}
      {notice && <p className="cafe-status-message" role="status">{notice}</p>}

      {confirmClose && (
        <ConfirmDialog
          title="Close the cafeteria now?"
          message="Students won't be able to place new orders until you open it again or go back to the normal hours. Orders already placed are not affected."
          confirmLabel="Close cafeteria"
          cancelLabel="Cancel"
          danger
          onConfirm={() => run("close")}
          onCancel={() => setConfirmClose(false)}
        />
      )}
    </section>
  );
}

export default CafeteriaStatusCard;
