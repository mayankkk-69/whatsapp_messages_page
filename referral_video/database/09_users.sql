-- ═══════════════════════════════════════════════
--  09_users.sql – Admin Users Table
-- ═══════════════════════════════════════════════

CREATE TABLE `users` (
  `id`          INT(11) NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(100) NOT NULL,
  `email`       VARCHAR(100) NOT NULL,
  `password`    VARCHAR(255) NOT NULL,      -- bcrypt hash
  `role`        ENUM('Super Admin','Admin','Manager') DEFAULT 'Admin',
  `avatar_url`  VARCHAR(255) DEFAULT NULL,
  `last_login`  TIMESTAMP NULL DEFAULT NULL,
  `is_active`   TINYINT(1) DEFAULT 1,
  `created_at`  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ═══════════════════════════════════════════════
--  Default Admin User
--  Email:    info.architectshive@gmail.com
--  Password: Qwer@1234
-- ═══════════════════════════════════════════════
INSERT INTO `users` (`name`, `email`, `password`, `role`) VALUES
('Admin User', 'info.architectshive@gmail.com', '$2y$12$d/CHv80DAd72K8FgrufsuO.QdLtYRWSi9wj/qH47W0csz9iNrgcZq', 'Super Admin');
-- Note: The hash above is the bcrypt hash for the password "Qwer@1234"
