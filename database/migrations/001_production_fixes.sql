-- Bagde ERP Production Fixes Migration v1.0
-- Run once on existing installations via phpMyAdmin or CLI

-- Billing policy & inventory settings
INSERT INTO `settings` (`setting_key`, `setting_value`, `setting_group`) VALUES
('billing_policy', 'order', 'accounting'),
('inventory_enabled', '0', 'accounting'),
('cgst_rate', '9', 'tax'),
('sgst_rate', '9', 'tax'),
('igst_rate', '18', 'tax')
ON DUPLICATE KEY UPDATE `setting_key` = `setting_key`;

-- Extend reference_type enums for reversal entries
ALTER TABLE `customer_ledger`
    MODIFY `reference_type` ENUM('opening','order','trip','payment','invoice','adjustment','reversal') NOT NULL;

ALTER TABLE `labour_ledger`
    MODIFY `reference_type` ENUM('trip','advance','payment','deduction','adjustment','reversal') NOT NULL;

ALTER TABLE `driver_ledger`
    MODIFY `reference_type` ENUM('trip','advance','payment','adjustment','reversal') NOT NULL;

-- Extend user roles
ALTER TABLE `users`
    MODIFY `role` ENUM('admin','manager','accountant','operator','viewer') NOT NULL DEFAULT 'operator';

ALTER TABLE `role_permissions`
    MODIFY `role` ENUM('admin','manager','accountant','operator','viewer') NOT NULL;

-- Manager permissions
INSERT IGNORE INTO `role_permissions` (`role`, `permission`) VALUES
('manager', 'dashboard.view'),
('manager', 'customers.view'), ('manager', 'customers.create'), ('manager', 'customers.edit'),
('manager', 'orders.view'), ('manager', 'orders.create'), ('manager', 'orders.edit'),
('manager', 'trips.view'), ('manager', 'trips.create'), ('manager', 'trips.edit'), ('manager', 'trips.delete'),
('manager', 'payments.view'), ('manager', 'payments.create'),
('manager', 'invoices.view'), ('manager', 'invoices.create'), ('manager', 'invoices.edit'),
('manager', 'challans.view'), ('manager', 'challans.create'),
('manager', 'labours.view'), ('manager', 'labours.create'), ('manager', 'labours.payment'),
('manager', 'drivers.view'), ('manager', 'drivers.create'), ('manager', 'drivers.payment'),
('manager', 'expenses.view'), ('manager', 'expenses.create'),
('manager', 'diesel.view'), ('manager', 'diesel.create'),
('manager', 'stock.view'), ('manager', 'stock.create'), ('manager', 'stock.edit'),
('manager', 'reports.view'), ('manager', 'reports.export'),
('manager', 'accounting.view'), ('manager', 'documents.view'), ('manager', 'documents.create'),
('manager', 'search.view'), ('manager', 'settings.view');

-- Viewer permissions (read-only)
INSERT IGNORE INTO `role_permissions` (`role`, `permission`) VALUES
('viewer', 'dashboard.view'),
('viewer', 'customers.view'), ('viewer', 'orders.view'), ('viewer', 'trips.view'),
('viewer', 'payments.view'), ('viewer', 'invoices.view'), ('viewer', 'challans.view'),
('viewer', 'labours.view'), ('viewer', 'drivers.view'), ('viewer', 'expenses.view'),
('viewer', 'diesel.view'), ('viewer', 'stock.view'), ('viewer', 'reports.view'),
('viewer', 'accounting.view'), ('viewer', 'search.view');

-- Additional permissions for existing roles
INSERT IGNORE INTO `role_permissions` (`role`, `permission`) VALUES
('accountant', 'trips.delete'),
('accountant', 'customers.delete'),
('accountant', 'invoices.edit'),
('accountant', 'expenses.delete'),
('accountant', 'reports.export'),
('accountant', 'documents.view'), ('accountant', 'documents.create'),
('accountant', 'search.view'),
('operator', 'payments.view'),
('operator', 'invoices.view'),
('operator', 'search.view');

-- Composite indexes for performance (ignore errors if already exist)
-- ALTER TABLE `customer_ledger` ADD INDEX `idx_cl_customer_date` (`customer_id`, `transaction_date`);
-- ALTER TABLE `trips` ADD INDEX `idx_trips_order` (`order_id`, `deleted_at`);
