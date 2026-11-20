// src/payment.js
// NEW: online card payment (PayGate sandbox; PayFast still supported).
//
// 1. POST /api/payments/payfast/initiate with the same body as a normal checkout.
//    The backend saves the order with paymentStatus PENDING and returns the
//    PayFast form fields (merchant_id, amount, signature, ...) plus payfast_url.
// 2. We post those fields to payfast_url, so the student pays on PayFast's page.
// 3. PayFast sends the student back to our return / cancel address
//    (e.g. /?payment=success#orders or /?payment=cancelled#cart).
// 4. PayFast tells the backend separately (ITN). Only then the order becomes PAID,
//    the stock is taken off and the kitchen sees the order.

export const PAYMENT_METHODS = {
  COUNTER: "counter",
  CARD: "card",
};

const METHOD_KEY = "paymentMethod";
const PENDING_KEY = "pendingPayment";

export function loadPaymentMethod() {
  try {
    return localStorage.getItem(METHOD_KEY) === PAYMENT_METHODS.CARD
      ? PAYMENT_METHODS.CARD
      : PAYMENT_METHODS.COUNTER;
  } catch {
    return PAYMENT_METHODS.COUNTER;
  }
}

export function savePaymentMethod(method) {
  try {
    localStorage.setItem(METHOD_KEY, method);
  } catch {
    // not saved - "pay at counter" is used next time
  }
}

// Sends the browser to the payment page (PayGate, or PayFast as before).
// A normal form POST is what both expect (it's a full page change).
//
// PayGate (Chaz's /api/payments/paygate/initiate) returns
//   { paygate_url, pay_request_id, checksum, orderId? }
//   -> we POST PAY_REQUEST_ID + CHECKSUM to paygate_url
// PayFast returned { payfast_url, merchant_id, ..., signature }
//   -> we POST every field to payfast_url
export function goToPayment(payload) {
  const data = payload || {};
  const orderId = data.orderId ?? data.order_id ?? data.m_payment_id ?? null;

  let url;
  let fields;
  const payGateUrl = data.paygate_url || data.payment_url;
  const requestId = data.pay_request_id ?? data.PAY_REQUEST_ID;
  const checksum = data.checksum ?? data.CHECKSUM;

  if (payGateUrl && requestId && checksum) {
    url = payGateUrl;
    fields = { PAY_REQUEST_ID: requestId, CHECKSUM: checksum };
  } else if (data.payfast_url) {
    const { payfast_url: payfastUrl, orderId: _id, ...rest } = data;
    url = payfastUrl;
    fields = rest;
  }

  if (!url) {
    throw new Error("The payment page could not be opened. Please try again or pay at the counter.");
  }

  try {
    // orderId lets the app cancel the unpaid order if the payment doesn't finish
    sessionStorage.setItem(
      PENDING_KEY,
      JSON.stringify({ orderId, item: data.item_name ?? null, at: Date.now() })
    );
  } catch {
    // only used when the student comes back
  }

  const form = document.createElement("form");
  form.method = "POST";
  form.action = url;
  form.style.display = "none";
  Object.entries(fields).forEach(([name, value]) => {
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = name;
    input.value = value ?? "";
    form.appendChild(input);
  });
  document.body.appendChild(form);
  form.submit();
}

// old names still work
export const goToPayFast = goToPayment;
export const goToPayGate = goToPayment;

// After PayFast sends the student back: { result: "success" | "cancelled", pending }.
// Read once when the app starts (and removed from the address bar), so a
// refresh doesn't show the message again.
// NEW: the student went to PayFast but came back WITHOUT PayFast sending them
// (the Back button, or PayFast's own error page, e.g. when the sandbox is down).
// Then "pendingPayment" is still saved: the payment never finished.
function readUnfinishedPayment() {
  try {
    const pending = JSON.parse(sessionStorage.getItem(PENDING_KEY) || "null");
    if (!pending) return null;
    sessionStorage.removeItem(PENDING_KEY);
    return { result: "failed", pending };
  } catch {
    return null;
  }
}

function parsePaymentReturn() {
  if (typeof window === "undefined") return null;
  const params = new URLSearchParams(window.location.search);
  const raw = (params.get("payment") || "").toLowerCase();
  if (!raw) return readUnfinishedPayment();

  params.delete("payment");
  const query = params.toString();
  window.history.replaceState(
    window.history.state,
    "",
    `${window.location.pathname}${query ? `?${query}` : ""}${window.location.hash}`
  );

  let pending = null;
  try {
    pending = JSON.parse(sessionStorage.getItem(PENDING_KEY) || "null");
    sessionStorage.removeItem(PENDING_KEY);
  } catch {
    pending = null;
  }

  // CHANGED: "failed" / "declined" = the card was declined or the payment
  // service had an error -> same "didn't go through" box as the Back button
  // "processing" = PayGate is still confirming the payment (Chaz's backend)
  const result =
    raw.startsWith("success") || raw === "paid"
      ? "success"
      : raw.startsWith("processing") || raw === "pending"
        ? "processing"
        : /fail|declin|error/.test(raw)
          ? "failed"
          : "cancelled";
  return { result, pending };
}

let paymentReturn = parsePaymentReturn();

// NEW: the Back button can show the old page from the browser's memory
// (the app doesn't restart), so check again when that happens
const returnListeners = new Set();
export function onPaymentReturn(listener) {
  returnListeners.add(listener);
  return () => returnListeners.delete(listener);
}

if (typeof window !== "undefined") {
  window.addEventListener("pageshow", (event) => {
    if (!event.persisted) return;
    const unfinished = readUnfinishedPayment();
    if (!unfinished) return;
    paymentReturn = unfinished;
    returnListeners.forEach((listener) => listener(unfinished));
  });
}

// The return result, until markPaymentReturnHandled() is called
export const peekPaymentReturn = () => paymentReturn;
export function markPaymentReturnHandled() {
  paymentReturn = null;
}

// Payment status of an order, as sent by the backend (paymentStatus)
export function paymentLabel(order) {
  const status = String(order?.paymentStatus || "").toUpperCase();
  if (status === "PENDING") return { text: "Waiting for payment", className: "pay-pending" };
  if (status === "PAID") return { text: "Paid online", className: "pay-paid" };
  if (status === "FAILED") return { text: "Payment failed", className: "pay-failed" };
  return null;
}
