// src/admin/OrderHistoryPage.jsx
// NEW: Order history - every finished order (collected or cancelled) in one
// easy-to-read table, so admins don't have to scroll through the board.
// Search, status and date filters, click a column heading to sort,
// click a row to see the items. Uses GET /api/orders (already loaded by
// the Admin Panel).

import { Fragment, useMemo, useState } from "react";
import "./OrderHistoryPage.css";
import SortHeader from "./SortHeader";
import { useSort, timeOf } from "./useSort";
import { formatRand } from "./adminData";
import { toBoardOrder } from "../orders";
import { cleanText } from "../textRules";

const PER_PAGE = 20;
const DAY_MS = 24 * 60 * 60 * 1000;

const PERIODS = [
  ["today", "Today"],
  ["7", "Last 7 days"],
  ["30", "Last 30 days"],
  ["all", "All time"],
];

const startOfToday = () => {
  const date = new Date();
  date.setHours(0, 0, 0, 0);
  return date.getTime();
};

const inPeriod = (createdAt, period) => {
  if (period === "all") return true;
  const time = timeOf(createdAt);
  if (time === null) return false;
  if (period === "today") return time >= startOfToday();
  return time >= startOfToday() - (Number(period) - 1) * DAY_MS;
};

const dateTime = (value) => {
  const time = timeOf(value);
  if (time === null) return "—";
  const date = new Date(time);
  return `${date.toLocaleDateString("en-ZA", { day: "2-digit", month: "short", year: "numeric" })} ${date.toLocaleTimeString("en-ZA", { hour: "2-digit", minute: "2-digit" })}`;
};

const lineText = (line) => {
  const extras = line.extras?.length ? ` (${line.extras.join(", ")})` : "";
  return `${line.quantity}× ${line.name}${extras}`;
};

