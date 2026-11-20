### `OperatingHoursValidator.java` (Component)
* **Purpose:** Manages cafeteria operating schedules, time zone/clock tracking, and administrative override states.
* **Key Design Patterns & Safety Features:**
  * **Immutability & Safety:** Fields lack public setters, preventing accidental mutation of operating hours during runtime.
  * **Configuration Driven:** Injects opening (`08:00`) and closing (`17:30`) times dynamically from `application.properties` via `@Value`.
  * **Testability:** Accepts an injected `Clock` bean, making it easy to mock time during unit testing.
  * **Admin Overrides:** Supports manual override states (`overrideState`) allowing staff or admins to force the cafeteria open or closed for special events regardless of the clock schedule.
* **Core Methods:**
  * `isOpen()`: Evaluates the current time against operating hours (or active override status) and returns a boolean.
  * `validateOpenForOrders()`: Acts as a security guard during checkout, throwing a `ResourceUnavailableException` if an order is attempted while closed.
  * `setForceOpen` / `resetToScheduledHours` / `isOverridden`: Provides administrative control hooks.

### `OrderItemCalculator.java` (Component / Service Helper)
* **Purpose:** Acts as the central calculation and validation engine for customer checkouts.
* **Key Architecture & Performance Features:**
  * **Batch Fetching Optimization:** Collects all requested menu item and modifier IDs into Sets and fetches them in single bulk database queries (`findAllById`), avoiding the performance-killing N+1 query problem.
  * **Historical Data Snapshots:** Captures exact item names, base prices, and modifier prices *at the time of purchase* (`priceAtPurchase`, `menuItemNameAtPurchase`), ensuring historical orders remain accurate even if menu prices change later.
  * **Modifier Constraint Enforcement:** Uses Java Streams and `Collectors.groupingBy` to tally user selections per modifier group, rigorously validating `minSelections`, `maxSelections`, and `isRequired` rules.
  * **Inventory Integrity Guard:** Validates that both the core menu item and every chosen modifier are currently flagged as available (`available = true`) before allowing checkout to proceed.

