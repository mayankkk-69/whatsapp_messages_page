CREATE TABLE `settings` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `setting_key` VARCHAR(50) NOT NULL,
  `setting_value` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key_unique` (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Initial Settings
INSERT INTO `settings` (`setting_key`, `setting_value`) VALUES
('business_phone_number_id', '+91 98765 00000'),
('access_token', 'EAAxxxxxxxxxxxxxxx'),
('webhook_verify_token', 'architectshive_wh_2026'),
('business_name', 'ArchitectsHive'),
('admin_email', 'admin@architectshive.com'),
('timezone', 'Asia/Kolkata');
