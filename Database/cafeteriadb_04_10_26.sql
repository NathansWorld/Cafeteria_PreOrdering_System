-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 04, 2026 at 12:36 PM
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
(3, 'Desserts', 3, '2026-09-28 07:44:07', '2026-09-28 07:44:07'),
(4, 'Beverages4', 1, '2026-10-02 08:58:05', '2026-10-02 08:58:05'),
(5, 'Beverages48', 1, '2026-10-03 10:53:50', '2026-10-03 10:53:50');

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
(2, 1, 'Spicy Chicken Burger', 'Crispy chicken breast with spicy mayo', 65.00, 1, NULL, 2, '2026-09-28 07:46:17', '2026-09-28 07:46:17'),
(3, 4, 'Cappuccino2', 'Rich espresso with steamed milk foam', 32.50, 1, NULL, 0, '2026-10-02 08:58:26', '2026-10-02 08:58:26'),
(4, 5, 'Cappuccino2', 'Rich espresso with steamed milk foam', 32.50, 1, NULL, 0, '2026-10-03 10:53:59', '2026-10-03 10:53:59');

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
(1, 2, 2, '2026-09-28 08:07:17', '2026-09-28 08:07:17'),
(1, 3, 3, '2026-10-02 08:59:09', '2026-10-02 08:59:09'),
(1, 4, 4, '2026-10-03 10:54:19', '2026-10-03 10:54:19');

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
(3, 1, 'BBQ Sauce', 5.00, 1, 0, '2026-09-28 08:09:51', '2026-09-28 08:09:51'),
(4, 2, 'Oat Milk', NULL, 1, 0, '2026-10-02 08:58:50', '2026-10-02 08:58:50'),
(5, 4, 'Oat Milk', NULL, 1, 0, '2026-10-03 10:54:24', '2026-10-03 10:54:24');

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
(2, 'Choose Sauce', 0, 1, NULL, '2026-09-28 08:07:17', '2026-09-28 08:07:17', b'0'),
(3, 'Milk Options', 1, 1, NULL, '2026-10-02 08:59:09', '2026-10-02 08:59:09', b'1'),
(4, 'Milk Options', 1, 1, NULL, '2026-10-03 10:54:19', '2026-10-03 10:54:19', b'1');

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
(60, 1, 1, 'ORD-20260928-7959', NULL, 111.00, '2026-09-28 08:22:37', '2026-09-28 08:22:37'),
(61, 1, 1, 'ORD-20261001-2C4A', NULL, 55.00, '2026-10-01 13:32:37', '2026-10-01 13:32:37'),
(62, 1, 6, 'ORD-20261001-7F54', NULL, 55.00, '2026-10-01 13:32:38', '2026-10-01 13:32:38'),
(63, 1, 2, 'ORD-20261001-990F', NULL, 55.00, '2026-10-01 13:32:40', '2026-10-01 13:32:40'),
(64, 1, 1, 'ORD-20261001-5B59', NULL, 55.00, '2026-10-01 13:34:54', '2026-10-01 13:34:54'),
(65, 1, 6, 'ORD-20261001-C9AB', NULL, 55.00, '2026-10-01 13:34:55', '2026-10-01 13:34:56'),
(66, 1, 2, 'ORD-20261001-4B4E', NULL, 55.00, '2026-10-01 13:34:58', '2026-10-01 13:34:58'),
(67, 1, 1, 'ORD-20261001-F00D', NULL, 55.00, '2026-10-01 14:41:48', '2026-10-01 14:41:48'),
(68, 1, 6, 'ORD-20261001-6FC9', NULL, 55.00, '2026-10-01 14:41:49', '2026-10-01 14:41:49'),
(69, 1, 2, 'ORD-20261001-2868', NULL, 55.00, '2026-10-01 14:41:50', '2026-10-01 14:41:51'),
(70, 1, 1, 'ORD-20261001-BB9A', NULL, 55.00, '2026-10-01 14:51:02', '2026-10-01 14:51:02'),
(71, 1, 6, 'ORD-20261001-E371', NULL, 55.00, '2026-10-01 14:51:03', '2026-10-01 14:51:03'),
(72, 1, 2, 'ORD-20261001-F8B7', NULL, 55.00, '2026-10-01 14:51:06', '2026-10-01 14:51:06'),
(73, 1, 1, 'ORD-20261001-63D2', NULL, 55.00, '2026-10-01 14:54:03', '2026-10-01 14:54:03'),
(74, 1, 6, 'ORD-20261001-F3DD', NULL, 55.00, '2026-10-01 14:54:04', '2026-10-01 14:54:04'),
(75, 1, 2, 'ORD-20261001-38F0', NULL, 55.00, '2026-10-01 14:54:08', '2026-10-01 14:54:08'),
(76, 1, 1, 'ORD-20261001-2136', NULL, 55.00, '2026-10-01 15:01:12', '2026-10-01 15:01:12'),
(77, 1, 6, 'ORD-20261001-5E64', NULL, 55.00, '2026-10-01 15:01:13', '2026-10-01 15:01:13'),
(78, 1, 2, 'ORD-20261001-C3A9', NULL, 55.00, '2026-10-01 15:01:17', '2026-10-01 15:01:17'),
(79, 1, 1, 'ORD-20261002-30D0', NULL, 55.00, '2026-10-02 08:48:08', '2026-10-02 08:48:08'),
(80, 1, 6, 'ORD-20261002-4445', NULL, 55.00, '2026-10-02 08:48:09', '2026-10-02 08:48:09'),
(81, 1, 2, 'ORD-20261002-DDD6', NULL, 55.00, '2026-10-02 08:48:13', '2026-10-02 08:48:14'),
(82, 1, 1, 'ORD-20261002-DCC3', NULL, 65.00, '2026-10-02 09:00:28', '2026-10-02 09:00:28'),
(83, 1, 1, 'ORD-20261002-ACEB', NULL, 55.00, '2026-10-02 10:02:17', '2026-10-02 10:02:17'),
(84, 1, 6, 'ORD-20261002-FA1C', NULL, 55.00, '2026-10-02 10:02:19', '2026-10-02 10:02:19'),
(85, 1, 2, 'ORD-20261002-0C69', NULL, 55.00, '2026-10-02 10:02:22', '2026-10-02 10:02:22'),
(86, 1, 1, 'ORD-20261002-F5E1', NULL, 55.00, '2026-10-02 12:10:24', '2026-10-02 12:10:24'),
(87, 1, 6, 'ORD-20261002-7F8B', NULL, 55.00, '2026-10-02 12:10:25', '2026-10-02 12:10:25'),
(88, 1, 2, 'ORD-20261002-33E6', NULL, 55.00, '2026-10-02 12:10:29', '2026-10-02 12:10:29'),
(89, 1, 1, 'ORD-20261002-F81A', NULL, 65.00, '2026-10-02 12:12:18', '2026-10-02 12:12:18'),
(90, 1, 1, 'ORD-20261002-3460', NULL, 55.00, '2026-10-02 12:20:21', '2026-10-02 12:20:21'),
(91, 5, 6, 'ORD-20261002-5569', NULL, 55.00, '2026-10-02 12:20:23', '2026-10-02 12:20:23'),
(92, 1, 2, 'ORD-20261002-5747', NULL, 55.00, '2026-10-02 12:20:26', '2026-10-02 12:20:26'),
(93, 10, 1, 'ORD-20261002-CCA6', NULL, 65.00, '2026-10-02 12:21:25', '2026-10-02 12:21:25'),
(94, 5, 6, 'ORD-20261003-A5C7', NULL, 55.00, '2026-10-03 08:03:32', '2026-10-03 08:03:32'),
(95, 1, 1, 'ORD-20261003-F408', NULL, 55.00, '2026-10-03 08:03:33', '2026-10-03 08:03:33'),
(96, 1, 2, 'ORD-20261003-6767', NULL, 55.00, '2026-10-03 08:03:35', '2026-10-03 08:03:35'),
(97, 1, 1, 'ORD-20261003-87EA', NULL, 55.00, '2026-10-03 08:06:36', '2026-10-03 08:06:36'),
(98, 5, 6, 'ORD-20261003-81EE', NULL, 55.00, '2026-10-03 08:06:37', '2026-10-03 08:06:38'),
(99, 1, 2, 'ORD-20261003-3078', NULL, 55.00, '2026-10-03 08:06:41', '2026-10-03 08:06:41'),
(100, 10, 1, 'ORD-20261003-8AAA', NULL, 65.00, '2026-10-03 08:11:38', '2026-10-03 08:11:38'),
(101, 1, 1, 'ORD-20261003-CA8E', NULL, 55.00, '2026-10-03 09:27:38', '2026-10-03 09:27:38'),
(102, 5, 6, 'ORD-20261003-CDFA', NULL, 55.00, '2026-10-03 09:27:39', '2026-10-03 09:27:40'),
(103, 1, 2, 'ORD-20261003-EBB1', NULL, 55.00, '2026-10-03 09:27:43', '2026-10-03 09:27:44'),
(104, 1, 1, 'ORD-20261003-2FBC', NULL, 55.00, '2026-10-03 09:35:25', '2026-10-03 09:35:25'),
(105, 5, 6, 'ORD-20261003-BF6A', NULL, 55.00, '2026-10-03 09:35:26', '2026-10-03 09:35:26'),
(106, 1, 2, 'ORD-20261003-E2B3', NULL, 55.00, '2026-10-03 09:35:30', '2026-10-03 09:35:30'),
(107, 1, 1, 'ORD-20261003-21F9', NULL, 55.00, '2026-10-03 10:39:50', '2026-10-03 10:39:50'),
(108, 5, 6, 'ORD-20261003-9F6B', NULL, 55.00, '2026-10-03 10:40:05', '2026-10-03 10:40:05'),
(109, 1, 2, 'ORD-20261003-B327', NULL, 55.00, '2026-10-03 10:40:07', '2026-10-03 10:40:07'),
(110, 1, 1, 'ORD-20261003-B03C', NULL, 55.00, '2026-10-03 10:45:09', '2026-10-03 10:45:09'),
(111, 5, 6, 'ORD-20261003-9DB5', NULL, 55.00, '2026-10-03 10:45:23', '2026-10-03 10:45:23'),
(112, 1, 2, 'ORD-20261003-B729', NULL, 55.00, '2026-10-03 10:45:25', '2026-10-03 10:45:25'),
(113, 10, 3, 'ORD-20261003-2619', NULL, 65.00, '2026-10-03 10:48:54', '2026-10-03 10:55:44'),
(114, 10, 1, 'ORD-20261003-D0CC', NULL, 65.00, '2026-10-03 12:43:21', '2026-10-03 12:43:21'),
(115, 1, 1, 'ORD-20261004-9D1F', NULL, 55.00, '2026-10-04 08:56:46', '2026-10-04 08:56:46'),
(116, 5, 6, 'ORD-20261004-964C', NULL, 55.00, '2026-10-04 08:56:58', '2026-10-04 08:56:58'),
(117, 1, 2, 'ORD-20261004-8E14', NULL, 55.00, '2026-10-04 08:57:00', '2026-10-04 08:57:00'),
(118, 1, 1, 'ORD-20261004-43E5', NULL, 55.00, '2026-10-04 09:04:38', '2026-10-04 09:04:38'),
(119, 5, 6, 'ORD-20261004-746E', NULL, 55.00, '2026-10-04 09:04:52', '2026-10-04 09:04:52'),
(120, 1, 2, 'ORD-20261004-B015', NULL, 55.00, '2026-10-04 09:04:54', '2026-10-04 09:04:54'),
(121, 1, 1, 'ORD-20261004-6CA9', NULL, 55.00, '2026-10-04 09:29:34', '2026-10-04 09:29:34'),
(122, 5, 6, 'ORD-20261004-CD7C', NULL, 55.00, '2026-10-04 09:29:51', '2026-10-04 09:29:52'),
(123, 1, 2, 'ORD-20261004-88EE', NULL, 55.00, '2026-10-04 09:29:54', '2026-10-04 09:29:54');

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
(56, 60, 1, 2, 'Classic Beef Burger', 55.00, 'Well done please', '2026-09-28 08:22:37', '2026-09-28 08:22:37'),
(57, 61, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-01 13:32:37', '2026-10-01 13:32:37'),
(58, 62, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-01 13:32:38', '2026-10-01 13:32:38'),
(59, 63, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-01 13:32:40', '2026-10-01 13:32:40'),
(60, 64, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-01 13:34:54', '2026-10-01 13:34:54'),
(61, 65, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-01 13:34:55', '2026-10-01 13:34:55'),
(62, 66, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-01 13:34:58', '2026-10-01 13:34:58'),
(63, 67, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-01 14:41:48', '2026-10-01 14:41:48'),
(64, 68, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-01 14:41:49', '2026-10-01 14:41:49'),
(65, 69, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-01 14:41:50', '2026-10-01 14:41:50'),
(66, 70, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-01 14:51:02', '2026-10-01 14:51:02'),
(67, 71, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-01 14:51:03', '2026-10-01 14:51:03'),
(68, 72, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-01 14:51:06', '2026-10-01 14:51:06'),
(69, 73, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-01 14:54:03', '2026-10-01 14:54:03'),
(70, 74, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-01 14:54:04', '2026-10-01 14:54:04'),
(71, 75, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-01 14:54:08', '2026-10-01 14:54:08'),
(72, 76, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-01 15:01:12', '2026-10-01 15:01:12'),
(73, 77, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-01 15:01:13', '2026-10-01 15:01:13'),
(74, 78, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-01 15:01:17', '2026-10-01 15:01:17'),
(75, 79, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-02 08:48:08', '2026-10-02 08:48:08'),
(76, 80, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-02 08:48:09', '2026-10-02 08:48:09'),
(77, 81, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-02 08:48:13', '2026-10-02 08:48:13'),
(78, 82, 3, 2, 'Cappuccino2', 32.50, 'Extra hot', '2026-10-02 09:00:28', '2026-10-02 09:00:28'),
(79, 83, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-02 10:02:17', '2026-10-02 10:02:17'),
(80, 84, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-02 10:02:19', '2026-10-02 10:02:19'),
(81, 85, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-02 10:02:22', '2026-10-02 10:02:22'),
(82, 86, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-02 12:10:24', '2026-10-02 12:10:24'),
(83, 87, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-02 12:10:25', '2026-10-02 12:10:25'),
(84, 88, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-02 12:10:29', '2026-10-02 12:10:29'),
(85, 89, 3, 2, 'Cappuccino2', 32.50, 'Extra hot', '2026-10-02 12:12:18', '2026-10-02 12:12:18'),
(86, 90, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-02 12:20:21', '2026-10-02 12:20:21'),
(87, 91, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-02 12:20:23', '2026-10-02 12:20:23'),
(88, 92, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-02 12:20:26', '2026-10-02 12:20:26'),
(89, 93, 3, 2, 'Cappuccino2', 32.50, 'Extra hot', '2026-10-02 12:21:25', '2026-10-02 12:21:25'),
(90, 94, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-03 08:03:32', '2026-10-03 08:03:32'),
(91, 95, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-03 08:03:33', '2026-10-03 08:03:33'),
(92, 96, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-03 08:03:35', '2026-10-03 08:03:35'),
(93, 97, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-03 08:06:36', '2026-10-03 08:06:36'),
(94, 98, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-03 08:06:37', '2026-10-03 08:06:37'),
(95, 99, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-03 08:06:41', '2026-10-03 08:06:41'),
(96, 100, 3, 2, 'Cappuccino2', 32.50, 'Extra hot', '2026-10-03 08:11:38', '2026-10-03 08:11:38'),
(97, 101, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-03 09:27:38', '2026-10-03 09:27:38'),
(98, 102, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-03 09:27:39', '2026-10-03 09:27:39'),
(99, 103, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-03 09:27:43', '2026-10-03 09:27:43'),
(100, 104, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-03 09:35:25', '2026-10-03 09:35:25'),
(101, 105, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-03 09:35:26', '2026-10-03 09:35:26'),
(102, 106, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-03 09:35:30', '2026-10-03 09:35:30'),
(103, 107, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-03 10:39:50', '2026-10-03 10:39:50'),
(104, 108, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-03 10:40:05', '2026-10-03 10:40:05'),
(105, 109, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-03 10:40:07', '2026-10-03 10:40:07'),
(106, 110, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-03 10:45:09', '2026-10-03 10:45:09'),
(107, 111, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-03 10:45:23', '2026-10-03 10:45:23'),
(108, 112, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-03 10:45:25', '2026-10-03 10:45:25'),
(109, 113, 3, 2, 'Cappuccino2', 32.50, 'Extra hot', '2026-10-03 10:48:54', '2026-10-03 10:48:54'),
(110, 114, 4, 2, 'Cappuccino2', 32.50, 'Extra hot', '2026-10-03 12:43:21', '2026-10-03 12:43:21'),
(111, 115, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-04 08:56:46', '2026-10-04 08:56:46'),
(112, 116, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-04 08:56:58', '2026-10-04 08:56:58'),
(113, 117, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-04 08:57:00', '2026-10-04 08:57:00'),
(114, 118, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-04 09:04:38', '2026-10-04 09:04:38'),
(115, 119, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-04 09:04:52', '2026-10-04 09:04:52'),
(116, 120, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-04 09:04:54', '2026-10-04 09:04:54'),
(117, 121, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket checkout test', '2026-10-04 09:29:34', '2026-10-04 09:29:34'),
(118, 122, 1, 1, 'Classic Beef Burger', 55.00, 'WebSocket cancellation test', '2026-10-04 09:29:51', '2026-10-04 09:29:51'),
(119, 123, 1, 1, 'Classic Beef Burger', 55.00, 'Status update test', '2026-10-04 09:29:54', '2026-10-04 09:29:54');

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
(30, 56, 2, 'Garlic Mayo', 0.00, '2026-09-28 08:22:37'),
(31, 78, 4, 'Oat Milk', 0.00, '2026-10-02 09:00:28'),
(32, 85, 4, 'Oat Milk', 0.00, '2026-10-02 12:12:18'),
(33, 89, 4, 'Oat Milk', 0.00, '2026-10-02 12:21:25'),
(34, 96, 4, 'Oat Milk', 0.00, '2026-10-03 08:11:38'),
(35, 109, 4, 'Oat Milk', 0.00, '2026-10-03 10:48:54'),
(36, 110, 5, 'Oat Milk', 0.00, '2026-10-03 12:43:21');

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
(46, 1, 3, NULL, '2026-09-28 10:34:48'),
(47, 62, 6, NULL, '2026-10-01 13:32:38'),
(48, 63, 2, NULL, '2026-10-01 13:32:40'),
(49, 65, 6, NULL, '2026-10-01 13:34:56'),
(50, 66, 2, NULL, '2026-10-01 13:34:58'),
(51, 68, 6, NULL, '2026-10-01 14:41:49'),
(52, 69, 2, NULL, '2026-10-01 14:41:51'),
(53, 71, 6, NULL, '2026-10-01 14:51:03'),
(54, 72, 2, NULL, '2026-10-01 14:51:06'),
(55, 74, 6, NULL, '2026-10-01 14:54:04'),
(56, 75, 2, NULL, '2026-10-01 14:54:08'),
(57, 77, 6, NULL, '2026-10-01 15:01:13'),
(58, 78, 2, NULL, '2026-10-01 15:01:17'),
(59, 80, 6, NULL, '2026-10-02 08:48:09'),
(60, 81, 2, NULL, '2026-10-02 08:48:14'),
(61, 84, 6, NULL, '2026-10-02 10:02:19'),
(62, 85, 2, NULL, '2026-10-02 10:02:22'),
(63, 87, 6, NULL, '2026-10-02 12:10:25'),
(64, 88, 2, NULL, '2026-10-02 12:10:29'),
(65, 91, 6, NULL, '2026-10-02 12:20:23'),
(66, 92, 2, NULL, '2026-10-02 12:20:26'),
(67, 94, 6, NULL, '2026-10-03 08:03:32'),
(68, 96, 2, NULL, '2026-10-03 08:03:35'),
(69, 98, 6, NULL, '2026-10-03 08:06:38'),
(70, 99, 2, NULL, '2026-10-03 08:06:41'),
(71, 102, 6, NULL, '2026-10-03 09:27:40'),
(72, 103, 2, NULL, '2026-10-03 09:27:44'),
(73, 105, 6, NULL, '2026-10-03 09:35:26'),
(74, 106, 2, NULL, '2026-10-03 09:35:30'),
(75, 108, 6, NULL, '2026-10-03 10:40:05'),
(76, 109, 2, NULL, '2026-10-03 10:40:07'),
(77, 111, 6, NULL, '2026-10-03 10:45:23'),
(78, 112, 2, NULL, '2026-10-03 10:45:25'),
(79, 113, 3, NULL, '2026-10-03 10:55:44'),
(80, 116, 6, NULL, '2026-10-04 08:56:58'),
(81, 117, 2, NULL, '2026-10-04 08:57:00'),
(82, 119, 6, NULL, '2026-10-04 09:04:52'),
(83, 120, 2, NULL, '2026-10-04 09:04:54'),
(84, 122, 6, NULL, '2026-10-04 09:29:52'),
(85, 123, 2, NULL, '2026-10-04 09:29:54');

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
(1, '797eef4f10606fb47b965619e83ca904ca11712274d04df7986bee8f5ccf1747', 9, '2026-10-08 13:39:52.000000', 0, '2026-10-01 13:39:52.000000'),
(2, 'b00aec02dbef79c2ef475adb281cb542f89772d3630534d7592be30a7ed53c75', 10, '2026-10-09 08:57:36.000000', 0, '2026-10-02 08:57:36.000000'),
(3, 'd26f953f723752f1ed365eb487274bb8e32d74b1a40d1a1cfe0726a21c194129', 10, '2026-10-09 08:57:42.000000', 1, '2026-10-02 08:57:42.000000'),
(4, '2c7d19c23165878ced5bd52b521fbd396447f650af824f6ea11929ee9d9eb921', 10, '2026-10-09 09:09:22.000000', 1, '2026-10-02 09:09:22.000000'),
(5, 'fe465f69b2177acb26ff9c779d2477d578fc672766aaab06ce1e02bcbca632d3', 10, '2026-10-09 09:09:33.000000', 1, '2026-10-02 09:09:33.000000'),
(6, 'a7a1c8ca47c8c4f5d7623c667861e746b1aa68dae1c6e384de0e17b8ac03c050', 10, '2026-10-09 09:09:44.000000', 0, '2026-10-02 09:09:44.000000'),
(7, '83fbbd887239f83866745934ba68941e115b017ea7cb4604224c2a96423dfacc', 10, '2026-10-09 10:03:11.000000', 0, '2026-10-02 10:03:11.000000'),
(8, '65b7944524da8e2595ee046ebceb33c7c4a59db4c694979d2f0123a877c39405', 10, '2026-10-09 12:12:10.000000', 0, '2026-10-02 12:12:10.000000'),
(9, '36a1bea1d4ecef63f8b963514f5180bb90f91e1abac3beaa4256a4702ea3a527', 10, '2026-10-09 12:21:18.000000', 0, '2026-10-02 12:21:18.000000'),
(10, '96d99eac344ef3bf90586a80dc362d13e86efd375f55061127f41be1bc9c0666', 10, '2026-10-10 08:07:56.000000', 1, '2026-10-03 08:07:56.000000'),
(11, '327bffa907cf36d2da2f4926cc995924bb1ae1c36eaba09c47c53ca0294dff13', 10, '2026-10-10 10:47:35.000000', 1, '2026-10-03 10:47:35.000000'),
(12, '7d088cfc8b94a54e5400e219dd8ac3e69714f411672eb499ad306215d292ad52', 10, '2026-10-10 10:53:36.000000', 1, '2026-10-03 10:53:36.000000'),
(13, '9849c63a01eb639ae31c238a12dcfdcd2f75a233f262c1a64620109d284e0fe6', 10, '2026-10-10 12:40:28.000000', 0, '2026-10-03 12:40:28.000000'),
(14, '8e1fa5f96f205af544fad229b7d4e1d5c674d1009b0aefd8f2818eb2e49150f5', 10, '2026-10-10 12:43:17.000000', 0, '2026-10-03 12:43:17.000000'),
(15, '69e8a8c825cc43468b313f0e1dbf8b5e020e7d6a5465c53446d0276ba040bbfe', 10, '2026-10-11 09:34:42.000000', 0, '2026-10-04 09:34:43.000000');

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
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `customer_code`, `first_name`, `last_name`, `email`, `phone_number`, `password_hash`, `role_id`, `active`, `created_at`, `updated_at`) VALUES
(1, 'STU99887', 'Alice', 'Smith', 'alice@campus.edu', NULL, '$2a$10$7R.v/u3xZ.bV9N9IeU.kZgQfE8Jg1u3u0i7cZ/2wD3q1234567890', 3, 1, '2026-07-10 14:05:36', '2026-09-18 09:16:05'),
(4, 'CUST-F1BCB0', 'Bob', 'Jones', 'bob@campus.edu', NULL, '$2a$10$h9Kt.sI061ynenuRduInq.eEsq9GsuyQrgrM5O34QEhq3rx2HU10u', 4, 1, '2026-09-18 09:53:50', '2026-09-18 09:53:50'),
(5, 'CUST-585FB1', 'Charlie', 'Brown', 'charlie@campus.edu', NULL, '$2a$10$giHY3ul6ViF23Afsg0.7U.ErWT2v3RMS31kBPazBl5VP9B2l7VN5C', 1, 1, '2026-09-20 10:44:29', '2026-09-20 10:53:22'),
(6, 'CUST-32D494', 'Charlie', 'Brown', 'charlie2@campus.edu', NULL, '$2a$10$0rQy1jNLRXEKZ3fVyJLoSuCROUTl0zrWrz9taZeA4DogKIYOzJtqq', 1, 1, '2026-09-26 10:56:00', '2026-09-28 07:36:25'),
(7, 'STU12345', 'John', 'Doe', 'john.doe@campus.edu', NULL, '$2a$10$e7...', 3, 1, '2026-09-28 07:32:39', '2026-09-28 07:32:39'),
(8, 'CUST-6FA8C8', 'Charlie', 'Brown', 'charli22222e@campus.edu', NULL, '$2a$10$B3ac2/EPpyXoTqrWrFItY.TZOrXwXI9y30HjfVearAhzLv0SVqnKa', 4, 1, '2026-09-29 13:05:33', '2026-09-29 13:05:33'),
(9, 'CUST-E3CF40', 'Refresh', 'Tester', 'refresh@test.com', NULL, '$2a$10$CrGKzNwXLM6nU7D9qqsEJeSz1AE/vanQrdM8MWYEDNHpHrlrjXGUa', 4, 1, '2026-10-01 13:39:52', '2026-10-01 13:39:52'),
(10, 'CUST-C8FCCF', 'paul', 'john', 'john@campus.edu', NULL, '$2a$10$H.QLaDYbnUyDD.nqVzRJaOab8FancP3btWSsT/NpxuCw1K5bhC7JS', 4, 1, '2026-10-02 08:57:36', '2026-10-03 12:42:21'),
(11, 'CUST-300279', 'Staff', 'Member', 'staff.membe9r@eduvos.com', NULL, '$2a$10$IqkKkQoMKlAdcQRdiKT6jesbhSmQ7kRYlLWHbgR8dEYRb4AsJNyBC', 3, 1, '2026-10-02 09:02:40', '2026-10-02 09:02:40'),
(12, 'CUST-7342D0', 'Staff3', 'Member3', 'staff.membe9dsadasr@eduvos.com', NULL, '$2a$10$iDA9rYw0jIEjbXa6JQj4t.lPK76YqjjmOGyqoSZ2xiG1FXYWbLSzm', 3, 1, '2026-10-03 10:56:44', '2026-10-03 10:56:44');

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
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `category_default_groups`
--
ALTER TABLE `category_default_groups`
  MODIFY `category_default_group_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `menu_items`
--
ALTER TABLE `menu_items`
  MODIFY `menu_item_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `modifiers`
--
ALTER TABLE `modifiers`
  MODIFY `modifier_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `modifier_groups`
--
ALTER TABLE `modifier_groups`
  MODIFY `modifier_group_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=124;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `order_item_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=120;

--
-- AUTO_INCREMENT for table `order_item_modifiers`
--
ALTER TABLE `order_item_modifiers`
  MODIFY `order_item_modifier_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `order_status`
--
ALTER TABLE `order_status`
  MODIFY `status_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `order_status_history`
--
ALTER TABLE `order_status_history`
  MODIFY `status_history_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=86;

--
-- AUTO_INCREMENT for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `role_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
