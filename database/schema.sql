-- Bagde ERP Database Schema
-- Building Material & Transport Management System
-- MySQL 5.7+ / MariaDB 10.3+

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- USERS & AUTHENTICATION
-- =====================================================

CREATE TABLE IF NOT EXISTS `users` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `role` ENUM('admin','manager','accountant','operator','viewer') NOT NULL DEFAULT 'operator',
    `mobile` VARCHAR(15) DEFAULT NULL,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `last_login` DATETIME DEFAULT NULL,
    `reset_token` VARCHAR(64) DEFAULT NULL,
    `reset_expires` DATETIME DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `updated_at` DATETIME DEFAULT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    INDEX `idx_users_role` (`role`),
    INDEX `idx_users_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `remember_tokens` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `token_hash` VARCHAR(64) NOT NULL,
    `expires_at` DATETIME NOT NULL,
    INDEX `idx_remember_user` (`user_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `role_permissions` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `role` ENUM('admin','manager','accountant','operator','viewer') NOT NULL,
    `permission` VARCHAR(50) NOT NULL,
    UNIQUE KEY `uk_role_permission` (`role`, `permission`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `activity_logs` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED DEFAULT NULL,
    `action` VARCHAR(50) NOT NULL,
    `description` TEXT,
    `module` VARCHAR(50) DEFAULT NULL,
    `record_id` INT UNSIGNED DEFAULT NULL,
    `ip_address` VARCHAR(45) DEFAULT NULL,
    `user_agent` VARCHAR(255) DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_activity_user` (`user_id`),
    INDEX `idx_activity_module` (`module`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- SETTINGS
-- =====================================================

CREATE TABLE IF NOT EXISTS `settings` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `setting_key` VARCHAR(100) NOT NULL UNIQUE,
    `setting_value` TEXT,
    `setting_group` VARCHAR(50) DEFAULT 'general',
    `updated_at` DATETIME DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `auto_sequences` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `type` VARCHAR(20) NOT NULL UNIQUE,
    `prefix` VARCHAR(10) NOT NULL,
    `last_number` INT UNSIGNED NOT NULL DEFAULT 0,
    `padding` TINYINT NOT NULL DEFAULT 6
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- CUSTOMERS
-- =====================================================

CREATE TABLE IF NOT EXISTS `customers` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `customer_code` VARCHAR(20) NOT NULL UNIQUE,
    `name` VARCHAR(150) NOT NULL,
    `mobile` VARCHAR(15) DEFAULT NULL,
    `email` VARCHAR(150) DEFAULT NULL,
    `address` TEXT,
    `city` VARCHAR(100) DEFAULT NULL,
    `state` VARCHAR(100) DEFAULT NULL,
    `pincode` VARCHAR(10) DEFAULT NULL,
    `gst_number` VARCHAR(20) DEFAULT NULL,
    `opening_balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `balance_type` ENUM('dr','cr') NOT NULL DEFAULT 'dr',
    `current_balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `credit_limit` DECIMAL(15,2) DEFAULT 0.00,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `notes` TEXT,
    `created_at` DATETIME NOT NULL,
    `updated_at` DATETIME DEFAULT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    INDEX `idx_customers_code` (`customer_code`),
    INDEX `idx_customers_name` (`name`),
    INDEX `idx_customers_mobile` (`mobile`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `customer_ledger` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `customer_id` INT UNSIGNED NOT NULL,
    `transaction_date` DATE NOT NULL,
    `reference_type` ENUM('opening','order','trip','payment','invoice','adjustment','reversal') NOT NULL,
    `reference_id` INT UNSIGNED DEFAULT NULL,
    `reference_no` VARCHAR(30) DEFAULT NULL,
    `description` VARCHAR(255) NOT NULL,
    `debit` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `credit` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_cl_customer` (`customer_id`),
    INDEX `idx_cl_date` (`transaction_date`),
    FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `customer_payments` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `payment_no` VARCHAR(20) NOT NULL UNIQUE,
    `customer_id` INT UNSIGNED NOT NULL,
    `order_id` INT UNSIGNED DEFAULT NULL,
    `invoice_id` INT UNSIGNED DEFAULT NULL,
    `payment_date` DATE NOT NULL,
    `amount` DECIMAL(15,2) NOT NULL,
    `payment_mode` ENUM('cash','upi','bank','cheque') NOT NULL DEFAULT 'cash',
    `reference_no` VARCHAR(50) DEFAULT NULL,
    `bank_name` VARCHAR(100) DEFAULT NULL,
    `cheque_no` VARCHAR(30) DEFAULT NULL,
    `cheque_date` DATE DEFAULT NULL,
    `remarks` TEXT,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `updated_at` DATETIME DEFAULT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    INDEX `idx_cp_customer` (`customer_id`),
    INDEX `idx_cp_date` (`payment_date`),
    INDEX `idx_cp_invoice` (`invoice_id`),
    FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- MATERIALS & STOCK
-- =====================================================

CREATE TABLE IF NOT EXISTS `materials` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `code` VARCHAR(20) DEFAULT NULL,
    `unit` ENUM('trip','ton','brass','cft','bag','kg','nos') NOT NULL DEFAULT 'trip',
    `default_rate` DECIMAL(15,2) DEFAULT 0.00,
    `opening_stock` DECIMAL(15,3) NOT NULL DEFAULT 0.000,
    `current_stock` DECIMAL(15,3) NOT NULL DEFAULT 0.000,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL,
    `updated_at` DATETIME DEFAULT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    INDEX `idx_materials_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `stock_ledger` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `material_id` INT UNSIGNED NOT NULL,
    `transaction_date` DATE NOT NULL,
    `reference_type` ENUM('opening','purchase','sale','trip','adjustment') NOT NULL,
    `reference_id` INT UNSIGNED DEFAULT NULL,
    `reference_no` VARCHAR(30) DEFAULT NULL,
    `description` VARCHAR(255),
    `quantity_in` DECIMAL(15,3) NOT NULL DEFAULT 0.000,
    `quantity_out` DECIMAL(15,3) NOT NULL DEFAULT 0.000,
    `balance` DECIMAL(15,3) NOT NULL DEFAULT 0.000,
    `rate` DECIMAL(15,2) DEFAULT 0.00,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_sl_material` (`material_id`),
    FOREIGN KEY (`material_id`) REFERENCES `materials`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `stock_purchases` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `purchase_no` VARCHAR(20) NOT NULL UNIQUE,
    `material_id` INT UNSIGNED NOT NULL,
    `purchase_date` DATE NOT NULL,
    `quantity` DECIMAL(15,3) NOT NULL,
    `rate` DECIMAL(15,2) NOT NULL,
    `amount` DECIMAL(15,2) NOT NULL,
    `supplier_name` VARCHAR(150) DEFAULT NULL,
    `remarks` TEXT,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    FOREIGN KEY (`material_id`) REFERENCES `materials`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- ORDERS
-- =====================================================

CREATE TABLE IF NOT EXISTS `orders` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `order_no` VARCHAR(20) NOT NULL UNIQUE,
    `customer_id` INT UNSIGNED NOT NULL,
    `material_id` INT UNSIGNED NOT NULL,
    `order_date` DATE NOT NULL,
    `quantity` DECIMAL(15,3) NOT NULL,
    `unit` VARCHAR(20) NOT NULL DEFAULT 'trip',
    `rate` DECIMAL(15,2) NOT NULL,
    `labour_charge_per_unit` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `total_amount` DECIMAL(15,2) NOT NULL,
    `advance_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `discount_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `net_amount` DECIMAL(15,2) NOT NULL,
    `trips_completed` INT UNSIGNED NOT NULL DEFAULT 0,
    `trips_remaining` DECIMAL(15,3) NOT NULL DEFAULT 0.000,
    `amount_received` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `balance_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `status` ENUM('running','completed','cancelled') NOT NULL DEFAULT 'running',
    `remarks` TEXT,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `updated_at` DATETIME DEFAULT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    INDEX `idx_orders_customer` (`customer_id`),
    INDEX `idx_orders_status` (`status`),
    INDEX `idx_orders_date` (`order_date`),
    FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`),
    FOREIGN KEY (`material_id`) REFERENCES `materials`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `order_payments` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `order_id` INT UNSIGNED NOT NULL,
    `customer_payment_id` INT UNSIGNED DEFAULT NULL,
    `amount` DECIMAL(15,2) NOT NULL,
    `payment_date` DATE NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`),
    FOREIGN KEY (`customer_payment_id`) REFERENCES `customer_payments`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- DRIVERS
-- =====================================================

CREATE TABLE IF NOT EXISTS `drivers` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `mobile` VARCHAR(15) NOT NULL,
    `address` TEXT,
    `licence_number` VARCHAR(30) DEFAULT NULL,
    `licence_expiry` DATE DEFAULT NULL,
    `licence_file` VARCHAR(255) DEFAULT NULL,
    `bank_name` VARCHAR(100) DEFAULT NULL,
    `account_number` VARCHAR(30) DEFAULT NULL,
    `ifsc_code` VARCHAR(15) DEFAULT NULL,
    `current_balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL,
    `updated_at` DATETIME DEFAULT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    INDEX `idx_drivers_mobile` (`mobile`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `driver_ledger` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `driver_id` INT UNSIGNED NOT NULL,
    `transaction_date` DATE NOT NULL,
    `reference_type` ENUM('trip','advance','payment','adjustment','reversal') NOT NULL,
    `reference_id` INT UNSIGNED DEFAULT NULL,
    `reference_no` VARCHAR(30) DEFAULT NULL,
    `description` VARCHAR(255) NOT NULL,
    `debit` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `credit` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_dl_driver` (`driver_id`),
    FOREIGN KEY (`driver_id`) REFERENCES `drivers`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `driver_advances` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `driver_id` INT UNSIGNED NOT NULL,
    `advance_date` DATE NOT NULL,
    `amount` DECIMAL(15,2) NOT NULL,
    `reason` VARCHAR(255) DEFAULT NULL,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    FOREIGN KEY (`driver_id`) REFERENCES `drivers`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `driver_payments` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `payment_no` VARCHAR(20) NOT NULL UNIQUE,
    `driver_id` INT UNSIGNED NOT NULL,
    `payment_date` DATE NOT NULL,
    `amount` DECIMAL(15,2) NOT NULL,
    `payment_mode` ENUM('cash','upi','bank') NOT NULL DEFAULT 'cash',
    `reference_no` VARCHAR(50) DEFAULT NULL,
    `remarks` TEXT,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    FOREIGN KEY (`driver_id`) REFERENCES `drivers`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- LABOURS
-- =====================================================

CREATE TABLE IF NOT EXISTS `labours` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `mobile` VARCHAR(15) DEFAULT NULL,
    `address` TEXT,
    `photo` VARCHAR(255) DEFAULT NULL,
    `aadhaar_number` VARCHAR(20) DEFAULT NULL,
    `aadhaar_file` VARCHAR(255) DEFAULT NULL,
    `bank_name` VARCHAR(100) DEFAULT NULL,
    `account_number` VARCHAR(30) DEFAULT NULL,
    `ifsc_code` VARCHAR(15) DEFAULT NULL,
    `current_balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL,
    `updated_at` DATETIME DEFAULT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    INDEX `idx_labours_name` (`name`),
    INDEX `idx_labours_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `labour_ledger` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `labour_id` INT UNSIGNED NOT NULL,
    `transaction_date` DATE NOT NULL,
    `reference_type` ENUM('trip','advance','payment','deduction','adjustment','reversal') NOT NULL,
    `reference_id` INT UNSIGNED DEFAULT NULL,
    `reference_no` VARCHAR(30) DEFAULT NULL,
    `description` VARCHAR(255) NOT NULL,
    `debit` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `credit` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_ll_labour` (`labour_id`),
    FOREIGN KEY (`labour_id`) REFERENCES `labours`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `labour_advances` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `labour_id` INT UNSIGNED NOT NULL,
    `advance_date` DATE NOT NULL,
    `amount` DECIMAL(15,2) NOT NULL,
    `reason` VARCHAR(255) DEFAULT NULL,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    FOREIGN KEY (`labour_id`) REFERENCES `labours`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `labour_payments` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `payment_no` VARCHAR(20) NOT NULL UNIQUE,
    `labour_id` INT UNSIGNED NOT NULL,
    `week_start` DATE NOT NULL,
    `week_end` DATE NOT NULL,
    `trip_earnings` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `advance_deducted` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `other_deduction` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `net_payable` DECIMAL(15,2) NOT NULL,
    `payment_date` DATE DEFAULT NULL,
    `payment_mode` ENUM('cash','upi','bank') DEFAULT NULL,
    `is_paid` TINYINT(1) NOT NULL DEFAULT 0,
    `remarks` TEXT,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    FOREIGN KEY (`labour_id`) REFERENCES `labours`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- VEHICLES (Fleet Master)
-- =====================================================

CREATE TABLE IF NOT EXISTS `vehicles` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `vehicle_number` VARCHAR(20) NOT NULL,
    `vehicle_type` ENUM('tractor','dumper','truck','pickup','tipper','other') NOT NULL DEFAULT 'tractor',
    `brand_model` VARCHAR(100) DEFAULT NULL,
    `registration_number` VARCHAR(30) DEFAULT NULL,
    `rc_expiry` DATE DEFAULT NULL,
    `insurance_expiry` DATE DEFAULT NULL,
    `puc_expiry` DATE DEFAULT NULL,
    `fitness_expiry` DATE DEFAULT NULL,
    `permit_expiry` DATE DEFAULT NULL,
    `owner_name` VARCHAR(100) DEFAULT NULL,
    `owner_id` INT UNSIGNED DEFAULT NULL,
    `fuel_card_no` VARCHAR(50) DEFAULT NULL,
    `gps_device_id` VARCHAR(100) DEFAULT NULL,
    `current_driver_id` INT UNSIGNED DEFAULT NULL,
    `lifecycle_status` ENUM('active','maintenance','breakdown','inactive','sold') NOT NULL DEFAULT 'active',
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `notes` TEXT,
    `current_odometer` INT UNSIGNED DEFAULT NULL,
    `engine_hours` INT UNSIGNED DEFAULT NULL,
    `sold_date` DATE DEFAULT NULL,
    `documents_updated_at` DATETIME DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `updated_at` DATETIME DEFAULT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    UNIQUE KEY `uk_vehicles_number` (`vehicle_number`),
    INDEX `idx_vehicles_active` (`is_active`),
    INDEX `idx_vehicles_lifecycle` (`lifecycle_status`),
    FOREIGN KEY (`current_driver_id`) REFERENCES `drivers`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `vehicle_driver_assignments` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `vehicle_id` INT UNSIGNED NOT NULL,
    `driver_id` INT UNSIGNED NOT NULL,
    `assigned_date` DATE NOT NULL,
    `released_date` DATE DEFAULT NULL,
    `notes` TEXT,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    INDEX `idx_vda_vehicle` (`vehicle_id`),
    INDEX `idx_vda_driver` (`driver_id`),
    FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles`(`id`),
    FOREIGN KEY (`driver_id`) REFERENCES `drivers`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `vehicle_events` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `vehicle_id` INT UNSIGNED NOT NULL,
    `event_type` ENUM(
        'trip_dispatched','trip_completed','maintenance',
        'driver_assigned','driver_released','document_updated','status_changed'
    ) NOT NULL,
    `event_date` DATETIME NOT NULL,
    `reference_type` VARCHAR(30) DEFAULT NULL,
    `reference_id` INT UNSIGNED DEFAULT NULL,
    `title` VARCHAR(150) NOT NULL,
    `description` TEXT,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    INDEX `idx_ve_vehicle` (`vehicle_id`),
    INDEX `idx_ve_date` (`event_date`),
    FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `vehicle_maintenance` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `vehicle_id` INT UNSIGNED NOT NULL,
    `maintenance_date` DATE NOT NULL,
    `maintenance_type` VARCHAR(50) NOT NULL,
    `description` TEXT,
    `vendor` VARCHAR(100) DEFAULT NULL,
    `cost` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `next_service_due` DATE DEFAULT NULL,
    `reminder_by` ENUM('date','odometer','engine_hours') NOT NULL DEFAULT 'date',
    `next_service_odometer` INT UNSIGNED DEFAULT NULL,
    `next_service_engine_hours` INT UNSIGNED DEFAULT NULL,
    `odometer` INT UNSIGNED DEFAULT NULL,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    INDEX `idx_vm_vehicle` (`vehicle_id`),
    INDEX `idx_vm_date` (`maintenance_date`),
    INDEX `idx_vm_next_due` (`next_service_due`),
    FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TRIPS (Core Module)
-- =====================================================

CREATE TABLE IF NOT EXISTS `trips` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `trip_no` VARCHAR(20) NOT NULL UNIQUE,
    `trip_date` DATE NOT NULL,
    `customer_id` INT UNSIGNED NOT NULL,
    `order_id` INT UNSIGNED DEFAULT NULL,
    `material_id` INT UNSIGNED NOT NULL,
    `quantity` DECIMAL(15,3) NOT NULL DEFAULT 1.000,
    `unit` VARCHAR(20) NOT NULL DEFAULT 'trip',
    `rate` DECIMAL(15,2) NOT NULL,
    `amount` DECIMAL(15,2) NOT NULL,
    `source` VARCHAR(150) DEFAULT NULL,
    `destination` VARCHAR(150) DEFAULT NULL,
    `tractor_number` VARCHAR(20) DEFAULT NULL,
    `vehicle_id` INT UNSIGNED DEFAULT NULL,
    `driver_id` INT UNSIGNED DEFAULT NULL,
    `driver_payment` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `diesel_litres` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `diesel_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `royalty` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `loading_charge` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `unloading_charge` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `other_expense` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `labour_cost` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `total_expense` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `net_profit` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `remarks` TEXT,
    `status` ENUM('pending','completed','cancelled') NOT NULL DEFAULT 'completed',
    `challan_generated` TINYINT(1) NOT NULL DEFAULT 0,
    `invoice_generated` TINYINT(1) NOT NULL DEFAULT 0,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `updated_at` DATETIME DEFAULT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    INDEX `idx_trips_date` (`trip_date`),
    INDEX `idx_trips_customer` (`customer_id`),
    INDEX `idx_trips_order` (`order_id`),
    INDEX `idx_trips_driver` (`driver_id`),
    INDEX `idx_trips_vehicle` (`vehicle_id`),
    FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`),
    FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`),
    FOREIGN KEY (`material_id`) REFERENCES `materials`(`id`),
    FOREIGN KEY (`driver_id`) REFERENCES `drivers`(`id`),
    FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `trip_labours` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `trip_id` INT UNSIGNED NOT NULL,
    `labour_id` INT UNSIGNED NOT NULL,
    `amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `is_override` TINYINT(1) NOT NULL DEFAULT 0,
    FOREIGN KEY (`trip_id`) REFERENCES `trips`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`labour_id`) REFERENCES `labours`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- DIESEL
-- =====================================================

CREATE TABLE IF NOT EXISTS `diesel_purchases` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `purchase_date` DATE NOT NULL,
    `litres` DECIMAL(10,2) NOT NULL,
    `rate` DECIMAL(10,2) NOT NULL,
    `amount` DECIMAL(15,2) NOT NULL,
    `pump_name` VARCHAR(100) DEFAULT NULL,
    `vehicle_no` VARCHAR(20) DEFAULT NULL,
    `vehicle_id` INT UNSIGNED DEFAULT NULL,
    `trip_id` INT UNSIGNED DEFAULT NULL,
    `remarks` TEXT,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    INDEX `idx_dp_date` (`purchase_date`),
    FOREIGN KEY (`trip_id`) REFERENCES `trips`(`id`),
    FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- EXPENSES
-- =====================================================

CREATE TABLE IF NOT EXISTS `expense_categories` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `expenses` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `expense_date` DATE NOT NULL,
    `category_id` INT UNSIGNED NOT NULL,
    `amount` DECIMAL(15,2) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `payment_mode` ENUM('cash','upi','bank') NOT NULL DEFAULT 'cash',
    `reference_no` VARCHAR(50) DEFAULT NULL,
    `trip_id` INT UNSIGNED DEFAULT NULL,
    `vehicle_no` VARCHAR(20) DEFAULT NULL,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    INDEX `idx_exp_date` (`expense_date`),
    INDEX `idx_exp_category` (`category_id`),
    FOREIGN KEY (`category_id`) REFERENCES `expense_categories`(`id`),
    FOREIGN KEY (`trip_id`) REFERENCES `trips`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- DELIVERY CHALLAN & INVOICES
-- =====================================================

CREATE TABLE IF NOT EXISTS `delivery_challans` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `challan_no` VARCHAR(20) NOT NULL UNIQUE,
    `trip_id` INT UNSIGNED NOT NULL,
    `challan_date` DATE NOT NULL,
    `customer_id` INT UNSIGNED NOT NULL,
    `material_id` INT UNSIGNED NOT NULL,
    `quantity` DECIMAL(15,3) NOT NULL,
    `unit` VARCHAR(20) NOT NULL,
    `vehicle_no` VARCHAR(20) DEFAULT NULL,
    `driver_name` VARCHAR(100) DEFAULT NULL,
    `source` VARCHAR(150) DEFAULT NULL,
    `destination` VARCHAR(150) DEFAULT NULL,
    `receiver_name` VARCHAR(100) DEFAULT NULL,
    `receiver_signature` VARCHAR(255) DEFAULT NULL,
    `remarks` TEXT,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    FOREIGN KEY (`trip_id`) REFERENCES `trips`(`id`),
    FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`),
    FOREIGN KEY (`material_id`) REFERENCES `materials`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `invoices` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `invoice_no` VARCHAR(20) NOT NULL UNIQUE,
    `invoice_type` ENUM('tax','non_gst','proforma') NOT NULL DEFAULT 'non_gst',
    `invoice_date` DATE NOT NULL,
    `customer_id` INT UNSIGNED NOT NULL,
    `order_id` INT UNSIGNED DEFAULT NULL,
    `subtotal` DECIMAL(15,2) NOT NULL,
    `discount` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `cgst_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `sgst_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `igst_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `total_amount` DECIMAL(15,2) NOT NULL,
    `advance_received` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `amount_received` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `balance_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `remarks` TEXT,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `updated_at` DATETIME DEFAULT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    INDEX `idx_inv_customer` (`customer_id`),
    INDEX `idx_inv_date` (`invoice_date`),
    FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`),
    FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `invoice_items` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `invoice_id` INT UNSIGNED NOT NULL,
    `trip_id` INT UNSIGNED DEFAULT NULL,
    `material_id` INT UNSIGNED NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    `quantity` DECIMAL(15,3) NOT NULL,
    `unit` VARCHAR(20) NOT NULL,
    `rate` DECIMAL(15,2) NOT NULL,
    `amount` DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (`invoice_id`) REFERENCES `invoices`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`trip_id`) REFERENCES `trips`(`id`),
    FOREIGN KEY (`material_id`) REFERENCES `materials`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- ACCOUNTING
-- =====================================================

CREATE TABLE IF NOT EXISTS `cash_book` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `transaction_date` DATE NOT NULL,
    `reference_type` VARCHAR(30) NOT NULL,
    `reference_id` INT UNSIGNED DEFAULT NULL,
    `reference_no` VARCHAR(30) DEFAULT NULL,
    `description` VARCHAR(255) NOT NULL,
    `receipt` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `payment` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_cb_date` (`transaction_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `bank_book` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `transaction_date` DATE NOT NULL,
    `reference_type` VARCHAR(30) NOT NULL,
    `reference_id` INT UNSIGNED DEFAULT NULL,
    `reference_no` VARCHAR(30) DEFAULT NULL,
    `description` VARCHAR(255) NOT NULL,
    `deposit` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `withdrawal` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_bb_date` (`transaction_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- DOCUMENTS
-- =====================================================

CREATE TABLE IF NOT EXISTS `documents` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `entity_type` ENUM('customer','driver','labour','trip','expense','diesel') NOT NULL,
    `entity_id` INT UNSIGNED NOT NULL,
    `document_type` VARCHAR(50) NOT NULL,
    `file_name` VARCHAR(255) NOT NULL,
    `original_name` VARCHAR(255) NOT NULL,
    `file_size` INT UNSIGNED DEFAULT 0,
    `uploaded_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_doc_entity` (`entity_type`, `entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- NOTIFICATIONS
-- =====================================================

CREATE TABLE IF NOT EXISTS `notifications` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED DEFAULT NULL,
    `title` VARCHAR(150) NOT NULL,
    `message` TEXT NOT NULL,
    `type` ENUM('info','warning','success','danger') NOT NULL DEFAULT 'info',
    `link` VARCHAR(255) DEFAULT NULL,
    `is_read` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_notif_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
