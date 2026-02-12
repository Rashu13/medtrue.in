-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 10, 2026 at 04:07 PM
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
-- Database: `hyperlocal`
--

-- --------------------------------------------------------

--
-- Table structure for table `addresses`
--

CREATE TABLE `addresses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `address_line1` varchar(255) NOT NULL,
  `address_line2` varchar(255) DEFAULT NULL,
  `city` varchar(100) NOT NULL,
  `landmark` varchar(100) DEFAULT NULL,
  `state` varchar(100) NOT NULL,
  `zipcode` varchar(20) NOT NULL,
  `mobile` varchar(20) NOT NULL,
  `address_type` enum('home','office','other') NOT NULL,
  `country` varchar(100) NOT NULL,
  `country_code` varchar(10) NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `banners`
--

CREATE TABLE `banners` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `type` enum('product','category','brand','custom') NOT NULL,
  `scope_type` enum('global','category') NOT NULL DEFAULT 'global',
  `scope_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `custom_url` varchar(255) DEFAULT NULL,
  `product_id` bigint(20) UNSIGNED DEFAULT NULL,
  `category_id` bigint(20) UNSIGNED DEFAULT NULL,
  `brand_id` bigint(20) UNSIGNED DEFAULT NULL,
  `position` enum('top','carousel') NOT NULL,
  `visibility_status` enum('published','draft') NOT NULL DEFAULT 'draft',
  `display_order` int(11) NOT NULL DEFAULT 0,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `brands`
--

CREATE TABLE `brands` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` char(36) NOT NULL,
  `scope_type` enum('global','category') NOT NULL DEFAULT 'global',
  `scope_id` bigint(20) UNSIGNED DEFAULT NULL,
  `slug` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `carts`
--

CREATE TABLE `carts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` char(36) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cart_items`
--

CREATE TABLE `cart_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `cart_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `product_variant_id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` int(11) NOT NULL,
  `save_for_later` enum('0','1') NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` char(36) NOT NULL,
  `parent_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `requires_approval` tinyint(1) NOT NULL DEFAULT 0,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `commission` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Commission percentage for sellers',
  `background_type` enum('image','color') DEFAULT NULL,
  `background_color` varchar(7) DEFAULT NULL,
  `font_color` varchar(255) DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `category_featured_section`
--

CREATE TABLE `category_featured_section` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `featured_section_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `category_product`
--

CREATE TABLE `category_product` (
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `category_product_conditions`
--

CREATE TABLE `category_product_conditions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `product_condition_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `collections`
--

CREATE TABLE `collections` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` char(36) NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `type` enum('manual','smart') NOT NULL,
  `visibility` enum('published','draft') NOT NULL,
  `description` text NOT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `countries`
--

CREATE TABLE `countries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `iso3` char(3) NOT NULL,
  `iso2` char(2) NOT NULL,
  `numeric_code` char(3) NOT NULL,
  `phonecode` varchar(255) NOT NULL,
  `capital` varchar(255) DEFAULT NULL,
  `currency` varchar(3) NOT NULL,
  `currency_name` varchar(255) DEFAULT NULL,
  `currency_symbol` varchar(255) DEFAULT NULL,
  `tld` varchar(255) DEFAULT NULL,
  `native` varchar(255) DEFAULT NULL,
  `region` varchar(255) DEFAULT NULL,
  `subregion` varchar(255) DEFAULT NULL,
  `timezones` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`timezones`)),
  `translations` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`translations`)),
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `emoji` varchar(191) DEFAULT NULL,
  `emojiU` varchar(191) DEFAULT NULL,
  `flag` tinyint(1) DEFAULT NULL,
  `wikiDataId` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delivery_boys`
--

CREATE TABLE `delivery_boys` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `delivery_zone_id` bigint(20) UNSIGNED DEFAULT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `driver_license` varchar(255) DEFAULT NULL,
  `driver_license_number` varchar(255) DEFAULT NULL,
  `vehicle_type` varchar(255) DEFAULT NULL,
  `vehicle_registration` varchar(255) DEFAULT NULL,
  `verification_status` enum('pending','rejected','verified') NOT NULL DEFAULT 'pending',
  `verification_remark` text DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delivery_boy_assignments`
--

CREATE TABLE `delivery_boy_assignments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `delivery_boy_id` bigint(20) UNSIGNED NOT NULL,
  `order_item_id` bigint(20) UNSIGNED DEFAULT NULL,
  `return_id` bigint(20) UNSIGNED DEFAULT NULL,
  `assignment_type` enum('delivery','return_pickup') NOT NULL DEFAULT 'delivery' COMMENT 'delivery, pickup',
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `status` enum('assigned','in_progress','completed','canceled') NOT NULL DEFAULT 'assigned',
  `base_fee` decimal(10,2) DEFAULT NULL,
  `per_store_pickup_fee` decimal(10,2) DEFAULT NULL,
  `distance_based_fee` decimal(10,2) DEFAULT NULL,
  `per_order_incentive` decimal(10,2) DEFAULT NULL,
  `total_earnings` decimal(10,2) DEFAULT NULL,
  `payment_status` enum('pending','paid') NOT NULL DEFAULT 'pending',
  `cod_cash_collected` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Cash collected by delivery boy for COD orders',
  `cod_cash_submitted` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Cash submitted by delivery boy to admin',
  `cod_submission_status` enum('pending','submitted','partially_submitted') NOT NULL DEFAULT 'pending' COMMENT 'Status of cash submission to admin',
  `paid_at` timestamp NULL DEFAULT NULL,
  `transaction_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delivery_boy_cash_transactions`
--

CREATE TABLE `delivery_boy_cash_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `delivery_boy_assignment_id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `delivery_boy_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `transaction_type` enum('collected','submitted') NOT NULL,
  `transaction_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delivery_boy_locations`
--

CREATE TABLE `delivery_boy_locations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `delivery_boy_id` bigint(20) UNSIGNED NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `recorded_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delivery_boy_withdrawal_requests`
--

CREATE TABLE `delivery_boy_withdrawal_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `delivery_boy_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(10,2) NOT NULL COMMENT 'Amount requested for withdrawal',
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `request_note` text DEFAULT NULL COMMENT 'Note from delivery boy',
  `admin_remark` text DEFAULT NULL COMMENT 'Remark from admin',
  `processed_at` timestamp NULL DEFAULT NULL COMMENT 'When the request was processed',
  `processed_by` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'Admin who processed the request',
  `transaction_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'Related wallet transaction ID',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delivery_feedback`
--

CREATE TABLE `delivery_feedback` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `delivery_boy_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `rating` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delivery_time_slots`
--

CREATE TABLE `delivery_time_slots` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `start_time` timestamp NULL DEFAULT NULL,
  `end_time` timestamp NULL DEFAULT NULL,
  `max_orders` int(11) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delivery_zones`
--

CREATE TABLE `delivery_zones` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `center_latitude` decimal(10,8) NOT NULL,
  `center_longitude` decimal(11,8) NOT NULL,
  `radius_km` double NOT NULL,
  `rush_delivery_time_per_km` int(11) DEFAULT NULL,
  `rush_delivery_charges` int(11) DEFAULT NULL,
  `delivery_time_per_km` int(11) NOT NULL,
  `regular_delivery_charges` int(11) NOT NULL,
  `free_delivery_amount` int(11) DEFAULT NULL,
  `distance_based_delivery_charges` int(11) DEFAULT NULL,
  `per_store_drop_off_fee` int(11) DEFAULT NULL,
  `handling_charges` int(11) DEFAULT NULL,
  `delivery_boy_base_fee` decimal(10,2) DEFAULT NULL,
  `delivery_boy_per_store_pickup_fee` decimal(10,2) DEFAULT NULL,
  `delivery_boy_distance_based_fee` decimal(10,2) DEFAULT NULL,
  `delivery_boy_per_order_incentive` decimal(10,2) DEFAULT NULL,
  `buffer_time` int(11) NOT NULL,
  `boundary_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`boundary_json`)),
  `rush_delivery_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('active','inactive') NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `faqs`
--

CREATE TABLE `faqs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `question` varchar(255) NOT NULL,
  `answer` varchar(255) NOT NULL,
  `status` enum('active','inactive') NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `featured_sections`
--

CREATE TABLE `featured_sections` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `scope_type` enum('global','category') NOT NULL DEFAULT 'global',
  `scope_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `short_description` text DEFAULT NULL,
  `style` varchar(255) NOT NULL,
  `background_type` enum('image','color') DEFAULT NULL,
  `background_color` varchar(255) DEFAULT NULL,
  `text_color` varchar(255) NOT NULL DEFAULT '#000000',
  `section_type` varchar(255) NOT NULL,
  `sort_order` int(11) DEFAULT 0,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `following_sellers`
--

CREATE TABLE `following_sellers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `seller_id` varchar(255) NOT NULL,
  `user_seller_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gift_cards`
--

CREATE TABLE `gift_cards` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `seller_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(250) NOT NULL,
  `barcode` varchar(250) NOT NULL,
  `start_time` timestamp NULL DEFAULT NULL,
  `end_time` timestamp NULL DEFAULT NULL,
  `minimum_order_amount` decimal(10,2) NOT NULL,
  `discount` decimal(10,2) NOT NULL,
  `used` enum('0','1') NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `global_product_attributes`
--

CREATE TABLE `global_product_attributes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `seller_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(350) NOT NULL,
  `label` varchar(255) NOT NULL,
  `swatche_type` enum('text','color','image') NOT NULL DEFAULT 'text',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `global_product_attribute_values`
--

CREATE TABLE `global_product_attribute_values` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `global_attribute_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `swatche_value` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `media`
--

