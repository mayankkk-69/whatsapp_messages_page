-- ══════════════════════════════════════════════════════════════════════════════
--  17_seed_subscriptions.sql
--  Enrolls demo clients into active automated nurture loops.
-- ══════════════════════════════════════════════════════════════════════════════

INSERT IGNORE INTO `sequence_subscriptions` 
(`sequence_id`, `sequence_name`, `client_id`, `client_name`, `client_phone`, `current_step_id`, `status`, `next_send_at`) 
VALUES
-- Enroll Arjun into the Year-Long loop (currently on Step 1)
(1, 'Year-Long Client Onboarding', 1, 'Arjun Mehta', '+91 98201 11001', 1, 'Running', DATE_ADD(NOW(), INTERVAL 1 DAY)),

-- Enroll Priya into the Year-Long loop (already on Step 2)
(1, 'Year-Long Client Onboarding', 2, 'Priya Sharma', '+91 98201 11002', 2, 'Running', DATE_ADD(NOW(), INTERVAL 3 DAY)),

-- Enroll Rohit into the Feedback loop (starting today)
(2, 'Post-Project Feedback Loop', 3, 'Rohit Kapoor', '+91 98201 11003', 4, 'Running', NOW());
