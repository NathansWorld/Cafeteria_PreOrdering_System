-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 28, 2026 at 12:38 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

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
(1, 'Burgers', 1, '2026-07-12 10:32:40', '2026-07-12 10:32:40'),
(2, 'Drinks', 5, '2026-09-21 13:00:35', '2026-09-21 13:00:35'),
(3, 'Desserts', 3, '2026-09-28 07:44:07', '2026-09-28 07:44:07');

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
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `menu_items`
--

INSERT INTO `menu_items` (`menu_item_id`, `category_id`, `name`, `description`, `price`, `available`, `image_path`, `display_order`, `created_at`, `updated_at`) VALUES
(1, 1, 'Classic Beef Burger', '150g flame-grilled patty with cheddar cheese', 55.00, 1, NULL, 1, '2026-07-12 11:22:26', '2026-07-17 10:45:10'),
(2, 1, 'Spicy Chicken Burger', 'Crispy chicken breast with spicy mayo', 65.00, 1, NULL, 2, '2026-09-28 07:46:17', '2026-09-28 07:46:17');

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
(1, 1, 1, '2026-07-13 13:31:17', '2026-07-13 13:31:17'),
(1, 2, 2, '2026-09-28 08:07:17', '2026-09-28 08:07:17');

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
(1, 1, 'BBQ Sauce', 0.50, 1, 0, '2026-07-14 08:18:53', '2026-07-14 08:18:53'),
(2, 1, 'Garlic Mayo', 0.00, 1, 0, '2026-07-14 08:20:10', '2026-07-14 08:20:10'),
(3, 1, 'BBQ Sauce', 5.00, 1, 0, '2026-09-28 08:09:51', '2026-09-28 08:09:51');

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
(1, 'Choose Your Sauce', 0, 1, 1, '2026-07-13 13:31:16', '2026-07-13 13:31:16', b'0'),
(2, 'Choose Sauce', 0, 1, NULL, '2026-09-28 08:07:17', '2026-09-28 08:07:17', b'0');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `order_id` bigint(20) NOT NULL,
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
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `user_id`, `status_id`, `customer_order_number`, `collected_at`, `total_price`, `created_at`, `updated_at`) VALUES
(1, 1, 3, 'ORD-20260714-5ECD', NULL, 111.00, '2026-07-14 15:32:43', '2026-09-28 10:34:48'),
(2, 1, 2, 'ORD-20260714-7955', NULL, 111.00, '2026-07-14 15:36:47', '2026-07-15 11:20:45'),
(3, 1, 1, 'ORD-20260717-5B96', NULL, 111.00, '2026-07-17 13:18:44', '2026-07-17 13:18:44'),
(4, 1, 2, 'ORD-20260920-134B', NULL, 111.00, '2026-09-20 13:58:21', '2026-09-22 13:56:06'),
(5, 1, 1, 'ORD-20260923-A7B9', NULL, 55.00, '2026-09-23 10:18:13', '2026-09-23 10:18:13'),
(6, 1, 6, 'ORD-20260923-5DCA', NULL, 55.00, '2026-09-23 10:40:25', '2026-09-23 10:40:25'),
(7, 1, 1, 'ORD-20260923-D3F7', NULL, 55.00, '2026-09-23 11:19:28', '2026-09-23 11:19:28'),
(8, 1, 6, 'ORD-20260923-F9F5', NULL, 55.00, '2026-09-23 11:19:29', '2026-09-23 11:19:29'),
(9, 1, 1, 'ORD-20260923-353D', NULL, 55.00, '2026-09-23 11:23:02', '2026-09-23 11:23:02'),
(10, 1, 6, 'ORD-20260923-1C38', NULL, 55.00, '2026-09-23 11:23:04', '2026-09-23 11:23:04'),
(11, 1, 1, 'ORD-20260923-B173', NULL, 55.00, '2026-09-23 12:14:03', '2026-09-23 12:14:03'),
(12, 1, 6, 'ORD-20260923-D4CB', NULL, 55.00, '2026-09-23 12:14:05', '2026-09-23 12:14:05'),
(13, 1, 1, 'ORD-20260923-54C5', NULL, 55.00, '2026-09-23 12:17:55', '2026-09-23 12:17:55'),
(14, 1, 6, 'ORD-20260923-F1AA', NULL, 55.00, '2026-09-23 12:17:56', '2026-09-23 12:17:56'),
(15, 1, 1, 'ORD-20260923-9BE1', NULL, 55.00, '2026-09-23 12:25:15', '2026-09-23 12:25:15'),
(16, 1, 6, 'ORD-20260923-0107', NULL, 55.00, '2026-09-23 12:25:16', '2026-09-23 12:25:16'),
(17, 1, 1, 'ORD-20260923-A724', NULL, 55.00, '2026-09-23 12:29:17', '2026-09-23 12:29:17'),
(18, 1, 6, 'ORD-20260923-51DF', NULL, 55.00, '2026-09-23 12:29:18', '2026-09-23 12:29:18'),
(19, 1, 1, 'ORD-20260923-F5B4', NULL, 55.00, '2026-09-23 12:30:13', '2026-09-23 12:30:13'),
(20, 1, 6, 'ORD-20260923-B875', NULL, 55.00, '2026-09-23 12:30:14', '2026-09-23 12:30:14'),
(21, 1, 1, 'ORD-20260923-369E', NULL, 55.00, '2026-09-23 13:20:52', '2026-09-23 13:20:52'),
(22, 1, 6, 'ORD-20260923-F298', NULL, 55.00, '2026-09-23 13:20:54', '2026-09-23 13:20:54'),
(23, 1, 1, 'ORD-20260923-9149', NULL, 55.00, '2026-09-23 13:23:37', '2026-09-23 13:23:37'),
(24, 1, 6, 'ORD-20260923-E840', NULL, 55.00, '2026-09-23 13:23:38', '2026-09-23 13:23:38'),
(25, 1, 1, 'ORD-20260923-9DBE', NULL, 55.00, '2026-09-23 13:24:44', '2026-09-23 13:24:44'),
(26, 1, 6, 'ORD-20260923-4257', NULL, 55.00, '2026-09-23 13:24:45', '2026-09-23 13:24:45'),
(27, 1, 1, 'ORD-20260923-40A5', NULL, 55.00, '2026-09-23 13:26:21', '2026-09-23 13:26:21'),
(28, 1, 6, 'ORD-20260923-068B', NULL, 55.00, '2026-09-23 13:26:22', '2026-09-23 13:26:22'),
(29, 1, 2, 'ORD-20260923-0672', NULL, 55.00, '2026-09-23 13:26:23', '2026-09-23 13:26:23'),
(30, 1, 1, 'ORD-20260923-E7D9', NULL, 55.00, '2026-09-23 13:30:37', '2026-09-23 13:30:37'),
(31, 1, 6, 'ORD-20260923-B603', NULL, 55.00, '2026-09-23 13:30:38', '2026-09-23 13:30:38'),
(32, 1, 2, 'ORD-20260923-C67F', NULL, 55.00, '2026-09-23 13:30:40', '2026-09-23 13:30:40'),
(33, 1, 1, 'ORD-20260923-D084', NULL, 55.00, '2026-09-23 13:40:29', '2026-09-23 13:40:29'),
(34, 1, 6, 'ORD-20260923-2F61', NULL, 55.00, '2026-09-23 13:40:30', '2026-09-23 13:40:30'),
(35, 1, 2, 'ORD-20260923-49B8', NULL, 55.00, '2026-09-23 13:40:32', '2026-09-23 13:40:32'),
(36, 1, 1, 'ORD-20260924-D800', NULL, 55.00, '2026-09-24 09:25:32', '2026-09-24 09:25:32'),
(37, 1, 6, 'ORD-20260924-0ABB', NULL, 55.00, '2026-09-24 09:25:34', '2026-09-24 09:25:34'),
(38, 1, 2, 'ORD-20260924-0C87', NULL, 55.00, '2026-09-24 09:25:37', '2026-09-24 09:25:37'),
(39, 5, 1, 'ORD-20260924-0A8F', NULL, 55.50, '2026-09-24 12:08:29', '2026-09-24 12:08:29'),
(40, 5, 1, 'ORD-20260924-8252', NULL, 55.50, '2026-09-24 12:32:39', '2026-09-24 12:32:39'),
(41, 5, 1, 'ORD-20260924-5D84', NULL, 55.50, '2026-09-24 12:33:49', '2026-09-24 12:33:49'),
(42, 5, 1, 'ORD-20260924-C7A0', NULL, 55.50, '2026-09-24 12:40:51', '2026-09-24 12:40:51'),
(43, 5, 1, 'ORD-20260925-D781', NULL, 55.50, '2026-09-25 10:20:50', '2026-09-25 10:20:50'),
(44, 5, 1, 'ORD-20260925-85CC', NULL, 55.50, '2026-09-25 10:25:24', '2026-09-25 10:25:24'),
(45, 5, 1, 'ORD-20260925-D4AD', NULL, 55.50, '2026-09-25 10:26:45', '2026-09-25 10:26:45'),
(51, 1, 1, 'ORD-20260926-51A7', NULL, 55.00, '2026-09-26 08:31:11', '2026-09-26 08:31:11'),
(52, 1, 6, 'ORD-20260926-27F2', NULL, 55.00, '2026-09-26 08:31:13', '2026-09-26 08:31:13'),
(53, 1, 2, 'ORD-20260926-506D', NULL, 55.00, '2026-09-26 08:31:14', '2026-09-26 08:31:14'),
(54, 5, 1, 'ORD-20260926-4FF3', NULL, 55.50, '2026-09-26 08:37:06', '2026-09-26 08:37:06'),
(55, 5, 1, 'ORD-20260926-C3D2', NULL, 55.50, '2026-09-26 08:38:11', '2026-09-26 08:38:11'),
(56, 1, 1, 'ORD-20260928-32A8', NULL, 55.00, '2026-09-28 07:18:22', '2026-09-28 07:18:22'),
(57, 1, 6, 'ORD-20260928-7BFC', NULL, 55.00, '2026-09-28 07:18:23', '2026-09-28 07:18:24'),
(58, 1, 2, 'ORD-20260928-9EAD', NULL, 55.00, '2026-09-28 07:18:27', '2026-09-28 07:18:27'),
(59, 1, 1, 'ORD-20260928-7394', NULL, 111.00, '2026-09-28 08:17:03', '2026-09-28 08:17:03'),
(60, 1, 1, 'ORD-20260928-7959', NULL, 111.00, '2026-09-28 08:22:37', '2026-09-28 08:22:37');

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
(1, 1, 1, 2, 'Classic Beef Burger', 55.00, 'Well done please', '2026-07-14 15:32:43', '2026-07-14 15:32:43'),
(2, 2, 1, 2, 'Classic Beef Burger', 55.00, 'Well done please', '2026-07-14 15:36:47', '2026-07-14 15:36:47'),
(3, 3, 1, 2, 'Classic Beef Burger', 55.00, 'Well done please', '2026-07-17 13:18:44', '2026-07-17 13:18:44'),
(4, 4, 1, 2, 'Classic Beef Burger', 55.00, 'Well done please', '2026-09-20 13:58:21', '2026-09-20 13:58:21'),
(5, 5, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-23 10:18:13', '2026-09-23 10:18:13'),
(6, 6, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-23 10:40:25', '2026-09-23 10:40:25'),
(7, 7, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-23 11:19:28', '2026-09-23 11:19:28'),
(8, 8, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-23 11:19:29', '2026-09-23 11:19:29'),
(9, 9, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-23 11:23:02', '2026-09-23 11:23:02'),
(10, 10, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-23 11:23:04', '2026-09-23 11:23:04'),
(11, 11, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-23 12:14:03', '2026-09-23 12:14:03'),
(12, 12, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-23 12:14:05', '2026-09-23 12:14:05'),
(13, 13, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-23 12:17:55', '2026-09-23 12:17:55'),
(14, 14, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-23 12:17:56', '2026-09-23 12:17:56'),
(15, 15, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-23 12:25:15', '2026-09-23 12:25:15'),
(16, 16, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-23 12:25:16', '2026-09-23 12:25:16'),
(17, 17, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-23 12:29:17', '2026-09-23 12:29:17'),
(18, 18, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-23 12:29:18', '2026-09-23 12:29:18'),
(19, 19, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-23 12:30:13', '2026-09-23 12:30:13'),
(20, 20, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-23 12:30:14', '2026-09-23 12:30:14'),
(21, 21, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-23 13:20:52', '2026-09-23 13:20:52'),
(22, 22, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-23 13:20:54', '2026-09-23 13:20:54'),
(23, 23, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-23 13:23:37', '2026-09-23 13:23:37'),
(24, 24, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-23 13:23:38', '2026-09-23 13:23:38'),
(25, 25, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-23 13:24:44', '2026-09-23 13:24:44'),
(26, 26, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-23 13:24:45', '2026-09-23 13:24:45'),
(27, 27, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-23 13:26:21', '2026-09-23 13:26:21'),
(28, 28, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-23 13:26:22', '2026-09-23 13:26:22'),
(29, 29, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-09-23 13:26:23', '2026-09-23 13:26:23'),
(30, 30, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-23 13:30:37', '2026-09-23 13:30:37'),
(31, 31, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-23 13:30:38', '2026-09-23 13:30:38'),
(32, 32, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-09-23 13:30:40', '2026-09-23 13:30:40'),
(33, 33, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-23 13:40:29', '2026-09-23 13:40:29'),
(34, 34, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-23 13:40:30', '2026-09-23 13:40:30'),
(35, 35, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-09-23 13:40:32', '2026-09-23 13:40:32'),
(36, 36, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-24 09:25:32', '2026-09-24 09:25:32'),
(37, 37, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-24 09:25:34', '2026-09-24 09:25:34'),
(38, 38, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-09-24 09:25:37', '2026-09-24 09:25:37'),
(39, 39, 1, 1, 'Classic Beef Burger', 55.00, 'Extra toasted, no onions', '2026-09-24 12:08:29', '2026-09-24 12:08:29'),
(40, 40, 1, 1, 'Classic Beef Burger', 55.00, 'Extra toasted, no onions', '2026-09-24 12:32:39', '2026-09-24 12:32:39'),
(41, 41, 1, 1, 'Classic Beef Burger', 55.00, 'Extra toasted, no onions', '2026-09-24 12:33:49', '2026-09-24 12:33:49'),
(42, 42, 1, 1, 'Classic Beef Burger', 55.00, 'Extra toasted, no onions', '2026-09-24 12:40:51', '2026-09-24 12:40:51'),
(43, 43, 1, 1, 'Classic Beef Burger', 55.00, 'Extra toasted, no onions', '2026-09-25 10:20:50', '2026-09-25 10:20:50'),
(44, 44, 1, 1, 'Classic Beef Burger', 55.00, 'Extra toasted, no onions', '2026-09-25 10:25:24', '2026-09-25 10:25:24'),
(45, 45, 1, 1, 'Classic Beef Burger', 55.00, 'Extra toasted, no onions', '2026-09-25 10:26:45', '2026-09-25 10:26:45'),
(47, 51, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-26 08:31:11', '2026-09-26 08:31:11'),
(48, 52, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-26 08:31:13', '2026-09-26 08:31:13'),
(49, 53, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-09-26 08:31:14', '2026-09-26 08:31:14'),
(50, 54, 1, 1, 'Classic Beef Burger', 55.00, 'Extra toasted, no onions', '2026-09-26 08:37:06', '2026-09-26 08:37:06'),
(51, 55, 1, 1, 'Classic Beef Burger', 55.00, 'Extra toasted, no onions', '2026-09-26 08:38:11', '2026-09-26 08:38:11'),
(52, 56, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-09-28 07:18:22', '2026-09-28 07:18:22'),
(53, 57, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-09-28 07:18:23', '2026-09-28 07:18:23'),
(54, 58, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-09-28 07:18:27', '2026-09-28 07:18:27'),
(55, 59, 1, 2, 'Classic Beef Burger', 55.00, 'Well done please', '2026-09-28 08:17:03', '2026-09-28 08:17:03'),
(56, 60, 1, 2, 'Classic Beef Burger', 55.00, 'Well done please', '2026-09-28 08:22:37', '2026-09-28 08:22:37');

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
(1, 1, 1, 'BBQ Sauce', 0.50, '2026-07-14 15:32:43'),
(2, 1, 2, 'Garlic Mayo', 0.00, '2026-07-14 15:32:43'),
(3, 2, 1, 'BBQ Sauce', 0.50, '2026-07-14 15:36:47'),
(4, 2, 2, 'Garlic Mayo', 0.00, '2026-07-14 15:36:47'),
(5, 3, 1, 'BBQ Sauce', 0.50, '2026-07-17 13:18:44'),
(6, 3, 2, 'Garlic Mayo', 0.00, '2026-07-17 13:18:44'),
(7, 4, 1, 'BBQ Sauce', 0.50, '2026-09-20 13:58:21'),
(8, 4, 2, 'Garlic Mayo', 0.00, '2026-09-20 13:58:21'),
(9, 39, 1, 'BBQ Sauce', 0.50, '2026-09-24 12:08:29'),
(10, 39, 2, 'Garlic Mayo', 0.00, '2026-09-24 12:08:29'),
(11, 40, 1, 'BBQ Sauce', 0.50, '2026-09-24 12:32:39'),
(12, 40, 2, 'Garlic Mayo', 0.00, '2026-09-24 12:32:39'),
(13, 41, 1, 'BBQ Sauce', 0.50, '2026-09-24 12:33:49'),
(14, 41, 2, 'Garlic Mayo', 0.00, '2026-09-24 12:33:49'),
(15, 42, 1, 'BBQ Sauce', 0.50, '2026-09-24 12:40:51'),
(16, 42, 2, 'Garlic Mayo', 0.00, '2026-09-24 12:40:51'),
(17, 43, 1, 'BBQ Sauce', 0.50, '2026-09-25 10:20:50'),
(18, 43, 2, 'Garlic Mayo', 0.00, '2026-09-25 10:20:50'),
(19, 44, 1, 'BBQ Sauce', 0.50, '2026-09-25 10:25:24'),
(20, 44, 2, 'Garlic Mayo', 0.00, '2026-09-25 10:25:24'),
(21, 45, 1, 'BBQ Sauce', 0.50, '2026-09-25 10:26:45'),
(22, 45, 2, 'Garlic Mayo', 0.00, '2026-09-25 10:26:45'),
(23, 50, 1, 'BBQ Sauce', 0.50, '2026-09-26 08:37:06'),
(24, 50, 2, 'Garlic Mayo', 0.00, '2026-09-26 08:37:06'),
(25, 51, 1, 'BBQ Sauce', 0.50, '2026-09-26 08:38:11'),
(26, 51, 2, 'Garlic Mayo', 0.00, '2026-09-26 08:38:11'),
(27, 55, 1, 'BBQ Sauce', 0.50, '2026-09-28 08:17:03'),
(28, 55, 2, 'Garlic Mayo', 0.00, '2026-09-28 08:17:03'),
(29, 56, 1, 'BBQ Sauce', 0.50, '2026-09-28 08:22:37'),
(30, 56, 2, 'Garlic Mayo', 0.00, '2026-09-28 08:22:37');

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
(1, 4, 2, NULL, '2026-09-22 13:11:08'),
(2, 4, 1, NULL, '2026-09-22 13:29:15'),
(3, 4, 2, NULL, '2026-09-22 13:41:46'),
(4, 4, 1, NULL, '2026-09-22 13:46:53'),
(5, 4, 2, NULL, '2026-09-22 13:56:06'),
(6, 4, 2, NULL, '2026-09-22 13:58:02'),
(7, 4, 2, NULL, '2026-09-22 14:01:56'),
(8, 4, 2, NULL, '2026-09-22 14:14:31'),
(9, 4, 2, NULL, '2026-09-22 14:21:07'),
(10, 4, 2, NULL, '2026-09-22 14:27:26'),
(11, 4, 2, NULL, '2026-09-23 09:48:53'),
(12, 1, 6, NULL, '2026-09-23 10:34:26'),
(13, 6, 6, NULL, '2026-09-23 10:40:25'),
(14, 8, 6, NULL, '2026-09-23 11:19:29'),
(15, 4, 2, NULL, '2026-09-23 11:19:30'),
(16, 10, 6, NULL, '2026-09-23 11:23:04'),
(17, 4, 2, NULL, '2026-09-23 11:23:05'),
(18, 12, 6, NULL, '2026-09-23 12:14:05'),
(19, 4, 2, NULL, '2026-09-23 12:14:06'),
(20, 14, 6, NULL, '2026-09-23 12:17:56'),
(21, 4, 2, NULL, '2026-09-23 12:17:57'),
(22, 16, 6, NULL, '2026-09-23 12:25:16'),
(23, 4, 2, NULL, '2026-09-23 12:25:17'),
(24, 18, 6, NULL, '2026-09-23 12:29:18'),
(25, 4, 2, NULL, '2026-09-23 12:29:20'),
(26, 20, 6, NULL, '2026-09-23 12:30:14'),
(27, 4, 2, NULL, '2026-09-23 12:30:16'),
(28, 22, 6, NULL, '2026-09-23 13:20:54'),
(29, 4, 2, NULL, '2026-09-23 13:20:55'),
(30, 24, 6, NULL, '2026-09-23 13:23:38'),
(31, 4, 2, NULL, '2026-09-23 13:23:40'),
(32, 26, 6, NULL, '2026-09-23 13:24:45'),
(33, 4, 2, NULL, '2026-09-23 13:24:46'),
(34, 28, 6, NULL, '2026-09-23 13:26:22'),
(35, 29, 2, NULL, '2026-09-23 13:26:23'),
(36, 31, 6, NULL, '2026-09-23 13:30:38'),
(37, 32, 2, NULL, '2026-09-23 13:30:40'),
(38, 34, 6, NULL, '2026-09-23 13:40:30'),
(39, 35, 2, NULL, '2026-09-23 13:40:32'),
(40, 37, 6, NULL, '2026-09-24 09:25:34'),
(41, 38, 2, NULL, '2026-09-24 09:25:37'),
(42, 52, 6, NULL, '2026-09-26 08:31:13'),
(43, 53, 2, NULL, '2026-09-26 08:31:14'),
(44, 57, 6, NULL, '2026-09-28 07:18:23'),
(45, 58, 2, NULL, '2026-09-28 07:18:27'),
(46, 1, 3, NULL, '2026-09-28 10:34:48');

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
  `password_hash` varchar(255) NOT NULL,
  `role_id` bigint(20) NOT NULL,
  `active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `customer_code`, `first_name`, `last_name`, `email`, `password_hash`, `role_id`, `active`, `created_at`, `updated_at`) VALUES
(1, 'STU99887', 'Alice', 'Smith', 'alice@campus.edu', '$2a$10$7R.v/u3xZ.bV9N9IeU.kZgQfE8Jg1u3u0i7cZ/2wD3q1234567890', 3, 1, '2026-07-10 14:05:36', '2026-09-18 09:16:05'),
(4, 'CUST-F1BCB0', 'Bob', 'Jones', 'bob@campus.edu', '$2a$10$h9Kt.sI061ynenuRduInq.eEsq9GsuyQrgrM5O34QEhq3rx2HU10u', 4, 1, '2026-09-18 09:53:50', '2026-09-18 09:53:50'),
(5, 'CUST-585FB1', 'Charlie', 'Brown', 'charlie@campus.edu', '$2a$10$giHY3ul6ViF23Afsg0.7U.ErWT2v3RMS31kBPazBl5VP9B2l7VN5C', 1, 1, '2026-09-20 10:44:29', '2026-09-20 10:53:22'),
(6, 'CUST-32D494', 'Charlie', 'Brown', 'charlie2@campus.edu', '$2a$10$0rQy1jNLRXEKZ3fVyJLoSuCROUTl0zrWrz9taZeA4DogKIYOzJtqq', 1, 1, '2026-09-26 10:56:00', '2026-09-28 07:36:25'),
(7, 'STU12345', 'John', 'Doe', 'john.doe@campus.edu', '$2a$10$e7...', 3, 1, '2026-09-28 07:32:39', '2026-09-28 07:32:39');

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
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `category_default_groups`
--
ALTER TABLE `category_default_groups`
  MODIFY `category_default_group_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `menu_items`
--
ALTER TABLE `menu_items`
  MODIFY `menu_item_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `modifiers`
--
ALTER TABLE `modifiers`
  MODIFY `modifier_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `modifier_groups`
--
ALTER TABLE `modifier_groups`
  MODIFY `modifier_group_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `order_item_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT for table `order_item_modifiers`
--
ALTER TABLE `order_item_modifiers`
  MODIFY `order_item_modifier_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `order_status`
--
ALTER TABLE `order_status`
  MODIFY `status_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `order_status_history`
--
ALTER TABLE `order_status_history`
  MODIFY `status_history_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `role_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

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
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_roles` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