CREATE TABLE `media` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) UNSIGNED NOT NULL,
  `uuid` char(36) DEFAULT NULL,
  `collection_name` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `mime_type` varchar(255) DEFAULT NULL,
  `disk` varchar(255) NOT NULL,
  `conversions_disk` varchar(255) DEFAULT NULL,
  `size` bigint(20) UNSIGNED NOT NULL,
  `manipulations` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`manipulations`)),
  `custom_properties` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`custom_properties`)),
  `generated_conversions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`generated_conversions`)),
  `responsive_images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`responsive_images`)),
  `order_column` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2025_05_05_112622_update_users_table', 1),
(5, '2025_05_05_121106_create_wallets_table', 1),
(6, '2025_05_05_122900_create_delivery_zones_table', 1),
(7, '2025_05_05_122901_create_sellers_table', 1),
(8, '2025_05_05_122902_create_stores_table', 1),
(9, '2025_05_05_122903_create_following_sellers_table', 1),
(10, '2025_05_05_122904_create_delivery_boys_table', 1),
(11, '2025_05_05_122905_add_fields_to_delivery_boys_table', 1),
(12, '2025_05_05_122905_create_delivery_boy_locations_table', 1),
(13, '2025_05_06_043058_create_categories_table', 1),
(14, '2025_05_06_043059_create_brands_table', 1),
(15, '2025_05_06_043505_create_product_conditions_table', 1),
(16, '2025_05_06_043506_create_products_table', 1),
(17, '2025_05_06_043507_create_product_variants_table', 1),
(18, '2025_05_06_053735_create_store_product_variants_table', 1),
(19, '2025_05_06_053745_create_store_inventory_logs_table', 1),
(20, '2025_05_06_055246_create_category_products_table', 1),
(21, '2025_05_06_055324_create_category_product_conditions_table', 1),
(22, '2025_05_06_055404_create_collections_table', 1),
(23, '2025_05_06_055445_create_carts_table', 1),
(24, '2025_05_06_055533_create_cart_items_table', 1),
(25, '2025_05_06_055819_create_wishlists_table', 1),
(26, '2025_05_06_055846_create_wishlist_items_table', 1),
(27, '2025_05_06_055900_create_delivery_time_slots_table', 1),
(28, '2025_05_06_055951_create_orders_table', 1),
(29, '2025_05_06_060344_create_order_items_table', 1),
(30, '2025_05_06_060450_create_seller_orders_table', 1),
(31, '2025_05_06_060519_create_seller_order_items_table', 1),
(32, '2025_05_06_061307_create_delivery_boy_assignments_table', 1),
(33, '2025_05_06_061340_create_shipping_parcels_table', 1),
(34, '2025_05_06_061449_create_shipping_parcel_items_table', 1),
(35, '2025_05_06_061530_create_addresses_table', 1),
(36, '2025_05_06_061651_create_reviews_table', 1),
(37, '2025_05_06_061718_create_seller_feedback_table', 1),
(38, '2025_05_06_061748_create_gift_cards_table', 1),
(39, '2025_05_06_061904_create_support_ticket_types_table', 1),
(40, '2025_05_06_062000_create_support_tickets_table', 1),
(41, '2025_05_06_062030_create_support_ticket_messages_table', 1),
(42, '2025_05_06_062302_create_settings_table', 1),
(43, '2025_05_06_062338_create_countries_table', 1),
(44, '2025_05_06_062411_create_faqs_table', 1),
(45, '2025_05_06_062437_create_product_faqs_table', 1),
(46, '2025_05_07_043060_add_commission_to_categories_table', 1),
(47, '2025_05_15_000000_add_otp_fields_to_products_and_order_items_tables', 1),
(48, '2025_05_15_000000_create_delivery_boy_cash_transactions_table', 1),
(49, '2025_05_15_100405_create_media_table', 1),
(50, '2025_05_16_000000_create_delivery_boy_withdrawal_requests_table', 1),
(51, '2025_05_16_114622_modify_categories_table', 1),
(52, '2025_05_17_000000_create_seller_withdrawal_requests_table', 1),
(53, '2025_05_17_062421_remove_image_colunms_from_tables', 1),
(54, '2025_05_19_091414_modify_brands_table', 1),
(55, '2025_05_20_091322_update_seller_table', 1),
(56, '2025_05_21_062058_create_tax_classes_table', 1),
(57, '2025_05_21_062132_create_tax_rates_table', 1),
(58, '2025_05_21_101700_create_table_tax_class_tax_rate', 1),
(59, '2025_05_27_113402_modify_users_table', 1),
(60, '2025_05_27_122053_create_permission_tables', 1),
(61, '2025_05_30_121905_create_seller_user', 1),
(62, '2025_05_31_124117_add_column_team_id_in_roles_table', 1),
(63, '2025_06_03_063244_update_stores_table', 1),
(64, '2025_06_11_123229_create_global_product_attributes_table', 1),
(65, '2025_06_11_123306_create_global_product_attribute_values_table', 1),
(66, '2025_06_11_123323_create_product_variant_attributes_table', 1),
(67, '2025_06_13_090459_update_product_table', 1),
(68, '2025_06_17_050536_create_personal_access_tokens_table', 1),
(69, '2025_06_18_083334_update_product_table', 1),
(70, '2025_06_18_085314_update_product_variant_table', 1),
(71, '2025_06_19_044813_add_soft_delete_in_tables', 1),
(72, '2025_06_21_060509_update_product_table', 1),
(73, '2025_06_21_083854_create_table_product_taxes', 1),
(74, '2025_06_25_075558_create_wallet_transactions_table', 1),
(75, '2025_06_25_112436_create_banners_table', 1),
(76, '2025_06_26_093708_update_users_table', 1),
(77, '2025_06_30_042142_add_field_in_users_table', 1),
(78, '2025_07_03_115318_update_stores_table', 1),
(79, '2025_07_03_115411_create_store_zone_table', 1),
(80, '2025_07_07_053035_update_delivery_zones_table', 1),
(81, '2025_07_07_053256_update_product_table', 1),
(82, '2025_07_08_054216_update_wishlist_items_table', 1),
(83, '2025_07_08_075253_create_table_featured_sections', 1),
(84, '2025_07_08_075511_create_category_featured_section_table', 1),
(85, '2025_07_12_062506_update_table_delivery_zones', 1),
(86, '2025_07_16_061649_add_product_id_to_product_variant_attributes_table', 1),
(87, '2025_07_17_063223_update_seller_orders_table', 1),
(88, '2025_07_17_102140_update_order_table', 1),
(89, '2025_07_17_103322_update_order_items_table', 1),
(90, '2025_07_17_161135_update_seller_order_items_table', 1),
(91, '2025_07_18_095508_update_orders_table', 1),
(92, '2025_07_22_120022_update_delivery_boy_location_table', 1),
(93, '2025_07_22_124047_update_orders_table', 1),
(94, '2025_07_24_053056_add_delivery_boy_earnings_fields_to_delivery_zones_table', 1),
(95, '2025_07_24_054345_update_delivery_boy_earnings_fields_to_decimal', 1),
(96, '2025_07_24_072733_add_earnings_fields_to_delivery_boy_assignments_table', 1),
(97, '2025_07_24_074553_add_payment_status_to_delivery_boy_assignments_table', 1),
(98, '2025_07_24_124902_update_delivery_boy_assignments_table', 1),
(99, '2025_07_26_050411_update_wallet_table', 1),
(100, '2025_07_31_112317_create_delivery_feedback_table', 1),
(101, '2025_08_04_044211_update_order_table', 1),
(102, '2025_08_12_063618_update_wishlists_table', 1),
(103, '2025_08_14_101202_create_promo_table', 1),
(104, '2025_08_14_101225_create_order_promo_line_table', 1),
(105, '2025_08_14_101245_add_promo_discount_to_order_items_table', 1),
(106, '2025_08_19_054507_update_banners_table', 1),
(107, '2025_08_19_085237_update_featured_sections', 1),
(108, '2025_08_20_120000_add_background_fields_to_categories_table', 1),
(109, '2025_08_20_124931_create_notifications_table', 1),
(110, '2025_08_23_101900_update_brands_table', 1),
(111, '2025_08_23_120000_add_font_color_to_categories_table', 1),
(112, '2025_08_25_084408_user_fcm_tokens', 1),
(113, '2025_09_08_091650_create_order_payment_transactions_table', 1),
(114, '2025_09_11_054945_add_column_in_products_table', 1),
(115, '2025_10_15_055036_remove_time_slot_config_add_status_to_stores_table', 1),
(116, '2025_10_28_053033_update_wallet_transactions_table', 1),
(117, '2025_11_12_160339_update_featured_sections_table', 1),
(118, '2025_11_13_104908_create_order_item_returns_table', 1),
(119, '2025_11_13_111623_update_order_items_table', 1),
(120, '2025_11_13_174710_update_delivery_boy_assignments_table', 1),
(121, '2025_11_14_115800_create_seller_statements_table', 1),
(122, '2025_11_14_123500_update_seller_statements_add_settlement_fields', 1),
(123, '2025_11_15_101749_update_featured_sections_table', 1),
(124, '2025_11_15_103927_update_reviews_table', 1),
(125, '2025_11_15_130945_update_seller_feedback_table', 1),
(126, '2025_11_21_113500_update_orders_add_handling_and_drop_fee', 1),
(127, '2025_11_25_152515_update_roles_table', 1),
(128, '2025_12_05_104800_add_image_fit_to_products_table', 1),
(129, '2025_12_19_000000_create_system_updates_table', 1),
(130, '2026_01_15_115753_update_reviews_table', 1),
(131, '2026_01_16_000001_add_custom_fields_to_products_table', 1),
(132, '2026_01_23_193900_add_sort_order_to_categories_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `model_has_permissions`
--

CREATE TABLE `model_has_permissions` (
  `permission_id` bigint(20) UNSIGNED NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `model_has_roles`
--

CREATE TABLE `model_has_roles` (
  `role_id` bigint(20) UNSIGNED NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `store_id` bigint(20) UNSIGNED DEFAULT NULL,
  `order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `type` varchar(255) NOT NULL DEFAULT 'general',
  `sent_to` enum('admin','customer','seller') NOT NULL DEFAULT 'admin',
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` char(36) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `slug` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `currency_code` varchar(3) NOT NULL DEFAULT 'USD',
  `currency_rate` decimal(10,6) NOT NULL,
  `payment_method` varchar(255) NOT NULL,
  `payment_status` varchar(255) NOT NULL,
  `fulfillment_type` enum('hyperlocal','regular') NOT NULL DEFAULT 'hyperlocal',
  `is_rush_order` tinyint(1) NOT NULL DEFAULT 0,
  `estimated_delivery_time` int(11) DEFAULT NULL,
  `delivery_time_slot_id` bigint(20) UNSIGNED DEFAULT NULL,
  `delivery_boy_id` bigint(20) UNSIGNED DEFAULT NULL,
  `delivery_zone_id` bigint(20) UNSIGNED NOT NULL,
  `wallet_balance` decimal(12,2) NOT NULL,
  `promo_code` varchar(50) DEFAULT NULL,
  `promo_discount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `gift_card` varchar(50) DEFAULT NULL,
  `gift_card_discount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `delivery_charge` decimal(10,2) NOT NULL DEFAULT 0.00,
  `handling_charges` decimal(10,2) NOT NULL DEFAULT 0.00,
  `per_store_drop_off_fee` decimal(10,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(12,2) NOT NULL,
  `total_payable` decimal(12,2) NOT NULL,
  `final_total` decimal(12,2) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `billing_name` varchar(255) NOT NULL,
  `billing_address_1` text NOT NULL,
  `billing_address_2` text DEFAULT NULL,
  `billing_landmark` varchar(255) NOT NULL,
  `billing_zip` varchar(20) NOT NULL,
  `billing_phone` varchar(20) NOT NULL,
  `billing_address_type` enum('home','office','other') NOT NULL,
  `billing_latitude` decimal(10,8) NOT NULL,
  `billing_longitude` decimal(11,8) NOT NULL,
  `billing_city` varchar(255) NOT NULL,
  `billing_state` varchar(255) NOT NULL,
  `billing_country` varchar(255) NOT NULL,
  `billing_country_code` varchar(3) NOT NULL,
  `shipping_name` varchar(255) NOT NULL,
  `shipping_address_1` text NOT NULL,
  `shipping_address_2` text DEFAULT NULL,
  `shipping_landmark` varchar(255) NOT NULL,
  `shipping_zip` varchar(20) NOT NULL,
  `shipping_phone` varchar(20) NOT NULL,
  `shipping_address_type` enum('home','office','other') NOT NULL,
  `shipping_latitude` decimal(10,8) NOT NULL,
  `shipping_longitude` decimal(11,8) NOT NULL,
  `shipping_city` varchar(255) NOT NULL,
  `shipping_state` varchar(255) NOT NULL,
  `shipping_country` varchar(255) NOT NULL,
  `shipping_country_code` varchar(3) NOT NULL,
  `order_note` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `product_variant_id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `variant_title` varchar(255) NOT NULL,
  `gift_card_discount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `admin_commission_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `seller_commission_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `commission_settled` enum('0','1') NOT NULL DEFAULT '0',
  `return_eligible` tinyint(1) NOT NULL DEFAULT 0,
  `return_deadline` date DEFAULT NULL,
  `returnable_days` tinyint(4) NOT NULL DEFAULT 0,
  `discounted_price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `discount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `promo_discount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `tax_amount` decimal(10,2) DEFAULT NULL,
  `tax_percent` decimal(5,2) DEFAULT NULL,
  `sku` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `status` varchar(255) NOT NULL,
  `otp` varchar(255) DEFAULT NULL,
  `otp_verified` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_item_returns`
--

CREATE TABLE `order_item_returns` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_item_id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `seller_id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `delivery_boy_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `refund_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `seller_comment` text DEFAULT NULL,
  `pickup_status` enum('pending','assigned','picked_up','delivered_to_seller','cancelled') NOT NULL DEFAULT 'pending',
  `return_status` enum('cancelled','requested','seller_approved','seller_rejected','pickup_assigned','picked_up','received_by_seller','refund_processed','completed') NOT NULL DEFAULT 'requested',
  `seller_approved_at` timestamp NULL DEFAULT NULL,
  `picked_up_at` timestamp NULL DEFAULT NULL,
  `received_at` timestamp NULL DEFAULT NULL,
  `refund_processed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tracks each return request for individual order items';

-- --------------------------------------------------------

--
-- Table structure for table `order_payment_transactions`
--

CREATE TABLE `order_payment_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` char(36) NOT NULL,
  `order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) NOT NULL,
  `payment_method` varchar(255) NOT NULL,
  `payment_status` enum('pending','completed','failed','refunded','partially_refunded') NOT NULL DEFAULT 'pending',
  `message` text DEFAULT NULL,
  `payment_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`payment_details`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_promo_line`
--

CREATE TABLE `order_promo_line` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `promo_id` bigint(20) UNSIGNED NOT NULL,
  `promo_code` varchar(25) NOT NULL,
  `discount_amount` decimal(10,2) NOT NULL,
  `cashback_flag` tinyint(1) NOT NULL DEFAULT 0,
  `is_awarded` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `guard_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES
(1, 'dashboard.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(2, 'category.create', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(4, 'category.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(5, 'category.delete', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(6, 'category.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(8, 'brand.create', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(9, 'brand.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(11, 'brand.delete', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(13, 'brand.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(14, 'seller.create', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(15, 'seller.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(16, 'seller.delete', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(18, 'seller.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(20, 'setting.view.all', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(21, 'setting.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(23, 'setting.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(24, 'setting.system.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(25, 'setting.system.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(26, 'setting.storage.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(27, 'setting.storage.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(29, 'setting.email.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(30, 'setting.email.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(31, 'setting.payment.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(33, 'setting.payment.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(34, 'setting.authentication.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(36, 'setting.authentication.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(37, 'setting.notification.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(39, 'setting.notification.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(40, 'setting.web.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(41, 'setting.web.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(43, 'setting.app.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(44, 'setting.app.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(46, 'setting.delivery_boy.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(48, 'setting.delivery_boy.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(50, 'setting.home_general_settings.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(51, 'setting.home_general_settings.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(53, 'role.create', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(54, 'role.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(56, 'role.delete', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(57, 'role.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(58, 'role.permission.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(60, 'role.permission.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(61, 'tax_class.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(62, 'tax_class.create', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(63, 'tax_class.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(64, 'tax_class.delete', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(65, 'system_user.create', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(66, 'system_user.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(68, 'system_user.delete', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(70, 'system_user.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(71, 'faq.create', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(72, 'faq.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(73, 'faq.delete', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(75, 'faq.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(76, 'banner.create', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(78, 'banner.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(79, 'banner.delete', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(81, 'banner.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(83, 'delivery_zone.create', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(84, 'delivery_zone.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(86, 'delivery_zone.delete', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(87, 'delivery_zone.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(88, 'featured_section.create', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(90, 'featured_section.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(91, 'featured_section.delete', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(92, 'featured_section.sorting_modify', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(93, 'featured_section.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(94, 'featured_section.sorting_view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(95, 'delivery_boy.edit', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(96, 'delivery_boy.delete', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(98, 'delivery_boy.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(99, 'delivery_boy_earning.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(101, 'delivery_boy_earning.process_payment', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(102, 'delivery_boy_cash_collection.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(104, 'delivery_boy_cash_collection.process', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(105, 'delivery_boy_withdrawal.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(106, 'delivery_boy_withdrawal.process', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(107, 'seller_withdrawal.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(109, 'seller_withdrawal.process', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(110, 'commission.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(112, 'commission.settle', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(114, 'orders.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(115, 'return.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(117, 'product.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(118, 'product.status_update', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(120, 'product_faqs.view', 'admin', '2026-02-10 15:07:21', '2026-02-10 15:07:21'),
(121, 'promo.create', 'admin', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(123, 'promo.edit', 'admin', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(125, 'promo.delete', 'admin', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(126, 'promo.view', 'admin', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(127, 'notification.create', 'admin', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(128, 'notification.edit', 'admin', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(129, 'notification.delete', 'admin', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(130, 'notification.view', 'admin', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(131, 'store.view', 'admin', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(132, 'store.verify', 'admin', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(133, 'customer.view', 'admin', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(134, 'dashboard.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(136, 'role.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(137, 'role.create', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(138, 'role.edit', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(140, 'role.delete', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(142, 'role.permission.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(143, 'role.permission.edit', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(144, 'system_user.create', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(145, 'system_user.edit', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(146, 'system_user.delete', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(148, 'system_user.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(149, 'store.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(150, 'store.create', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(152, 'store.edit', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(153, 'store.delete', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(154, 'attribute.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(155, 'attribute.create', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(156, 'attribute.edit', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(157, 'attribute.delete', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(158, 'product_condition.create', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(160, 'product_condition.edit', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(161, 'product_condition.delete', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(163, 'product.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(164, 'product.create', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(165, 'product.edit', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(166, 'product.delete', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(167, 'product_faq.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(168, 'product_faq.create', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(171, 'product_faq.edit', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(172, 'product_faq.delete', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(174, 'order.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(176, 'order.edit', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(178, 'order.update_status', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(179, 'earning.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(181, 'notification.create', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(182, 'notification.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(184, 'notification.edit', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(185, 'notification.delete', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(186, 'tax_rate.create', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(187, 'tax_rate.edit', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(188, 'tax_rate.delete', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(190, 'tax_rate.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(191, 'wallet.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(192, 'withdrawal.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(194, 'withdrawal.request', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(195, 'return.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(196, 'return.decide', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(197, 'category.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22'),
(198, 'brand.view', 'seller', '2026-02-10 15:07:22', '2026-02-10 15:07:22');

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` char(36) NOT NULL,
  `seller_id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `brand_id` bigint(20) UNSIGNED DEFAULT NULL,
  `product_condition_id` bigint(20) UNSIGNED DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `provider_product_id` bigint(20) UNSIGNED DEFAULT NULL,
  `slug` varchar(500) NOT NULL,
  `title` varchar(255) NOT NULL,
  `product_identity` int(11) DEFAULT NULL,
  `type` enum('simple','variant','digital') NOT NULL,
  `short_description` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `indicator` enum('veg','non_veg') DEFAULT NULL,
  `download_allowed` enum('0','1') NOT NULL DEFAULT '0',
  `download_link` varchar(255) DEFAULT NULL,
  `minimum_order_quantity` int(11) NOT NULL DEFAULT 1,
  `quantity_step_size` int(11) NOT NULL DEFAULT 1,
  `total_allowed_quantity` int(11) NOT NULL DEFAULT 1,
  `is_inclusive_tax` enum('0','1') NOT NULL DEFAULT '0',
  `is_returnable` enum('0','1') NOT NULL DEFAULT '0',
  `returnable_days` int(11) DEFAULT NULL,
  `is_cancelable` enum('0','1') NOT NULL DEFAULT '0',
  `cancelable_till` enum('pending','awaiting_store_response','accepted','preparing') DEFAULT NULL,
  `is_attachment_required` enum('0','1') NOT NULL DEFAULT '0',
  `base_prep_time` int(11) NOT NULL,
  `status` enum('active','draft') NOT NULL DEFAULT 'active',
  `verification_status` enum('pending_verification','rejected','approved') NOT NULL DEFAULT 'approved',
  `rejection_reason` varchar(255) DEFAULT NULL,
  `requires_otp` tinyint(1) NOT NULL DEFAULT 0,
  `featured` enum('0','1') NOT NULL DEFAULT '0',
  `video_type` enum('self_hosted','youtube','vimeo') DEFAULT NULL,
  `video_link` varchar(255) DEFAULT NULL,
  `cloned_from_id` bigint(20) UNSIGNED DEFAULT NULL,
  `tags` text NOT NULL,
  `custom_fields` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`custom_fields`)),
  `warranty_period` varchar(255) DEFAULT NULL,
  `guarantee_period` varchar(255) DEFAULT NULL,
  `made_in` varchar(255) DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `image_fit` enum('cover','contain') NOT NULL DEFAULT 'contain',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `hsn_code` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product_conditions`
--

CREATE TABLE `product_conditions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` char(36) NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `alignment` enum('strip') NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product_faqs`
--

CREATE TABLE `product_faqs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `question` varchar(255) NOT NULL,
  `answer` varchar(255) NOT NULL,
  `status` enum('active','inactive') NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product_taxes`
--

CREATE TABLE `product_taxes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `tax_class_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product_variants`
--

CREATE TABLE `product_variants` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` char(36) NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(500) NOT NULL,
  `weight` double DEFAULT NULL,
  `height` double DEFAULT NULL,
  `breadth` double DEFAULT NULL,
  `length` double DEFAULT NULL,
  `availability` tinyint(1) NOT NULL,
  `provider` varchar(255) NOT NULL DEFAULT 'self',
  `provider_product_id` varchar(255) DEFAULT NULL,
  `provider_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`provider_json`)),
  `barcode` varchar(255) NOT NULL,
  `visibility` enum('published','draft') NOT NULL,
  `is_default` tinyint(1) NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product_variant_attributes`
--

CREATE TABLE `product_variant_attributes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `product_variant_id` bigint(20) UNSIGNED NOT NULL,
  `global_attribute_id` bigint(20) UNSIGNED NOT NULL,
  `global_attribute_value_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `promo`
--

CREATE TABLE `promo` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(25) NOT NULL,
  `description` text DEFAULT NULL,
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `discount_type` enum('free_shipping','flat','percent') NOT NULL,
  `discount_amount` decimal(10,2) DEFAULT NULL,
  `promo_mode` enum('instant','cashback') NOT NULL DEFAULT 'instant',
  `usage_count` int(11) NOT NULL DEFAULT 0,
  `individual_use` int(11) NOT NULL DEFAULT 0,
  `max_total_usage` int(11) DEFAULT NULL,
  `max_usage_per_user` int(11) DEFAULT NULL,
  `min_order_total` decimal(10,2) DEFAULT NULL,
  `max_discount_value` decimal(10,2) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `order_item_id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `rating` int(11) NOT NULL,
  `title` varchar(255) NOT NULL COMMENT 'Review title',
  `slug` varchar(255) NOT NULL,
  `comment` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `team_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `guard_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `role_has_permissions`
--

CREATE TABLE `role_has_permissions` (
  `permission_id` bigint(20) UNSIGNED NOT NULL,
  `role_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sellers`
--

CREATE TABLE `sellers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `address` varchar(255) NOT NULL,
  `city` varchar(100) NOT NULL,
  `landmark` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `zipcode` varchar(20) NOT NULL,
  `country` varchar(100) NOT NULL,
  `country_code` varchar(10) NOT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `verification_status` enum('approved','not_approved') NOT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `visibility_status` enum('visible','draft') NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `seller_feedback`
--

CREATE TABLE `seller_feedback` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `seller_id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `order_item_id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED DEFAULT NULL,
  `rating` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `seller_orders`
--

CREATE TABLE `seller_orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `seller_id` bigint(20) UNSIGNED NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `seller_order_items`
--

CREATE TABLE `seller_order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `seller_order_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `product_variant_id` bigint(20) UNSIGNED NOT NULL,
  `order_item_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `seller_statements`
--

CREATE TABLE `seller_statements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `seller_id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `order_item_id` bigint(20) UNSIGNED DEFAULT NULL,
  `return_id` bigint(20) UNSIGNED DEFAULT NULL,
  `entry_type` enum('credit','debit') NOT NULL COMMENT 'credit adds to seller balance, debit subtracts',
  `amount` decimal(12,2) NOT NULL,
  `currency_code` varchar(10) DEFAULT NULL,
  `reference_type` varchar(255) DEFAULT NULL COMMENT 'e.g., order, return, adjustment',
  `reference_id` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `posted_at` timestamp NULL DEFAULT NULL,
  `settlement_status` enum('pending','settled') NOT NULL DEFAULT 'pending',
  `settled_at` timestamp NULL DEFAULT NULL,
  `settlement_reference` varchar(255) DEFAULT NULL COMMENT 'payment reference / batch ID',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `seller_user`
--

CREATE TABLE `seller_user` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `seller_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `seller_withdrawal_requests`
--

CREATE TABLE `seller_withdrawal_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `seller_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(10,2) NOT NULL COMMENT 'Amount requested for withdrawal',
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `request_note` text DEFAULT NULL COMMENT 'Note from seller',
  `admin_remark` text DEFAULT NULL COMMENT 'Remark from admin',
  `processed_at` timestamp NULL DEFAULT NULL COMMENT 'When the request was processed',
  `processed_by` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'Admin who processed the request',
  `transaction_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'Related wallet transaction ID',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `variable` varchar(255) NOT NULL,
  `value` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `shipping_parcels`
--

CREATE TABLE `shipping_parcels` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `delivery_boy_id` bigint(20) UNSIGNED DEFAULT NULL,
  `shipment_id` bigint(20) UNSIGNED DEFAULT NULL,
  `external_shipment_id` bigint(20) UNSIGNED DEFAULT NULL,
  `carrier_id` bigint(20) UNSIGNED DEFAULT NULL,
  `manifest_id` bigint(20) UNSIGNED DEFAULT NULL,
  `manifest_url` varchar(255) DEFAULT NULL,
  `service_code` varchar(255) DEFAULT NULL,
  `label_id` bigint(20) UNSIGNED DEFAULT NULL,
  `label_url` varchar(255) DEFAULT NULL,
  `invoice_url` varchar(255) DEFAULT NULL,
  `tracking_id` bigint(20) UNSIGNED NOT NULL,
  `tracking_url` varchar(255) DEFAULT NULL,
  `shipment_cost_currency` varchar(10) NOT NULL,
  `shipment_cost` decimal(10,2) NOT NULL,
  `weight` double DEFAULT NULL,
  `height` double DEFAULT NULL,
  `breadth` double DEFAULT NULL,
  `length` double DEFAULT NULL,
  `status` enum('pending','shipped','out_for_delivery','delivered') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `shipping_parcel_items`
--

CREATE TABLE `shipping_parcel_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `parcel_id` bigint(20) UNSIGNED NOT NULL,
  `order_item_id` bigint(20) UNSIGNED NOT NULL,
  `quantity_shipped` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stores`
--

CREATE TABLE `stores` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `seller_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(300) NOT NULL,
  `address` varchar(255) NOT NULL,
  `city` varchar(100) NOT NULL,
  `landmark` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `zipcode` varchar(20) NOT NULL,
  `country` varchar(100) NOT NULL,
  `country_code` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `contact_email` varchar(50) NOT NULL,
  `contact_number` varchar(20) NOT NULL,
  `description` text DEFAULT NULL,
  `timing` varchar(500) DEFAULT NULL,
  `tax_name` varchar(250) NOT NULL,
  `tax_number` varchar(250) NOT NULL,
  `bank_name` varchar(250) NOT NULL,
  `bank_branch_code` varchar(250) NOT NULL,
  `account_holder_name` varchar(250) NOT NULL,
  `account_number` varchar(250) NOT NULL,
  `routing_number` varchar(250) NOT NULL,
  `bank_account_type` enum('checking','savings') NOT NULL,
  `currency_code` varchar(255) DEFAULT NULL,
  `max_delivery_distance` double NOT NULL DEFAULT 10,
  `order_preparation_time` int(11) NOT NULL DEFAULT 15,
  `promotional_text` varchar(1024) DEFAULT NULL,
  `about_us` text DEFAULT NULL,
  `return_replacement_policy` text DEFAULT NULL,
  `refund_policy` text DEFAULT NULL,
  `terms_and_conditions` text DEFAULT NULL,
  `delivery_policy` text DEFAULT NULL,
  `domestic_shipping_charges` decimal(10,2) DEFAULT NULL,
  `international_shipping_charges` decimal(10,2) DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `verification_status` enum('approved','not_approved') NOT NULL,
  `visibility_status` enum('visible','draft') NOT NULL DEFAULT 'draft',
  `fulfillment_type` enum('hyperlocal','regular','both') NOT NULL DEFAULT 'hyperlocal',
  `status` enum('online','offline') NOT NULL DEFAULT 'online',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `store_inventory_logs`
--

CREATE TABLE `store_inventory_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `product_variant_id` bigint(20) UNSIGNED NOT NULL,
  `change_type` enum('add','remove','adjust') NOT NULL,
  `quantity` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `store_product_variants`
--

CREATE TABLE `store_product_variants` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_variant_id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `sku` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `special_price` decimal(10,2) NOT NULL,
  `cost` decimal(10,2) NOT NULL,
  `stock` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `store_zone`
--

CREATE TABLE `store_zone` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `zone_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `support_tickets`
--

CREATE TABLE `support_tickets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `ticket_type_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `subject` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `status` enum('open','in_progress','reopen','pending_review','resolved','closed') NOT NULL DEFAULT 'open',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `support_ticket_messages`
--

CREATE TABLE `support_ticket_messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `send_by` enum('admin','user') NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `ticket_id` bigint(20) UNSIGNED NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `support_ticket_types`
--

CREATE TABLE `support_ticket_types` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_updates`
--

CREATE TABLE `system_updates` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `version` varchar(255) NOT NULL,
  `package_name` varchar(255) NOT NULL,
  `checksum` varchar(255) DEFAULT NULL,
  `status` enum('pending','applied','failed') NOT NULL DEFAULT 'pending',
  `applied_by` bigint(20) UNSIGNED DEFAULT NULL,
  `applied_at` timestamp NULL DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `log` longtext DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tax_classes`
--

CREATE TABLE `tax_classes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tax_class_tax_rate`
--

CREATE TABLE `tax_class_tax_rate` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tax_class_id` bigint(20) UNSIGNED NOT NULL,
  `tax_rate_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tax_rates`
--

CREATE TABLE `tax_rates` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `rate` decimal(5,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `mobile` varchar(20) NOT NULL,
  `referral_code` varchar(32) DEFAULT NULL,
  `friends_code` varchar(32) DEFAULT NULL,
  `reward_points` decimal(10,2) NOT NULL DEFAULT 0.00,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `country` varchar(255) DEFAULT NULL,
  `iso_2` varchar(2) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `access_panel` enum('web','admin','seller') NOT NULL DEFAULT 'web' COMMENT 'Defines the access panel for the user: web, admin, or seller',
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_fcm_tokens`
--

CREATE TABLE `user_fcm_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `fcm_token` varchar(255) NOT NULL,
  `device_type` enum('android','ios','web') DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wallets`
--

CREATE TABLE `wallets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `balance` decimal(10,2) NOT NULL,
  `blocked_balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `currency_code` varchar(3) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wallet_transactions`
--

CREATE TABLE `wallet_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `wallet_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `store_id` bigint(20) UNSIGNED DEFAULT NULL,
  `transaction_type` enum('deposit','payment','refund','adjustment') NOT NULL,
  `payment_method` varchar(255) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency_code` varchar(3) NOT NULL DEFAULT 'USD',
  `status` enum('pending','completed','failed','cancelled','refunded','partially_refunded') NOT NULL DEFAULT 'pending',
  `transaction_reference` varchar(100) DEFAULT NULL COMMENT 'Transaction ID from payment gateway',
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wishlists`
--

CREATE TABLE `wishlists` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `wishlist_items`
--

CREATE TABLE `wishlist_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `wishlist_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `product_variant_id` bigint(20) UNSIGNED DEFAULT NULL,
  `store_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `addresses`
--
ALTER TABLE `addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `addresses_user_id_foreign` (`user_id`);

--
-- Indexes for table `banners`
--
ALTER TABLE `banners`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `banners_slug_unique` (`slug`),
  ADD KEY `banners_product_id_foreign` (`product_id`),
  ADD KEY `banners_category_id_foreign` (`category_id`),
  ADD KEY `banners_brand_id_foreign` (`brand_id`),
  ADD KEY `banners_scope_id_foreign` (`scope_id`),
  ADD KEY `banners_scope_type_scope_id_index` (`scope_type`,`scope_id`);

--
-- Indexes for table `brands`
--
ALTER TABLE `brands`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `brands_uuid_unique` (`uuid`),
  ADD UNIQUE KEY `brands_slug_unique` (`slug`),
  ADD KEY `brands_scope_id_foreign` (`scope_id`),
  ADD KEY `brands_scope_type_scope_id_index` (`scope_type`,`scope_id`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `carts_uuid_unique` (`uuid`),
  ADD KEY `carts_user_id_foreign` (`user_id`);

--
-- Indexes for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cart_items_cart_id_foreign` (`cart_id`),
  ADD KEY `cart_items_product_id_foreign` (`product_id`),
  ADD KEY `cart_items_product_variant_id_foreign` (`product_variant_id`),
  ADD KEY `cart_items_store_id_foreign` (`store_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `categories_uuid_unique` (`uuid`),
  ADD UNIQUE KEY `categories_slug_unique` (`slug`),
  ADD KEY `categories_parent_id_foreign` (`parent_id`),
  ADD KEY `categories_sort_order_index` (`sort_order`);

--
-- Indexes for table `category_featured_section`
--
ALTER TABLE `category_featured_section`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `category_featured_section_category_id_featured_section_id_unique` (`category_id`,`featured_section_id`),
  ADD KEY `category_featured_section_category_id_index` (`category_id`),
  ADD KEY `category_featured_section_featured_section_id_index` (`featured_section_id`);

--
-- Indexes for table `category_product`
--
ALTER TABLE `category_product`
  ADD PRIMARY KEY (`category_id`,`product_id`),
  ADD KEY `category_product_product_id_foreign` (`product_id`);

--
-- Indexes for table `category_product_conditions`
--
ALTER TABLE `category_product_conditions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_product_conditions_category_id_foreign` (`category_id`),
  ADD KEY `category_product_conditions_product_condition_id_foreign` (`product_condition_id`);

--
-- Indexes for table `collections`
--
ALTER TABLE `collections`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `collections_uuid_unique` (`uuid`),
  ADD UNIQUE KEY `collections_slug_unique` (`slug`);

--
-- Indexes for table `countries`
--
ALTER TABLE `countries`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `delivery_boys`
--
ALTER TABLE `delivery_boys`
  ADD PRIMARY KEY (`id`),
  ADD KEY `delivery_boys_delivery_zone_id_foreign` (`delivery_zone_id`);

--
-- Indexes for table `delivery_boy_assignments`
--
ALTER TABLE `delivery_boy_assignments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `delivery_boy_assignments_order_id_foreign` (`order_id`),
  ADD KEY `delivery_boy_assignments_delivery_boy_id_foreign` (`delivery_boy_id`),
  ADD KEY `delivery_boy_assignments_transaction_id_foreign` (`transaction_id`),
  ADD KEY `delivery_boy_assignments_order_item_id_foreign` (`order_item_id`),
  ADD KEY `delivery_boy_assignments_return_id_foreign` (`return_id`);

--
-- Indexes for table `delivery_boy_cash_transactions`
--
ALTER TABLE `delivery_boy_cash_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_dbc_assignment` (`delivery_boy_assignment_id`),
  ADD KEY `fk_dbc_order` (`order_id`),
  ADD KEY `fk_dbc_boy` (`delivery_boy_id`);

--
-- Indexes for table `delivery_boy_locations`
--
ALTER TABLE `delivery_boy_locations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `delivery_boy_locations_delivery_boy_id_unique` (`delivery_boy_id`);

--
-- Indexes for table `delivery_boy_withdrawal_requests`
--
ALTER TABLE `delivery_boy_withdrawal_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `delivery_boy_withdrawal_requests_processed_by_foreign` (`processed_by`),
  ADD KEY `delivery_boy_withdrawal_requests_user_id_index` (`user_id`),
  ADD KEY `delivery_boy_withdrawal_requests_delivery_boy_id_index` (`delivery_boy_id`),
  ADD KEY `delivery_boy_withdrawal_requests_status_index` (`status`);

--
-- Indexes for table `delivery_feedback`
--
ALTER TABLE `delivery_feedback`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `delivery_feedback_slug_unique` (`slug`),
  ADD KEY `delivery_feedback_user_id_foreign` (`user_id`),
  ADD KEY `delivery_feedback_order_id_foreign` (`order_id`),
  ADD KEY `delivery_feedback_delivery_boy_id_foreign` (`delivery_boy_id`);

--
-- Indexes for table `delivery_time_slots`
--
ALTER TABLE `delivery_time_slots`
  ADD PRIMARY KEY (`id`),
  ADD KEY `delivery_time_slots_store_id_foreign` (`store_id`);

--
-- Indexes for table `delivery_zones`
--
ALTER TABLE `delivery_zones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `delivery_zones_slug_unique` (`slug`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `faqs`
--
ALTER TABLE `faqs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `featured_sections`
--
ALTER TABLE `featured_sections`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `featured_sections_slug_unique` (`slug`),
  ADD KEY `featured_sections_sort_order_index` (`sort_order`),
  ADD KEY `featured_sections_slug_index` (`slug`),
  ADD KEY `featured_sections_section_type_index` (`section_type`),
  ADD KEY `featured_sections_scope_id_foreign` (`scope_id`);

--
-- Indexes for table `following_sellers`
--
ALTER TABLE `following_sellers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `gift_cards`
--
ALTER TABLE `gift_cards`
  ADD PRIMARY KEY (`id`),
  ADD KEY `gift_cards_seller_id_foreign` (`seller_id`);

--
-- Indexes for table `global_product_attributes`
--
ALTER TABLE `global_product_attributes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `global_product_attributes_slug_unique` (`slug`),
  ADD KEY `global_product_attributes_seller_id_foreign` (`seller_id`);

--
-- Indexes for table `global_product_attribute_values`
--
ALTER TABLE `global_product_attribute_values`
  ADD PRIMARY KEY (`id`),
  ADD KEY `global_product_attribute_values_global_attribute_id_foreign` (`global_attribute_id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `media`
--
ALTER TABLE `media`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `media_uuid_unique` (`uuid`),
  ADD KEY `media_model_type_model_id_index` (`model_type`,`model_id`),
  ADD KEY `media_order_column_index` (`order_column`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `model_has_permissions`
--
ALTER TABLE `model_has_permissions`
  ADD PRIMARY KEY (`permission_id`,`model_id`,`model_type`),
  ADD KEY `model_has_permissions_model_id_model_type_index` (`model_id`,`model_type`);

--
-- Indexes for table `model_has_roles`
--
ALTER TABLE `model_has_roles`
  ADD PRIMARY KEY (`role_id`,`model_id`,`model_type`),
  ADD KEY `model_has_roles_model_id_model_type_index` (`model_id`,`model_type`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_user_id_foreign` (`user_id`),
  ADD KEY `notifications_store_id_foreign` (`store_id`),
  ADD KEY `notifications_order_id_foreign` (`order_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `orders_uuid_unique` (`uuid`),
  ADD UNIQUE KEY `orders_slug_unique` (`slug`),
  ADD KEY `orders_user_id_foreign` (`user_id`),
  ADD KEY `orders_delivery_time_slot_id_foreign` (`delivery_time_slot_id`),
  ADD KEY `orders_delivery_boy_id_foreign` (`delivery_boy_id`),
  ADD KEY `orders_delivery_zone_id_foreign` (`delivery_zone_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_items_order_id_foreign` (`order_id`),
  ADD KEY `order_items_product_id_foreign` (`product_id`),
  ADD KEY `order_items_product_variant_id_foreign` (`product_variant_id`),
  ADD KEY `order_items_store_id_foreign` (`store_id`);

--
-- Indexes for table `order_item_returns`
--
ALTER TABLE `order_item_returns`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_item_returns_order_item_id_foreign` (`order_item_id`),
  ADD KEY `order_item_returns_order_id_foreign` (`order_id`),
  ADD KEY `order_item_returns_user_id_foreign` (`user_id`),
  ADD KEY `order_item_returns_seller_id_foreign` (`seller_id`),
  ADD KEY `order_item_returns_store_id_foreign` (`store_id`),
  ADD KEY `order_item_returns_delivery_boy_id_foreign` (`delivery_boy_id`);

--
-- Indexes for table `order_payment_transactions`
--
ALTER TABLE `order_payment_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `order_payment_transactions_uuid_unique` (`uuid`),
  ADD KEY `order_payment_transactions_order_id_foreign` (`order_id`),
  ADD KEY `order_payment_transactions_user_id_foreign` (`user_id`);

--
-- Indexes for table `order_promo_line`
--
ALTER TABLE `order_promo_line`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_promo_line_order_id_foreign` (`order_id`),
  ADD KEY `order_promo_line_promo_id_foreign` (`promo_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `permissions_name_guard_name_unique` (`name`,`guard_name`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `products_uuid_unique` (`uuid`),
  ADD UNIQUE KEY `products_slug_unique` (`slug`),
  ADD UNIQUE KEY `products_product_identity_unique` (`product_identity`),
  ADD KEY `products_seller_id_foreign` (`seller_id`),
  ADD KEY `products_category_id_foreign` (`category_id`),
  ADD KEY `products_brand_id_foreign` (`brand_id`),
  ADD KEY `products_product_condition_id_foreign` (`product_condition_id`);

--
-- Indexes for table `product_conditions`
--
ALTER TABLE `product_conditions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `product_conditions_uuid_unique` (`uuid`),
  ADD UNIQUE KEY `product_conditions_slug_unique` (`slug`),
  ADD KEY `product_conditions_category_id_foreign` (`category_id`);

--
-- Indexes for table `product_faqs`
--
ALTER TABLE `product_faqs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_faqs_product_id_foreign` (`product_id`);

--
-- Indexes for table `product_taxes`
--
ALTER TABLE `product_taxes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_taxes_product_id_foreign` (`product_id`),
  ADD KEY `product_taxes_tax_class_id_foreign` (`tax_class_id`);

--
-- Indexes for table `product_variants`
--
ALTER TABLE `product_variants`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `product_variants_slug_unique` (`slug`),
  ADD KEY `product_variants_product_id_foreign` (`product_id`);

--
-- Indexes for table `product_variant_attributes`
--
ALTER TABLE `product_variant_attributes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_variant_attributes_product_variant_id_foreign` (`product_variant_id`),
  ADD KEY `product_variant_attributes_global_attribute_id_foreign` (`global_attribute_id`),
  ADD KEY `product_variant_attributes_global_attribute_value_id_foreign` (`global_attribute_value_id`),
  ADD KEY `product_variant_attributes_product_id_foreign` (`product_id`);

--
-- Indexes for table `promo`
--
ALTER TABLE `promo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `promo_code_unique` (`code`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `reviews_slug_unique` (`slug`),
  ADD UNIQUE KEY `reviews_order_item_id_unique` (`order_item_id`),
  ADD KEY `reviews_user_id_foreign` (`user_id`),
  ADD KEY `reviews_product_id_foreign` (`product_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `roles_team_id_guard_name_name_unique` (`team_id`,`guard_name`,`name`);

--
-- Indexes for table `role_has_permissions`
--
ALTER TABLE `role_has_permissions`
  ADD PRIMARY KEY (`permission_id`,`role_id`),
  ADD KEY `role_has_permissions_role_id_foreign` (`role_id`);

--
-- Indexes for table `sellers`
--
ALTER TABLE `sellers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `seller_feedback`
--
ALTER TABLE `seller_feedback`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `seller_feedback_slug_unique` (`slug`),
  ADD UNIQUE KEY `seller_feedback_order_item_id_unique` (`order_item_id`),
  ADD KEY `seller_feedback_user_id_foreign` (`user_id`),
  ADD KEY `seller_feedback_seller_id_foreign` (`seller_id`),
  ADD KEY `seller_feedback_order_id_foreign` (`order_id`),
  ADD KEY `seller_feedback_store_id_foreign` (`store_id`);

--
-- Indexes for table `seller_orders`
--
ALTER TABLE `seller_orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `seller_orders_order_id_foreign` (`order_id`),
  ADD KEY `seller_orders_seller_id_foreign` (`seller_id`);

--
-- Indexes for table `seller_order_items`
--
ALTER TABLE `seller_order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `seller_order_items_seller_order_id_foreign` (`seller_order_id`),
  ADD KEY `seller_order_items_product_id_foreign` (`product_id`),
  ADD KEY `seller_order_items_product_variant_id_foreign` (`product_variant_id`),
  ADD KEY `seller_order_items_order_item_id_foreign` (`order_item_id`);

--
-- Indexes for table `seller_statements`
--
ALTER TABLE `seller_statements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `seller_statements_seller_id_posted_at_index` (`seller_id`,`posted_at`),
  ADD KEY `seller_statements_order_id_index` (`order_id`),
  ADD KEY `seller_statements_order_item_id_index` (`order_item_id`),
  ADD KEY `seller_statements_return_id_index` (`return_id`),
  ADD KEY `seller_statements_entry_type_index` (`entry_type`),
  ADD KEY `seller_statements_seller_id_settlement_status_index` (`seller_id`,`settlement_status`),
  ADD KEY `seller_statements_settlement_status_posted_at_index` (`settlement_status`,`posted_at`);

--
-- Indexes for table `seller_user`
--
ALTER TABLE `seller_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_seller_user` (`user_id`,`seller_id`),
  ADD KEY `seller_user_seller_id_foreign` (`seller_id`);

--
-- Indexes for table `seller_withdrawal_requests`
--
ALTER TABLE `seller_withdrawal_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `seller_withdrawal_requests_processed_by_foreign` (`processed_by`),
  ADD KEY `seller_withdrawal_requests_user_id_index` (`user_id`),
  ADD KEY `seller_withdrawal_requests_seller_id_index` (`seller_id`),
  ADD KEY `seller_withdrawal_requests_status_index` (`status`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`variable`);

--
-- Indexes for table `shipping_parcels`
--
ALTER TABLE `shipping_parcels`
  ADD PRIMARY KEY (`id`),
  ADD KEY `shipping_parcels_order_id_foreign` (`order_id`),
  ADD KEY `shipping_parcels_store_id_foreign` (`store_id`),
  ADD KEY `shipping_parcels_delivery_boy_id_foreign` (`delivery_boy_id`);

--
-- Indexes for table `shipping_parcel_items`
--
ALTER TABLE `shipping_parcel_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `shipping_parcel_items_parcel_id_foreign` (`parcel_id`),
  ADD KEY `shipping_parcel_items_order_item_id_foreign` (`order_item_id`);

--
-- Indexes for table `stores`
--
ALTER TABLE `stores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `stores_slug_unique` (`slug`),
  ADD KEY `stores_seller_id_foreign` (`seller_id`);

--
-- Indexes for table `store_inventory_logs`
--
ALTER TABLE `store_inventory_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `store_inventory_logs_store_id_foreign` (`store_id`),
  ADD KEY `store_inventory_logs_product_variant_id_foreign` (`product_variant_id`);

--
-- Indexes for table `store_product_variants`
--
ALTER TABLE `store_product_variants`
  ADD PRIMARY KEY (`id`),
  ADD KEY `store_product_variants_product_variant_id_foreign` (`product_variant_id`),
  ADD KEY `store_product_variants_store_id_foreign` (`store_id`);

--
-- Indexes for table `store_zone`
--
ALTER TABLE `store_zone`
  ADD PRIMARY KEY (`id`),
  ADD KEY `store_zone_store_id_foreign` (`store_id`),
  ADD KEY `store_zone_zone_id_foreign` (`zone_id`);

--
-- Indexes for table `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `support_tickets_slug_unique` (`slug`),
  ADD KEY `support_tickets_ticket_type_id_foreign` (`ticket_type_id`),
  ADD KEY `support_tickets_user_id_foreign` (`user_id`);

--
-- Indexes for table `support_ticket_messages`
--
ALTER TABLE `support_ticket_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `support_ticket_messages_user_id_foreign` (`user_id`),
  ADD KEY `support_ticket_messages_ticket_id_foreign` (`ticket_id`);

--
-- Indexes for table `support_ticket_types`
--
ALTER TABLE `support_ticket_types`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `system_updates`
--
ALTER TABLE `system_updates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `system_updates_version_index` (`version`);

--
-- Indexes for table `tax_classes`
--
ALTER TABLE `tax_classes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tax_class_tax_rate`
--
ALTER TABLE `tax_class_tax_rate`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tax_class_tax_rate_tax_class_id_tax_rate_id_unique` (`tax_class_id`,`tax_rate_id`),
  ADD KEY `tax_class_tax_rate_tax_rate_id_foreign` (`tax_rate_id`);

--
-- Indexes for table `tax_rates`
--
ALTER TABLE `tax_rates`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD UNIQUE KEY `users_mobile_unique` (`mobile`);

--
-- Indexes for table `user_fcm_tokens`
--
ALTER TABLE `user_fcm_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_fcm_tokens_fcm_token_unique` (`fcm_token`),
  ADD KEY `user_fcm_tokens_user_id_foreign` (`user_id`);

--
-- Indexes for table `wallets`
--
ALTER TABLE `wallets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `wallets_user_id_foreign` (`user_id`);

--
-- Indexes for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `wallet_transactions_transaction_reference_unique` (`transaction_reference`),
  ADD KEY `wallet_transactions_wallet_id_foreign` (`wallet_id`),
  ADD KEY `wallet_transactions_user_id_foreign` (`user_id`),
  ADD KEY `wallet_transactions_order_id_foreign` (`order_id`),
  ADD KEY `wallet_transactions_store_id_foreign` (`store_id`);

--
-- Indexes for table `wishlists`
--
ALTER TABLE `wishlists`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `wishlists_user_id_slug_unique` (`user_id`,`slug`);

--
-- Indexes for table `wishlist_items`
--
ALTER TABLE `wishlist_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `wishlist_items_wishlist_id_foreign` (`wishlist_id`),
  ADD KEY `wishlist_items_product_id_foreign` (`product_id`),
  ADD KEY `wishlist_items_product_variant_id_foreign` (`product_variant_id`),
  ADD KEY `wishlist_items_store_id_foreign` (`store_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `addresses`
--
ALTER TABLE `addresses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `banners`
--
ALTER TABLE `banners`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `brands`
--
ALTER TABLE `brands`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `carts`
--
ALTER TABLE `carts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `category_featured_section`
--
ALTER TABLE `category_featured_section`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `category_product_conditions`
--
ALTER TABLE `category_product_conditions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `collections`
--
ALTER TABLE `collections`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `countries`
--
ALTER TABLE `countries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delivery_boys`
--
ALTER TABLE `delivery_boys`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delivery_boy_assignments`
--
ALTER TABLE `delivery_boy_assignments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delivery_boy_cash_transactions`
--
ALTER TABLE `delivery_boy_cash_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delivery_boy_locations`
--
ALTER TABLE `delivery_boy_locations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delivery_boy_withdrawal_requests`
--
ALTER TABLE `delivery_boy_withdrawal_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delivery_feedback`
--
ALTER TABLE `delivery_feedback`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delivery_time_slots`
--
ALTER TABLE `delivery_time_slots`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delivery_zones`
--
ALTER TABLE `delivery_zones`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `faqs`
--
ALTER TABLE `faqs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `featured_sections`
--
ALTER TABLE `featured_sections`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `following_sellers`
--
ALTER TABLE `following_sellers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `gift_cards`
--
ALTER TABLE `gift_cards`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `global_product_attributes`
--
ALTER TABLE `global_product_attributes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `global_product_attribute_values`
--
ALTER TABLE `global_product_attribute_values`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `media`
--
ALTER TABLE `media`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_item_returns`
--
ALTER TABLE `order_item_returns`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_payment_transactions`
--
ALTER TABLE `order_payment_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_promo_line`
--
ALTER TABLE `order_promo_line`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=200;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_conditions`
--
ALTER TABLE `product_conditions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_faqs`
--
ALTER TABLE `product_faqs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_taxes`
--
ALTER TABLE `product_taxes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_variants`
--
ALTER TABLE `product_variants`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_variant_attributes`
--
ALTER TABLE `product_variant_attributes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `promo`
--
ALTER TABLE `promo`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sellers`
--
ALTER TABLE `sellers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seller_feedback`
--
ALTER TABLE `seller_feedback`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seller_orders`
--
ALTER TABLE `seller_orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seller_order_items`
--
ALTER TABLE `seller_order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seller_statements`
--
ALTER TABLE `seller_statements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seller_user`
--
ALTER TABLE `seller_user`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seller_withdrawal_requests`
--
ALTER TABLE `seller_withdrawal_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `shipping_parcels`
--
ALTER TABLE `shipping_parcels`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `shipping_parcel_items`
--
ALTER TABLE `shipping_parcel_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `stores`
--
ALTER TABLE `stores`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `store_inventory_logs`
--
ALTER TABLE `store_inventory_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `store_product_variants`
--
ALTER TABLE `store_product_variants`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `store_zone`
--
ALTER TABLE `store_zone`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `support_tickets`
--
ALTER TABLE `support_tickets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `support_ticket_messages`
--
ALTER TABLE `support_ticket_messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `support_ticket_types`
--
ALTER TABLE `support_ticket_types`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_updates`
--
ALTER TABLE `system_updates`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tax_classes`
--
ALTER TABLE `tax_classes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tax_class_tax_rate`
--
ALTER TABLE `tax_class_tax_rate`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tax_rates`
--
ALTER TABLE `tax_rates`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_fcm_tokens`
--
ALTER TABLE `user_fcm_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `wallets`
--
ALTER TABLE `wallets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `wishlists`
--
ALTER TABLE `wishlists`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `wishlist_items`
--
ALTER TABLE `wishlist_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `addresses`
--
ALTER TABLE `addresses`
  ADD CONSTRAINT `addresses_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `banners`
--
ALTER TABLE `banners`
  ADD CONSTRAINT `banners_brand_id_foreign` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `banners_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `banners_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `banners_scope_id_foreign` FOREIGN KEY (`scope_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `brands`
--
ALTER TABLE `brands`
  ADD CONSTRAINT `brands_scope_id_foreign` FOREIGN KEY (`scope_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `cart_items_cart_id_foreign` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_items_product_variant_id_foreign` FOREIGN KEY (`product_variant_id`) REFERENCES `product_variants` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_items_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `categories_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `category_featured_section`
--
ALTER TABLE `category_featured_section`
  ADD CONSTRAINT `category_featured_section_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `category_featured_section_featured_section_id_foreign` FOREIGN KEY (`featured_section_id`) REFERENCES `featured_sections` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `category_product`
--
ALTER TABLE `category_product`
  ADD CONSTRAINT `category_product_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `category_product_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `category_product_conditions`
--
ALTER TABLE `category_product_conditions`
  ADD CONSTRAINT `category_product_conditions_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `category_product_conditions_product_condition_id_foreign` FOREIGN KEY (`product_condition_id`) REFERENCES `product_conditions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `delivery_boys`
--
ALTER TABLE `delivery_boys`
  ADD CONSTRAINT `delivery_boys_delivery_zone_id_foreign` FOREIGN KEY (`delivery_zone_id`) REFERENCES `delivery_zones` (`id`);

--
-- Constraints for table `delivery_boy_assignments`
--
ALTER TABLE `delivery_boy_assignments`
  ADD CONSTRAINT `delivery_boy_assignments_delivery_boy_id_foreign` FOREIGN KEY (`delivery_boy_id`) REFERENCES `delivery_boys` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `delivery_boy_assignments_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `delivery_boy_assignments_order_item_id_foreign` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `delivery_boy_assignments_return_id_foreign` FOREIGN KEY (`return_id`) REFERENCES `order_item_returns` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `delivery_boy_assignments_transaction_id_foreign` FOREIGN KEY (`transaction_id`) REFERENCES `wallet_transactions` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `delivery_boy_cash_transactions`
--
ALTER TABLE `delivery_boy_cash_transactions`
  ADD CONSTRAINT `fk_dbc_assignment` FOREIGN KEY (`delivery_boy_assignment_id`) REFERENCES `delivery_boy_assignments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dbc_boy` FOREIGN KEY (`delivery_boy_id`) REFERENCES `delivery_boys` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dbc_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `delivery_boy_withdrawal_requests`
--
ALTER TABLE `delivery_boy_withdrawal_requests`
  ADD CONSTRAINT `delivery_boy_withdrawal_requests_delivery_boy_id_foreign` FOREIGN KEY (`delivery_boy_id`) REFERENCES `delivery_boys` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `delivery_boy_withdrawal_requests_processed_by_foreign` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `delivery_boy_withdrawal_requests_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `delivery_feedback`
--
ALTER TABLE `delivery_feedback`
  ADD CONSTRAINT `delivery_feedback_delivery_boy_id_foreign` FOREIGN KEY (`delivery_boy_id`) REFERENCES `delivery_boys` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `delivery_feedback_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `delivery_feedback_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `delivery_time_slots`
--
ALTER TABLE `delivery_time_slots`
  ADD CONSTRAINT `delivery_time_slots_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `featured_sections`
--
ALTER TABLE `featured_sections`
  ADD CONSTRAINT `featured_sections_scope_id_foreign` FOREIGN KEY (`scope_id`) REFERENCES `categories` (`id`);

--
-- Constraints for table `gift_cards`
--
ALTER TABLE `gift_cards`
  ADD CONSTRAINT `gift_cards_seller_id_foreign` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `global_product_attributes`
--
ALTER TABLE `global_product_attributes`
  ADD CONSTRAINT `global_product_attributes_seller_id_foreign` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`id`);

--
-- Constraints for table `global_product_attribute_values`
--
ALTER TABLE `global_product_attribute_values`
  ADD CONSTRAINT `global_product_attribute_values_global_attribute_id_foreign` FOREIGN KEY (`global_attribute_id`) REFERENCES `global_product_attributes` (`id`);

--
-- Constraints for table `model_has_permissions`
--
ALTER TABLE `model_has_permissions`
  ADD CONSTRAINT `model_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `model_has_roles`
--
ALTER TABLE `model_has_roles`
  ADD CONSTRAINT `model_has_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `notifications_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_delivery_boy_id_foreign` FOREIGN KEY (`delivery_boy_id`) REFERENCES `delivery_boys` (`id`),
  ADD CONSTRAINT `orders_delivery_time_slot_id_foreign` FOREIGN KEY (`delivery_time_slot_id`) REFERENCES `delivery_time_slots` (`id`),
  ADD CONSTRAINT `orders_delivery_zone_id_foreign` FOREIGN KEY (`delivery_zone_id`) REFERENCES `delivery_zones` (`id`),
  ADD CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_product_variant_id_foreign` FOREIGN KEY (`product_variant_id`) REFERENCES `product_variants` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_item_returns`
--
ALTER TABLE `order_item_returns`
  ADD CONSTRAINT `order_item_returns_delivery_boy_id_foreign` FOREIGN KEY (`delivery_boy_id`) REFERENCES `delivery_boys` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `order_item_returns_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_item_returns_order_item_id_foreign` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_item_returns_seller_id_foreign` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_item_returns_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_item_returns_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_payment_transactions`
--
ALTER TABLE `order_payment_transactions`
  ADD CONSTRAINT `order_payment_transactions_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_payment_transactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_promo_line`
--
ALTER TABLE `order_promo_line`
  ADD CONSTRAINT `order_promo_line_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_promo_line_promo_id_foreign` FOREIGN KEY (`promo_id`) REFERENCES `promo` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_brand_id_foreign` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `products_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `products_product_condition_id_foreign` FOREIGN KEY (`product_condition_id`) REFERENCES `product_conditions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `products_seller_id_foreign` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `product_conditions`
--
ALTER TABLE `product_conditions`
  ADD CONSTRAINT `product_conditions_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `product_faqs`
--
ALTER TABLE `product_faqs`
  ADD CONSTRAINT `product_faqs_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `product_taxes`
--
ALTER TABLE `product_taxes`
  ADD CONSTRAINT `product_taxes_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_taxes_tax_class_id_foreign` FOREIGN KEY (`tax_class_id`) REFERENCES `tax_classes` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `product_variants`
--
ALTER TABLE `product_variants`
  ADD CONSTRAINT `product_variants_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `product_variant_attributes`
--
ALTER TABLE `product_variant_attributes`
  ADD CONSTRAINT `product_variant_attributes_global_attribute_id_foreign` FOREIGN KEY (`global_attribute_id`) REFERENCES `global_product_attributes` (`id`),
  ADD CONSTRAINT `product_variant_attributes_global_attribute_value_id_foreign` FOREIGN KEY (`global_attribute_value_id`) REFERENCES `global_product_attribute_values` (`id`),
  ADD CONSTRAINT `product_variant_attributes_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  ADD CONSTRAINT `product_variant_attributes_product_variant_id_foreign` FOREIGN KEY (`product_variant_id`) REFERENCES `product_variants` (`id`);

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `role_has_permissions`
--
ALTER TABLE `role_has_permissions`
  ADD CONSTRAINT `role_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `role_has_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `seller_feedback`
--
ALTER TABLE `seller_feedback`
  ADD CONSTRAINT `seller_feedback_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `seller_feedback_order_item_id_foreign` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `seller_feedback_seller_id_foreign` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `seller_feedback_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `seller_feedback_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `seller_orders`
--
ALTER TABLE `seller_orders`
  ADD CONSTRAINT `seller_orders_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `seller_orders_seller_id_foreign` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `seller_order_items`
--
ALTER TABLE `seller_order_items`
  ADD CONSTRAINT `seller_order_items_order_item_id_foreign` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `seller_order_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `seller_order_items_product_variant_id_foreign` FOREIGN KEY (`product_variant_id`) REFERENCES `product_variants` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `seller_order_items_seller_order_id_foreign` FOREIGN KEY (`seller_order_id`) REFERENCES `seller_orders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `seller_statements`
--
ALTER TABLE `seller_statements`
  ADD CONSTRAINT `seller_statements_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `seller_statements_order_item_id_foreign` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `seller_statements_return_id_foreign` FOREIGN KEY (`return_id`) REFERENCES `order_item_returns` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `seller_statements_seller_id_foreign` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `seller_user`
--
ALTER TABLE `seller_user`
  ADD CONSTRAINT `seller_user_seller_id_foreign` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `seller_user_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `seller_withdrawal_requests`
--
ALTER TABLE `seller_withdrawal_requests`
  ADD CONSTRAINT `seller_withdrawal_requests_processed_by_foreign` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `seller_withdrawal_requests_seller_id_foreign` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `seller_withdrawal_requests_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `shipping_parcels`
--
ALTER TABLE `shipping_parcels`
  ADD CONSTRAINT `shipping_parcels_delivery_boy_id_foreign` FOREIGN KEY (`delivery_boy_id`) REFERENCES `delivery_boys` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `shipping_parcels_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `shipping_parcels_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `shipping_parcel_items`
--
ALTER TABLE `shipping_parcel_items`
  ADD CONSTRAINT `shipping_parcel_items_order_item_id_foreign` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `shipping_parcel_items_parcel_id_foreign` FOREIGN KEY (`parcel_id`) REFERENCES `shipping_parcels` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `stores`
--
ALTER TABLE `stores`
  ADD CONSTRAINT `stores_seller_id_foreign` FOREIGN KEY (`seller_id`) REFERENCES `sellers` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `store_inventory_logs`
--
ALTER TABLE `store_inventory_logs`
  ADD CONSTRAINT `store_inventory_logs_product_variant_id_foreign` FOREIGN KEY (`product_variant_id`) REFERENCES `product_variants` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `store_inventory_logs_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `store_product_variants`
--
ALTER TABLE `store_product_variants`
  ADD CONSTRAINT `store_product_variants_product_variant_id_foreign` FOREIGN KEY (`product_variant_id`) REFERENCES `product_variants` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `store_product_variants_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `store_zone`
--
ALTER TABLE `store_zone`
  ADD CONSTRAINT `store_zone_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `store_zone_zone_id_foreign` FOREIGN KEY (`zone_id`) REFERENCES `delivery_zones` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD CONSTRAINT `support_tickets_ticket_type_id_foreign` FOREIGN KEY (`ticket_type_id`) REFERENCES `support_ticket_types` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `support_tickets_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `support_ticket_messages`
--
ALTER TABLE `support_ticket_messages`
  ADD CONSTRAINT `support_ticket_messages_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `support_ticket_messages_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tax_class_tax_rate`
--
ALTER TABLE `tax_class_tax_rate`
  ADD CONSTRAINT `tax_class_tax_rate_tax_class_id_foreign` FOREIGN KEY (`tax_class_id`) REFERENCES `tax_classes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tax_class_tax_rate_tax_rate_id_foreign` FOREIGN KEY (`tax_rate_id`) REFERENCES `tax_rates` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_fcm_tokens`
--
ALTER TABLE `user_fcm_tokens`
  ADD CONSTRAINT `user_fcm_tokens_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `wallets`
--
ALTER TABLE `wallets`
  ADD CONSTRAINT `wallets_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD CONSTRAINT `wallet_transactions_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `wallet_transactions_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`),
  ADD CONSTRAINT `wallet_transactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `wallet_transactions_wallet_id_foreign` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`id`);

--
-- Constraints for table `wishlists`
--
ALTER TABLE `wishlists`
  ADD CONSTRAINT `wishlists_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `wishlist_items`
--
ALTER TABLE `wishlist_items`
  ADD CONSTRAINT `wishlist_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `wishlist_items_product_variant_id_foreign` FOREIGN KEY (`product_variant_id`) REFERENCES `product_variants` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `wishlist_items_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `wishlist_items_wishlist_id_foreign` FOREIGN KEY (`wishlist_id`) REFERENCES `wishlists` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
