-- Bagde ERP Fleet Production Migration v3.0
-- Run once after 002_vehicles.sql on existing installations

-- Lifecycle status (stored manual state; on_trip/available computed from trips)
ALTER TABLE `vehicles`
    CHANGE COLUMN `operational_status` `lifecycle_status`
        ENUM('active','maintenance','breakdown','inactive','sold') NOT NULL DEFAULT 'active';

-- Future-ready columns
ALTER TABLE `vehicles`
    ADD COLUMN `current_odometer` INT UNSIGNED DEFAULT NULL AFTER `notes`,
    ADD COLUMN `engine_hours` INT UNSIGNED DEFAULT NULL AFTER `current_odometer`,
    ADD COLUMN `owner_id` INT UNSIGNED DEFAULT NULL AFTER `owner_name`,
    ADD COLUMN `fuel_card_no` VARCHAR(50) DEFAULT NULL AFTER `owner_id`,
    ADD COLUMN `gps_device_id` VARCHAR(100) DEFAULT NULL AFTER `fuel_card_no`,
    ADD COLUMN `sold_date` DATE DEFAULT NULL AFTER `gps_device_id`,
    ADD COLUMN `documents_updated_at` DATETIME DEFAULT NULL AFTER `sold_date`;

-- Driver assignment history (never overwrite — append-only)
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
    INDEX `idx_vda_dates` (`assigned_date`, `released_date`),
    FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles`(`id`),
    FOREIGN KEY (`driver_id`) REFERENCES `drivers`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Operational event log (timeline — references trips/maintenance, no financial duplication)
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

-- Maintenance scheduler fields
ALTER TABLE `vehicle_maintenance`
    ADD COLUMN `reminder_by` ENUM('date','odometer','engine_hours') NOT NULL DEFAULT 'date' AFTER `next_service_due`,
    ADD COLUMN `next_service_odometer` INT UNSIGNED DEFAULT NULL AFTER `reminder_by`,
    ADD COLUMN `next_service_engine_hours` INT UNSIGNED DEFAULT NULL AFTER `next_service_odometer`;

-- Backfill current driver assignments into history
INSERT INTO `vehicle_driver_assignments` (`vehicle_id`, `driver_id`, `assigned_date`, `created_at`)
SELECT v.id, v.current_driver_id, COALESCE(DATE(v.created_at), CURDATE()), NOW()
FROM `vehicles` v
WHERE v.current_driver_id IS NOT NULL AND v.deleted_at IS NULL
AND NOT EXISTS (
    SELECT 1 FROM `vehicle_driver_assignments` vda
    WHERE vda.vehicle_id = v.id AND vda.driver_id = v.current_driver_id AND vda.released_date IS NULL
);

-- Map old 'available' if any remain after enum change (002 used available — 003 changes enum)
-- lifecycle_status default is 'active'
