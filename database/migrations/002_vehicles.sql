-- Bagde ERP Vehicle Master Migration v2.0
-- Run once on existing installations via phpMyAdmin or CLI

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
    `current_driver_id` INT UNSIGNED DEFAULT NULL,
    `operational_status` ENUM('available','maintenance','breakdown') NOT NULL DEFAULT 'available',
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `notes` TEXT,
    `created_at` DATETIME NOT NULL,
    `updated_at` DATETIME DEFAULT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    UNIQUE KEY `uk_vehicles_number` (`vehicle_number`),
    INDEX `idx_vehicles_active` (`is_active`),
    INDEX `idx_vehicles_status` (`operational_status`),
    FOREIGN KEY (`current_driver_id`) REFERENCES `drivers`(`id`)
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
    `odometer` INT UNSIGNED DEFAULT NULL,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `created_at` DATETIME NOT NULL,
    `deleted_at` DATETIME DEFAULT NULL,
    INDEX `idx_vm_vehicle` (`vehicle_id`),
    INDEX `idx_vm_date` (`maintenance_date`),
    FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Link trips to vehicles (keep tractor_number for backward compatibility)
ALTER TABLE `trips`
    ADD COLUMN `vehicle_id` INT UNSIGNED DEFAULT NULL AFTER `tractor_number`,
    ADD INDEX `idx_trips_vehicle` (`vehicle_id`),
    ADD CONSTRAINT `fk_trips_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles`(`id`);

-- Link diesel purchases to vehicles
ALTER TABLE `diesel_purchases`
    ADD COLUMN `vehicle_id` INT UNSIGNED DEFAULT NULL AFTER `vehicle_no`,
    ADD INDEX `idx_dp_vehicle` (`vehicle_id`),
    ADD CONSTRAINT `fk_dp_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles`(`id`);

-- Backfill vehicles from historical trip tractor numbers
INSERT IGNORE INTO `vehicles` (`vehicle_number`, `vehicle_type`, `created_at`)
SELECT DISTINCT UPPER(TRIM(tractor_number)), 'tractor', NOW()
FROM `trips`
WHERE tractor_number IS NOT NULL AND TRIM(tractor_number) != '' AND deleted_at IS NULL;

UPDATE `trips` t
JOIN `vehicles` v ON UPPER(TRIM(v.vehicle_number)) = UPPER(TRIM(t.tractor_number))
SET t.vehicle_id = v.id
WHERE t.vehicle_id IS NULL
  AND t.tractor_number IS NOT NULL AND TRIM(t.tractor_number) != '';

-- Permissions
INSERT IGNORE INTO `role_permissions` (`role`, `permission`) VALUES
('manager', 'vehicles.view'), ('manager', 'vehicles.create'), ('manager', 'vehicles.edit'), ('manager', 'vehicles.maintenance'),
('accountant', 'vehicles.view'), ('accountant', 'vehicles.create'), ('accountant', 'vehicles.maintenance'),
('operator', 'vehicles.view'),
('viewer', 'vehicles.view');
