-- Seed Data for Development and Testing
-- This file contains sample data for testing the application

-- ============================================================================
-- IMPORTANT: Only run this in development environments!
-- ============================================================================

-- Create a test admin user profile
-- Note: You need to create the auth user first through Supabase Dashboard or Auth API
-- Then update the UUID below with the actual user ID

-- Example: Creating a test user (adjust the UUID to match your auth user)
-- INSERT INTO profiles (id, username, email, is_admin)
-- VALUES (
--   'your-auth-user-uuid-here',
--   'admin',
--   'admin@example.com',
--   true
-- );

-- ============================================================================
-- SAMPLE PATIENTS
-- ============================================================================
INSERT INTO patients (full_name, date_of_birth, phone, mobile, city, hmo, status, notes) VALUES
  ('דוד כהן', '1995-05-15', '03-1234567', '050-1234567', 'תל אביב', 'כללית', 'active', 'מטופל פעיל'),
  ('שרה לevi', '1988-08-22', '04-9876543', '052-9876543', 'חיפה', 'מכבי', 'active', 'מטופלת חדשה'),
  ('יוסף מזרחי', '2000-12-10', '09-5551234', '054-5551234', 'באר שבע', 'מאוחדת', 'active', NULL),
  ('רחל גולן', '1992-03-30', '02-7778888', '053-7778888', 'ירושלים', 'לאומית', 'active', 'ממתינה לתוצאות בדיקה'),
  ('משה ברק', '1985-11-05', '08-4445566', '050-4445566', 'אשדוד', 'כללית', 'inactive', 'סיים טיפול');

-- ============================================================================
-- SAMPLE SESSIONS
-- ============================================================================
-- Note: These will be linked to the patients created above
INSERT INTO sessions (patient_id, session_date, session_time, duration_minutes, session_type, notes, summary, key_points, payment_status)
SELECT
  p.id,
  CURRENT_DATE - (random() * 30)::integer,
  '10:00'::time,
  50,
  'טיפול פרטני',
  'מפגש טוב, התקדמות משמעותית',
  'המטופל הראה שיפור בהתמודדות',
  ARRAY['שיפור במצב הרוח', 'יותר פתיחות', 'מוכנות לשינוי'],
  'paid'
FROM patients p
WHERE p.full_name = 'דוד כהן'
LIMIT 1;

INSERT INTO sessions (patient_id, session_date, session_time, duration_minutes, session_type, notes, summary, key_points, payment_status)
SELECT
  p.id,
  CURRENT_DATE - 7,
  '11:00'::time,
  50,
  'טיפול משפחתי',
  'מפגש עם בני המשפחה',
  'דיון פתוח על נושאים משפחתיים',
  ARRAY['שיפור בתקשורת', 'הבנת צרכים', 'קביעת גבולות'],
  'paid'
FROM patients p
WHERE p.full_name = 'שרה לevi'
LIMIT 1;

-- ============================================================================
-- SAMPLE APPOINTMENTS
-- ============================================================================
INSERT INTO appointments (patient_id, patient_name, appointment_date, appointment_time, duration_minutes, status)
SELECT
  id,
  full_name,
  CURRENT_DATE + 1,
  '09:00'::time,
  50,
  'scheduled'
FROM patients
WHERE full_name = 'דוד כהן';

INSERT INTO appointments (patient_id, patient_name, appointment_date, appointment_time, duration_minutes, status)
SELECT
  id,
  full_name,
  CURRENT_DATE + 2,
  '10:00'::time,
  50,
  'scheduled'
FROM patients
WHERE full_name = 'רחל גולן';

INSERT INTO appointments (patient_id, patient_name, appointment_date, appointment_time, duration_minutes, status)
SELECT
  id,
  full_name,
  CURRENT_DATE + 3,
  '14:00'::time,
  50,
  'scheduled'
FROM patients
WHERE full_name = 'יוסף מזרחי';

-- ============================================================================
-- SAMPLE RECURRING APPOINTMENTS
-- ============================================================================
INSERT INTO recurring_appointments (patient_id, patient_name, day_of_week, time, start_date, duration_minutes, is_active)
SELECT
  id,
  full_name,
  1, -- Monday
  '10:00'::time,
  CURRENT_DATE,
  50,
  true
FROM patients
WHERE full_name = 'דוד כהן';

-- ============================================================================
-- SAMPLE REPORTS
-- ============================================================================
INSERT INTO reports (patient_id, patient_name, report_date, content, key_points, recommendations)
SELECT
  p.id,
  p.full_name,
  CURRENT_DATE - 7,
  'דוח טיפולי - התקדמות משמעותית בחודש האחרון. המטופל מראה שיפור בהתמודדות עם מצבי לחץ ובניהול רגשות.',
  ARRAY['שיפור משמעותי במצב הרוח', 'יכולת טובה יותר להתמודדות', 'התקדמות ביעדי הטיפול'],
  ARRAY['המשך טיפול שבועי', 'תרגול טכניקות הרפיה בבית', 'מעקב אחר תרגילים ביומן']
FROM patients p
WHERE p.full_name = 'דוד כהן'
LIMIT 1;

-- ============================================================================
-- SAMPLE TASKS
-- ============================================================================
INSERT INTO tasks (title, description, status, priority, due_date)
VALUES
  ('להכין דוח חודשי', 'דוח סיכום טיפולים לחודש נובמבר', 'pending', 'high', CURRENT_DATE + 3),
  ('לעדכן תיק מטופל', 'עדכון מסמכים עבור דוד כהן', 'in_progress', 'medium', CURRENT_DATE + 7),
  ('להזמין ציוד משרדי', 'נייר, עטים, תיקיות', 'pending', 'low', CURRENT_DATE + 14);

INSERT INTO tasks (title, description, patient_id, status, priority, due_date)
SELECT
  'מעקב אחר תרגילים',
  'לבדוק ביצוע תרגילי בית',
  id,
  'pending',
  'medium',
  CURRENT_DATE + 5
FROM patients
WHERE full_name = 'שרה לevi';

-- ============================================================================
-- SAMPLE ACTIVITIES
-- ============================================================================
INSERT INTO activities (title, activity_type, start_date, location, topic, paid, payment_status)
VALUES
  ('סדנת קבוצתית', 'קבוצה', CURRENT_DATE + 10, 'אולם הקליניקה', 'ניהול חרדות', false, 'pending'),
  ('הרצאה', 'הרצאה ציבורית', CURRENT_DATE + 20, 'מרכז קהילתי', 'בריאות נפש', true, 'paid');

-- ============================================================================
-- USEFUL QUERIES FOR TESTING
-- ============================================================================

-- View all patients with their statistics
-- SELECT
--   p.*,
--   (SELECT COUNT(*) FROM sessions s WHERE s.patient_id = p.id) as session_count,
--   (SELECT COUNT(*) FROM appointments a WHERE a.patient_id = p.id) as appointment_count
-- FROM patients p
-- WHERE soft_deleted_at IS NULL;

-- View upcoming appointments
-- SELECT * FROM appointments
-- WHERE appointment_date >= CURRENT_DATE
-- ORDER BY appointment_date, appointment_time;

-- View dashboard statistics
-- SELECT * FROM get_dashboard_stats();

-- Generate recurring appointments for next month
-- SELECT generate_recurring_appointments(
--   recurring_id,
--   CURRENT_DATE,
--   CURRENT_DATE + INTERVAL '30 days'
-- ) FROM recurring_appointments WHERE is_active = true;
