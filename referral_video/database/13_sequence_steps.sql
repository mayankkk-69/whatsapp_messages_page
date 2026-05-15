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
