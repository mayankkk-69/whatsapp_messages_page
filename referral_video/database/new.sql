-- ══════════════════════════════════════════════════════════════════════════════
--  new.sql – Dedicated Migration Script for Automated Drip Sequences
--  Contains all schema tables and initial seed data for the Nurture Loops module.
--  Run this directly against your existing database to add sequence support.
-- ══════════════════════════════════════════════════════════════════════════════

-- ──────────────────────────────────────────────────────────────────────────────
--  1. Master Sequences Table
-- ──────────────────────────────────────────────────────────────────────────────

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


-- ──────────────────────────────────────────────────────────────────────────────
--  2. Sequence Timeline Steps Table
-- ──────────────────────────────────────────────────────────────────────────────

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


-- ──────────────────────────────────────────────────────────────────────────────
--  3. Sequence Client Subscriptions Table
-- ──────────────────────────────────────────────────────────────────────────────

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
--  Initial Seed Data Initialization
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


-- ──────────────────────────────────────────────────────────────────────────────
--  4. Sequence Delivery Logs (History)
-- ──────────────────────────────────────────────────────────────────────────────

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
