-- Bagde ERP v1.0 — Operator role alignment (run once on existing installations)

DELETE FROM `role_permissions`
WHERE `role` = 'operator'
  AND `permission` IN (
    'orders.create',
    'challans.view',
    'challans.create',
    'diesel.view',
    'diesel.create',
    'invoices.view',
    'trips.delete',
    'trips.edit'
  );

INSERT IGNORE INTO `role_permissions` (`role`, `permission`) VALUES
('operator', 'payments.view'),
('operator', 'payments.create'),
('operator', 'labours.payment'),
('operator', 'stock.view');
