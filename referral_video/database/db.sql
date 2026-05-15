-- ══════════════════════════════════════════════════════════════════════════════
--  WHATSAPP TEMPLATE MASTER DATABASE SCRIPT
--  Consolidated from individual migration files
-- ══════════════════════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS `whatsapp_template`;
USE `whatsapp_template`;

-- ──────────────────────────────────────────────────────────────────────────────
-- 01_clients.sql
-- ──────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `clients` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `email` VARCHAR(100) DEFAULT NULL,
  `notes` TEXT DEFAULT NULL,
  `status` ENUM('Active', 'Inactive') DEFAULT 'Active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone_unique` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ──────────────────────────────────────────────────────────────────────────────
-- 02_templates.sql
-- ──────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `templates` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `template_key` VARCHAR(50) NOT NULL,
  `label` VARCHAR(100) NOT NULL,
  `category` VARCHAR(50) NOT NULL,
  `body` TEXT NOT NULL,
  `status` ENUM('Active', 'Draft', 'Archived') DEFAULT 'Active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key_unique` (`template_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ──────────────────────────────────────────────────────────────────────────────
-- 03_campaigns.sql
-- ──────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `campaigns` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `template_id` INT(11) NOT NULL,
  `template_name` VARCHAR(100) DEFAULT NULL COMMENT 'Snapshot of template label used',
  `button_link` VARCHAR(255) DEFAULT NULL,
  `target_audience` ENUM('All', 'Selected') DEFAULT 'All',
  `schedule_type` ENUM('Now', 'Later') DEFAULT 'Now',
  `scheduled_at` DATETIME DEFAULT NULL,
  `is_repeat` BOOLEAN DEFAULT FALSE,
  `repeat_interval` VARCHAR(50) DEFAULT NULL,
  `stop_on_reply` BOOLEAN DEFAULT TRUE,
  `status` ENUM('Draft', 'Running', 'Paused', 'Completed') DEFAULT 'Draft',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`template_id`) REFERENCES `templates`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ──────────────────────────────────────────────────────────────────────────────
-- 04_campaign_deliveries.sql
-- ──────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `campaign_deliveries` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `campaign_id` INT(11) NOT NULL,
  `client_id` INT(11) NOT NULL,
  `client_name` VARCHAR(100) DEFAULT NULL COMMENT 'Snapshot of name at time of send',
  `client_phone` VARCHAR(20) DEFAULT NULL COMMENT 'Snapshot of phone at time of send',
  `template_name` VARCHAR(100) DEFAULT NULL COMMENT 'Snapshot of template label used',
  `status` ENUM('Pending', 'Sent', 'Delivered', 'Read', 'Replied', 'Failed') DEFAULT 'Pending',
  `sent_at` DATETIME DEFAULT NULL,
  `delivered_at` DATETIME DEFAULT NULL,
  `read_at` DATETIME DEFAULT NULL,
  `replied_at` DATETIME DEFAULT NULL,
  `error_message` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`campaign_id`) REFERENCES `campaigns`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`client_id`) REFERENCES `clients`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ──────────────────────────────────────────────────────────────────────────────