function OrderHistoryPage({ orders = [], loading = false }) {
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("finished");
  const [period, setPeriod] = useState("7");
  const [page, setPage] = useState(1);
  const [openId, setOpenId] = useState(null);
  const sort = useSort("date", "desc", ["date"]);

  // Only finished orders: collected (completed) or cancelled
  const finished = useMemo(
    () =>
      orders
        .map(toBoardOrder)
        .filter((order) => order.status === "Completed"),
    [orders]
  );

  const term = search.trim().toLowerCase();
  const filtered = finished.filter((order) => {
    if (status === "collected" && order.cancelled) return false;
    if (status === "cancelled" && !order.cancelled) return false;
    if (!inPeriod(order.createdAt, period)) return false;
    return !term || order.searchText.includes(term);
  });

  const sorted = sort.sortRows(filtered, (order, column) => {
    if (column === "date") return timeOf(order.createdAt);
    if (column === "order") return order.id;
    if (column === "customer") return order.customer;
    if (column === "total") return order.total;
    if (column === "status") return order.cancelled ? "Cancelled" : "Collected";
    return "";
  });

  const pages = Math.max(1, Math.ceil(sorted.length / PER_PAGE));
  const safePage = Math.min(page, pages);
  const shown = sorted.slice((safePage - 1) * PER_PAGE, safePage * PER_PAGE);

  const collected = filtered.filter((order) => !order.cancelled);
  const revenue = collected.reduce((sum, order) => sum + order.total, 0);
  const cancelledCount = filtered.length - collected.length;

  const changeFilter = (setter) => (event) => {
    setter(event.target.value);
    setPage(1);
    setOpenId(null);
  };

  const sortBy = (column) => {
    sort.toggle(column);
    setPage(1);
  };

  return (
    <section className="history-page">
      <div className="history-header">
        <div>
          <span className="history-breadcrumb">EDUEATS / ORDERS</span>
          <h2>Order History</h2>
          <p>Every finished order. Click a row to see what was ordered.</p>
        </div>
      </div>

      {/* Summary for the chosen filters */}
      <div className="history-summary">
        <div>
          <strong>{collected.length}</strong>
          <span>collected</span>
        </div>
        <div>
          <strong>{formatRand(revenue)}</strong>
          <span>collected sales</span>
        </div>
        <div>
          <strong>{cancelledCount}</strong>
          <span>cancelled</span>
        </div>
      </div>

      {/* Filters */}
      <div className="history-toolbar">
        <input
          type="search"
          className="history-search"
          placeholder="Search order number, customer or item..."
          value={search}
          onChange={(event) => changeFilter(setSearch)({ target: { value: cleanText(event.target.value) } })}
          aria-label="Search orders"
          maxLength={60}
        />
        <select value={status} onChange={changeFilter(setStatus)} aria-label="Status">
          <option value="finished">Collected and cancelled</option>
          <option value="collected">Collected only</option>
          <option value="cancelled">Cancelled only</option>
        </select>
        <select value={period} onChange={changeFilter(setPeriod)} aria-label="Period">
          {PERIODS.map(([value, label]) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </select>
      </div>

      <div className="history-table-wrap">
        <table className="history-table">
          <thead>
            <tr>
              <SortHeader label="Date" column="date" sort={sort} onSort={sortBy} />
              <SortHeader label="Order" column="order" sort={sort} onSort={sortBy} />
              <SortHeader label="Customer" column="customer" sort={sort} onSort={sortBy} />
              <th>Items</th>
              <SortHeader label="Total" column="total" sort={sort} onSort={sortBy} />
              <SortHeader label="Status" column="status" sort={sort} onSort={sortBy} />
            </tr>
          </thead>
          <tbody>
            {shown.map((order) => {
              const open = openId === order.backendId;
              return (
                <Fragment key={order.backendId}>
                <tr
                  className={`history-row ${open ? "open" : ""}`}
                  onClick={() => setOpenId(open ? null : order.backendId)}
                  onKeyDown={(event) => {
                    if (event.key === "Enter" || event.key === " ") {
                      event.preventDefault();
                      setOpenId(open ? null : order.backendId);
                    }
                  }}
                  tabIndex={0}
                  aria-expanded={open}
                >
                  <td className="history-date">{dateTime(order.createdAt)}</td>
                  <td className="history-id">{order.id}</td>
                  <td>
                    {order.customer}
                    {order.walkIn && <span className="history-tag">Walk-in</span>}
                  </td>
                  <td className="history-items">
                    {order.lines.map(lineText).join(", ")}
                  </td>
                  <td className="history-total">{formatRand(order.total)}</td>
                  <td>
                    <span className={`history-status ${order.cancelled ? "cancelled" : "collected"}`}>
                      {order.cancelled ? "Cancelled" : "Collected"}
                    </span>
                  </td>
                </tr>
                {open && (
                  <tr className="history-details">
                    <td colSpan="6">
                      <ul>
                        {order.lines.map((line, index) => (
                          <li key={index}>
                            <strong>{lineText(line)}</strong>
                            {line.note && <span> – note: “{line.note}”</span>}
                          </li>
                        ))}
                      </ul>
                    </td>
                  </tr>
                )}
                </Fragment>
              );
            })}

            {shown.length === 0 && (
              <tr>
                <td colSpan="6" className="history-empty">
                  {loading ? "Loading orders..." : "No finished orders match these filters."}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      <div className="history-pagination">
        <span>
          {sorted.length === 0
            ? "0 orders"
            : `Showing ${(safePage - 1) * PER_PAGE + 1}–${Math.min(safePage * PER_PAGE, sorted.length)} of ${sorted.length} orders`}
        </span>
        <div>
          <button type="button" disabled={safePage === 1} onClick={() => setPage(safePage - 1)}>
            Previous
          </button>
          <span>
            {safePage} / {pages}
          </span>
          <button type="button" disabled={safePage === pages} onClick={() => setPage(safePage + 1)}>
            Next
          </button>
        </div>
      </div>
    </section>
  );
}

export default OrderHistoryPage;
