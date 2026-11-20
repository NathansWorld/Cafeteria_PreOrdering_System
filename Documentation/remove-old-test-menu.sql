-- EduEats: remove the old test menu and the test orders that used it.
-- Run AFTER cafeteria-menu.sql. Back up the database first.
-- Keeps: all users, the 36 real menu items, their categories and options,
--        and any orders that only contain real menu items.
-- Deletes: old test items, orders that contain old test items (with their
--          lines, options, status history and notifications), old option groups
--          and categories that are no longer used.

USE cafeteriadb;
START TRANSACTION;

-- 1. The real menu: the newest item with each of these names
DROP TEMPORARY TABLE IF EXISTS keep_items;
CREATE TEMPORARY TABLE keep_items AS
SELECT MAX(menu_item_id) AS menu_item_id FROM menu_items
WHERE name IN (
  'Breakfast Sandwich',
  'Breakfast Wrap',
  'Omelette',
  'Bubble Waffle',
  'Classic Beef Burger',
  'Classic Chicken Burger',
  'Cheesy Mushroom Beef Burger',
  'Masala Steak Burger',
  'Polony Gatsby',
  'Chicken Gatsby',
  'Grilled Chicken Wrap',
  'Crumbed Chicken Wrap',
  'Cheese Sandwich',
  'Chicken Mayo Sandwich',
  'Chip Roll',
  'Russian Roll',
  'Chicken Strips (5 pieces)',
  'Hot Chips',
  'Greek Salad',
  'Butter Chicken',
  'Pizza Slice',
  'Macaroni & Cheese',
  'Coffee',
  'Tea',
  'Hot Chocolate',
  'Jive 500ml',
  'Juice',
  'Water 500ml',
  'Red Bull',
  'Passion Fruit Mocktail',
  'Watermelon Mint Mocktail',
  'Brownie',
  'Cheesecake',
  'Cinnamon Donut',
  'Lay''s 36g',
  'Doritos'
)
GROUP BY name;

-- Safety check: if the 36 real items are not all there, nothing is deleted
SET @real_menu_ok = ((SELECT COUNT(*) FROM keep_items) = 36);
SELECT (SELECT COUNT(*) FROM keep_items) AS real_menu_items_found, @real_menu_ok AS safe_to_delete;

DROP TEMPORARY TABLE IF EXISTS old_items;
CREATE TEMPORARY TABLE old_items AS
SELECT menu_item_id FROM menu_items
WHERE @real_menu_ok = 1
  AND menu_item_id NOT IN (SELECT menu_item_id FROM keep_items);

-- 2. Orders that contain an old item
DROP TEMPORARY TABLE IF EXISTS old_orders;
CREATE TEMPORARY TABLE old_orders AS
SELECT DISTINCT order_id FROM order_items
WHERE menu_item_id IN (SELECT menu_item_id FROM old_items);

DELETE oim FROM order_item_modifiers oim
  JOIN order_items oi ON oi.order_item_id = oim.order_item_id
  WHERE oi.order_id IN (SELECT order_id FROM old_orders);
DELETE FROM order_items WHERE order_id IN (SELECT order_id FROM old_orders);
DELETE FROM order_status_history WHERE order_id IN (SELECT order_id FROM old_orders);
DELETE FROM notifications WHERE order_id IN (SELECT order_id FROM old_orders);
DELETE FROM orders WHERE order_id IN (SELECT order_id FROM old_orders);

-- 3. Old menu items and their option links
DELETE FROM menu_item_modifier_groups WHERE menu_item_id IN (SELECT menu_item_id FROM old_items);
DELETE FROM menu_items WHERE menu_item_id IN (SELECT menu_item_id FROM old_items);

-- 4. Option groups that no item uses any more (and their options)
DROP TEMPORARY TABLE IF EXISTS old_groups;
CREATE TEMPORARY TABLE old_groups AS
SELECT modifier_group_id FROM modifier_groups
WHERE @real_menu_ok = 1 AND modifier_group_id NOT IN (SELECT modifier_group_id FROM menu_item_modifier_groups);

DELETE FROM category_default_groups WHERE modifier_group_id IN (SELECT modifier_group_id FROM old_groups);
DELETE FROM order_item_modifiers WHERE modifier_id IN
  (SELECT modifier_id FROM modifiers WHERE modifier_group_id IN (SELECT modifier_group_id FROM old_groups));
DELETE FROM modifiers WHERE modifier_group_id IN (SELECT modifier_group_id FROM old_groups);
DELETE FROM modifier_groups WHERE modifier_group_id IN (SELECT modifier_group_id FROM old_groups);

-- 5. Categories with no items left
DROP TEMPORARY TABLE IF EXISTS old_categories;
CREATE TEMPORARY TABLE old_categories AS
SELECT category_id FROM categories
WHERE @real_menu_ok = 1 AND category_id NOT IN (SELECT category_id FROM menu_items);

DELETE FROM category_default_groups WHERE category_id IN (SELECT category_id FROM old_categories);
DELETE FROM categories WHERE category_id IN (SELECT category_id FROM old_categories);

COMMIT;

-- Check: should say 36 items, 10 categories, 11 option groups
SELECT
  (SELECT COUNT(*) FROM menu_items) AS menu_items,
  (SELECT COUNT(*) FROM categories) AS categories,
  (SELECT COUNT(*) FROM modifier_groups) AS option_groups,
  (SELECT COUNT(*) FROM orders) AS orders_left;
