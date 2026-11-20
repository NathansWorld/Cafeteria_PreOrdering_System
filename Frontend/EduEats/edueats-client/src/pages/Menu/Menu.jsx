import { useEffect, useMemo, useRef, useState } from "react";
import "./Menu.css";
import { errorFromBody } from "../../apiError";
import { cleanText, noteProblem } from "../../validation";
import { apiFetch } from "../../api";
import { PAYMENT_METHODS, goToPayment } from "../../payment";
import useCafeteriaStatus from "../../useCafeteriaStatus";
import useMenuUpdates from "../../useMenuUpdates";
import { orderLineTotal } from "../../orderLine";
import AppHeader from "../../components/AppHeader";
import CategoryBar from "../../components/CategoryBar";
import CustomiseSheet from "../../components/CustomiseSheet";
import NotifyPrompt from "../../components/NotifyPrompt";
import {
  normalizeGroups,
  makeLineId,
  lineIdOf,
  unitPrice,
  describeModifiers,
} from "./customizations";
import {
  matchesSearch,
  getCategoryName,
  getImageUrl,
  getPlaceholderIcon,
} from "./menuUtils";

// Most of one item a student can order at once
const MAX_QTY_PER_ITEM = 10;

const SORT_OPTIONS = [
  { value: "default", label: "Recommended" },
  { value: "price-asc", label: "Price: low to high" },
  { value: "price-desc", label: "Price: high to low" },
  { value: "name-asc", label: "Name: A to Z" },
];

const formatRand = (amount) => `R${Number(amount ?? 0).toFixed(2)}`;

// NEW: stock. How many of an item the kitchen still has,
// or null if the backend doesn't send a stock number (no limit then).
const LOW_STOCK = 5; // "Only 3 left" from this number down
const stockOf = (item) => {
  if (item?.stockQuantity === undefined || item?.stockQuantity === null) return null;
  const count = Number(item.stockQuantity);
  return Number.isFinite(count) ? Math.max(0, count) : null;
};

// NEW: how often the menu quietly checks for sold-out / unavailable items
// CHANGED: 10 seconds, so admin changes (stock, categories, availability) show quickly
// CHANGED: once a minute (was every 10 seconds) - sold-out / price changes
// already arrive live through useMenuUpdates, and the backend's rate limit
// counts every request
const MENU_REFRESH_MS = 60000;

// NEW: why an item can't be ordered right now (or "" if it can)
const blockedReason = (item) => {
  if (!item || item.available === false) return "Unavailable";
  if (stockOf(item) === 0) return "Sold out";
  return "";
};

// Checkout refused because something sold out / not enough left
const isStockError = (status, message) =>
  status === 503 || /stock|unavailable/i.test(message || "");

// NEW: picture of the item, or a placeholder until images are added
// CHANGED: "band" shows a SOLD OUT / UNAVAILABLE strip across the picture
function ItemImage({ item, categoryName, band = "" }) {
  const [failed, setFailed] = useState(false);
  const url = getImageUrl(item);
  const strip = band && <span className="menu-card-band">{band}</span>;

  if (url && !failed) {
    return (
      <div className="menu-card-image">
        <img
          src={url}
          alt={item.name}
          loading="lazy"
          onError={() => setFailed(true)}
        />
        {strip}
      </div>
    );
  }

  return (
    <div className="menu-card-image placeholder">
      <span aria-hidden="true">{getPlaceholderIcon(categoryName)}</span>
      {strip}
    </div>
  );
}

// How long the green "Open" banner stays before it tucks away to the side
const BANNER_VISIBLE_MS = 4000;

// Open/closed + connection banner.
// Green "Open": shows for a few seconds, then slides away into a small pill
// on the side (tap the pill to see the hours again).
// Red "Closed" and grey "Offline" always stay, because students must see them.
// Remembers that the green banner already slid away once,
// so it doesn't pop back up every time the student switches page
let bannerCollapsedBefore = false;

// NEW: warn students when the cafeteria is about to close
const CLOSING_SOON_MINUTES = 30;

// "21:00" or "21:00:00" -> minutes until then today (null if unknown/past)
function minutesUntil(time, now) {
  const match = String(time || "").match(/^(\d{1,2}):(\d{2})/);
  if (!match) return null;
  const closing = new Date(now);
  closing.setHours(Number(match[1]), Number(match[2]), 0, 0);
  const minutes = Math.ceil((closing.getTime() - now) / 60000);
  return minutes > 0 ? minutes : null;
}

const shortTime = (time) => String(time || "").slice(0, 5);

