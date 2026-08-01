-- Bagde ERP RC — production workflow fixes (run once on existing DBs)

-- BUG 4: Labour charge per unit on orders
SET @col := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'labour_charge_per_unit'
);
SET @sql := IF(@col = 0,
    'ALTER TABLE `orders` ADD COLUMN `labour_charge_per_unit` DECIMAL(15,2) NOT NULL DEFAULT 0.00 AFTER `rate`',
    'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- BUG 5: Ensure active flag is set for legacy rows
UPDATE `labours` SET `is_active` = 1 WHERE `is_active` IS NULL;

-- BUG 2: Split labour advance from weekly payment for operators
INSERT IGNORE INTO `role_permissions` (`role`, `permission`) VALUES
('operator', 'challans.view'),
('operator', 'challans.create'),
('operator', 'labours.advance'),
('manager', 'labours.advance'),
('accountant', 'labours.advance'),
('admin', 'labours.advance');

DELETE FROM `role_permissions`
WHERE `role` = 'operator' AND `permission` = 'labours.payment';

-- BUG 3: Ensure operator has challans (005 may have removed them)
INSERT IGNORE INTO `role_permissions` (`role`, `permission`) VALUES
('operator', 'challans.view'),
('operator', 'challans.create');
