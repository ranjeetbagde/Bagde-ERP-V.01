-- Run on existing production databases before v1.0 stable release.
-- Safe to re-run: skips columns/indexes that already exist.

-- 006: invoice payments
SET @col := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'customer_payments' AND COLUMN_NAME = 'invoice_id'
);
SET @sql := IF(@col = 0,
    'ALTER TABLE `customer_payments` ADD COLUMN `invoice_id` INT UNSIGNED DEFAULT NULL AFTER `order_id`',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @idx := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'customer_payments' AND INDEX_NAME = 'idx_cp_invoice'
);
SET @sql := IF(@idx = 0,
    'ALTER TABLE `customer_payments` ADD INDEX `idx_cp_invoice` (`invoice_id`)',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