function StatusBanner({ status }) {
  // "full" -> "leaving" (slide-out animation) -> "pill"
  const [phase, setPhase] = useState(() => (bannerCollapsedBefore ? "pill" : "full"));

  // NEW: clock for the "closing soon" warning (checked every 30 seconds)
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    const timer = setInterval(() => setNow(Date.now()), 30000);
    return () => clearInterval(timer);
  }, []);

  const isOpenAndOnline =
    status.loaded && status.connected && status.isOpen === true;

  // Start the timer whenever the full green banner is showing
  useEffect(() => {
    if (!isOpenAndOnline || phase !== "full") return undefined;
    const timer = setTimeout(() => setPhase("leaving"), BANNER_VISIBLE_MS);
    return () => clearTimeout(timer);
  }, [isOpenAndOnline, phase]);

  // After the slide-out animation, show the small pill
  useEffect(() => {
    if (phase !== "leaving") return undefined;
    const timer = setTimeout(() => {
      bannerCollapsedBefore = true;
      setPhase("pill");
    }, 350);
    return () => clearTimeout(timer);
  }, [phase]);

  if (!status.loaded) return null;

  if (!status.connected) {
    return (
      <div className="status-banner offline" role="status">
        <span className="status-dot" />
        Offline: can't reach the cafeteria right now. Check your connection.
      </div>
    );
  }

  // Opening hours unknown: don't show a banner
  if (status.isOpen === null) return null;

  if (status.isOpen) {
    // NEW: last 30 minutes - a warning that stays (doesn't tuck away)
    const minutesLeft = status.isOverridden ? null : minutesUntil(status.closingTime, now);
    if (minutesLeft !== null && minutesLeft <= CLOSING_SOON_MINUTES) {
      return (
        <div className="status-banner closing-soon" role="alert">
          <span className="status-icon" aria-hidden="true">⏰</span>
          <span>
            <strong>Closing soon</strong> · the cafeteria closes at {shortTime(status.closingTime)} (in{" "}
            {minutesLeft} {minutesLeft === 1 ? "minute" : "minutes"}). Place your order now.
          </span>
        </div>
      );
    }

    const hours = status.closingTime ? `Open until ${shortTime(status.closingTime)}` : "Open now";

    if (phase === "pill") {
      return (
        <button
          type="button"
          className="status-pill"
          onClick={() => setPhase("full")}
          aria-label={`${hours}. Tap for details`}
          title={hours}
        >
          <span className="status-dot" />
          Open
        </button>
      );
    }

    return (
      <div
        className={`status-banner open ${phase === "leaving" ? "leaving" : ""}`}
        role="status"
      >
        <span className="status-dot" />
        {hours}
        <span className="status-connected">Connected</span>
      </div>
    );
  }

  return (
    <div className="status-banner closed" role="alert">
      {/* CHANGED: bigger and clearer, so students notice it straight away */}
      <span className="status-icon" aria-hidden="true">🔒</span>
      <span>
        <strong>The cafeteria is closed</strong>
        {/* CHANGED: closed by an admin -> we don't know when it opens again */}
        {status.isOverridden
          ? " for now. You can still look at the menu."
          : status.openingTime
            ? `. Orders open again at ${shortTime(status.openingTime)}.`
            : "."}
      </span>
    </div>
  );
}

