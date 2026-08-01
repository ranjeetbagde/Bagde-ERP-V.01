-- Bagde ERP Default Seed Data

-- Default Admin User (password: admin123)
INSERT INTO `users` (`name`, `email`, `password`, `role`, `is_active`, `created_at`) VALUES
('Administrator', 'admin@bagdeerp.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 1, NOW());

-- Role Permissions
INSERT INTO `role_permissions` (`role`, `permission`) VALUES
-- Accountant permissions
('accountant', 'dashboard.view'),
('accountant', 'customers.view'),
('accountant', 'customers.create'),
('accountant', 'customers.edit'),
('accountant', 'orders.view'),
('accountant', 'orders.create'),
('accountant', 'orders.edit'),
('accountant', 'trips.view'),
('accountant', 'trips.create'),
('accountant', 'trips.edit'),
('accountant', 'payments.view'),
('accountant', 'payments.create'),
('accountant', 'invoices.view'),
('accountant', 'invoices.create'),
('accountant', 'challans.view'),
('accountant', 'challans.create'),
('accountant', 'labours.view'),
('accountant', 'labours.create'),
('accountant', 'labours.advance'),
('accountant', 'labours.payment'),
('accountant', 'drivers.view'),
('accountant', 'drivers.create'),
('accountant', 'drivers.payment'),
('accountant', 'vehicles.view'),
('accountant', 'vehicles.create'),
('accountant', 'vehicles.maintenance'),
('accountant', 'expenses.view'),
('accountant', 'expenses.create'),
('accountant', 'diesel.view'),
('accountant', 'diesel.create'),
('accountant', 'stock.view'),
('accountant', 'reports.view'),
('accountant', 'accounting.view'),
('accountant', 'documents.view'),
('accountant', 'documents.upload'),
('accountant', 'documents.download'),
('accountant', 'documents.delete'),
-- Operator permissions
('operator', 'dashboard.view'),
('operator', 'customers.view'),
('operator', 'orders.view'),
('operator', 'trips.view'),
('operator', 'trips.create'),
('operator', 'payments.view'),
('operator', 'payments.create'),
('operator', 'labours.view'),
('operator', 'labours.advance'),
('operator', 'challans.view'),
('operator', 'challans.create'),
('operator', 'drivers.view'),
('operator', 'vehicles.view'),
('operator', 'stock.view'),
('operator', 'documents.view'),
('operator', 'documents.upload'),
-- Manager permissions
('manager', 'dashboard.view'),
('manager', 'customers.view'), ('manager', 'customers.create'), ('manager', 'customers.edit'),
('manager', 'orders.view'), ('manager', 'orders.create'), ('manager', 'orders.edit'),
('manager', 'trips.view'), ('manager', 'trips.create'), ('manager', 'trips.edit'), ('manager', 'trips.delete'),
('manager', 'payments.view'), ('manager', 'payments.create'),
('manager', 'invoices.view'), ('manager', 'invoices.create'), ('manager', 'invoices.edit'),
('manager', 'challans.view'), ('manager', 'challans.create'),
('manager', 'labours.view'), ('manager', 'labours.create'), ('manager', 'labours.advance'), ('manager', 'labours.payment'),
('manager', 'drivers.view'), ('manager', 'drivers.create'), ('manager', 'drivers.payment'),
('manager', 'vehicles.view'), ('manager', 'vehicles.create'), ('manager', 'vehicles.edit'), ('manager', 'vehicles.maintenance'),
('manager', 'expenses.view'), ('manager', 'expenses.create'),
('manager', 'diesel.view'), ('manager', 'diesel.create'),
('manager', 'stock.view'), ('manager', 'stock.create'), ('manager', 'stock.edit'),
('manager', 'reports.view'), ('manager', 'reports.export'),
('manager', 'accounting.view'), ('manager', 'documents.view'), ('manager', 'documents.upload'), ('manager', 'documents.download'), ('manager', 'documents.delete'),
('manager', 'search.view'), ('manager', 'settings.view'),
-- Viewer permissions
('viewer', 'dashboard.view'),
('viewer', 'customers.view'), ('viewer', 'orders.view'), ('viewer', 'trips.view'),
('viewer', 'payments.view'), ('viewer', 'invoices.view'), ('viewer', 'challans.view'),
('viewer', 'labours.view'), ('viewer', 'drivers.view'), ('viewer', 'vehicles.view'), ('viewer', 'expenses.view'),
('viewer', 'diesel.view'), ('viewer', 'stock.view'), ('viewer', 'reports.view'),
('viewer', 'accounting.view'), ('viewer', 'search.view'), ('viewer', 'documents.view'), ('viewer', 'documents.download');

-- Auto Number Sequences
INSERT INTO `auto_sequences` (`type`, `prefix`, `last_number`, `padding`) VALUES
('order', 'ORD-', 0, 6),
('trip', 'TRP-', 0, 6),
('invoice', 'INV-', 0, 6),
('challan', 'DC-', 0, 6),
('labour_payment', 'LPR-', 0, 6),
('customer_payment', 'CPY-', 0, 6),
('driver_payment', 'DPR-', 0, 6),
('customer', 'CUS-', 0, 4),
('stock_purchase', 'STK-', 0, 6);

-- Default Settings
INSERT INTO `settings` (`setting_key`, `setting_value`, `setting_group`) VALUES
('company_name', 'Bagde Building Material Supplier', 'company'),
('company_tagline', 'Building Material & Transport Management System', 'company'),
('company_address', '', 'company'),
('company_phone', '', 'company'),
('company_email', '', 'company'),
('company_gst', '', 'company'),
('company_logo', '', 'company'),
('financial_year', '2025-2026', 'general'),
('order_prefix', 'ORD-', 'numbering'),
('trip_prefix', 'TRP-', 'numbering'),
('invoice_prefix', 'INV-', 'numbering'),
('challan_prefix', 'DC-', 'numbering'),
('cash_in_hand', '0', 'accounting'),
('bank_balance', '0', 'accounting'),
('billing_policy', 'order', 'accounting'),
('inventory_enabled', '0', 'accounting'),
('cgst_rate', '9', 'tax'),
('sgst_rate', '9', 'tax'),
('igst_rate', '18', 'tax'),
('theme_mode', 'light', 'appearance'),
('show_erp_footer_on_print', '1', 'branding');

-- Default Materials
INSERT INTO `materials` (`name`, `code`, `unit`, `default_rate`, `created_at`) VALUES
('Sand', 'SAND', 'trip', 0, NOW()),
('Gitti', 'GITT', 'trip', 0, NOW()),
('Dust', 'DUST', 'trip', 0, NOW()),
('Murum', 'MURM', 'trip', 0, NOW()),
('Bricks', 'BRCK', 'nos', 0, NOW()),
('Cement', 'CEMT', 'bag', 0, NOW()),
('Steel', 'STEL', 'kg', 0, NOW());

-- Expense Categories
INSERT INTO `expense_categories` (`name`) VALUES
('Diesel'), ('Repair'), ('Engine Oil'), ('Tyre'), ('Battery'),
('Police'), ('Royalty'), ('Loading'), ('Unloading'), ('Misc');
