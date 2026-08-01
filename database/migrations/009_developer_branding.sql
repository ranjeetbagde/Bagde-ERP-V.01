-- Developer branding settings
INSERT INTO `settings` (`setting_key`, `setting_value`, `setting_group`) VALUES
('show_erp_footer_on_print', '1', 'branding')
ON DUPLICATE KEY UPDATE `setting_key` = `setting_key`;
