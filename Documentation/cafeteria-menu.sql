-- EduEats: real Cherry Catering menu (cafeteria menu, October 2026)
-- 36 items in 10 categories, with option groups.
-- Run in MySQL on the cafeteriadb database. Safe to run on a database that has orders:
-- old menu items are only hidden (available = 0), never deleted, so past orders keep working.
-- Photos are not set here: upload them on Admin Panel > Products.

USE cafeteriadb;
START TRANSACTION;

-- 1. Hide the old test menu
UPDATE menu_items SET available = 0, updated_at = NOW();

-- 2. Categories (re-uses a category if the name already exists)
INSERT INTO categories (category_name, display_order, created_at, updated_at) VALUES ('Breakfast', 1, NOW(), NOW())
  ON DUPLICATE KEY UPDATE display_order = VALUES(display_order), updated_at = NOW();
INSERT INTO categories (category_name, display_order, created_at, updated_at) VALUES ('Burgers', 2, NOW(), NOW())
  ON DUPLICATE KEY UPDATE display_order = VALUES(display_order), updated_at = NOW();
INSERT INTO categories (category_name, display_order, created_at, updated_at) VALUES ('Cape Town Favourites', 3, NOW(), NOW())
  ON DUPLICATE KEY UPDATE display_order = VALUES(display_order), updated_at = NOW();
INSERT INTO categories (category_name, display_order, created_at, updated_at) VALUES ('Wraps & Sandwiches', 4, NOW(), NOW())
  ON DUPLICATE KEY UPDATE display_order = VALUES(display_order), updated_at = NOW();
INSERT INTO categories (category_name, display_order, created_at, updated_at) VALUES ('Rolls & Sides', 5, NOW(), NOW())
  ON DUPLICATE KEY UPDATE display_order = VALUES(display_order), updated_at = NOW();
INSERT INTO categories (category_name, display_order, created_at, updated_at) VALUES ('Hot Meals', 6, NOW(), NOW())
  ON DUPLICATE KEY UPDATE display_order = VALUES(display_order), updated_at = NOW();
INSERT INTO categories (category_name, display_order, created_at, updated_at) VALUES ('Hot Drinks', 7, NOW(), NOW())
  ON DUPLICATE KEY UPDATE display_order = VALUES(display_order), updated_at = NOW();
INSERT INTO categories (category_name, display_order, created_at, updated_at) VALUES ('Cold Drinks', 8, NOW(), NOW())
  ON DUPLICATE KEY UPDATE display_order = VALUES(display_order), updated_at = NOW();
INSERT INTO categories (category_name, display_order, created_at, updated_at) VALUES ('Desserts', 9, NOW(), NOW())
  ON DUPLICATE KEY UPDATE display_order = VALUES(display_order), updated_at = NOW();
INSERT INTO categories (category_name, display_order, created_at, updated_at) VALUES ('Snacks', 10, NOW(), NOW())
  ON DUPLICATE KEY UPDATE display_order = VALUES(display_order), updated_at = NOW();

-- 3. Option groups and their options
INSERT INTO modifier_groups (name, minimum_selections, maximum_selections, available, is_required, created_at, updated_at)
  VALUES ('Sauce', 0, 2, 1, 0, NOW(), NOW());
SET @g_sauce = LAST_INSERT_ID();
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_sauce, 'Tomato sauce', 0.00, 1, NOW(), NOW());
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_sauce, 'BBQ sauce', 0.00, 1, NOW(), NOW());
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_sauce, 'Garlic mayo', 0.00, 1, NOW(), NOW());
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_sauce, 'Mayo', 0.00, 1, NOW(), NOW());
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_sauce, 'Chilli sauce', 0.00, 1, NOW(), NOW());

INSERT INTO modifier_groups (name, minimum_selections, maximum_selections, available, is_required, created_at, updated_at)
  VALUES ('Leave out', 0, 4, 1, 0, NOW(), NOW());
SET @g_leave = LAST_INSERT_ID();
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_leave, 'No onions', 0.00, 1, NOW(), NOW());
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_leave, 'No tomato', 0.00, 1, NOW(), NOW());
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_leave, 'No lettuce', 0.00, 1, NOW(), NOW());
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_leave, 'No sauce', 0.00, 1, NOW(), NOW());

INSERT INTO modifier_groups (name, minimum_selections, maximum_selections, available, is_required, created_at, updated_at)
  VALUES ('Extras', 0, 2, 1, 0, NOW(), NOW());
SET @g_extras = LAST_INSERT_ID();
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_extras, 'Fried onions', 5.00, 1, NOW(), NOW());
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_extras, 'Avocado', 15.00, 1, NOW(), NOW());

INSERT INTO modifier_groups (name, minimum_selections, maximum_selections, available, is_required, created_at, updated_at)
  VALUES ('Add chips', 0, 1, 1, 0, NOW(), NOW());
SET @g_chips = LAST_INSERT_ID();
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_chips, 'With chips', 10.00, 1, NOW(), NOW());

