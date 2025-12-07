# מדריך הגדרת Supabase למערכת ניהול קליניקה

## שלב 1: יצירת פרויקט Supabase

1. היכנס ל-[Supabase Dashboard](https://app.supabase.com)
2. לחץ על "New Project"
3. בחר ארגון או צור חדש
4. מלא את פרטי הפרויקט:
   - **Project name**: clinic-management
   - **Database Password**: שמור סיסמה חזקה
   - **Region**: בחר את האזור הקרוב ביותר (Europe West לישראל)
5. לחץ "Create new project"
6. המתן כמה דקות עד שהפרויקט יהיה מוכן

## שלב 2: קבלת API Keys

1. בדאשבורד, לך ל-**Settings** (⚙️) → **API**
2. העתק את הערכים הבאים:
   - **Project URL** - זה יהיה ה-`VITE_SUPABASE_URL`
   - **anon/public key** - זה יהיה ה-`VITE_SUPABASE_ANON_KEY`

## שלב 3: הגדרת משתני סביבה

1. צור קובץ `.env` בשורש הפרויקט:
```bash
cp .env.example .env
```

2. ערוך את הקובץ `.env` והוסף את הערכים:
```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

## שלב 4: הרצת Migrations

### אופציה 1: דרך Supabase Dashboard (מומלץ למתחילים)

1. לך ל-**SQL Editor** בדאשבורד
2. הרץ כל migration לפי הסדר:

#### 4.1 הרץ Schema (00001_initial_schema.sql)
```sql
-- העתק והדבק את כל התוכן מהקובץ:
-- supabase/migrations/00001_initial_schema.sql
```

#### 4.2 הרץ RLS Policies (00002_row_level_security.sql)
```sql
-- העתק והדבק את כל התוכן מהקובץ:
-- supabase/migrations/00002_row_level_security.sql
```

#### 4.3 הרץ Functions (00003_functions_and_triggers.sql)
```sql
-- העתק והדבק את כל התוכן מהקובץ:
-- supabase/migrations/00003_functions_and_triggers.sql
```

#### 4.4 (אופציונלי) הרץ Seed Data (00004_seed_data.sql)
```sql
-- רק בסביבת פיתוח! לא לייצור!
-- העתק והדבק את כל התוכן מהקובץ:
-- supabase/migrations/00004_seed_data.sql
```

### אופציה 2: דרך Supabase CLI (למתקדמים)

1. התקן Supabase CLI:
```bash
npm install -g supabase
```

2. התחבר לפרויקט:
```bash
supabase login
supabase link --project-ref your-project-ref
```

3. הרץ migrations:
```bash
supabase db push
```

## שלב 5: יצירת משתמש מנהל ראשון

### דרך Supabase Dashboard:

1. לך ל-**Authentication** → **Users**
2. לחץ "Add user" → "Create new user"
3. מלא:
   - **Email**: admin@example.com
   - **Password**: סיסמה חזקה
4. לחץ "Create user"
5. העתק את ה-UUID של המשתמש

### עדכן את הפרופיל ל-admin:

1. לך ל-**SQL Editor**
2. הרץ את הקוד הבא (החלף את ה-UUID):
```sql
-- החלף 'your-user-uuid-here' ב-UUID האמיתי
INSERT INTO profiles (id, username, email, is_admin)
VALUES (
  'your-user-uuid-here',
  'admin',
  'admin@example.com',
  true
)
ON CONFLICT (id) DO UPDATE
SET is_admin = true;

-- הוסף תפקיד admin
INSERT INTO user_roles (user_id, role)
VALUES ('your-user-uuid-here', 'admin');
```

## שלב 6: הגדרת Storage (לקבצים)

1. לך ל-**Storage** בדאשבורד
2. צור bucket חדש:
   - **Name**: `clinic-files`
   - **Public**: ❌ (לא ציבורי)
3. הגדר policies ל-bucket:

```sql
-- Policy לצפייה בקבצים (משתמשים מורשים בלבד)
CREATE POLICY "Authenticated users can view files"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'clinic-files' AND
  auth.role() = 'authenticated'
);

-- Policy להעלאת קבצים
CREATE POLICY "Authenticated users can upload files"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'clinic-files' AND
  auth.role() = 'authenticated'
);

-- Policy למחיקת קבצים (רק מי שהעלה או admin)
CREATE POLICY "Users can delete own files"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'clinic-files' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
```

## שלב 7: הגדרות נוספות (אופציונלי)

### הפעלת Email Confirmations:

1. לך ל-**Authentication** → **Settings** → **Email Templates**
2. התאם אישית את תבניות המייל לעברית
3. הגדר SMTP אם רוצה לשלוח מיילים משלך

### הגדרת Realtime (עדכונים בזמן אמת):

```sql
-- הפעל realtime לטבלאות שצריכות עדכונים חיים
ALTER PUBLICATION supabase_realtime ADD TABLE appointments;
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
```

### הגדרת הצפנה (אופציונלי):

אם אתה רוצה להצפין הערות רגישות, הגדר encryption key:

```sql
-- הגדר מפתח הצפנה (שמור אותו בסודיות!)
ALTER DATABASE postgres SET app.encryption_key = 'your-secret-encryption-key-min-32-chars';
```

## שלב 8: בדיקת החיבור

1. הפעל את הפרויקט:
```bash
npm run dev
```

2. פתח את הדפדפן ב-http://localhost:5173
3. נסה להתחבר עם המשתמש שיצרת
4. בדוק שאתה רואה את הדאשבורד

## בעיות נפוצות ופתרונות

### שגיאת חיבור ל-Supabase

**בעיה**: "Failed to fetch" או "Network error"

**פתרון**:
1. בדוק שה-`.env` קיים ויש בו ערכים נכונים
2. הפעל מחדש את שרת הפיתוח (`npm run dev`)
3. בדוק שה-CORS מופעל ב-Supabase (ברירת מחדל מופעל)

### שגיאת RLS

**בעיה**: "Row Level Security policy violation"

**פתרון**:
1. ודא שהרצת את כל ה-RLS policies
2. בדוק שהמשתמש מחובר נכון
3. ודא שהמשתמש יש לו תפקיד מתאים ב-`user_roles`

### משתמש לא יכול להתחבר

**פתרון**:
1. ודא שהמייל אומת (או כבה email confirmation)
2. בדוק שהסיסמה נכונה
3. בדוק ב-Authentication → Users שהמשתמש קיים

## טיפים לאבטחה

1. **אל תשתף** את ה-service_role key בקוד הלקוח
2. **השתמש רק** ב-anon key בצד הלקוח
3. **הפעל** RLS על כל הטבלאות
4. **החלף** את הסיסמאות הדיפולטיביות
5. **גבה** את בסיס הנתונים באופן קבוע

## גיבוי ושחזור

### גיבוי ידני:

```bash
# התקן pg_dump
supabase db dump -f backup.sql
```

### שחזור:

```bash
supabase db reset
psql -f backup.sql
```

## קישורים שימושיים

- [תיעוד Supabase](https://supabase.com/docs)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Storage](https://supabase.com/docs/guides/storage)

## תמיכה

אם נתקלת בבעיות, בדוק:
1. Supabase logs בדאשבורד
2. Console בדפדפן (F12)
3. [Supabase Discord](https://discord.supabase.com)
