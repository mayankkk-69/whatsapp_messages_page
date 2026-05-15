-- ══════════════════════════════════════════════════════════════════════════════
--  update_columns.sql – Migration Script for Existing Databases
--  Run this code if your tables already exist and you want to add the new
--  snapshot columns for Client Name, Phone, and Template Name.
-- ══════════════════════════════════════════════════════════════════════════════

-- ─── 1. Update Campaigns ──────────────────────────────────────────────────────
ALTER TABLE `campaigns` 
ADD COLUMN `template_name` VARCHAR(100) DEFAULT NULL COMMENT 'Snapshot of template label used' 
AFTER `template_id`;


-- ─── 2. Update Campaign Deliveries ────────────────────────────────────────────
ALTER TABLE `campaign_deliveries` 
ADD COLUMN `client_name` VARCHAR(100) DEFAULT NULL COMMENT 'Snapshot of name at time of send' AFTER `client_id`,
ADD COLUMN `client_phone` VARCHAR(20) DEFAULT NULL COMMENT 'Snapshot of phone at time of send' AFTER `client_name`,
ADD COLUMN `template_name` VARCHAR(100) DEFAULT NULL COMMENT 'Snapshot of template label used' AFTER `client_phone`;


-- ─── 3. Update Client Tags ────────────────────────────────────────────────────
ALTER TABLE `client_tags` 
ADD COLUMN `client_name` VARCHAR(100) DEFAULT NULL AFTER `client_id`,
ADD COLUMN `client_phone` VARCHAR(20) DEFAULT NULL AFTER `client_name`;


-- ─── 4. Update Sequence Steps (Automated Loops) ───────────────────────────────
ALTER TABLE `sequence_steps` 
ADD COLUMN `template_name` VARCHAR(100) DEFAULT NULL COMMENT 'Snapshot of template label used' 
AFTER `template_id`;


-- ─── 5. Update Sequence Subscriptions (Enrollments) ───────────────────────────
ALTER TABLE `sequence_subscriptions` 
ADD COLUMN `sequence_name` VARCHAR(100) DEFAULT NULL COMMENT 'Snapshot of sequence name at enrollment' AFTER `sequence_id`,
ADD COLUMN `client_name` VARCHAR(100) DEFAULT NULL COMMENT 'Snapshot of client name at enrollment' AFTER `client_id`,
ADD COLUMN `client_phone` VARCHAR(20) DEFAULT NULL COMMENT 'Snapshot of client phone at enrollment' AFTER `client_name`;