INSERT INTO modifier_groups (name, minimum_selections, maximum_selections, available, is_required, created_at, updated_at)
  VALUES ('Size', 1, 1, 1, 1, NOW(), NOW());
SET @g_size = LAST_INSERT_ID();
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_size, 'Small', 0.00, 1, NOW(), NOW());
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_size, 'Large', 20.00, 1, NOW(), NOW());

INSERT INTO modifier_groups (name, minimum_selections, maximum_selections, available, is_required, created_at, updated_at)
  VALUES ('Egg style', 1, 1, 1, 1, NOW(), NOW());
SET @g_egg = LAST_INSERT_ID();
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_egg, 'Scrambled', 0.00, 1, NOW(), NOW());
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_egg, 'Sunny-side up', 0.00, 1, NOW(), NOW());

INSERT INTO modifier_groups (name, minimum_selections, maximum_selections, available, is_required, created_at, updated_at)
  VALUES ('Toppings', 0, 1, 1, 0, NOW(), NOW());
SET @g_waffle = LAST_INSERT_ID();
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_waffle, '1 topping and syrup', 15.00, 1, NOW(), NOW());

INSERT INTO modifier_groups (name, minimum_selections, maximum_selections, available, is_required, created_at, updated_at)
  VALUES ('How would you like it?', 0, 1, 1, 0, NOW(), NOW());
SET @g_toasted = LAST_INSERT_ID();
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_toasted, 'Toasted', 0.00, 1, NOW(), NOW());

INSERT INTO modifier_groups (name, minimum_selections, maximum_selections, available, is_required, created_at, updated_at)
  VALUES ('Coffee extras', 0, 3, 1, 0, NOW(), NOW());
SET @g_coffee = LAST_INSERT_ID();
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_coffee, 'Extra shot', 6.00, 1, NOW(), NOW());
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_coffee, 'Syrup', 10.00, 1, NOW(), NOW());
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_coffee, 'Oat milk', 10.00, 1, NOW(), NOW());

INSERT INTO modifier_groups (name, minimum_selections, maximum_selections, available, is_required, created_at, updated_at)
  VALUES ('Milk', 0, 1, 1, 0, NOW(), NOW());
SET @g_milk = LAST_INSERT_ID();
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_milk, 'Oat milk', 10.00, 1, NOW(), NOW());

INSERT INTO modifier_groups (name, minimum_selections, maximum_selections, available, is_required, created_at, updated_at)
  VALUES ('Tea', 1, 1, 1, 1, NOW(), NOW());
SET @g_tea = LAST_INSERT_ID();
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_tea, 'Ceylon', 0.00, 1, NOW(), NOW());
INSERT INTO modifiers (modifier_group_id, name, added_price, available, created_at, updated_at) VALUES (@g_tea, 'Rooibos', 0.00, 1, NOW(), NOW());

