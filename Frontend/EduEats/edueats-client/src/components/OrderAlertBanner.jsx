// src/components/OrderAlertBanner.jsx
// Bar shown on the Menu, Cart and Profile pages when something happens to
// an order (My Orders has its own messages):
// - green: "Your order is ready!"
// - red: "Your order was cancelled" (e.g. not accepted in time)
// "View" opens My Orders.
// NEW: can also be swiped away sideways.

import "./OrderAlertBanner.css";
import useSwipeDismiss from "../useSwipeDismiss";
import { cancelMessage } from "../orderStatus";

function OrderAlertBanner({ alert, onView, onClose }) {
  const { kind, order } = alert;
  const number = order.customerOrderNumber || `#${order.orderId}`;
  const { offset, handlers } = useSwipeDismiss(onClose);

  return (
    <div
      className={`order-alert ${kind}`}
      role="alert"
      style={
        offset
          ? {
              transform: `translateX(calc(-50% + ${offset}px))`,
              opacity: Math.max(0.2, 1 - Math.abs(offset) / 240),
            }
          : undefined
      }
      {...handlers}
    >
      <span className="order-alert-text">
        {kind === "ready" ? (
          <>
            🍽️ Your order <strong>{number}</strong> is ready! Collect it at the counter.
          </>
        ) : (
          <>⚠️ {cancelMessage(order)}</>
        )}
      </span>
      <button type="button" className="order-alert-view" onClick={onView}>
        View
      </button>
      <button type="button" className="order-alert-close" onClick={onClose} aria-label="Close message">
        ×
      </button>
    </div>
  );
}

export default OrderAlertBanner;
