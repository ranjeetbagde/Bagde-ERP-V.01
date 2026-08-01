-- Order-centric billing: link customer payments to invoices (run once)
ALTER TABLE `customer_payments`
    ADD COLUMN `invoice_id` INT UNSIGNED DEFAULT NULL AFTER `order_id`;

ALTER TABLE `customer_payments`
    ADD INDEX `idx_cp_invoice` (`invoice_id`);
