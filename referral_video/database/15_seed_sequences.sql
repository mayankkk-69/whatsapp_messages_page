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
