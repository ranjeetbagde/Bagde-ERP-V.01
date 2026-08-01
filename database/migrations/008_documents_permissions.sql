-- Documents module permissions (order-based billing compatible)
-- Run once on existing databases that still use documents.create

INSERT IGNORE INTO `role_permissions` (`role`, `permission`) VALUES
('manager', 'documents.upload'),
('manager', 'documents.download'),
('manager', 'documents.delete'),
('accountant', 'documents.view'),
('accountant', 'documents.upload'),
('accountant', 'documents.download'),
('accountant', 'documents.delete'),
('operator', 'documents.view'),
('operator', 'documents.upload'),
('viewer', 'documents.view'),
('viewer', 'documents.download');