-- 4. Menu items, each linked to its option groups
INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Breakfast Sandwich', 'Scrambled or sunny-side up eggs and cheese.', 35.00, 1, 1, 30, NOW(), NOW() FROM categories WHERE category_name = 'Breakfast';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_egg, 1, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_sauce, 2, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Breakfast Wrap', 'A toasted wrap filled with scrambled egg.', 40.00, 1, 2, 30, NOW(), NOW() FROM categories WHERE category_name = 'Breakfast';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_sauce, 1, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_leave, 2, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Omelette', 'A fluffy egg dish with cheese.', 45.00, 1, 3, 30, NOW(), NOW() FROM categories WHERE category_name = 'Breakfast';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_extras, 1, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Bubble Waffle', 'Bubble waffle with ice cream. Add a topping and syrup for R15.', 40.00, 1, 4, 30, NOW(), NOW() FROM categories WHERE category_name = 'Breakfast';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_waffle, 1, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Classic Beef Burger', NULL, 35.00, 1, 1, 30, NOW(), NOW() FROM categories WHERE category_name = 'Burgers';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_sauce, 1, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_extras, 2, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_leave, 3, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Classic Chicken Burger', NULL, 35.00, 1, 2, 30, NOW(), NOW() FROM categories WHERE category_name = 'Burgers';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_sauce, 1, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_extras, 2, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_leave, 3, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Cheesy Mushroom Beef Burger', NULL, 55.00, 1, 3, 30, NOW(), NOW() FROM categories WHERE category_name = 'Burgers';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_sauce, 1, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_extras, 2, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_leave, 3, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Masala Steak Burger', NULL, 60.00, 1, 4, 30, NOW(), NOW() FROM categories WHERE category_name = 'Burgers';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_sauce, 1, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_extras, 2, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_leave, 3, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Polony Gatsby', 'A full Cape Town gatsby.', 100.00, 1, 1, 30, NOW(), NOW() FROM categories WHERE category_name = 'Cape Town Favourites';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_sauce, 1, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_leave, 2, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Chicken Gatsby', 'A full Cape Town gatsby.', 150.00, 1, 2, 30, NOW(), NOW() FROM categories WHERE category_name = 'Cape Town Favourites';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_sauce, 1, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_leave, 2, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Grilled Chicken Wrap', NULL, 45.00, 1, 1, 30, NOW(), NOW() FROM categories WHERE category_name = 'Wraps & Sandwiches';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_sauce, 1, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_leave, 2, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Crumbed Chicken Wrap', NULL, 45.00, 1, 2, 30, NOW(), NOW() FROM categories WHERE category_name = 'Wraps & Sandwiches';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_sauce, 1, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_leave, 2, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Cheese Sandwich', NULL, 25.00, 1, 3, 30, NOW(), NOW() FROM categories WHERE category_name = 'Wraps & Sandwiches';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_toasted, 1, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Chicken Mayo Sandwich', NULL, 40.00, 1, 4, 30, NOW(), NOW() FROM categories WHERE category_name = 'Wraps & Sandwiches';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_toasted, 1, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Chip Roll', NULL, 25.00, 1, 1, 30, NOW(), NOW() FROM categories WHERE category_name = 'Rolls & Sides';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_sauce, 1, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Russian Roll', 'Add chips for R10.', 30.00, 1, 2, 30, NOW(), NOW() FROM categories WHERE category_name = 'Rolls & Sides';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_chips, 1, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_sauce, 2, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_leave, 3, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Chicken Strips (5 pieces)', 'Add chips for R10.', 40.00, 1, 3, 30, NOW(), NOW() FROM categories WHERE category_name = 'Rolls & Sides';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_chips, 1, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_sauce, 2, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Hot Chips', 'Small or large.', 20.00, 1, 4, 30, NOW(), NOW() FROM categories WHERE category_name = 'Rolls & Sides';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_size, 1, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_sauce, 2, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Greek Salad', NULL, 35.00, 1, 5, 30, NOW(), NOW() FROM categories WHERE category_name = 'Rolls & Sides';

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Butter Chicken', NULL, 60.00, 1, 1, 30, NOW(), NOW() FROM categories WHERE category_name = 'Hot Meals';

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Pizza Slice', NULL, 30.00, 1, 2, 30, NOW(), NOW() FROM categories WHERE category_name = 'Hot Meals';

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Macaroni & Cheese', NULL, 55.00, 1, 3, 30, NOW(), NOW() FROM categories WHERE category_name = 'Hot Meals';

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Coffee', NULL, 15.00, 1, 1, 30, NOW(), NOW() FROM categories WHERE category_name = 'Hot Drinks';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_coffee, 1, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Tea', 'Ceylon or rooibos tea.', 15.00, 1, 2, 30, NOW(), NOW() FROM categories WHERE category_name = 'Hot Drinks';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_tea, 1, NOW(), NOW());
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_milk, 2, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Hot Chocolate', NULL, 30.00, 1, 3, 30, NOW(), NOW() FROM categories WHERE category_name = 'Hot Drinks';
SET @item = LAST_INSERT_ID();
INSERT INTO menu_item_modifier_groups (menu_item_id, modifier_group_id, display_order, created_at, updated_at) VALUES (@item, @g_milk, 1, NOW(), NOW());

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Jive 500ml', NULL, 13.00, 1, 1, 30, NOW(), NOW() FROM categories WHERE category_name = 'Cold Drinks';

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Juice', NULL, 18.00, 1, 2, 30, NOW(), NOW() FROM categories WHERE category_name = 'Cold Drinks';

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Water 500ml', NULL, 10.00, 1, 3, 30, NOW(), NOW() FROM categories WHERE category_name = 'Cold Drinks';

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Red Bull', NULL, 20.00, 1, 4, 30, NOW(), NOW() FROM categories WHERE category_name = 'Cold Drinks';

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Passion Fruit Mocktail', NULL, 35.00, 1, 5, 30, NOW(), NOW() FROM categories WHERE category_name = 'Cold Drinks';

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Watermelon Mint Mocktail', NULL, 35.00, 1, 6, 30, NOW(), NOW() FROM categories WHERE category_name = 'Cold Drinks';

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Brownie', NULL, 16.00, 1, 1, 30, NOW(), NOW() FROM categories WHERE category_name = 'Desserts';

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Cheesecake', NULL, 17.50, 1, 2, 30, NOW(), NOW() FROM categories WHERE category_name = 'Desserts';

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Cinnamon Donut', NULL, 10.00, 1, 3, 30, NOW(), NOW() FROM categories WHERE category_name = 'Desserts';

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Lay''s 36g', NULL, 12.00, 1, 1, 30, NOW(), NOW() FROM categories WHERE category_name = 'Snacks';

INSERT INTO menu_items (category_id, name, description, price, available, display_order, stock_quantity, created_at, updated_at)
  SELECT category_id, 'Doritos', NULL, 12.00, 1, 2, 30, NOW(), NOW() FROM categories WHERE category_name = 'Snacks';

COMMIT;

-- Check: should list the new menu
SELECT c.category_name, m.name, m.price FROM menu_items m JOIN categories c ON c.category_id = m.category_id
  WHERE m.available = 1 ORDER BY c.display_order, m.display_order;
