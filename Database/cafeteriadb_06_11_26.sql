-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 06, 2026 at 02:58 PM
-- Server version: 10.11.16-MariaDB
-- PHP Version: 8.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cafeteriadb`
--

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `category_id` bigint(20) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `display_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`category_id`, `category_name`, `display_order`, `created_at`, `updated_at`) VALUES
(1, 'Burgers', 2, '2026-07-12 10:32:40', '2026-10-21 13:48:15'),
(3, 'Desserts', 9, '2026-09-28 07:44:07', '2026-10-21 13:48:15'),
(14, 'Breakfast', 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(16, 'Cape Town Favourites', 3, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(17, 'Wraps & Sandwiches', 4, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(18, 'Rolls & Sides', 5, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(19, 'Hot Meals', 6, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(20, 'Hot Drinks', 7, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(21, 'Cold Drinks', 8, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(23, 'Snacks', 10, '2026-10-21 13:48:15', '2026-10-21 13:48:15');

-- --------------------------------------------------------

--
-- Table structure for table `category_default_groups`
--

CREATE TABLE `category_default_groups` (
  `category_default_group_id` bigint(20) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `modifier_group_id` bigint(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `menu_items`
--

CREATE TABLE `menu_items` (
  `menu_item_id` bigint(20) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `available` tinyint(1) DEFAULT 1,
  `image_path` varchar(255) DEFAULT NULL,
  `display_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `stock_quantity` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `menu_items`
--

INSERT INTO `menu_items` (`menu_item_id`, `category_id`, `name`, `description`, `price`, `available`, `image_path`, `display_order`, `created_at`, `updated_at`, `stock_quantity`) VALUES
(10, 14, 'Breakfast Sandwich', 'Scrambled or sunny-side up eggs and cheese.', 35.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792483959/edueats/menu-items/40176f61-106f-4f21-b1a4-edb507ed6384.jpg', 1, '2026-10-21 13:48:15', '2026-11-01 12:08:54', 1),
(11, 14, 'Breakfast Wrap', 'A toasted wrap filled with scrambled egg.', 40.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792163085/edueats/menu-items/0172f1cf-6cda-4e22-b9f9-e9562d3d39a8.jpg', 2, '2026-10-21 13:48:15', '2026-11-03 10:00:17', 30),
(12, 14, 'Omelette', 'A fluffy egg dish with cheese.', 45.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792484376/edueats/menu-items/aeeee96c-3316-4e9a-8efa-729725c8efc5.jpg', 3, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(13, 14, 'Bubble Waffle', 'Bubble waffle with ice cream. Add a topping and syrup for R15.', 40.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792484421/edueats/menu-items/1d217f6b-680a-4823-aed7-cfccbdbf5576.jpg', 4, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(14, 1, 'Classic Beef Burger', NULL, 35.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792158225/edueats/menu-items/71e1e5ec-dde6-4c35-94a5-617bd2e74e0d.jpg', 1, '2026-10-21 13:48:15', '2026-10-27 08:47:42', 29),
(15, 1, 'Classic Chicken Burger', NULL, 35.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792162639/edueats/menu-items/d538ee0b-4c50-4f51-8290-cfbe14111800.jpg', 2, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(16, 1, 'Cheesy Mushroom Beef Burger', NULL, 55.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792484589/edueats/menu-items/2a5aedfc-284d-4b2b-a063-ab01a53b5cd9.jpg', 3, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(17, 1, 'Masala Steak Burger', NULL, 60.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792490588/edueats/menu-items/092b889e-b29a-432f-930c-e7bde9c6a20d.jpg', 4, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(18, 16, 'Polony Gatsby', 'A full Cape Town gatsby.', 100.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792492277/edueats/menu-items/884ade26-7327-4ec4-a9c6-748f9373ea6b.jpg', 1, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(19, 16, 'Chicken Gatsby', 'A full Cape Town gatsby.', 150.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792490363/edueats/menu-items/ab27c360-4749-4fd7-a95a-c4e9fc811665.png', 2, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(20, 17, 'Grilled Chicken Wrap', NULL, 45.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792491072/edueats/menu-items/d1e56ca9-437b-4b65-a204-29359d4f8f7c.jpg', 1, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(21, 17, 'Crumbed Chicken Wrap', NULL, 45.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792491525/edueats/menu-items/b9679554-5cb4-45a1-8367-af01be2140b6.jpg', 2, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(22, 17, 'Cheese Sandwich', NULL, 25.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792491654/edueats/menu-items/0e8a19e8-7591-4278-a019-13d7bea21471.jpg', 3, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(23, 17, 'Chicken Mayo Sandwich', NULL, 40.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792491883/edueats/menu-items/18b0defe-ff3a-43ee-80f9-830717feedf2.jpg', 4, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(24, 18, 'Chip Roll', NULL, 25.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792492726/edueats/menu-items/bfa8af55-7145-45ce-a7e4-b9e57f0a7911.jpg', 1, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(25, 18, 'Russian Roll', 'Add chips for R10.', 30.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792492802/edueats/menu-items/33e9e0ec-b9e3-4a2c-8718-7ae3761a4f61.jpg', 2, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(26, 18, 'Chicken Strips (5 pieces)', 'Add chips for R10.', 40.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792492950/edueats/menu-items/87e14c7b-cde2-4727-8812-b4f7d21d96d1.jpg', 3, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(27, 18, 'Hot Chips', 'Small or large.', 20.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792493156/edueats/menu-items/5f5281f2-4e78-4ef2-aaec-08b271ddc70c.jpg', 4, '2026-10-21 13:48:15', '2026-10-21 14:33:00', 30),
(28, 18, 'Greek Salad', NULL, 35.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792493380/edueats/menu-items/2f3803b3-81f6-4e88-98d3-803b5f5bd677.jpg', 5, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(29, 19, 'Butter Chicken', NULL, 60.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792493550/edueats/menu-items/ea566a9f-358d-415a-9584-3b42a8f72e61.jpg', 1, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(30, 19, 'Pizza Slice', NULL, 30.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792493780/edueats/menu-items/bdcb0b6c-79c9-4e03-a65d-57ec676d6ba0.jpg', 2, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(31, 19, 'Macaroni & Cheese', NULL, 55.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792493947/edueats/menu-items/67e2d008-abe7-4e5c-96a1-7eac88893f07.jpg', 3, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(32, 20, 'Coffee', NULL, 15.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792494048/edueats/menu-items/abc20ee9-3c5f-4bab-8510-c84983f87ded.jpg', 1, '2026-10-21 13:48:15', '2026-10-27 10:21:47', 30),
(33, 20, 'Tea', 'Ceylon or rooibos tea.', 15.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792494312/edueats/menu-items/ad889c4e-4644-4069-8abe-290294ecf83a.jpg', 2, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(34, 20, 'Hot Chocolate', NULL, 30.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792494331/edueats/menu-items/c830af3d-caf8-4820-9856-f7dbad596f9d.jpg', 3, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(35, 21, 'Jive 500ml', NULL, 13.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497583/edueats/menu-items/914e2b97-7391-454a-8c16-e8cdcea21172.png', 1, '2026-10-21 13:48:15', '2026-10-27 10:37:37', 30),
(36, 21, 'Juice', NULL, 18.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497610/edueats/menu-items/83ea39ed-6683-4cd6-86af-94f8e6e3360c.jpg', 2, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(37, 21, 'Water 500ml', NULL, 10.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497664/edueats/menu-items/8e20f646-5d9e-4430-aedd-7e0d9a32121b.jpg', 3, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(38, 21, 'Red Bull', NULL, 20.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497680/edueats/menu-items/18a19169-71a7-4ce2-8af8-ce7d127b579a.jpg', 4, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(39, 21, 'Passion Fruit Mocktail', NULL, 35.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497731/edueats/menu-items/75395941-d919-4b0b-95ef-8ed108bded16.jpg', 5, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(40, 21, 'Watermelon Mint Mocktail', NULL, 35.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497773/edueats/menu-items/ef117e10-93c3-4b54-9f0c-8f53c8ddda2e.jpg', 6, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(41, 3, 'Brownie', NULL, 16.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497786/edueats/menu-items/e84b5416-82bd-4497-99cd-8f361f71200a.jpg', 1, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(42, 3, 'Cheesecake', NULL, 17.50, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497833/edueats/menu-items/115ad142-ed9a-414e-9589-396624a4ad86.jpg', 2, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(43, 3, 'Cinnamon Donut', NULL, 10.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497947/edueats/menu-items/295fff95-d22e-40a5-8dc6-1546aa6282e4.jpg', 3, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(44, 23, 'Lay\'s 36g', NULL, 12.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792497972/edueats/menu-items/2cb8a1f2-bed4-4c23-8d31-3ae4880f79c3.jpg', 1, '2026-10-21 13:48:15', '2026-11-04 10:07:02', 30),
(45, 23, 'Doritos', NULL, 12.00, 1, 'https://res.cloudinary.com/qpskyxx6/image/upload/v1792498017/edueats/menu-items/67930a0a-b14a-4a0d-b8dc-8d271ba75a90.jpg', 2, '2026-10-21 13:48:15', '2026-10-21 14:33:01', 30),
(46, 14, 'Test Product Chaz', 'This is a product to test local image storage', 12.32, 1, 'http://localhost:8080/uploads/menu-items/23370ad8-d973-45a0-83ca-06b56fde6287.png', 1, '2026-10-30 07:59:27', '2026-11-01 10:17:31', 1);

-- --------------------------------------------------------

--
-- Table structure for table `menu_item_modifier_groups`
--

CREATE TABLE `menu_item_modifier_groups` (
  `menu_item_id` bigint(20) NOT NULL,
  `modifier_group_id` bigint(20) NOT NULL,
  `display_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `menu_item_modifier_groups`
--

INSERT INTO `menu_item_modifier_groups` (`menu_item_id`, `modifier_group_id`, `display_order`, `created_at`, `updated_at`) VALUES
(10, 8, 2, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(10, 13, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(11, 8, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(11, 9, 2, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(12, 10, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(13, 14, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(14, 8, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(14, 9, 3, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(14, 10, 2, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(15, 8, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(15, 9, 3, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(15, 10, 2, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(16, 8, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(16, 9, 3, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(16, 10, 2, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(17, 8, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(17, 9, 3, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(17, 10, 2, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(18, 8, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(18, 9, 2, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(19, 8, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(19, 9, 2, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(20, 8, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(20, 9, 2, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(21, 8, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(21, 9, 2, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(22, 15, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(23, 15, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(24, 8, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(25, 8, 2, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(25, 9, 3, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(25, 11, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(26, 8, 2, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(26, 11, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(27, 8, 2, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(27, 12, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(32, 16, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(33, 17, 2, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(33, 18, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(34, 17, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15');

-- --------------------------------------------------------

--
-- Table structure for table `modifiers`
--

CREATE TABLE `modifiers` (
  `modifier_id` bigint(20) NOT NULL,
  `modifier_group_id` bigint(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `added_price` decimal(10,2) DEFAULT 0.00,
  `available` tinyint(1) DEFAULT 1,
  `display_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `modifiers`
--

INSERT INTO `modifiers` (`modifier_id`, `modifier_group_id`, `name`, `added_price`, `available`, `display_order`, `created_at`, `updated_at`) VALUES
(9, 8, 'Tomato sauce', 0.00, 1, 0, '2026-10-21 13:48:15', '2026-11-01 12:10:17'),
(10, 8, 'BBQ sauce', 0.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(12, 8, 'Mayo', 0.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(13, 8, 'Chilli sauce', 0.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(14, 9, 'No onions', 0.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(15, 9, 'No tomato', 0.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(16, 9, 'No lettuce', 0.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(17, 9, 'No sauce', 0.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(18, 10, 'Fried onions', 5.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(19, 10, 'Avocado', 15.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(20, 11, 'With chips', 10.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(21, 12, 'Small', 0.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(22, 12, 'Large', 20.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(23, 13, 'Scrambled', 0.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(24, 13, 'Sunny-side up', 0.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(25, 14, '1 topping and syrup', 15.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(26, 15, 'Toasted', 0.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(27, 16, 'Extra shot', 6.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(28, 16, 'Syrup', 10.00, 1, 0, '2026-10-21 13:48:15', '2026-10-27 10:06:05'),
(29, 16, 'Oat milk', 10.00, 1, 0, '2026-10-21 13:48:15', '2026-10-27 10:06:13'),
(30, 17, 'Oat milk', 10.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(31, 18, 'Ceylon', 0.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15'),
(32, 18, 'Rooibos', 0.00, 1, 0, '2026-10-21 13:48:15', '2026-10-21 13:48:15');

-- --------------------------------------------------------

--
-- Table structure for table `modifier_groups`
--

CREATE TABLE `modifier_groups` (
  `modifier_group_id` bigint(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `minimum_selections` int(11) DEFAULT 0,
  `maximum_selections` int(11) DEFAULT 1,
  `available` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_required` bit(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `modifier_groups`
--

INSERT INTO `modifier_groups` (`modifier_group_id`, `name`, `minimum_selections`, `maximum_selections`, `available`, `created_at`, `updated_at`, `is_required`) VALUES
(8, 'Sauce', 0, 2, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15', b'0'),
(9, 'Leave out', 0, 4, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15', b'0'),
(10, 'Extras', 0, 2, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15', b'0'),
(11, 'Add chips', 0, 1, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15', b'0'),
(12, 'Size', 1, 1, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15', b'1'),
(13, 'Egg style', 1, 1, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15', b'1'),
(14, 'Toppings', 0, 1, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15', b'0'),
(15, 'How would you like it?', 0, 1, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15', b'0'),
(16, 'Coffee extras', 0, 3, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15', b'0'),
(17, 'Milk', 0, 1, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15', b'0'),
(18, 'Tea', 1, 1, 1, '2026-10-21 13:48:15', '2026-10-21 13:48:15', b'1');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `order_id` bigint(20) DEFAULT NULL,
  `type` varchar(50) NOT NULL,
  `title` varchar(50) NOT NULL,
  `message` text NOT NULL,
  `channel` varchar(50) NOT NULL,
  `delivery_status` varchar(50) NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`notification_id`, `user_id`, `order_id`, `type`, `title`, `message`, `channel`, `delivery_status`, `is_read`, `read_at`, `sent_at`, `created_at`) VALUES
(1, 22, 528, 'ORDER_PLACED', 'Order Placed', 'Your order #ORD-10-25-EL5U has been successfully placed.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:14:49', '2026-10-25 16:14:49'),
(2, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Accepted', 'Your order #ORD-10-25-EL5U is now Accepted.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:14:54', '2026-10-25 16:14:54'),
(3, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Preparing', 'Your order #ORD-10-25-EL5U is now Preparing.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:14:54', '2026-10-25 16:14:54'),
(4, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Accepted', 'Your order #ORD-10-25-EL5U is now Accepted.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:14:55', '2026-10-25 16:14:55'),
(5, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Preparing', 'Your order #ORD-10-25-EL5U is now Preparing.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:14:56', '2026-10-25 16:14:56'),
(6, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Ready', 'Your order #ORD-10-25-EL5U is now Ready.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:14:56', '2026-10-25 16:14:56'),
(7, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Preparing', 'Your order #ORD-10-25-EL5U is now Preparing.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:14:57', '2026-10-25 16:14:57'),
(8, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Ready', 'Your order #ORD-10-25-EL5U is now Ready.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:14:58', '2026-10-25 16:14:58'),
(9, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Collected', 'Your order #ORD-10-25-EL5U is now Collected.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:14:59', '2026-10-25 16:14:59'),
(10, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Ready', 'Your order #ORD-10-25-EL5U is now Ready.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:15:00', '2026-10-25 16:15:00'),
(11, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Collected', 'Your order #ORD-10-25-EL5U is now Collected.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:15:01', '2026-10-25 16:15:01'),
(12, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Ready', 'Your order #ORD-10-25-EL5U is now Ready.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:15:01', '2026-10-25 16:15:01'),
(13, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Preparing', 'Your order #ORD-10-25-EL5U is now Preparing.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:18:14', '2026-10-25 16:18:14'),
(14, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Ready', 'Your order #ORD-10-25-EL5U is now Ready.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:18:15', '2026-10-25 16:18:15'),
(15, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Collected', 'Your order #ORD-10-25-EL5U is now Collected.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:18:16', '2026-10-25 16:18:16'),
(16, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Ready', 'Your order #ORD-10-25-EL5U is now Ready.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:18:18', '2026-10-25 16:18:18'),
(17, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Collected', 'Your order #ORD-10-25-EL5U is now Collected.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:27:33', '2026-10-25 16:27:33'),
(18, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Ready', 'Your order #ORD-10-25-EL5U is now Ready.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:27:51', '2026-10-25 16:27:51'),
(19, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Collected', 'Your order #ORD-10-25-EL5U is now Collected.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:27:52', '2026-10-25 16:27:52'),
(20, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Ready', 'Your order #ORD-10-25-EL5U is now Ready.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:27:53', '2026-10-25 16:27:53'),
(21, 22, 528, 'ORDER_STATUS_UPDATE', 'Order Collected', 'Your order #ORD-10-25-EL5U is now Collected.', 'IN_APP', 'SENT', 0, NULL, '2026-10-25 16:27:54', '2026-10-25 16:27:54'),
(22, 22, 529, 'ORDER_PLACED', 'Order Placed', 'Your order #ORD-10-26-SEEH has been successfully placed.', 'IN_APP', 'SENT', 0, NULL, '2026-10-26 07:40:50', '2026-10-26 07:40:50'),
(23, 22, 529, 'ORDER_STATUS_UPDATE', 'Order Accepted', 'Your order #ORD-10-26-SEEH is now Accepted.', 'IN_APP', 'SENT', 0, NULL, '2026-10-26 07:40:57', '2026-10-26 07:40:57'),
(24, 22, 529, 'ORDER_STATUS_UPDATE', 'Order Preparing', 'Your order #ORD-10-26-SEEH is now Preparing.', 'IN_APP', 'SENT', 0, NULL, '2026-10-26 07:40:57', '2026-10-26 07:40:57'),
(25, 22, 529, 'ORDER_STATUS_UPDATE', 'Order Accepted', 'Your order #ORD-10-26-SEEH is now Accepted.', 'IN_APP', 'SENT', 0, NULL, '2026-10-26 07:41:00', '2026-10-26 07:41:00'),
(26, 22, 529, 'ORDER_STATUS_UPDATE', 'Order Preparing', 'Your order #ORD-10-26-SEEH is now Preparing.', 'IN_APP', 'SENT', 0, NULL, '2026-10-26 07:41:01', '2026-10-26 07:41:01'),
(27, 22, 529, 'ORDER_STATUS_UPDATE', 'Order Ready', 'Your order #ORD-10-26-SEEH is now Ready.', 'IN_APP', 'SENT', 0, NULL, '2026-10-26 07:41:02', '2026-10-26 07:41:02'),
(28, 22, 529, 'ORDER_STATUS_UPDATE', 'Order Preparing', 'Your order #ORD-10-26-SEEH is now Preparing.', 'IN_APP', 'SENT', 0, NULL, '2026-10-26 07:41:03', '2026-10-26 07:41:03'),
(29, 22, 529, 'ORDER_STATUS_UPDATE', 'Order Ready', 'Your order #ORD-10-26-SEEH is now Ready.', 'IN_APP', 'SENT', 0, NULL, '2026-10-26 07:41:04', '2026-10-26 07:41:04'),
(30, 22, 529, 'ORDER_STATUS_UPDATE', 'Order Preparing', 'Your order #ORD-10-26-SEEH is now Preparing.', 'IN_APP', 'SENT', 0, NULL, '2026-10-26 07:41:06', '2026-10-26 07:41:06'),
(31, 22, 529, 'ORDER_STATUS_UPDATE', 'Order Ready', 'Your order #ORD-10-26-SEEH is now Ready.', 'IN_APP', 'SENT', 0, NULL, '2026-10-26 07:41:07', '2026-10-26 07:41:07'),
(32, 22, 529, 'ORDER_STATUS_UPDATE', 'Order Collected', 'Your order #ORD-10-26-SEEH is now Collected.', 'IN_APP', 'SENT', 0, NULL, '2026-10-26 07:41:17', '2026-10-26 07:41:17'),
(33, 22, 530, 'ORDER_PLACED', 'Order Placed', 'Your order #ORD-10-27-NIJH has been successfully placed.', 'IN_APP', 'SENT', 0, NULL, '2026-10-27 08:29:09', '2026-10-27 08:29:09'),
(34, 22, 530, 'ORDER_TIMEOUT', 'Order Expired', 'Your order (ORD-10-27-NIJH) was automatically cancelled because the cafeteria did not accept within 15 minutes.', 'IN_APP', 'SENT', 0, NULL, '2026-10-27 08:47:42', '2026-10-27 08:47:42'),
(35, 22, 531, 'ORDER_PLACED', 'Order Placed', 'Your order #ORD-10-27-JJXJ has been successfully placed.', 'IN_APP', 'SENT', 0, NULL, '2026-10-27 10:06:16', '2026-10-27 10:06:16'),
(36, 22, 531, 'ORDER_TIMEOUT', 'Order Expired', 'Your order (ORD-10-27-JJXJ) was automatically cancelled because the cafeteria did not accept within 15 minutes.', 'IN_APP', 'SENT', 0, NULL, '2026-10-27 10:21:47', '2026-10-27 10:21:47'),
(37, 22, 532, 'ORDER_PLACED', 'Order Placed', 'Your order #ORD-10-27-O7OQ has been successfully placed.', 'IN_APP', 'SENT', 0, NULL, '2026-10-27 10:21:48', '2026-10-27 10:21:48'),
(38, 22, 532, 'ORDER_TIMEOUT', 'Order Expired', 'Your order (ORD-10-27-O7OQ) was automatically cancelled because the cafeteria did not accept within 15 minutes.', 'IN_APP', 'SENT', 0, NULL, '2026-10-27 10:37:37', '2026-10-27 10:37:37'),
(39, 22, 533, 'ORDER_PLACED', 'Order Placed', 'Your order #ORD-11-03-B6MB has been successfully placed.', 'IN_APP', 'SENT', 0, NULL, '2026-11-03 09:44:56', '2026-11-03 09:44:56'),
(40, 22, 533, 'ORDER_TIMEOUT', 'Order Expired', 'Your order (ORD-11-03-B6MB) was automatically cancelled because the cafeteria did not accept within 15 minutes.', 'IN_APP', 'SENT', 0, NULL, '2026-11-03 10:00:17', '2026-11-03 10:00:17'),
(41, 22, 534, 'ORDER_TIMEOUT', 'Order Expired', 'Your order (ORD-11-03-X27W) was automatically cancelled because the cafeteria did not accept within 15 minutes.', 'IN_APP', 'SENT', 0, NULL, '2026-11-03 10:25:12', '2026-11-03 10:25:12'),
(42, 22, 535, 'ORDER_TIMEOUT', 'Order Expired', 'Your order (ORD-11-03-4TZO) was automatically cancelled because the cafeteria did not accept within 15 minutes.', 'IN_APP', 'SENT', 0, NULL, '2026-11-03 10:40:34', '2026-11-03 10:40:34'),
(43, 22, 536, 'ORDER_TIMEOUT', 'Order Expired', 'Your order (ORD-11-03-YZSU) was automatically cancelled because the cafeteria did not accept within 15 minutes.', 'IN_APP', 'SENT', 0, NULL, '2026-11-04 10:07:02', '2026-11-04 10:07:02'),
(44, 22, 537, 'ORDER_TIMEOUT', 'Order Expired', 'Your order (ORD-11-03-C07C) was automatically cancelled because the cafeteria did not accept within 15 minutes.', 'IN_APP', 'SENT', 0, NULL, '2026-11-04 10:07:02', '2026-11-04 10:07:02');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `status_id` bigint(20) NOT NULL,
  `customer_order_number` varchar(20) DEFAULT NULL,
  `collected_at` timestamp NULL DEFAULT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `payment_status` varchar(50) NOT NULL DEFAULT 'PENDING',
  `payfast_payment_id` varchar(100) DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `user_id`, `status_id`, `customer_order_number`, `collected_at`, `total_price`, `payment_status`, `payfast_payment_id`, `paid_at`, `created_at`, `updated_at`) VALUES
(527, 22, 6, 'ORD-10-24-YUUQ', NULL, 40.00, 'PENDING', NULL, NULL, '2026-10-24 08:58:49', '2026-10-24 09:21:27'),
(528, 22, 5, 'ORD-10-25-EL5U', NULL, 35.00, 'PENDING', NULL, NULL, '2026-10-25 16:14:49', '2026-10-25 16:27:54'),
(529, 22, 5, 'ORD-10-26-SEEH', NULL, 35.00, 'PENDING', NULL, NULL, '2026-10-26 07:40:50', '2026-10-26 07:41:17'),
(530, 22, 6, 'ORD-10-27-NIJH', NULL, 35.00, 'PENDING', NULL, NULL, '2026-10-27 08:29:09', '2026-10-27 08:47:42'),
(531, 22, 6, 'ORD-10-27-JJXJ', NULL, 21.00, 'PENDING', NULL, NULL, '2026-10-27 10:06:16', '2026-10-27 10:21:47'),
(532, 22, 6, 'ORD-10-27-O7OQ', NULL, 13.00, 'PENDING', NULL, NULL, '2026-10-27 10:21:48', '2026-10-27 10:37:37'),
(533, 22, 6, 'ORD-11-03-B6MB', NULL, 80.00, 'PENDING', NULL, NULL, '2026-11-03 09:44:56', '2026-11-03 10:00:17'),
(534, 22, 6, 'ORD-11-03-X27W', NULL, 12.00, 'PAID', 'TEST_PF_99999', '2026-11-03 10:13:02', '2026-11-03 10:10:06', '2026-11-03 10:25:12'),
(535, 22, 6, 'ORD-11-03-4TZO', NULL, 12.00, 'PAID', 'TEST_PF_99999', '2026-11-03 10:20:33', '2026-11-03 10:20:23', '2026-11-03 10:40:34'),
(536, 22, 6, 'ORD-11-03-YZSU', NULL, 12.00, 'PAID', 'TEST_PF_99999', '2026-11-03 10:46:07', '2026-11-03 10:45:48', '2026-11-04 10:07:02'),
(537, 22, 6, 'ORD-11-03-C07C', NULL, 12.00, 'PAID', 'TEST_PF_99999', '2026-11-03 10:55:00', '2026-11-03 10:54:56', '2026-11-04 10:07:02');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `order_item_id` bigint(20) NOT NULL,
  `order_id` bigint(20) NOT NULL,
  `menu_item_id` bigint(20) NOT NULL,
  `quantity` int(11) NOT NULL,
  `menu_item_name_at_purchase` varchar(150) NOT NULL,
  `price_at_purchase` decimal(10,2) NOT NULL,
  `special_instructions` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`order_item_id`, `order_id`, `menu_item_id`, `quantity`, `menu_item_name_at_purchase`, `price_at_purchase`, `special_instructions`, `created_at`, `updated_at`) VALUES
(525, 527, 11, 1, 'Breakfast Wrap', 40.00, '', '2026-10-24 08:58:49', '2026-10-24 08:58:49'),
(526, 528, 14, 1, 'Classic Beef Burger', 35.00, '', '2026-10-25 16:14:49', '2026-10-25 16:14:49'),
(527, 529, 10, 1, 'Breakfast Sandwich', 35.00, '', '2026-10-26 07:40:50', '2026-10-26 07:40:50'),
(528, 530, 14, 1, 'Classic Beef Burger', 35.00, '', '2026-10-27 08:29:09', '2026-10-27 08:29:09'),
(529, 531, 32, 1, 'Coffee', 15.00, 'I like milk', '2026-10-27 10:06:16', '2026-10-27 10:06:16'),
(530, 532, 35, 1, 'Jive 500ml', 13.00, '', '2026-10-27 10:21:48', '2026-10-27 10:21:48'),
(531, 533, 11, 2, 'Breakfast Wrap', 40.00, 'Extra hot', '2026-11-03 09:44:56', '2026-11-03 09:44:56'),
(532, 534, 44, 1, 'Lay\'s 36g', 12.00, 'Postman test order', '2026-11-03 10:10:06', '2026-11-03 10:10:06'),
(533, 535, 44, 1, 'Lay\'s 36g', 12.00, 'Postman test order', '2026-11-03 10:20:23', '2026-11-03 10:20:23'),
(534, 536, 44, 1, 'Lay\'s 36g', 12.00, 'Postman test order', '2026-11-03 10:45:48', '2026-11-03 10:45:48'),
(535, 537, 44, 1, 'Lay\'s 36g', 12.00, 'Postman test order', '2026-11-03 10:54:56', '2026-11-03 10:54:56');

-- --------------------------------------------------------

--
-- Table structure for table `order_item_modifiers`
--

CREATE TABLE `order_item_modifiers` (
  `order_item_modifier_id` bigint(20) NOT NULL,
  `order_item_id` bigint(20) NOT NULL,
  `modifier_id` bigint(20) NOT NULL,
  `modifier_name_at_purchase` varchar(150) NOT NULL,
  `price_at_purchase` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_item_modifiers`
--

INSERT INTO `order_item_modifiers` (`order_item_modifier_id`, `order_item_id`, `modifier_id`, `modifier_name_at_purchase`, `price_at_purchase`, `created_at`) VALUES
(60, 525, 12, 'Mayo', 0.00, '2026-10-24 08:58:49'),
(61, 525, 15, 'No tomato', 0.00, '2026-10-24 08:58:49'),
(62, 527, 24, 'Sunny-side up', 0.00, '2026-10-26 07:40:50'),
(63, 527, 9, 'Tomato sauce', 0.00, '2026-10-26 07:40:50'),
(64, 528, 9, 'Tomato sauce', 0.00, '2026-10-27 08:29:09'),
(65, 528, 10, 'BBQ sauce', 0.00, '2026-10-27 08:29:09'),
(66, 529, 27, 'Extra shot', 6.00, '2026-10-27 10:06:16'),
(67, 531, 12, 'Mayo', 0.00, '2026-11-03 09:44:56');

-- --------------------------------------------------------

--
-- Table structure for table `order_status`
--

CREATE TABLE `order_status` (
  `status_id` bigint(20) NOT NULL,
  `status_name` varchar(50) NOT NULL,
  `sort_order` int(11) DEFAULT 0,
  `is_final` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_status`
--

INSERT INTO `order_status` (`status_id`, `status_name`, `sort_order`, `is_final`, `created_at`, `updated_at`) VALUES
(1, 'Submitted', 1, 0, '2026-07-10 12:14:01', '2026-07-10 12:14:01'),
(2, 'Accepted', 2, 0, '2026-07-10 12:14:01', '2026-07-10 12:14:01'),
(3, 'Preparing', 3, 0, '2026-07-10 12:14:01', '2026-07-10 12:14:01'),
(4, 'Ready', 4, 0, '2026-07-10 12:14:01', '2026-07-10 12:14:01'),
(5, 'Collected', 5, 1, '2026-07-10 12:14:01', '2026-07-10 12:14:01'),
(6, 'Cancelled', 6, 1, '2026-07-10 12:14:01', '2026-07-10 12:14:01');

-- --------------------------------------------------------

--
-- Table structure for table `order_status_history`
--

CREATE TABLE `order_status_history` (
  `status_history_id` bigint(20) NOT NULL,
  `order_id` bigint(20) NOT NULL,
  `status_id` bigint(20) NOT NULL,
  `changed_by_user_id` bigint(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_status_history`
--

INSERT INTO `order_status_history` (`status_history_id`, `order_id`, `status_id`, `changed_by_user_id`, `created_at`) VALUES
(637, 527, 6, NULL, '2026-10-24 09:21:27'),
(638, 528, 2, 20, '2026-10-25 16:14:54'),
(639, 528, 3, 20, '2026-10-25 16:14:54'),
(640, 528, 2, 20, '2026-10-25 16:14:55'),
(641, 528, 3, 20, '2026-10-25 16:14:56'),
(642, 528, 4, 20, '2026-10-25 16:14:56'),
(643, 528, 3, 20, '2026-10-25 16:14:57'),
(644, 528, 4, 20, '2026-10-25 16:14:58'),
(645, 528, 5, 20, '2026-10-25 16:14:59'),
(646, 528, 4, 20, '2026-10-25 16:15:00'),
(647, 528, 5, 20, '2026-10-25 16:15:01'),
(648, 528, 4, 20, '2026-10-25 16:15:01'),
(649, 528, 3, 20, '2026-10-25 16:18:14'),
(650, 528, 4, 20, '2026-10-25 16:18:15'),
(651, 528, 5, 20, '2026-10-25 16:18:16'),
(652, 528, 4, 20, '2026-10-25 16:18:18'),
(653, 528, 5, 21, '2026-10-25 16:27:33'),
(654, 528, 4, 20, '2026-10-25 16:27:51'),
(655, 528, 5, 20, '2026-10-25 16:27:52'),
(656, 528, 4, 20, '2026-10-25 16:27:53'),
(657, 528, 5, 20, '2026-10-25 16:27:54'),
(658, 529, 2, 20, '2026-10-26 07:40:57'),
(659, 529, 3, 20, '2026-10-26 07:40:57'),
(660, 529, 2, 20, '2026-10-26 07:41:00'),
(661, 529, 3, 20, '2026-10-26 07:41:01'),
(662, 529, 4, 20, '2026-10-26 07:41:02'),
(663, 529, 3, 20, '2026-10-26 07:41:03'),
(664, 529, 4, 20, '2026-10-26 07:41:04'),
(665, 529, 3, 20, '2026-10-26 07:41:06'),
(666, 529, 4, 20, '2026-10-26 07:41:07'),
(667, 529, 5, 20, '2026-10-26 07:41:17'),
(668, 530, 6, NULL, '2026-10-27 08:47:42'),
(669, 531, 6, NULL, '2026-10-27 10:21:47'),
(670, 532, 6, NULL, '2026-10-27 10:37:37'),
(671, 533, 6, NULL, '2026-11-03 10:00:17'),
(672, 534, 6, NULL, '2026-11-03 10:25:12'),
(673, 535, 6, NULL, '2026-11-03 10:40:34'),
(674, 536, 6, NULL, '2026-11-04 10:07:02'),
(675, 537, 6, NULL, '2026-11-04 10:07:02');

-- --------------------------------------------------------

--
-- Table structure for table `refresh_tokens`
--

CREATE TABLE `refresh_tokens` (
  `id` bigint(20) NOT NULL,
  `token_hash` varchar(64) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `expires_at` datetime(6) NOT NULL,
  `revoked` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `refresh_tokens`
--

INSERT INTO `refresh_tokens` (`id`, `token_hash`, `user_id`, `expires_at`, `revoked`, `created_at`) VALUES
(206, 'adffc57bfa56971c91aa4217cd62e5cce2cb44dfe56752dfa9b8ddeefc0a8b48', 20, '2026-10-31 08:57:26.000000', 1, '2026-10-24 08:57:26.000000'),
(207, '339aea0baf1fbe4e59b767243225556e0ea4eeb64fcd903ffd199185fc8fef83', 22, '2026-10-31 08:58:21.000000', 1, '2026-10-24 08:58:21.000000'),
(208, '6d1f30fbfe7b8fd62da93db19521079997ab900adb1eee0b6e8ecf6da0928ff6', 20, '2026-10-31 09:21:45.000000', 1, '2026-10-24 09:21:45.000000'),
(209, '6b8a74fc117a041405f457f401c75a908c4e7b3726cc7ac2488e82e9aa27f2b5', 22, '2026-10-31 09:29:12.000000', 1, '2026-10-24 09:29:12.000000'),
(210, '94626bace5b5d1388fb9d21f5c62f16d6fab99e9e29351aa940333cba1184728', 22, '2026-10-31 09:29:24.000000', 1, '2026-10-24 09:29:24.000000'),
(211, 'e6775b6e03419b455a24cd0e761b0cd5e7fb08131df3574a139d325f314c844b', 20, '2026-10-31 09:36:45.000000', 1, '2026-10-24 09:36:45.000000'),
(212, '3c77890463a0d039de4a192b18b97703f2c1ed0b93359f247b05b228a6af7ad8', 22, '2026-10-31 09:44:47.000000', 1, '2026-10-24 09:44:47.000000'),
(213, '709193741af9b70a8e2b7d29536e40571bb12f8ff471e70ef667c8bbacd7c7b4', 20, '2026-10-31 09:51:45.000000', 0, '2026-10-24 09:51:45.000000'),
(214, '0c13c0fceec5cb0de51816740f9de80a81b9d3ff3b181b88f2412144178bcaae', 20, '2026-11-01 16:11:14.000000', 1, '2026-10-25 16:11:14.000000'),
(215, 'b8c8c023b781d2531592be0a3ee7a4d3ed731facf53642939084edfafb9659bd', 20, '2026-11-01 16:12:34.000000', 1, '2026-10-25 16:12:34.000000'),
(216, '22a16a53a4894f74bf1b2314eb1ba0524d0bac26ab4574627a3a2eb37444ab7d', 22, '2026-11-01 16:14:31.000000', 1, '2026-10-25 16:14:31.000000'),
(217, '3e613e12d09cdfffd8bcced4f7cde8b09c597ee483f5a001e0594269daa9dbb1', 21, '2026-11-01 16:18:31.000000', 1, '2026-10-25 16:18:31.000000'),
(218, '2986c7dc6061f4cf721782ca110b40ea0380b7834749807cc8ce131b1c132094', 20, '2026-11-01 16:27:50.000000', 0, '2026-10-25 16:27:50.000000'),
(219, 'b0cb54a538da70ee768f9a2f1208b3a0a8d21502834555932c7a97d1b68e3f61', 22, '2026-11-01 16:29:51.000000', 1, '2026-10-25 16:29:51.000000'),
(220, '82ef76eb1fca4479fdc7920106dc31282c4e13f0331999561cc06112560e989b', 22, '2026-11-02 07:40:02.000000', 0, '2026-10-26 07:40:02.000000'),
(221, '55148df80ecd93c74d3582131106ac6816d614b3d6917350dd5f69476da14cc2', 20, '2026-11-02 07:40:13.000000', 1, '2026-10-26 07:40:13.000000'),
(222, 'fb9fb24ae9a16c6e1f2cb0f41958f8e6e02c9de7358392cb29a60a47ae2f8ae7', 20, '2026-11-02 11:59:47.000000', 1, '2026-10-26 11:59:47.000000'),
(223, 'd54b836f940681dbb2a7eec2de6ebd718e25c77bd4af8f047c71a9877f20ea50', 22, '2026-11-02 12:02:04.000000', 1, '2026-10-26 12:02:04.000000'),
(224, '4080ef18e14dfc11e39acb4afd327a3b40d3150d5b83dc97b1568715b7536ffc', 20, '2026-11-02 12:16:51.000000', 1, '2026-10-26 12:16:51.000000'),
(225, '37eb918bcbb1279493c618caefa2f6799d9a92d7051a0e8a45a7087a868c3dfe', 22, '2026-11-02 12:31:14.000000', 1, '2026-10-26 12:31:14.000000'),
(226, '8d22941af202821ce87cc347d3fae4970d42696668e2c4e6a17701585a265bda', 20, '2026-11-02 13:36:16.000000', 0, '2026-10-26 13:36:16.000000'),
(227, '84f47b5aee45eab1946f9951b12acd6673e3475de14750407ce94d70d02bfa99', 22, '2026-11-02 16:41:13.000000', 1, '2026-10-26 16:41:13.000000'),
(228, '149967d9227183c0a09c4086b3edfd8d365f04c52072bd19aca83134d3643c8e', 20, '2026-11-02 16:42:45.000000', 1, '2026-10-26 16:42:45.000000'),
(229, 'eac62996bad940866617c8e732d9ba06dc2284767f8f253ab102e059deea8b40', 22, '2026-11-03 08:28:16.000000', 1, '2026-10-27 08:28:16.000000'),
(230, '2163c1cb5801c319e11522b6cd7a2082c0d566c4a1fff1b18fba056f146d779d', 22, '2026-11-03 08:28:34.000000', 0, '2026-10-27 08:28:34.000000'),
(231, 'bce9fe9b56134095503cfca8c4c627271fe30c0d1b2f7fee91e6b4e84142b8d4', 20, '2026-11-03 08:28:42.000000', 1, '2026-10-27 08:28:42.000000'),
(232, '1b7a29cb26f5182df0982edf14d2af2ea711f7c323a5989de38d5ad9e815db98', 22, '2026-11-03 08:28:57.000000', 1, '2026-10-27 08:28:57.000000'),
(233, '97e26fa45c2f4f97b29a48f843fa7e545b011e3777576a4b521d3d24fdc30e8a', 20, '2026-11-03 08:43:42.000000', 1, '2026-10-27 08:43:42.000000'),
(234, 'd846b578a8884448ccdfa867fe02457ec92d7b7d93b1de9f70350892d6f3d418', 22, '2026-11-03 08:47:42.000000', 1, '2026-10-27 08:47:42.000000'),
(235, '1616176cc317d739f2deefb3c3d1011da183321de819ba44c147090063ede61b', 20, '2026-11-03 08:59:08.000000', 1, '2026-10-27 08:59:08.000000'),
(236, '5b3dfa71434c4575458550ff5e4d1e56d7aefb62d79dbcc06f3839e613d2f8dc', 20, '2026-11-03 09:14:25.000000', 1, '2026-10-27 09:14:25.000000'),
(237, 'b3491e1fcf8ee4234aecfefc1f5340d3812108f00fe8b8b1472561cd3a0498d8', 20, '2026-11-03 09:29:25.000000', 1, '2026-10-27 09:29:25.000000'),
(238, 'cc018914cba07954e0926708813f3f34bc65daeacb602554dcdbbfbe2ed4802c', 20, '2026-11-03 09:44:25.000000', 1, '2026-10-27 09:44:25.000000'),
(239, '2607e09874bdefad35b303c6a7f7f525dbe99a5f750338799b69e85470b4bd25', 20, '2026-11-03 09:59:25.000000', 1, '2026-10-27 09:59:25.000000'),
(240, 'b7e41ddaba76af88a07e60761b212c106cc7792597d07ee67fd3d93dcf5d9bd8', 22, '2026-11-03 10:03:57.000000', 1, '2026-10-27 10:03:57.000000'),
(241, '82a44bf62dc6b580e0cf574a5db376d7191d1817c6578cd85cfba5ad55f13c18', 20, '2026-11-03 10:14:25.000000', 1, '2026-10-27 10:14:25.000000'),
(242, '1ccccf071945dbc3422fb1169e85115a3e9e31d7bae1c15a870a64c3c0537b74', 22, '2026-11-03 10:20:52.000000', 1, '2026-10-27 10:20:52.000000'),
(243, 'a3f7ce7647fc3437b552685457894ddd1343d243e97ef0477b91c4eb699bb7ed', 20, '2026-11-03 10:29:33.000000', 0, '2026-10-27 10:29:33.000000'),
(244, '4466472a021725d36125137a3b69d4700f0177e49e819bea588ffdf376facc40', 22, '2026-11-03 10:36:23.000000', 0, '2026-10-27 10:36:23.000000'),
(245, 'f6b61bc334efa93e2a600b6339836cf86c32132da083cad512c20a7d44f61dc1', 22, '2026-11-06 07:57:18.000000', 0, '2026-10-30 07:57:18.000000'),
(246, '634f68911c7ed198f59da3c1af6d6a9772f317d8573c626d2acb7712cdd696c4', 20, '2026-11-06 07:57:34.000000', 0, '2026-10-30 07:57:34.000000'),
(247, '271342f8e66ecc8058a8ca08befe04fde68b9441fa75bc00555687a454993f3a', 22, '2026-11-06 10:18:02.000000', 1, '2026-10-30 10:18:02.000000'),
(248, '43059da9f7f4c06ec5982107ee7f30ee1efd2ff9c4a8b237de948920607626b4', 20, '2026-11-06 10:18:23.000000', 0, '2026-10-30 10:18:23.000000'),
(249, 'f26c024e6cf31942f8a0d35abe23642b80d022d0771cb38a5bc1c3943e272383', 20, '2026-11-06 10:18:40.000000', 0, '2026-10-30 10:18:40.000000'),
(250, '1a771fd30fefefb354d9f63075ffb4308acb3a19da6493f4e600782010af9b6d', 22, '2026-11-06 10:18:54.000000', 0, '2026-10-30 10:18:54.000000'),
(251, '4e9955b315c7be8c00ca4320cb10e46e23ed8f5ac4ebce6523e1cd1647bbe73b', 20, '2026-11-06 10:20:05.000000', 0, '2026-10-30 10:20:05.000000'),
(252, '637e001683544c5d8c06914191ce8551489356792aa93429c6b8a3b2e4e72538', 20, '2026-11-06 12:27:47.000000', 0, '2026-10-30 12:27:47.000000'),
(253, '7bb1e00ecafda0fd1c0d07e9457eeb70b6c7a6611d513074a776c85dacd651a3', 20, '2026-11-06 12:30:58.000000', 0, '2026-10-30 12:30:58.000000'),
(254, 'b275d393863b2f18b1add45e16643296fedfa856cfc61af0cef1953637b5be4c', 22, '2026-11-08 10:00:34.000000', 1, '2026-11-01 10:00:34.000000'),
(255, '01ab8365604066755337625f054c2b5ab0c606cdbfd4ae05add5cfd2fe5e009a', 20, '2026-11-08 10:00:45.000000', 1, '2026-11-01 10:00:45.000000'),
(256, '18769f9ed3d3d98fa504bf8c23bde8426f322c61dbf3d28fd41e8a2dc0d525be', 20, '2026-11-08 10:16:53.000000', 1, '2026-11-01 10:16:53.000000'),
(257, '35fce5e94fc055bd10e917f2f4d77280d967a77fb35fe95f8be51522d3ab6607', 22, '2026-11-08 10:16:58.000000', 0, '2026-11-01 10:16:58.000000'),
(258, 'fced6e7adcb405b9251198a703aeccec9beb4f19f2d94fdf6a4cc47427f5d6a6', 22, '2026-11-08 10:17:06.000000', 1, '2026-11-01 10:17:06.000000'),
(259, '862370f742a18cbf31dd7c714a199a1bcc973981f53dacba8e9e6ff541a74360', 22, '2026-11-08 11:11:49.000000', 1, '2026-11-01 11:11:49.000000'),
(260, '67c2d1af14e88b7929758969f0cb4fad1b25ce20a072bb718fff69ae0025a488', 20, '2026-11-08 11:11:51.000000', 1, '2026-11-01 11:11:51.000000'),
(261, '94e9be40b3dfacdc59c5dee68b9b3961316b19f20338853f6806e85d30c31b42', 20, '2026-11-08 11:26:57.000000', 1, '2026-11-01 11:26:57.000000'),
(262, '60440b1c47105a008ee92809849bb304a999e99d3b1616fac97c952f64708b09', 20, '2026-11-08 11:41:57.000000', 1, '2026-11-01 11:41:57.000000'),
(263, 'aefb4c216f65ff551b9a9ba65165d71642804cafd1af6e4432ffb20216f78230', 20, '2026-11-08 11:56:57.000000', 0, '2026-11-01 11:56:57.000000'),
(264, 'b52d01de3f7d2dfa6b5b5d20fada5a3cb43380fa00408223c13a0eae301a6b31', 22, '2026-11-08 12:09:09.000000', 1, '2026-11-01 12:09:09.000000'),
(265, '306fdc2f15e9c1c0fe542be51fdae1e2e3e882794a696f3d7a969036375f5628', 22, '2026-11-08 12:25:57.000000', 1, '2026-11-01 12:25:57.000000'),
(266, '608563f75c4c46b1e5c2f4ad0094bb2e964e751e13f5db545f9e784c4b3d0305', 20, '2026-11-10 09:38:29.000000', 0, '2026-11-03 09:38:29.000000'),
(267, 'a52edf1e8b2cc45a3173021d0b1714c7702860075630b8ec649f8400833441cd', 20, '2026-11-10 09:38:41.000000', 0, '2026-11-03 09:38:41.000000'),
(268, 'cb41f387bdb7fe2832c3c3bf1db46e6ec93ae5b12a7623312db385ded51ba9e1', 22, '2026-11-10 09:42:43.000000', 0, '2026-11-03 09:42:43.000000'),
(269, '67b3cb6ca6a478e2a84841c3cae26714ada0fdbb02e78e0658dbd01b840212a1', 22, '2026-11-10 09:55:53.000000', 1, '2026-11-03 09:55:53.000000'),
(270, '992a07fbcb41417a1d9e3bbd157397e35a9b2fc1dd7bce4b3db43e8090b7cd56', 22, '2026-11-10 09:57:46.000000', 0, '2026-11-03 09:57:46.000000'),
(271, 'b16bbc2f06cf0fe811d3bdb613a9e202e203683977471ae8c9f16e4aa88c8b67', 22, '2026-11-10 10:08:39.000000', 0, '2026-11-03 10:08:39.000000'),
(272, '2fc6aa155c5fc6e0095a7f745872c02bc818d469e17f73186facc7ca5fd812ed', 22, '2026-11-10 10:20:15.000000', 0, '2026-11-03 10:20:15.000000'),
(273, '8cca55492dc792f8d3cf5658fad0a434f5f0f33afbf233ff9536bdce31c42f9c', 22, '2026-11-10 10:44:52.000000', 0, '2026-11-03 10:44:52.000000'),
(274, '7ed79394a0ffe42ee2732b85c319a2625eeb1dd044e3b178a2fa85f4c989f776', 22, '2026-11-10 10:54:44.000000', 0, '2026-11-03 10:54:44.000000'),
(275, '6674e83d1152d6dd06951b20c27011b69e174bf2aeab043ea718ad08636634fa', 22, '2026-11-11 10:07:31.000000', 0, '2026-11-04 10:07:31.000000'),
(276, '557e42b32508ccd0b45d05f22bc47474c04928ec8a7edaefc812b27372f9956e', 20, '2026-11-11 10:07:44.000000', 0, '2026-11-04 10:07:44.000000');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `role_id` bigint(20) NOT NULL,
  `role_name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`role_id`, `role_name`, `created_at`, `updated_at`) VALUES
(1, 'ADMIN', '2026-07-10 12:14:01', '2026-09-28 10:33:24'),
(2, 'STAFF', '2026-07-10 12:14:01', '2026-09-28 10:33:24'),
(3, 'STUDENT', '2026-07-10 12:14:01', '2026-09-28 10:33:24'),
(4, 'CUSTOMER', '2026-09-18 09:44:34', '2026-09-28 10:33:24');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` bigint(20) NOT NULL,
  `customer_code` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role_id` bigint(20) NOT NULL,
  `active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_login` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `customer_code`, `first_name`, `last_name`, `email`, `phone_number`, `password_hash`, `role_id`, `active`, `created_at`, `updated_at`, `last_login`) VALUES
(20, 'CUST-ADM-01', 'System', 'Administrator', 'admin@campus.edu', '+15550101', '$2a$12$OZJUEBBMpc/fqv7tKsRI/euZOMSj7nUk5rjR7hX11JxCQBHq0TlBq', 1, 1, '2026-10-24 08:56:01', '2026-11-04 10:07:44', '2026-11-04 12:07:44'),
(21, 'CUST-STF-02', 'Campus', 'Staff', 'staff@campus.edu', '+15550102', '$2a$12$gU2nXTHKxJnaVRsew48H3uKI9Zl37F6/k1rjXZ2tuhuiNteLDDdR2', 2, 1, '2026-10-24 08:56:01', '2026-10-25 16:18:31', '2026-10-25 18:18:31'),
(22, 'CUST-CUS-03', 'John', 'Doe', 'customer@campus.edu', '+15550103', '$2a$12$NJfdsxahy/UBQCwaVMOpIeMbnEe6NDZi1WYp6n0snvWOaVcfNP2tq', 4, 1, '2026-10-24 08:56:01', '2026-11-04 10:07:31', '2026-11-04 12:07:31');

-- --------------------------------------------------------

--
-- Table structure for table `user_devices`
--

CREATE TABLE `user_devices` (
  `device_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `fcm_token` varchar(512) NOT NULL,
  `device_type` varchar(50) DEFAULT 'WEB_PWA',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`),
  ADD UNIQUE KEY `uq_category_name` (`category_name`);

--
-- Indexes for table `category_default_groups`
--
ALTER TABLE `category_default_groups`
  ADD PRIMARY KEY (`category_default_group_id`),
  ADD UNIQUE KEY `uq_category_group` (`category_id`,`modifier_group_id`),
  ADD KEY `fk_cdg_modifier_group` (`modifier_group_id`);

--
-- Indexes for table `menu_items`
--
ALTER TABLE `menu_items`
  ADD PRIMARY KEY (`menu_item_id`),
  ADD KEY `idx_menu_items_category_id` (`category_id`);

--
-- Indexes for table `menu_item_modifier_groups`
--
ALTER TABLE `menu_item_modifier_groups`
  ADD PRIMARY KEY (`menu_item_id`,`modifier_group_id`),
  ADD KEY `fk_mimg_modifier_group` (`modifier_group_id`);

--
-- Indexes for table `modifiers`
--
ALTER TABLE `modifiers`
  ADD PRIMARY KEY (`modifier_id`),
  ADD KEY `idx_modifiers_group_id` (`modifier_group_id`);

--
-- Indexes for table `modifier_groups`
--
ALTER TABLE `modifier_groups`
  ADD PRIMARY KEY (`modifier_group_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `idx_notifications_user_id` (`user_id`),
  ADD KEY `idx_notifications_order_id` (`order_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD UNIQUE KEY `uq_customer_order_number` (`customer_order_number`),
  ADD KEY `idx_orders_user_id` (`user_id`),
  ADD KEY `idx_orders_status_id` (`status_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`order_item_id`),
  ADD KEY `idx_order_items_order_id` (`order_id`),
  ADD KEY `idx_order_items_menu_item_id` (`menu_item_id`);

--
-- Indexes for table `order_item_modifiers`
--
ALTER TABLE `order_item_modifiers`
  ADD PRIMARY KEY (`order_item_modifier_id`),
  ADD KEY `fk_oim_modifier` (`modifier_id`),
  ADD KEY `fk_oim_order_item` (`order_item_id`);

--
-- Indexes for table `order_status`
--
ALTER TABLE `order_status`
  ADD PRIMARY KEY (`status_id`),
  ADD UNIQUE KEY `uq_status_name` (`status_name`);

--
-- Indexes for table `order_status_history`
--
ALTER TABLE `order_status_history`
  ADD PRIMARY KEY (`status_history_id`),
  ADD KEY `idx_status_history_order_id` (`order_id`),
  ADD KEY `fk_osh_status` (`status_id`),
  ADD KEY `fk_osh_user` (`changed_by_user_id`);

--
-- Indexes for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_refresh_token_hash` (`token_hash`),
  ADD KEY `fk_refresh_token_user` (`user_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`role_id`),
  ADD UNIQUE KEY `uq_role_name` (`role_name`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `uq_email` (`email`),
  ADD UNIQUE KEY `uq_customer_code` (`customer_code`),
  ADD KEY `idx_users_role_id` (`role_id`);

--
-- Indexes for table `user_devices`
--
ALTER TABLE `user_devices`
  ADD PRIMARY KEY (`device_id`),
  ADD UNIQUE KEY `uq_fcm_token` (`fcm_token`),
  ADD KEY `idx_user_devices_user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `category_default_groups`
--
ALTER TABLE `category_default_groups`
  MODIFY `category_default_group_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `menu_items`
--
ALTER TABLE `menu_items`
  MODIFY `menu_item_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT for table `modifiers`
--
ALTER TABLE `modifiers`
  MODIFY `modifier_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `modifier_groups`
--
ALTER TABLE `modifier_groups`
  MODIFY `modifier_group_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=538;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `order_item_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=536;

--
-- AUTO_INCREMENT for table `order_item_modifiers`
--
ALTER TABLE `order_item_modifiers`
  MODIFY `order_item_modifier_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT for table `order_status`
--
ALTER TABLE `order_status`
  MODIFY `status_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `order_status_history`
--
ALTER TABLE `order_status_history`
  MODIFY `status_history_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=676;

--
-- AUTO_INCREMENT for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=277;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `role_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `user_devices`
--
ALTER TABLE `user_devices`
  MODIFY `device_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `category_default_groups`
--
ALTER TABLE `category_default_groups`
  ADD CONSTRAINT `fk_cdg_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`),
  ADD CONSTRAINT `fk_cdg_modifier_group` FOREIGN KEY (`modifier_group_id`) REFERENCES `modifier_groups` (`modifier_group_id`);

--
-- Constraints for table `menu_items`
--
ALTER TABLE `menu_items`
  ADD CONSTRAINT `fk_menu_items_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`);

--
-- Constraints for table `menu_item_modifier_groups`
--
ALTER TABLE `menu_item_modifier_groups`
  ADD CONSTRAINT `fk_mimg_menu_item` FOREIGN KEY (`menu_item_id`) REFERENCES `menu_items` (`menu_item_id`),
  ADD CONSTRAINT `fk_mimg_modifier_group` FOREIGN KEY (`modifier_group_id`) REFERENCES `modifier_groups` (`modifier_group_id`);

--
-- Constraints for table `modifiers`
--
ALTER TABLE `modifiers`
  ADD CONSTRAINT `fk_modifiers_group` FOREIGN KEY (`modifier_group_id`) REFERENCES `modifier_groups` (`modifier_group_id`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notifications_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  ADD CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_status` FOREIGN KEY (`status_id`) REFERENCES `order_status` (`status_id`),
  ADD CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_order_items_menu_item` FOREIGN KEY (`menu_item_id`) REFERENCES `menu_items` (`menu_item_id`),
  ADD CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`);

--
-- Constraints for table `order_item_modifiers`
--
ALTER TABLE `order_item_modifiers`
  ADD CONSTRAINT `fk_oim_modifier` FOREIGN KEY (`modifier_id`) REFERENCES `modifiers` (`modifier_id`),
  ADD CONSTRAINT `fk_oim_order_item` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`order_item_id`);

--
-- Constraints for table `order_status_history`
--
ALTER TABLE `order_status_history`
  ADD CONSTRAINT `fk_osh_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  ADD CONSTRAINT `fk_osh_status` FOREIGN KEY (`status_id`) REFERENCES `order_status` (`status_id`),
  ADD CONSTRAINT `fk_osh_user` FOREIGN KEY (`changed_by_user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD CONSTRAINT `fk_refresh_token_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_roles` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`);

--
-- Constraints for table `user_devices`
--
ALTER TABLE `user_devices`
  ADD CONSTRAINT `fk_user_devices_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