-- 05_settings.sql
-- ──────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `settings` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `setting_key` VARCHAR(50) NOT NULL,
  `setting_value` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key_unique` (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `settings` (`setting_key`, `setting_value`) VALUES
('business_phone_number_id', '+91 98765 00000'),
('access_token', 'EAAxxxxxxxxxxxxxxx'),
('webhook_verify_token', 'architectshive_wh_2026'),
('business_name', 'ArchitectsHive'),
('admin_email', 'admin@architectshive.com'),
('timezone', 'Asia/Kolkata');

-- ──────────────────────────────────────────────────────────────────────────────
-- 06_tags.sql
-- ──────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `tags` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `tags` (`name`) VALUES
('Lead'),
('Customer'),
('VIP'),
('Prospect'),
('Partner');

-- ──────────────────────────────────────────────────────────────────────────────
-- 07_client_tags.sql
-- ──────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `client_tags` (
  `client_id` INT(11) NOT NULL,
  `tag_id` INT(11) NOT NULL,
  PRIMARY KEY (`client_id`, `tag_id`),
  FOREIGN KEY (`client_id`) REFERENCES `clients`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`tag_id`) REFERENCES `tags`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ──────────────────────────────────────────────────────────────────────────────
-- 08_user_activities.sql
-- ──────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `user_activities` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `activity_type` VARCHAR(50) NOT NULL,
  `page_name` VARCHAR(50) DEFAULT NULL,
  `field_name` VARCHAR(50) DEFAULT NULL,
  `activity_data` TEXT DEFAULT NULL,
  `user_agent` TEXT DEFAULT NULL,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ──────────────────────────────────────────────────────────────────────────────
-- 09_users.sql
-- ──────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `users` (
  `id`          INT(11) NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(100) NOT NULL,
  `email`       VARCHAR(100) NOT NULL,
  `password`    VARCHAR(255) NOT NULL,
  `role`        ENUM('Super Admin','Admin','Manager') DEFAULT 'Admin',
  `avatar_url`  VARCHAR(255) DEFAULT NULL,
  `last_login`  TIMESTAMP NULL DEFAULT NULL,
  `is_active`   TINYINT(1) DEFAULT 1,
  `created_at`  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `users` (`name`, `email`, `password`, `role`) VALUES
('Admin User', 'info.architectshive@gmail.com', '$2y$12$d/CHv80DAd72K8FgrufsuO.QdLtYRWSi9wj/qH47W0csz9iNrgcZq', 'Super Admin');

-- ──────────────────────────────────────────────────────────────────────────────
-- 10_seed_templates.sql
-- ──────────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO `templates` (`template_key`, `label`, `category`, `body`, `status`) VALUES
('promo', 'May Promotion Offer', 'Promotional', '🎉 *Big News from ArchitectsHive!*\n\nWe''re running an exclusive *May Promotion* just for you!\n\n✅ 20% off on all interior design consultations\n✅ Free 3D rendering with every package\n✅ Limited slots available\n\nBook your free consultation today and transform your dream space into reality! 🏠\n\n📞 Call us or click the link below to get started.\n\n_ArchitectsHive – Design. Build. Inspire._', 'Active'),
('followup', 'Follow-Up Reminder', 'Follow-Up', '👋 *Hi there!*\n\nWe noticed you showed interest in our services recently and we wanted to follow up.\n\nHave you had a chance to review our proposal? We''d love to answer any questions you might have.\n\nOur team is ready to help you take the next step — whether it''s scheduling a site visit or refining the design plan. 🏗️\n\nReply to this message or click the link below to connect with us.\n\n_ArchitectsHive – We''re here for you!_', 'Active'),
('welcome', 'Welcome Message', 'Onboarding', '🏠 *Welcome to ArchitectsHive!*\n\nWe''re thrilled to have you on board. You''ve just taken the first step towards your dream project!\n\nHere''s what happens next:\n1️⃣ Our team will review your requirements\n2️⃣ We''ll schedule an initial consultation\n3️⃣ You''ll receive a custom proposal within 48 hrs\n\nIf you have any immediate questions, just reply to this message — we''re always here. 💬\n\n_ArchitectsHive – Turning visions into reality._', 'Active'),
('quote', 'Quote Ready Notification', 'Transactional', '📋 *Your Quote is Ready!*\n\nGreat news — we''ve prepared a detailed quote for your project.\n\n🔹 Project: *{{project_name}}*\n🔹 Estimated Timeline: *{{timeline}}*\n🔹 Quote Reference: *{{quote_ref}}*\n\nClick the link below to view your full quote and approve it online, or reply here to discuss any changes.\n\nThis quote is valid for *7 days*. Don''t miss out!\n\n_ArchitectsHive – Quality you can count on._', 'Active'),
('referral', 'Referral Invite', 'Referral', '🤝 *Refer a Friend & Earn Rewards!*\n\nHi! We hope your experience with ArchitectsHive has been fantastic.\n\nDid you know you can earn exclusive rewards by referring your friends and family?\n\n🎁 *For every successful referral:*\n• You get ₹2,000 off your next project\n• Your friend gets a free initial consultation\n\nJust share your unique referral link below and let the rewards roll in!\n\n_ArchitectsHive – Great spaces are meant to be shared._', 'Active'),
('reminder', 'Appointment Reminder', 'Reminder', '📅 *Appointment Reminder*\n\nThis is a friendly reminder that you have an upcoming appointment with *ArchitectsHive*.\n\n🗓️ Date: *{{appointment_date}}*\n⏰ Time: *{{appointment_time}}*\n📍 Location: *{{location}}*\n\nPlease confirm your attendance by replying *YES* to this message, or call us to reschedule.\n\nWe look forward to meeting you! 😊\n\n_ArchitectsHive – Punctuality is part of our promise._', 'Active'),
('feedback', 'Post-Project Feedback', 'Feedback', '⭐ *We Value Your Feedback!*\n\nYour project is now complete — congratulations on your beautiful new space! 🎊\n\nWe''d love to hear about your experience working with us. Your feedback helps us improve and serve you better.\n\n👉 Please take 2 minutes to share your thoughts:\n• How satisfied are you with the final result?\n• Was our team professional and responsive?\n• Would you recommend us to others?\n\nReply directly to this message or click the link below.\n\n_ArchitectsHive – Your satisfaction is our success._', 'Active');

-- ──────────────────────────────────────────────────────────────────────────────
-- 11_seed_clients_campaigns.sql
-- ──────────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO `clients` (`name`, `phone`, `email`, `notes`, `status`) VALUES
('Arjun Mehta',      '+91 98201 11001', 'arjun.mehta@gmail.com',      'Interested in 3BHK interior design',          'Active'),
('Priya Sharma',     '+91 98201 11002', 'priya.sharma@gmail.com',      'Follow up after site visit on May 3',         'Active'),
('Rohit Kapoor',     '+91 98201 11003', 'rohit.kapoor@outlook.com',    'Waiting for revised quote – villa project',   'Active'),
('Sneha Patel',      '+91 98201 11004', 'sneha.patel@yahoo.com',       'Referred by Arjun Mehta',                     'Active'),
('Vikram Joshi',     '+91 98201 11005', 'vikram.joshi@gmail.com',      'Commercial office space – 2000 sq ft',        'Active'),
('Anjali Nair',      '+91 98201 11006', 'anjali.nair@gmail.com',       'Kitchen & bathroom renovation inquiry',       'Active'),
('Karan Malhotra',   '+91 98201 11007', 'karan.m@hotmail.com',         'Budget conscious – needs affordable options', 'Active'),
('Deepika Singh',    '+91 98201 11008', 'deepika.singh@gmail.com',     'Project approved – starts June 1',            'Active'),
('Suresh Kumar',     '+91 98201 11009', 'suresh.k@gmail.com',          'Senior citizen – prefers phone calls',        'Active'),
('Pooja Verma',      '+91 98201 11010', 'pooja.verma@gmail.com',       'New lead from website inquiry form',          'Active'),
('Amit Desai',       '+91 98201 11011', 'amit.desai@gmail.com',        'Wants smart home integration',                'Active'),
('Riya Choudhary',   '+91 98201 11012', 'riya.c@gmail.com',            'Interior + landscaping package',              'Active'),
('Naveen Gupta',     '+91 98201 11013', 'naveen.gupta@gmail.com',      'Approved quote – payment pending',            'Active'),
('Meera Iyer',       '+91 98201 11014', 'meera.iyer@gmail.com',        'Relocated from Bangalore – new home setup',  'Active'),
('Rahul Bose',       '+91 98201 11015', 'rahul.bose@outlook.com',      'Cold lead – no reply in 2 weeks',             'Inactive');

INSERT IGNORE INTO `campaigns` (`name`, `template_id`, `template_name`, `button_link`, `target_audience`, `schedule_type`, `scheduled_at`, `is_repeat`, `repeat_interval`, `stop_on_reply`, `status`, `created_at`) VALUES
('May Promotion Blast', 1, 'https://architectshive.com/may-offer', 'All', 'Now', NULL, 0, NULL, 1, 'Completed', '2026-05-01 10:00:00'),
('New Client Welcome Series', 3, 'https://architectshive.com/welcome', 'Selected', 'Now', NULL, 1, '48 hours', 1, 'Running', '2026-05-04 09:30:00'),
('May Follow-Up Drive', 2, NULL, 'All', 'Later', '2026-05-10 11:00:00', 0, NULL, 1, 'Draft', '2026-05-05 14:00:00'),
('Referral Rewards Program', 5, 'https://architectshive.com/referral', 'Selected', 'Now', NULL, 1, '7 days', 0, 'Paused', '2026-04-28 08:00:00');

INSERT IGNORE INTO `campaign_deliveries` (`campaign_id`, `client_id`, `client_name`, `client_phone`, `template_name`, `status`, `sent_at`, `delivered_at`, `read_at`, `replied_at`) VALUES
(1, 1,  'Arjun Mehta',    '+91 98201 11001', 'May Promotion Offer', 'Replied',   '2026-05-01 10:05:00', '2026-05-01 10:06:00', '2026-05-01 10:30:00', '2026-05-01 11:00:00'),
(1, 2,  'Priya Sharma',   '+91 98201 11002', 'May Promotion Offer', 'Read',      '2026-05-01 10:05:00', '2026-05-01 10:06:00', '2026-05-01 10:45:00', NULL),
(1, 3,  'Rohit Kapoor',   '+91 98201 11003', 'May Promotion Offer', 'Delivered', '2026-05-01 10:05:00', '2026-05-01 10:07:00', NULL,                  NULL),
(1, 4,  'Sneha Patel',    '+91 98201 11004', 'May Promotion Offer', 'Replied',   '2026-05-01 10:05:00', '2026-05-01 10:06:00', '2026-05-01 10:20:00', '2026-05-01 10:55:00'),
(1, 5,  'Vikram Joshi',   '+91 98201 11005', 'May Promotion Offer', 'Read',      '2026-05-01 10:05:00', '2026-05-01 10:06:00', '2026-05-01 11:10:00', NULL),
(1, 6,  'Anjali Nair',    '+91 98201 11006', 'May Promotion Offer', 'Delivered', '2026-05-01 10:06:00', '2026-05-01 10:08:00', NULL,                  NULL),
(1, 7,  'Karan Malhotra', '+91 98201 11007', 'May Promotion Offer', 'Sent',      '2026-05-01 10:06:00', NULL,                  NULL,                  NULL),
(1, 8,  'Deepika Singh',  '+91 98201 11008', 'May Promotion Offer', 'Replied',   '2026-05-01 10:06:00', '2026-05-01 10:07:00', '2026-05-01 10:25:00', '2026-05-01 10:40:00'),
(1, 9,  'Suresh Kumar',   '+91 98201 11009', 'May Promotion Offer', 'Read',      '2026-05-01 10:06:00', '2026-05-01 10:07:00', '2026-05-01 12:00:00', NULL),
(1, 10, 'Pooja Verma',    '+91 98201 11010', 'May Promotion Offer', 'Delivered', '2026-05-01 10:07:00', '2026-05-01 10:09:00', NULL,                  NULL),
(1, 11, 'Amit Desai',     '+91 98201 11011', 'May Promotion Offer', 'Read',      '2026-05-01 10:07:00', '2026-05-01 10:08:00', '2026-05-01 10:50:00', NULL),
(1, 12, 'Riya Choudhary', '+91 98201 11012', 'May Promotion Offer', 'Replied',   '2026-05-01 10:07:00', '2026-05-01 10:08:00', '2026-05-01 10:30:00', '2026-05-01 11:15:00'),
(1, 13, 'Naveen Gupta',   '+91 98201 11013', 'May Promotion Offer', 'Delivered', '2026-05-01 10:08:00', '2026-05-01 10:10:00', NULL,                  NULL),
(1, 14, 'Meera Iyer',     '+91 98201 11014', 'May Promotion Offer', 'Read',      '2026-05-01 10:08:00', '2026-05-01 10:09:00', '2026-05-01 13:00:00', NULL),
(2, 1,  'Arjun Mehta',    '+91 98201 11001', 'Welcome Message', 'Delivered', '2026-05-04 09:35:00', '2026-05-04 09:36:00', NULL,                  NULL),
(2, 4,  'Sneha Patel',    '+91 98201 11004', 'Welcome Message', 'Replied',   '2026-05-04 09:35:00', '2026-05-04 09:36:00', '2026-05-04 10:00:00', '2026-05-04 10:30:00'),
(2, 8,  'Deepika Singh',  '+91 98201 11008', 'Welcome Message', 'Read',      '2026-05-04 09:35:00', '2026-05-04 09:36:00', '2026-05-04 11:00:00', NULL),
(2, 10, 'Pooja Verma',    '+91 98201 11010', 'Welcome Message', 'Sent',      '2026-05-04 09:36:00', NULL,                  NULL,                  NULL),
(2, 14, 'Meera Iyer',     '+91 98201 11014', 'Welcome Message', 'Delivered', '2026-05-04 09:36:00', '2026-05-04 09:38:00', NULL,                  NULL),
(4, 2,  'Priya Sharma',   '+91 98201 11002', 'Referral Invite', 'Replied',   '2026-04-28 08:10:00', '2026-04-28 08:11:00', '2026-04-28 09:00:00', '2026-04-28 09:45:00'),
(4, 5,  'Vikram Joshi',   '+91 98201 11005', 'Referral Invite', 'Read',      '2026-04-28 08:10:00', '2026-04-28 08:11:00', '2026-04-28 10:30:00', NULL),
(4, 11, 'Amit Desai',     '+91 98201 11011', 'Referral Invite', 'Delivered', '2026-04-28 08:10:00', '2026-04-28 08:12:00', NULL,                  NULL);

INSERT IGNORE INTO `user_activities` (`activity_type`, `page_name`, `activity_data`, `ip_address`, `created_at`) VALUES
('Campaign Started', 'campaigns', '{"name":"May Promotion Blast","audience":14,"repeat":"No repeat","stop_on_reply":"Yes"}',        '127.0.0.1', '2026-05-01 10:04:00'),
('Campaign Started', 'campaigns', '{"name":"New Client Welcome Series","audience":5,"repeat":"48 hours","stop_on_reply":"Yes"}',    '127.0.0.1', '2026-05-04 09:29:00'),
('Campaign Started', 'campaigns', '{"name":"Referral Rewards Program","audience":3,"repeat":"7 days","stop_on_reply":"No"}',        '127.0.0.1', '2026-04-28 07:59:00'),
('Client Added',     'clients',   '{"name":"Pooja Verma","phone":"+91 98201 11010"}',                                               '127.0.0.1', '2026-05-03 14:00:00'),
('Client Added',     'clients',   '{"name":"Riya Choudhary","phone":"+91 98201 11012"}',                                            '127.0.0.1', '2026-05-04 10:00:00'),
('Client Removed',   'clients',   '{"name":"Rahul Bose","phone":"+91 98201 11015"}',                                                '127.0.0.1', '2026-05-05 09:00:00'),
('Login',            'login',     '{"name":"Admin User","email":"info.architectshive@gmail.com"}',                                  '127.0.0.1', '2026-05-06 09:00:00');
-- ══════════════════════════════════════════════════════════════════════════════
--  12_sequences.sql
--  Defines master automated sequence loop configurations.
-- ══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `sequences` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `is_persistent` BOOLEAN DEFAULT TRUE COMMENT 'If TRUE, sequence continues triggering chronologically even if client replies',
  `status` ENUM('Active', 'Paused', 'Archived') DEFAULT 'Active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ══════════════════════════════════════════════════════════════════════════════
--  13_sequence_steps.sql
--  Defines timeline execution steps and custom delays for automated drip loops.
-- ══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `sequence_steps` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `sequence_id` INT(11) NOT NULL,
  `template_id` INT(11) NOT NULL,
  `template_name` VARCHAR(100) DEFAULT NULL COMMENT 'Snapshot of template label used',
  `step_order` INT(11) NOT NULL COMMENT 'The numerical sequence order of the step',
  `delay_value` INT(11) DEFAULT 0 COMMENT 'Wait time interval before triggering send',
  `delay_unit` ENUM('days', 'weeks', 'months') DEFAULT 'days',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`sequence_id`) REFERENCES `sequences`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`template_id`) REFERENCES `templates`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ══════════════════════════════════════════════════════════════════════════════
--  14_sequence_subscriptions.sql
--  Tracks enrolled clients, active cycle progress, and chron job scheduling.
-- ══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `sequence_subscriptions` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `sequence_id` INT(11) NOT NULL,
  `sequence_name` VARCHAR(100) DEFAULT NULL COMMENT 'Snapshot of sequence name at enrollment',
  `client_id` INT(11) NOT NULL,
  `client_name` VARCHAR(100) DEFAULT NULL COMMENT 'Snapshot of client name at enrollment',
  `client_phone` VARCHAR(20) DEFAULT NULL COMMENT 'Snapshot of client phone at enrollment',
  `current_step_id` INT(11) DEFAULT NULL COMMENT 'The timeline step the client is currently processing',
  `status` ENUM('Running', 'Paused', 'Completed', 'Stopped') DEFAULT 'Running',
  `next_send_at` DATETIME DEFAULT NULL COMMENT 'Calculated absolute timestamp for next automated dispatch',
  `last_sent_at` DATETIME DEFAULT NULL,
  `enrolled_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_sub` (`sequence_id`, `client_id`),
  FOREIGN KEY (`sequence_id`) REFERENCES `sequences`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`client_id`) REFERENCES `clients`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`current_step_id`) REFERENCES `sequence_steps`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ══════════════════════════════════════════════════════════════════════════════
--  15_seed_sequences.sql
--  Pre-loads sample automated nurture loops and multi-step chronological templates.
-- ══════════════════════════════════════════════════════════════════════════════

-- ─── MASTER LOOP PROFILES ─────────────────────────────────────────────────────

INSERT IGNORE INTO `sequences` (`id`, `name`, `description`, `is_persistent`) VALUES
(1, 'Year-Long Client Onboarding', 'Comprehensive multi-step automated loop spacing educational templates over the first year.', 1),
(2, 'Post-Project Feedback Loop', 'Short high-conversion follow-up sequence requesting feedback and offering referral bonuses.', 1);


-- ─── TIMELINE SEQUENCE STEPS ──────────────────────────────────────────────────

INSERT IGNORE INTO `sequence_steps` (`sequence_id`, `template_id`, `template_name`, `step_order`, `delay_value`, `delay_unit`) VALUES

-- Sequence 1: Year-Long Onboarding Schedule
(1, 3, 'Welcome Message',     1, 1, 'days'),  -- Step 1: Welcome Template triggered on Day 1
(1, 2, 'Follow-Up Reminder',  2, 3, 'days'),  -- Step 2: Followup reminder sent 3 days after Step 1
(1, 5, 'Referral Invite',     3, 10, 'days'), -- Step 3: Referral invite sent 10 days after Step 2

-- Sequence 2: Short Feedback & Referral Schedule
(2, 7, 'Post-Project Feedback', 1, 1, 'days'),  -- Step 1: Immediate feedback template targeted on Day 1
(2, 5, 'Referral Invite',       2, 5, 'days');  -- Step 2: Referral bonus program deployed 5 days later

-- ══════════════════════════════════════════════════════════════════════════════
--  16_sequence_deliveries.sql
--  Detailed delivery logs for automated sequence messages.
-- ══════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `sequence_deliveries` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `subscription_id` INT(11) NOT NULL COMMENT 'Link to the client enrollment',
  `sequence_step_id` INT(11) NOT NULL COMMENT 'The specific step that was sent',
  `client_id` INT(11) NOT NULL,
  `client_name` VARCHAR(100) NOT NULL COMMENT 'Snapshot of name at time of send',
  `client_phone` VARCHAR(20) NOT NULL COMMENT 'Snapshot of phone at time of send',
  `template_name` VARCHAR(100) NOT NULL COMMENT 'Snapshot of template label used',
  `status` ENUM('Pending', 'Sent', 'Delivered', 'Read', 'Replied', 'Failed') DEFAULT 'Sent',
  `sent_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `delivered_at` DATETIME DEFAULT NULL,
  `read_at` DATETIME DEFAULT NULL,
  `replied_at` DATETIME DEFAULT NULL,
  `error_message` TEXT DEFAULT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`subscription_id`) REFERENCES `sequence_subscriptions`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`sequence_step_id`) REFERENCES `sequence_steps`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`client_id`) REFERENCES `clients`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
