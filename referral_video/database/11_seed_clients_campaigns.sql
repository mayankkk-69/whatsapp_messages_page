-- ══════════════════════════════════════════════════════════════════════════════
--  11_seed_clients_campaigns.sql
--  Demo clients, campaigns & delivery records initialization
--  Import AFTER: 01 to 10 SQL files
-- ══════════════════════════════════════════════════════════════════════════════

-- ─── DEMO CLIENTS (15 users) ──────────────────────────────────────────────────

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


-- ─── DEMO CAMPAIGNS (4 campaigns) ─────────────────────────────────────────────
-- Note: template_id values correspond to the order in 10_seed_templates.sql
-- promo=1, followup=2, welcome=3, quote=4, referral=5, reminder=6, feedback=7

INSERT IGNORE INTO `campaigns` (`name`, `template_id`, `template_name`, `button_link`, `target_audience`, `schedule_type`, `scheduled_at`, `is_repeat`, `repeat_interval`, `stop_on_reply`, `status`, `created_at`) VALUES

-- Campaign 1: Completed promo blast
('May Promotion Blast',
 1,
 'May Promotion Offer',
 'https://architectshive.com/may-offer',
 'All',
 'Now',
 NULL,
 0,
 NULL,
 1,
 'Completed',
 '2026-05-01 10:00:00'),

-- Campaign 2: Currently running welcome sequence
('New Client Welcome Series',
 3,
 'Welcome Message',
 'https://architectshive.com/welcome',
 'Selected',
 'Now',
 NULL,
 1,
 '48 hours',
 1,
 'Running',
 '2026-05-04 09:30:00'),

-- Campaign 3: Scheduled follow-up
('May Follow-Up Drive',
 2,
 'Follow-Up Reminder',
 NULL,
 'All',
 'Later',
 '2026-05-10 11:00:00',
 0,
 NULL,
 1,
 'Draft',
 '2026-05-05 14:00:00'),

-- Campaign 4: Referral campaign (paused)
('Referral Rewards Program',
 5,
 'Referral Invite',
 'https://architectshive.com/referral',
 'Selected',
 'Now',
 NULL,
 1,
 '7 days',
 0,
 'Paused',
 '2026-04-28 08:00:00');


-- ─── DELIVERY RECORDS ─────────────────────────────────────────────────────────
-- Campaign 1 (May Promo Blast) – All 14 active clients, mostly delivered/read

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

-- Campaign 2 (Welcome Series) – Selected clients, running
(2, 1,  'Arjun Mehta',    '+91 98201 11001', 'Welcome Message', 'Delivered', '2026-05-04 09:35:00', '2026-05-04 09:36:00', NULL,                  NULL),
(2, 4,  'Sneha Patel',    '+91 98201 11004', 'Welcome Message', 'Replied',   '2026-05-04 09:35:00', '2026-05-04 09:36:00', '2026-05-04 10:00:00', '2026-05-04 10:30:00'),
(2, 8,  'Deepika Singh',  '+91 98201 11008', 'Welcome Message', 'Read',      '2026-05-04 09:35:00', '2026-05-04 09:36:00', '2026-05-04 11:00:00', NULL),
(2, 10, 'Pooja Verma',    '+91 98201 11010', 'Welcome Message', 'Sent',      '2026-05-04 09:36:00', NULL,                  NULL,                  NULL),
(2, 14, 'Meera Iyer',     '+91 98201 11014', 'Welcome Message', 'Delivered', '2026-05-04 09:36:00', '2026-05-04 09:38:00', NULL,                  NULL),

-- Campaign 4 (Referral – Paused) – few records
(4, 2,  'Priya Sharma',   '+91 98201 11002', 'Referral Invite', 'Replied',   '2026-04-28 08:10:00', '2026-04-28 08:11:00', '2026-04-28 09:00:00', '2026-04-28 09:45:00'),
(4, 5,  'Vikram Joshi',   '+91 98201 11005', 'Referral Invite', 'Read',      '2026-04-28 08:10:00', '2026-04-28 08:11:00', '2026-04-28 10:30:00', NULL),
(4, 11, 'Amit Desai',     '+91 98201 11011', 'Referral Invite', 'Delivered', '2026-04-28 08:10:00', '2026-04-28 08:12:00', NULL,                  NULL);


-- ─── SAMPLE ACTIVITY LOGS ─────────────────────────────────────────────────────

INSERT IGNORE INTO `user_activities` (`activity_type`, `page_name`, `activity_data`, `ip_address`, `created_at`) VALUES
('Campaign Started', 'campaigns', '{"name":"May Promotion Blast","audience":14,"repeat":"No repeat","stop_on_reply":"Yes"}',        '127.0.0.1', '2026-05-01 10:04:00'),
('Campaign Started', 'campaigns', '{"name":"New Client Welcome Series","audience":5,"repeat":"48 hours","stop_on_reply":"Yes"}',    '127.0.0.1', '2026-05-04 09:29:00'),
('Campaign Started', 'campaigns', '{"name":"Referral Rewards Program","audience":3,"repeat":"7 days","stop_on_reply":"No"}',        '127.0.0.1', '2026-04-28 07:59:00'),
('Client Added',     'clients',   '{"name":"Pooja Verma","phone":"+91 98201 11010"}',                                               '127.0.0.1', '2026-05-03 14:00:00'),
('Client Added',     'clients',   '{"name":"Riya Choudhary","phone":"+91 98201 11012"}',                                            '127.0.0.1', '2026-05-04 10:00:00'),
('Client Removed',   'clients',   '{"name":"Rahul Bose","phone":"+91 98201 11015"}',                                                '127.0.0.1', '2026-05-05 09:00:00'),
('Login',            'login',     '{"name":"Admin User","email":"info.architectshive@gmail.com"}',                                  '127.0.0.1', '2026-05-06 09:00:00');
