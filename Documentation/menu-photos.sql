-- EduEats: menu photo links (Cloudinary) for the 36 real menu items.
-- Run AFTER cafeteria-menu.sql. Only sets image_path on the current (available) items.
-- Photo credits: Documentation/photo-credits.txt

USE cafeteriadb;
START TRANSACTION;

UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792483959/edueats/menu-items/40176f61-106f-4f21-b1a4-edb507ed6384.jpg', updated_at = NOW() WHERE name = 'Breakfast Sandwich' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792163085/edueats/menu-items/0172f1cf-6cda-4e22-b9f9-e9562d3d39a8.jpg', updated_at = NOW() WHERE name = 'Breakfast Wrap' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792484376/edueats/menu-items/aeeee96c-3316-4e9a-8efa-729725c8efc5.jpg', updated_at = NOW() WHERE name = 'Omelette' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792484421/edueats/menu-items/1d217f6b-680a-4823-aed7-cfccbdbf5576.jpg', updated_at = NOW() WHERE name = 'Bubble Waffle' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792158225/edueats/menu-items/71e1e5ec-dde6-4c35-94a5-617bd2e74e0d.jpg', updated_at = NOW() WHERE name = 'Classic Beef Burger' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792162639/edueats/menu-items/d538ee0b-4c50-4f51-8290-cfbe14111800.jpg', updated_at = NOW() WHERE name = 'Classic Chicken Burger' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792484589/edueats/menu-items/2a5aedfc-284d-4b2b-a063-ab01a53b5cd9.jpg', updated_at = NOW() WHERE name = 'Cheesy Mushroom Beef Burger' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792490588/edueats/menu-items/092b889e-b29a-432f-930c-e7bde9c6a20d.jpg', updated_at = NOW() WHERE name = 'Masala Steak Burger' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792492277/edueats/menu-items/884ade26-7327-4ec4-a9c6-748f9373ea6b.jpg', updated_at = NOW() WHERE name = 'Polony Gatsby' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792490363/edueats/menu-items/ab27c360-4749-4fd7-a95a-c4e9fc811665.png', updated_at = NOW() WHERE name = 'Chicken Gatsby' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792491072/edueats/menu-items/d1e56ca9-437b-4b65-a204-29359d4f8f7c.jpg', updated_at = NOW() WHERE name = 'Grilled Chicken Wrap' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792491525/edueats/menu-items/b9679554-5cb4-45a1-8367-af01be2140b6.jpg', updated_at = NOW() WHERE name = 'Crumbed Chicken Wrap' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792491654/edueats/menu-items/0e8a19e8-7591-4278-a019-13d7bea21471.jpg', updated_at = NOW() WHERE name = 'Cheese Sandwich' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792491883/edueats/menu-items/18b0defe-ff3a-43ee-80f9-830717feedf2.jpg', updated_at = NOW() WHERE name = 'Chicken Mayo Sandwich' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792492726/edueats/menu-items/bfa8af55-7145-45ce-a7e4-b9e57f0a7911.jpg', updated_at = NOW() WHERE name = 'Chip Roll' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792492802/edueats/menu-items/33e9e0ec-b9e3-4a2c-8718-7ae3761a4f61.jpg', updated_at = NOW() WHERE name = 'Russian Roll' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792492950/edueats/menu-items/87e14c7b-cde2-4727-8812-b4f7d21d96d1.jpg', updated_at = NOW() WHERE name = 'Chicken Strips (5 pieces)' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792493156/edueats/menu-items/5f5281f2-4e78-4ef2-aaec-08b271ddc70c.jpg', updated_at = NOW() WHERE name = 'Hot Chips' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792493380/edueats/menu-items/2f3803b3-81f6-4e88-98d3-803b5f5bd677.jpg', updated_at = NOW() WHERE name = 'Greek Salad' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792493550/edueats/menu-items/ea566a9f-358d-415a-9584-3b42a8f72e61.jpg', updated_at = NOW() WHERE name = 'Butter Chicken' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792493780/edueats/menu-items/bdcb0b6c-79c9-4e03-a65d-57ec676d6ba0.jpg', updated_at = NOW() WHERE name = 'Pizza Slice' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792493947/edueats/menu-items/67e2d008-abe7-4e5c-96a1-7eac88893f07.jpg', updated_at = NOW() WHERE name = 'Macaroni & Cheese' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792494048/edueats/menu-items/abc20ee9-3c5f-4bab-8510-c84983f87ded.jpg', updated_at = NOW() WHERE name = 'Coffee' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792494312/edueats/menu-items/ad889c4e-4644-4069-8abe-290294ecf83a.jpg', updated_at = NOW() WHERE name = 'Tea' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792494331/edueats/menu-items/c830af3d-caf8-4820-9856-f7dbad596f9d.jpg', updated_at = NOW() WHERE name = 'Hot Chocolate' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497583/edueats/menu-items/914e2b97-7391-454a-8c16-e8cdcea21172.png', updated_at = NOW() WHERE name = 'Jive 500ml' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497610/edueats/menu-items/83ea39ed-6683-4cd6-86af-94f8e6e3360c.jpg', updated_at = NOW() WHERE name = 'Juice' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497664/edueats/menu-items/8e20f646-5d9e-4430-aedd-7e0d9a32121b.jpg', updated_at = NOW() WHERE name = 'Water 500ml' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497680/edueats/menu-items/18a19169-71a7-4ce2-8af8-ce7d127b579a.jpg', updated_at = NOW() WHERE name = 'Red Bull' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497731/edueats/menu-items/75395941-d919-4b0b-95ef-8ed108bded16.jpg', updated_at = NOW() WHERE name = 'Passion Fruit Mocktail' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497773/edueats/menu-items/ef117e10-93c3-4b54-9f0c-8f53c8ddda2e.jpg', updated_at = NOW() WHERE name = 'Watermelon Mint Mocktail' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497786/edueats/menu-items/e84b5416-82bd-4497-99cd-8f361f71200a.jpg', updated_at = NOW() WHERE name = 'Brownie' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497833/edueats/menu-items/115ad142-ed9a-414e-9589-396624a4ad86.jpg', updated_at = NOW() WHERE name = 'Cheesecake' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497947/edueats/menu-items/295fff95-d22e-40a5-8dc6-1546aa6282e4.jpg', updated_at = NOW() WHERE name = 'Cinnamon Donut' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497972/edueats/menu-items/2cb8a1f2-bed4-4c23-8d31-3ae4880f79c3.jpg', updated_at = NOW() WHERE name = 'Lay''s 36g' AND available = 1;
UPDATE menu_items SET image_path = 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792498017/edueats/menu-items/67930a0a-b14a-4a0d-b8dc-8d271ba75a90.jpg', updated_at = NOW() WHERE name = 'Doritos' AND available = 1;

COMMIT;

-- Check: should say 36
SELECT COUNT(*) AS items_with_photos FROM menu_items WHERE available = 1 AND image_path IS NOT NULL;
