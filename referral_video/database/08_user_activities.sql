CREATE TABLE `user_activities` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `activity_type` VARCHAR(50) NOT NULL, -- 'Page View', 'Form Input', 'Draft Saved', 'Campaign Started', 'Abandoned'
  `page_name` VARCHAR(50) DEFAULT NULL,
  `field_name` VARCHAR(50) DEFAULT NULL, -- Which field they were filling
  `activity_data` TEXT DEFAULT NULL,    -- JSON data of the form state
  `user_agent` TEXT DEFAULT NULL,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
