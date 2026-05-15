-- ══════════════════════════════════════════════════════════════════════════════
--  10_seed_templates.sql – Sample WhatsApp Templates
--  Pre-populates default active templates for onboarding, promos, and feedback.
--  Run this in phpMyAdmin or via MySQL CLI:
--  mysql -u root whatsapp_template < 10_seed_templates.sql
-- ══════════════════════════════════════════════════════════════════════════════

INSERT IGNORE INTO `templates` (`template_key`, `label`, `category`, `body`, `status`) VALUES

('promo',
 'May Promotion Offer',
 'Promotional',
 '🎉 *Big News from ArchitectsHive!*\n\nWe''re running an exclusive *May Promotion* just for you!\n\n✅ 20% off on all interior design consultations\n✅ Free 3D rendering with every package\n✅ Limited slots available\n\nBook your free consultation today and transform your dream space into reality! 🏠\n\n📞 Call us or click the link below to get started.\n\n_ArchitectsHive – Design. Build. Inspire._',
 'Active'),

('followup',
 'Follow-Up Reminder',
 'Follow-Up',
 '👋 *Hi there!*\n\nWe noticed you showed interest in our services recently and we wanted to follow up.\n\nHave you had a chance to review our proposal? We''d love to answer any questions you might have.\n\nOur team is ready to help you take the next step — whether it''s scheduling a site visit or refining the design plan. 🏗️\n\nReply to this message or click the link below to connect with us.\n\n_ArchitectsHive – We''re here for you!_',
 'Active'),

('welcome',
 'Welcome Message',
 'Onboarding',
 '🏠 *Welcome to ArchitectsHive!*\n\nWe''re thrilled to have you on board. You''ve just taken the first step towards your dream project!\n\nHere''s what happens next:\n1️⃣ Our team will review your requirements\n2️⃣ We''ll schedule an initial consultation\n3️⃣ You''ll receive a custom proposal within 48 hrs\n\nIf you have any immediate questions, just reply to this message — we''re always here. 💬\n\n_ArchitectsHive – Turning visions into reality._',
 'Active'),

('quote',
 'Quote Ready Notification',
 'Transactional',
 '📋 *Your Quote is Ready!*\n\nGreat news — we''ve prepared a detailed quote for your project.\n\n🔹 Project: *{{project_name}}*\n🔹 Estimated Timeline: *{{timeline}}*\n🔹 Quote Reference: *{{quote_ref}}*\n\nClick the link below to view your full quote and approve it online, or reply here to discuss any changes.\n\nThis quote is valid for *7 days*. Don''t miss out!\n\n_ArchitectsHive – Quality you can count on._',
 'Active'),

('referral',
 'Referral Invite',
 'Referral',
 '🤝 *Refer a Friend & Earn Rewards!*\n\nHi! We hope your experience with ArchitectsHive has been fantastic.\n\nDid you know you can earn exclusive rewards by referring your friends and family?\n\n🎁 *For every successful referral:*\n• You get ₹2,000 off your next project\n• Your friend gets a free initial consultation\n\nJust share your unique referral link below and let the rewards roll in!\n\n_ArchitectsHive – Great spaces are meant to be shared._',
 'Active'),

('reminder',
 'Appointment Reminder',
 'Reminder',
 '📅 *Appointment Reminder*\n\nThis is a friendly reminder that you have an upcoming appointment with *ArchitectsHive*.\n\n🗓️ Date: *{{appointment_date}}*\n⏰ Time: *{{appointment_time}}*\n📍 Location: *{{location}}*\n\nPlease confirm your attendance by replying *YES* to this message, or call us to reschedule.\n\nWe look forward to meeting you! 😊\n\n_ArchitectsHive – Punctuality is part of our promise._',
 'Active'),

('feedback',
 'Post-Project Feedback',
 'Feedback',
 '⭐ *We Value Your Feedback!*\n\nYour project is now complete — congratulations on your beautiful new space! 🎊\n\nWe''d love to hear about your experience working with us. Your feedback helps us improve and serve you better.\n\n👉 Please take 2 minutes to share your thoughts:\n• How satisfied are you with the final result?\n• Was our team professional and responsive?\n• Would you recommend us to others?\n\nReply directly to this message or click the link below.\n\n_ArchitectsHive – Your satisfaction is our success._',
 'Active');