function Menu({
  user,
  token,
  onLogout,
  onNavigate,
  view = "menu",
  cart,
  setCart,
  cartAlert = false,
  onCartSeen,
  newOrderCount = 0,
  onOrderPlaced,
  reorderOrder = null, // NEW: a past order to add to the cart again ("Order again")
  onReorderDone,
  paymentProblem = null, // NEW: the card payment didn't go through
  onPaymentProblemSeen,
}) {
  const [menuItems, setMenuItems] = useState([]);
  const [selectedCategory, setSelectedCategory] = useState("All");
  const showCart = view === "cart";
  const [loading, setLoading] = useState(true);
  const [menuError, setMenuError] = useState("");
  const [orderMessage, setOrderMessage] = useState("");
  const [placingOrder, setPlacingOrder] = useState(false);
  // NEW: pay at the counter (cash/card at the till) or pay online now with PayFast
  // CHANGED: nothing is chosen by default - the student must pick one each time
  const [paymentMethod, setPaymentMethod] = useState(null);

  // NEW: back from PayFast via the Back button - the page may come back from the
  // browser's memory still saying "Opening payment...", so reset the button
  useEffect(() => {
    const onShow = (event) => {
      if (event.persisted) setPlacingOrder(false);
    };
    window.addEventListener("pageshow", onShow);
    return () => window.removeEventListener("pageshow", onShow);
  }, []);
  const payByCard = paymentMethod === PAYMENT_METHODS.CARD;
  const [lastOrder, setLastOrder] = useState(null);

  const [searchTerm, setSearchTerm] = useState("");
  const [sortOption, setSortOption] = useState("default");
  const [justAddedId, setJustAddedId] = useState(null);

  // NEW: item customisations (Sauce, Extras, note for the kitchen)
  const [customising, setCustomising] = useState(null); // { item, groups }
  const [loadingOptionsId, setLoadingOptionsId] = useState(null);
  const optionsCache = useRef(new Map()); // menuItemId -> groups (asked once per visit)
  const [cartNotice, setCartNotice] = useState("");

  // NEW: bumped to load the menu again (fresh stock numbers)
  const [menuReload, setMenuReload] = useState(0);

  // NEW: open/closed + connected
  const cafeteria = useCafeteriaStatus();
  const isClosed = cafeteria.loaded && cafeteria.connected && cafeteria.isOpen === false;

  // NEW: the first load shows the skeleton cards; later checks are silent
  const menuLoadedRef = useRef(false);
  const [menuLoaded, setMenuLoaded] = useState(false);

  useEffect(() => {
    const loadMenu = async () => {
      try {
        if (!menuLoadedRef.current) setLoading(true);
        setMenuError("");

        const response = await apiFetch("/api/menu-items");

        if (response.status === 401) {
          if (onLogout) onLogout();
          return;
        }

        if (!response.ok) {
          throw new Error(`Could not load menu. Server returned ${response.status}.`);
        }

        const data = await response.json();

        // CHANGED: unavailable items are kept (shown greyed out with a band)
        // instead of vanishing, if the backend sends them
        setMenuItems(
          [...data].sort((a, b) => (a.displayOrder ?? 0) - (b.displayOrder ?? 0))
        );
        menuLoadedRef.current = true;
        setMenuLoaded(true);
      } catch (error) {
        console.error("Menu loading error:", error);
        // A failed background check keeps the menu that's already showing
        if (!menuLoadedRef.current) {
          setMenuError("The menu could not be loaded from the server.");
        }
      } finally {
        setLoading(false);
      }
    };

    loadMenu();
    // Reload when the login token changes, or after an order (fresh stock).
    // onLogout doesn't need to trigger it.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [token, menuReload]);

  // NEW: check the menu again every 20 seconds, and straight away when the
  // student comes back to the app, so sold-out / unavailable items show
  // without a manual refresh
  useEffect(() => {
    const reload = () => {
      if (document.visibilityState === "visible") setMenuReload((count) => count + 1);
    };
    const timer = setInterval(reload, MENU_REFRESH_MS);
    window.addEventListener("focus", reload);
    document.addEventListener("visibilitychange", reload);
    return () => {
      clearInterval(timer);
      window.removeEventListener("focus", reload);
      document.removeEventListener("visibilitychange", reload);
    };
  }, []);

  // CHANGED: categories follow the admin's category positions (displayOrder),
  // so renaming or moving a category shows on the next menu check (every 10 s)
  const categories = useMemo(() => {
    const positions = new Map();
    menuItems.forEach((item) => {
      const name = getCategoryName(item);
      if (!positions.has(name)) positions.set(name, item.category?.displayOrder ?? 999);
    });
    const names = [...positions.keys()].sort(
      (a, b) => positions.get(a) - positions.get(b) || a.localeCompare(b)
    );
    return ["All", ...names];
  }, [menuItems]);

  // A category that was renamed or removed: go back to "All"
  if (selectedCategory !== "All" && menuLoaded && !categories.includes(selectedCategory)) {
    setSelectedCategory("All");
  }

  // NEW: reload straight away when an admin changes a category / item / option
  useMenuUpdates(Boolean(token), () => setMenuReload((count) => count + 1));

  // NEW (item 8): switching between Menu and Cart checks the menu again
  const firstViewRef = useRef(true);
  useEffect(() => {
    if (firstViewRef.current) {
      firstViewRef.current = false;
      return;
    }
    setMenuReload((count) => count + 1);
  }, [view]);

  // CHANGED: smart search ("burger" also finds "burgers")
  const filteredItems = useMemo(
    () =>
      menuItems
        .filter(
          (item) =>
            selectedCategory === "All" ||
            getCategoryName(item) === selectedCategory
        )
        .filter((item) =>
          matchesSearch(item, searchTerm, getCategoryName(item))
        )
        .sort((a, b) => {
          // CHANGED: sold-out / unavailable items keep their normal place
          // in the list (they're greyed out, not moved to the end)
          if (sortOption === "price-asc") return Number(a.price) - Number(b.price);
          if (sortOption === "price-desc") return Number(b.price) - Number(a.price);
          if (sortOption === "name-asc") return a.name.localeCompare(b.name);
          return 0;
        }),
    [menuItems, selectedCategory, searchTerm, sortOption]
  );

  const goHome = () => {
    setLastOrder(null);
    onNavigate("menu");
    setSelectedCategory("All");
    setSearchTerm("");
    setSortOption("default");
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const showCartNotice = (message) => {
    setCartNotice(message);
    setTimeout(() => setCartNotice(""), 3000);
  };

  // Quantity already in the cart for one cart line
  const getLineQuantity = (lineId) =>
    cart.find((line) => lineIdOf(line) === lineId)?.quantity ?? 0;

  // How many of one menu item are in the cart (all option combinations)
  const getItemQuantity = (menuItemId) =>
    cart
      .filter((line) => line.menuItemId === menuItemId)
      .reduce((total, line) => total + line.quantity, 0);

  // NEW: stock left for one item after what's already in the cart
  // (Infinity = no stock number from the backend)
  const stockById = useMemo(
    () => new Map(menuItems.map((item) => [item.menuItemId, stockOf(item)])),
    [menuItems]
  );

  // NEW: items that can't be ordered now (unavailable, or gone from the menu)
  const itemById = useMemo(
    () => new Map(menuItems.map((item) => [item.menuItemId, item])),
    [menuItems]
  );
  const isUnorderable = (menuItemId) =>
    menuLoaded && blockedReason(itemById.get(menuItemId)) === "Unavailable";

  const stockLeftFor = (menuItemId) => {
    if (isUnorderable(menuItemId)) return -getItemQuantity(menuItemId);
    const stock = stockById.get(menuItemId);
    if (stock === null || stock === undefined) return Infinity;
    return stock - getItemQuantity(menuItemId);
  };

  // NEW: lines in the cart that can't be ordered as they are
  const cartHasProblems = cart.some((line) => stockLeftFor(line.menuItemId) < 0);

  const stockNotice = (item) => {
    if (isUnorderable(item.menuItemId)) {
      return `Sorry, ${item.name} is not available right now.`;
    }
    const stock = stockById.get(item.menuItemId) ?? 0;
    const inCart = getItemQuantity(item.menuItemId);
    if (stock <= 0) return `Sorry, ${item.name} is sold out.`;
    return `Sorry, only ${stock} × ${item.name} left${
      inCart > 0 ? ` and ${inCart} ${inCart === 1 ? "is" : "are"} already in your cart` : ""
    }.`;
  };

  const flashAdded = (menuItemId) => {
    setJustAddedId(menuItemId);
    setTimeout(() => {
      setJustAddedId((currentId) => (currentId === menuItemId ? null : currentId));
    }, 1200);
  };

  // Puts an item (with its chosen options) in the cart.
  // Same item + same options + same note = one line; otherwise a new line.
  const addLine = (item, modifiers = [], note = "", quantity = 1) => {
    const lineId = makeLineId(item.menuItemId, modifiers, note);
    const alreadyInCart = getLineQuantity(lineId);

    if (alreadyInCart + quantity > MAX_QTY_PER_ITEM) {
      showCartNotice(`You can order at most ${MAX_QTY_PER_ITEM} of ${item.name}.`);
      return false;
    }

    // NEW: not more than the kitchen has left
    if (quantity > stockLeftFor(item.menuItemId)) {
      showCartNotice(stockNotice(item));
      return false;
    }

    setOrderMessage("");
    setLastOrder(null);
    flashAdded(item.menuItemId);

    setCart((currentCart) => {
      if (currentCart.some((line) => lineIdOf(line) === lineId)) {
        return currentCart.map((line) =>
          lineIdOf(line) === lineId
            ? { ...line, quantity: line.quantity + quantity }
            : line
        );
      }

      return [
        ...currentCart,
        {
          ...item,
          lineId,
          quantity,
          modifiers: modifiers.map(({ id, name, price }) => ({ id, name, price })),
          specialInstructions: note,
        },
      ];
    });

    return true;
  };

  // Asks the backend once per item which options it has (cached afterwards)
  const loadOptions = async (item) => {
    if (optionsCache.current.has(item.menuItemId)) {
      return optionsCache.current.get(item.menuItemId);
    }

    try {
      const response = await apiFetch(`/api/menu-items/${item.menuItemId}/customizations`);

      if (response.status === 401) {
        if (onLogout) onLogout();
        return null;
      }

      // No options or an error: the item can still be ordered plainly
      if (!response.ok) {
        console.warn(`Customisations returned ${response.status} for item ${item.menuItemId}`);
        return [];
      }

      const groups = normalizeGroups(await response.json(), item.menuItemId);
      optionsCache.current.set(item.menuItemId, groups);
      return groups;
    } catch (error) {
      console.warn("Could not load customisations:", error);
      return [];
    }
  };

  // "Add to Cart": items with options open the Customise sheet,
  // items without options go straight into the cart (one tap)
  const addToCart = async (item) => {
    // NEW: sold out (or the rest is already in the cart): don't open options
    if (stockLeftFor(item.menuItemId) < 1) {
      showCartNotice(stockNotice(item));
      return;
    }

    setLoadingOptionsId(item.menuItemId);
    const groups = await loadOptions(item);
    setLoadingOptionsId(null);

    if (groups === null) return; // logged out

    if (groups.length > 0) {
      setCustomising({ item, groups });
      return;
    }

    addLine(item);
  };

  // Called by the Customise sheet's "Add to cart" button
  const addCustomised = ({ modifiers, note, quantity }) => {
    const { item } = customising;

    if (addLine(item, modifiers, note, quantity)) {
      setCustomising(null);
      showCartNotice(`${quantity} × ${item.name} added to your cart.`);
    }
  };

  // NEW: options change live. Every menu check (10 s, an admin change via
  // /topic/menu/updates, or switching page) forgets the saved options, and if
  // the options pop-up is open it asks the backend again, so an option an
  // admin just switched off disappears without a refresh.
  const customisingRef = useRef(customising);
  const loadOptionsRef = useRef(loadOptions);
  const addLineRef = useRef(addLine);
  const menuItemsRef = useRef(menuItems);
  const onReorderDoneRef = useRef(onReorderDone);
  useEffect(() => {
    customisingRef.current = customising;
    loadOptionsRef.current = loadOptions;
    addLineRef.current = addLine;
    menuItemsRef.current = menuItems;
    onReorderDoneRef.current = onReorderDone;
  });

  // NEW: "Order again" from My Orders. Once the menu has loaded, each item of
  // the old order goes back into the cart with the same options and note
  // (matched by name, because the order only stores names). Items that are
  // sold out or no longer on the menu are skipped and listed for the student.
  const reorderDoneRef = useRef(null);
  useEffect(() => {
    if (!reorderOrder || !menuLoaded) return;
    if (reorderDoneRef.current === reorderOrder.orderId) return;
    reorderDoneRef.current = reorderOrder.orderId;

    const sameName = (a, b) => String(a || "").trim().toLowerCase() === String(b || "").trim().toLowerCase();

    const run = async () => {
      const added = [];
      const skipped = [];

      for (const oldItem of reorderOrder.items || []) {
        const menuItem = menuItemsRef.current.find(
          (item) =>
            (oldItem.menuItemId && item.menuItemId === oldItem.menuItemId) ||
            sameName(item.name, oldItem.menuItemName)
        );

        if (!menuItem || menuItem.available === false) {
          skipped.push(oldItem.menuItemName);
          continue;
        }

        let modifiers = [];
        const wanted = oldItem.selectedModifiers || [];
        if (wanted.length > 0) {
          const groups = await loadOptionsRef.current(menuItem);
          if (groups === null) return; // logged out
          const options = groups.flatMap((group) => group.options);
          modifiers = wanted
            .map((name) => options.find((option) => sameName(option.name, name)))
            .filter(Boolean);
          if (modifiers.length < wanted.length) {
            skipped.push(`some options for ${menuItem.name}`);
          }
        }

        // old notes that don't fit today's rule are left out
        const note = oldItem.specialInstructions || "";
        const keepNote = note && !noteProblem(note) ? note : "";

        const ok = addLineRef.current(menuItem, modifiers, keepNote, Number(oldItem.quantity) || 1);
        if (ok) added.push(menuItem.name);
        else skipped.push(menuItem.name);
      }

      setCartNotice(
        added.length === 0
          ? "None of the items from that order can be ordered right now."
          : skipped.length > 0
            ? `Added to your cart. Not available any more: ${skipped.join(", ")}.`
            : "Your previous order is in the cart. Check it and choose how to pay."
      );
      setTimeout(() => setCartNotice(""), 6000);
      onReorderDoneRef.current?.();
    };

    run();
  }, [reorderOrder, menuLoaded]);

  useEffect(() => {
    optionsCache.current.clear();
    const open = customisingRef.current;
    if (!open) return undefined;

    let stopped = false;
    loadOptionsRef.current(open.item).then((groups) => {
      if (stopped || !groups) return;
      setCustomising((current) =>
        current && current.item.menuItemId === open.item.menuItemId
          ? { ...current, groups }
          : current
      );
    });
    return () => {
      stopped = true;
    };
  }, [menuReload]);

  const increaseQuantity = (lineId) => {
    if (getLineQuantity(lineId) >= MAX_QTY_PER_ITEM) {
      showCartNotice(`You can order at most ${MAX_QTY_PER_ITEM} of one item.`);
      return;
    }

    // NEW: not more than the kitchen has left
    const line = cart.find((cartLine) => lineIdOf(cartLine) === lineId);
    if (line && stockLeftFor(line.menuItemId) < 1) {
      showCartNotice(stockNotice(line));
      return;
    }

    setCart((currentCart) =>
      currentCart.map((line) =>
        lineIdOf(line) === lineId ? { ...line, quantity: line.quantity + 1 } : line
      )
    );
  };

  const decreaseQuantity = (lineId) => {
    setCart((currentCart) =>
      currentCart
        .map((line) =>
          lineIdOf(line) === lineId ? { ...line, quantity: line.quantity - 1 } : line
        )
        .filter((line) => line.quantity > 0)
    );
  };

  const removeFromCart = (lineId) => {
    setCart((currentCart) => currentCart.filter((line) => lineIdOf(line) !== lineId));
  };

  const clearCart = () => {
    setCart([]);
    setOrderMessage("");
  };

  const cartCount = cart.reduce((total, item) => total + item.quantity, 0);

  // Includes the price of any extras chosen
  const cartTotal = cart.reduce((total, line) => total + unitPrice(line) * line.quantity, 0);

  const placeOrder = async () => {
    if (cart.length === 0) {
      setOrderMessage("Your cart is empty.");
      return;
    }

    // NEW: something in the cart sold out or became unavailable
    if (cartHasProblems) {
      setOrderMessage("Some items in your cart are no longer available. Please remove them first.");
      return;
    }

    if (!user?.userId) {
      setOrderMessage("Your user account could not be identified. Please log in again.");
      return;
    }

    // NEW: the student must choose how to pay (no default)
    if (!paymentMethod) {
      setOrderMessage("Please choose how you'd like to pay.");
      return;
    }

    try {
      setPlacingOrder(true);
      setOrderMessage("");

    const orderRequest = {
      userId: user.userId,
      // CHANGED: card payments now use PayGate (backend enum "PAYGATE" or "CASH")
      paymentMethod: payByCard ? "PAYGATE" : "CASH",
      items: cart.map((line) => ({
        menuItemId: line.menuItemId,
        quantity: line.quantity,
        specialInstructions: line.specialInstructions || "",
        modifierIds: (line.modifiers || []).map((modifier) => modifier.id),
      })),
    };

      // CHANGED: card payments go through PayFast first
      const response = await apiFetch(payByCard ? "/api/payments/paygate/initiate" : "/api/orders/checkout", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(orderRequest),
      });

      if (response.status === 401) {
        if (onLogout) onLogout();
        return;
      }

      if (!response.ok) {
        let errorMessage = `Order failed. Server returned ${response.status}.`;

        try {
          const errorData = await response.json();
          errorMessage = errorFromBody(errorData) || errorMessage;
        } catch {
          // Response did not contain JSON.
        }

        // NEW: 403 = this login isn't allowed to order (e.g. a staff account,
        // or an old login) - say what to do instead of "Server returned 403"
        if (response.status === 403 && /server returned 403/i.test(errorMessage)) {
          errorMessage =
            "You don't have permission to place this order. Please log out and sign in again with your student account.";
        }

        // NEW: something sold out while the student was choosing
        if (isStockError(response.status, errorMessage)) {
          setMenuReload((count) => count + 1);
          errorMessage =
            "Sorry, something in your cart has just sold out or there are fewer left than you chose. " +
            "The menu has been updated, please check your cart and try again.";
        }

        throw new Error(errorMessage);
      }

      if (payByCard) {
        // The cart stays until PayFast sends the student back with "success"
        goToPayment(await response.json());
        return;
      }

      const order = await response.json();

      setLastOrder(order);
      setCart([]);
      setMenuReload((count) => count + 1); // NEW: fresh stock numbers
      if (onOrderPlaced) onOrderPlaced(order);
    } catch (error) {
      console.error("Checkout error:", error);
      setOrderMessage(error.message || "Could not place your order.");
    } finally {
      setPlacingOrder(false);
    }
  };

  const openCart = () => {
    onNavigate("cart");
  };

  const backToMenu = () => {
    setLastOrder(null);
    onNavigate("menu");
  };

  // ---------- shared pieces ----------

  // Shared top bar + ☰ side menu + Help (same on every page)
  const header = (
    <AppHeader
      user={user}
      current={showCart ? "cart" : "menu"}
      cartCount={cartCount}
      cartAlert={cartAlert}
      onCartSeen={onCartSeen}
      newOrderCount={newOrderCount}
      onNavigate={(page) => (page === "menu" ? goHome() : onNavigate(page))}
      onLogout={onLogout}
    />
  );

  const notice = cartNotice && (
    <p className="cart-notice" role="status">
      {cartNotice}
    </p>
  );

  // ---------- order confirmation ----------

  const renderOrderConfirmation = () => (
    <div className="menu-card confirmation-card">
      <h3>✅ Order placed!</h3>

      <p>
        Order number: <strong>{lastOrder.customerOrderNumber}</strong>
      </p>

      <p>
        Status: <strong>{lastOrder.status}</strong>
      </p>

      {Array.isArray(lastOrder.items) && lastOrder.items.length > 0 && (
        <div className="confirmation-items">
          {lastOrder.items.map((item, index) => (
            <div key={index} className="confirmation-item">
              <p>
                {item.quantity} × {item.menuItemName} —{" "}
                {formatRand(orderLineTotal(item))}
              </p>
              {item.selectedModifiers?.length > 0 && (
                <small>{item.selectedModifiers.join(", ")}</small>
              )}
              {item.specialInstructions && (
                <small className="cart-item-note">Note: “{item.specialInstructions}”</small>
              )}
            </div>
          ))}
        </div>
      )}

      <h2 className="confirmation-total">
        Amount to pay at the till: {formatRand(lastOrder.totalPrice)}
      </h2>

      <p>
        Please pay at the cafeteria pay station when you collect your order.
        Show your order number to the cashier.
      </p>

      <NotifyPrompt />

      <div className="confirmation-actions">
        <button className="cart-button" onClick={backToMenu}>
          Back to Menu
        </button>

        <button
          className="cart-button"
          onClick={() => {
            setLastOrder(null);
            onNavigate("orders");
          }}
        >
          View My Orders
        </button>
      </div>
    </div>
  );

  // ---------- cart page ----------

  if (showCart) {
    return (
      <div className="menu-page">
        {header}

        {/* key: a new key = a new page, so the slide-in animation plays again */}
        <main key={lastOrder ? "confirmation" : "cart"} className="menu-content page-enter">
          {notice}
          <StatusBanner status={cafeteria} />

          {lastOrder ? (
            <>
              <section className="welcome-section">
                <h2>Thank you, {user?.firstName || "student"}!</h2>
                <p>Your order has been sent to the cafeteria.</p>
              </section>

              {renderOrderConfirmation()}
            </>
          ) : (
            <>
              <section className="welcome-section">
                <h2>Your Cart</h2>
                <p>Review your order before placing it.</p>
              </section>

              {cart.length === 0 ? (
                <div className="menu-card empty-cart">
                  <h3>Your cart is empty</h3>
                  <p>Add something from the menu to get started.</p>
                  <button className="cart-button" onClick={backToMenu}>
                    Browse Menu
                  </button>
                </div>
              ) : (
                <section className="cart-list">
                  {cart.map((item) => (
                    <article className="cart-item" key={lineIdOf(item)}>
                      <ItemImage item={item} categoryName={getCategoryName(item)} />

                      <div className="cart-item-info">
                        <h3>{item.name}</h3>

                        {/* NEW: chosen options and note */}
                        {item.modifiers?.length > 0 && (
                          <p className="cart-item-options">
                            {describeModifiers(item.modifiers, formatRand)}
                          </p>
                        )}
                        {item.specialInstructions && (
                          <p className="cart-item-note">Note: “{item.specialInstructions}”</p>
                        )}

                        <p>{formatRand(unitPrice(item))} each</p>

                        {/* NEW: more in the cart than the kitchen has left */}
                        {stockLeftFor(item.menuItemId) < 0 && (
                          <p className="cart-item-stock" role="alert">
                            {stockNotice(item)} Please remove{" "}
                            {-stockLeftFor(item.menuItemId)}.
                          </p>
                        )}

                        <div className="qty-controls">
                          <button
                            onClick={() => decreaseQuantity(lineIdOf(item))}
                            aria-label={`One less ${item.name}`}
                          >
                            −
                          </button>

                          <span>{item.quantity}</span>

                          <button
                            onClick={() => increaseQuantity(lineIdOf(item))}
                            disabled={
                              item.quantity >= MAX_QTY_PER_ITEM || stockLeftFor(item.menuItemId) < 1
                            }
                            aria-label={`One more ${item.name}`}
                          >
                            +
                          </button>

                          <button
                            className="remove-button"
                            onClick={() => removeFromCart(lineIdOf(item))}
                          >
                            Remove
                          </button>
                        </div>
                      </div>

                      <strong className="cart-item-total">
                        {formatRand(unitPrice(item) * item.quantity)}
                      </strong>
                    </article>
                  ))}
                </section>
              )}

              {cart.length > 0 && (
                <div className="checkout-box">
                  <h2>Total: {formatRand(cartTotal)}</h2>
                  {/* NEW: card payment didn't go through (e.g. PayFast is down) */}
                  {paymentProblem && (
                    <div className="pay-failed-banner" role="alert">
                      <p>
                        <strong>⚠ Your card payment didn't go through.</strong> The payment service may be
                        having problems right now. You haven't been charged and your cart is still here.
                      </p>
                      <div className="pay-failed-actions">
                        <button
                          type="button"
                          className="pay-failed-counter"
                          onClick={() => {
                            setPaymentMethod(PAYMENT_METHODS.COUNTER);
                            setOrderMessage("");
                            onPaymentProblemSeen?.();
                          }}
                        >
                          Pay at the counter instead
                        </button>
                        <button
                          type="button"
                          className="pay-failed-retry"
                          onClick={() => {
                            setPaymentMethod(PAYMENT_METHODS.CARD);
                            setOrderMessage("");
                            onPaymentProblemSeen?.();
                          }}
                        >
                          Try card again
                        </button>
                      </div>
                    </div>
                  )}

                  {/* NEW: choose how to pay */}
                  <fieldset className="pay-choice">
                    <legend>How would you like to pay?</legend>
                    {[
                      [PAYMENT_METHODS.COUNTER, "Pay at the counter", "Pay at the cafeteria pay station when you collect."],
                      [PAYMENT_METHODS.CARD, "Pay by card now", "Pay securely online before your order goes to the kitchen."],
                    ].map(([value, label, hint]) => (
                      <label key={value} className={`pay-option ${paymentMethod === value ? "selected" : ""}`}>
                        <input
                          type="radio"
                          name="payment-method"
                          value={value}
                          checked={paymentMethod === value}
                          disabled={placingOrder}
                          onChange={() => {
                            setPaymentMethod(value);
                            setOrderMessage("");
                            onPaymentProblemSeen?.(); // FIX: a new choice hides the old warning
                          }}
                        />
                        <span>
                          <strong>{label}</strong>
                          <small>{hint}</small>
                        </span>
                      </label>
                    ))}
                    {/* NEW: warn before paying by card - refunds aren't possible */}
                    {payByCard && (
                      <p className="pay-warning" role="note">
                        ⚠ Card orders can't be cancelled in the app once paid. If there's a problem with your
                        order, the cafeteria staff can refund you at the counter.
                      </p>
                    )}
                  </fieldset>

                  {isClosed && (
                    <p className="checkout-closed">
                      The cafeteria is closed right now
                      {cafeteria.openingTime && !cafeteria.isOverridden
                        ? `. Orders open again at ${cafeteria.openingTime}.`
                        : "."}
                    </p>
                  )}

                  {orderMessage && (
                    <p className="checkout-message">
                      <strong>{orderMessage}</strong>
                    </p>
                  )}

                  <div className="checkout-actions">
                    <button className="cart-button secondary" onClick={clearCart}>
                      Clear Cart
                    </button>

                    <button
                      className="cart-button"
                      onClick={placeOrder}
                      disabled={placingOrder || isClosed || cartHasProblems || !paymentMethod}
                    >
                      {!paymentMethod && !placingOrder
                        ? "Choose how to pay"
                        : placingOrder
                        ? payByCard
                          ? "Opening payment..."
                          : "Placing Order..."
                        : payByCard
                          ? `Pay ${formatRand(cartTotal)}`
                          : "Place Order"}
                    </button>
                  </div>
                </div>
              )}
            </>
          )}
        </main>
      </div>
    );
  }

  // ---------- menu page ----------

  return (
    <div className="menu-page">
      {header}

      <main key="menu" className="menu-content page-enter">
        {notice}
        <StatusBanner status={cafeteria} />

        <section className="welcome-section">
          <h2>
            {user?.firstName ? `Welcome, ${user.firstName}` : "What's on the menu?"}
          </h2>
          <p>Browse today's meals and order ahead.</p>
        </section>

        {menuError && <p className="menu-error">{menuError}</p>}

        {!menuError && (
          <>
            {/* CHANGED: search + sort + categories stick to the top while scrolling */}
            <div className="menu-sticky">
              <div className="menu-toolbar">
                <label className="menu-search">
                  <span aria-hidden="true">⌕</span>
                  <input
                    type="search"
                    placeholder="Search, e.g. burger or coffee"
                    value={searchTerm}
                    maxLength={50}
                    onChange={(event) => setSearchTerm(cleanText(event.target.value))}
                  />
                  {/* NEW: clear the search in one tap */}
                  {searchTerm && (
                    <button
                      type="button"
                      className="search-clear"
                      onClick={() => setSearchTerm("")}
                      aria-label="Clear search"
                    >
                      ×
                    </button>
                  )}
                </label>

                {/* CHANGED: compact sort button next to the search box.
                    The real dropdown sits invisibly on top, so tapping it
                    opens the phone's normal picker. */}
                <label
                  className={`menu-sort ${sortOption !== "default" ? "active" : ""}`}
                  title="Sort the menu"
                >
                  <span className="menu-sort-icon" aria-hidden="true">⇅</span>
                  <span className="menu-sort-label">
                    {SORT_OPTIONS.find((option) => option.value === sortOption)?.label}
                  </span>
                  <select
                    value={sortOption}
                    onChange={(event) => setSortOption(event.target.value)}
                    aria-label="Sort menu"
                  >
                    {SORT_OPTIONS.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </select>
                </label>
              </div>

              {/* CHANGED: sideways row with fades + arrows so it's clear it scrolls */}
              <CategoryBar
                categories={categories}
                selected={selectedCategory}
                onSelect={setSelectedCategory}
              />
            </div>

            <section className="menu-grid">
              {/* NEW: grey placeholder cards while loading */}
              {loading &&
                Array.from({ length: 6 }).map((_, index) => (
                  <div className="menu-card skeleton" key={`skeleton-${index}`}>
                    <div className="menu-card-image" />
                    <div className="skeleton-line wide" />
                    <div className="skeleton-line" />
                  </div>
                ))}

              {!loading &&
                filteredItems.map((item, index) => {
                  const categoryName = getCategoryName(item);
                  const added = justAddedId === item.menuItemId;
                  const loadingOptions = loadingOptionsId === item.menuItemId;

                  // The plain version (no options, no note) gets a − 2 + stepper
                  // right on the card, so ordering several doesn't need the cart page
                  const plainLineId = makeLineId(item.menuItemId);
                  const plainQuantity = getLineQuantity(plainLineId);
                  // Versions with options are counted too, e.g. "2 in cart"
                  const inCart = getItemQuantity(item.menuItemId);

                  // NEW: stock, and items that can't be ordered right now
                  const stock = stockOf(item);
                  const blocked = blockedReason(item); // "", "Sold out" or "Unavailable"
                  const soldOut = Boolean(blocked);
                  const noneLeftToAdd = stockLeftFor(item.menuItemId) < 1;

                  return (
                    <article
                      className={`menu-card ${soldOut ? "sold-out" : ""}`}
                      key={item.menuItemId}
                      style={{ animationDelay: `${Math.min(index, 10) * 30}ms` }}
                      aria-disabled={soldOut || undefined}
                    >
                      <ItemImage item={item} categoryName={categoryName} band={blocked} />

                      <span className="category">{categoryName}</span>

                      <h3>{item.name}</h3>

                      <p>{item.description}</p>

                      {/* NEW: stock label */}
                      {soldOut ? (
                        <span className="stock-label stock-out">{blocked}</span>
                      ) : (
                        stock !== null &&
                        stock <= LOW_STOCK && (
                          <span className="stock-label stock-low">Only {stock} left</span>
                        )
                      )}

                      <div className="menu-card-footer">
                        <div className="menu-card-price">
                          <strong>{formatRand(item.price)}</strong>
                          {inCart > plainQuantity && (
                            <small className="menu-card-in-cart">{inCart} in cart</small>
                          )}
                        </div>

                        {plainQuantity > 0 ? (
                          <div className="card-stepper" role="group" aria-label={`${item.name} quantity`}>
                            <button
                              type="button"
                              onClick={() => decreaseQuantity(plainLineId)}
                              aria-label={
                                plainQuantity === 1
                                  ? `Remove ${item.name} from cart`
                                  : `One less ${item.name}`
                              }
                            >
                              −
                            </button>

                            <span key={plainQuantity} aria-live="polite">
                              {plainQuantity}
                            </span>

                            <button
                              type="button"
                              onClick={() => addToCart(item)}
                              disabled={
                                loadingOptions || plainQuantity >= MAX_QTY_PER_ITEM || noneLeftToAdd
                              }
                              aria-label={`One more ${item.name}`}
                            >
                              +
                            </button>
                          </div>
                        ) : (
                          <button
                            className={`add-button ${added ? "added" : ""}`}
                            onClick={() => addToCart(item)}
                            disabled={loadingOptions || soldOut}
                          >
                            {soldOut
                              ? blocked
                              : loadingOptions
                                ? "Loading…"
                                : added
                                  ? "Added ✓"
                                  : "Add to Cart"}
                          </button>
                        )}
                      </div>
                    </article>
                  );
                })}
            </section>

            {!loading && filteredItems.length === 0 && (
              <p className="menu-empty">
                {searchTerm.trim()
                  ? `No meals match "${searchTerm.trim()}".`
                  : "No menu items are currently available."}
              </p>
            )}
          </>
        )}
      </main>

      {/* NEW: floating cart bar */}
      {cartCount > 0 && (
        <button className="floating-cart" onClick={openCart}>
          <span key={cartCount} className="floating-cart-count">
            {cartCount}
          </span>
          <span>View cart</span>
          <strong>{formatRand(cartTotal)}</strong>
        </button>
      )}

      {/* NEW: options pop-up for items that can be customised */}
      {customising && (
        <CustomiseSheet
          item={customising.item}
          groups={customising.groups}
          maxQuantity={Math.max(1, Math.min(MAX_QTY_PER_ITEM, stockLeftFor(customising.item.menuItemId)))}
          formatRand={formatRand}
          onAdd={addCustomised}
          onClose={() => setCustomising(null)}
        />
      )}
    </div>
  );
}

export default Menu;
