-- Bagde ERP Labour Status Migration v4.0
-- Run once on existing installations via phpMyAdmin or CLI
-- Ensures active/inactive status column exists (safe to skip if already present)

ALTER TABLE `labours`
    ADD COLUMN `is_active` TINYINT(1) NOT NULL DEFAULT 1 AFTER `current_balance`;

ALTER TABLE `labours`
    ADD INDEX `idx_labours_active` (`is_active`);
