-- Row Level Security Policies
-- This ensures users can only access data they are authorized to see

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE recurring_appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE files ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- HELPER FUNCTIONS FOR RLS
-- ============================================================================

-- Check if user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid() AND is_admin = TRUE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user has specific role
CREATE OR REPLACE FUNCTION has_role(role_name TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = role_name
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user can access patient data
CREATE OR REPLACE FUNCTION can_access_patient_data()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN is_admin() OR
         has_role('therapist') OR
         has_role('supervisor') OR
         has_role('receptionist') OR
         has_role('billing');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- PROFILES POLICIES
-- ============================================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Admins can view all profiles
CREATE POLICY "Admins can view all profiles"
  ON profiles FOR SELECT
  USING (is_admin());

-- Admins can update all profiles
CREATE POLICY "Admins can update all profiles"
  ON profiles FOR UPDATE
  USING (is_admin());

-- ============================================================================
-- USER ROLES POLICIES
-- ============================================================================

-- Users can view their own roles
CREATE POLICY "Users can view own roles"
  ON user_roles FOR SELECT
  USING (auth.uid() = user_id);

-- Admins can manage all roles
CREATE POLICY "Admins can manage all roles"
  ON user_roles FOR ALL
  USING (is_admin());

-- ============================================================================
-- PATIENTS POLICIES
-- ============================================================================

-- Authorized users can view non-deleted patients
CREATE POLICY "Authorized users can view patients"
  ON patients FOR SELECT
  USING (can_access_patient_data() AND soft_deleted_at IS NULL);

-- Therapists and admins can insert patients
CREATE POLICY "Therapists can insert patients"
  ON patients FOR INSERT
  WITH CHECK (is_admin() OR has_role('therapist'));

-- Therapists and admins can update patients
CREATE POLICY "Therapists can update patients"
  ON patients FOR UPDATE
  USING (is_admin() OR has_role('therapist'));

-- Only admins can delete patients (soft delete)
CREATE POLICY "Admins can delete patients"
  ON patients FOR UPDATE
  USING (is_admin() AND soft_deleted_at IS NULL);

-- ============================================================================
-- SESSIONS POLICIES
-- ============================================================================

-- Authorized users can view sessions
CREATE POLICY "Authorized users can view sessions"
  ON sessions FOR SELECT
  USING (can_access_patient_data());

-- Therapists can insert sessions
CREATE POLICY "Therapists can insert sessions"
  ON sessions FOR INSERT
  WITH CHECK (is_admin() OR has_role('therapist'));

-- Therapists can update their sessions
CREATE POLICY "Therapists can update sessions"
  ON sessions FOR UPDATE
  USING (is_admin() OR has_role('therapist'));

-- Admins can delete sessions
CREATE POLICY "Admins can delete sessions"
  ON sessions FOR DELETE
  USING (is_admin());

-- ============================================================================
-- APPOINTMENTS POLICIES
-- ============================================================================

-- All authorized users can view appointments
CREATE POLICY "Authorized users can view appointments"
  ON appointments FOR SELECT
  USING (can_access_patient_data());

-- Therapists and receptionists can create appointments
CREATE POLICY "Therapists and receptionists can create appointments"
  ON appointments FOR INSERT
  WITH CHECK (is_admin() OR has_role('therapist') OR has_role('receptionist'));

-- Therapists and receptionists can update appointments
CREATE POLICY "Therapists and receptionists can update appointments"
  ON appointments FOR UPDATE
  USING (is_admin() OR has_role('therapist') OR has_role('receptionist'));

-- Admins and receptionists can delete appointments
CREATE POLICY "Admins and receptionists can delete appointments"
  ON appointments FOR DELETE
  USING (is_admin() OR has_role('receptionist'));

-- ============================================================================
-- RECURRING APPOINTMENTS POLICIES
-- ============================================================================

-- All authorized users can view recurring appointments
CREATE POLICY "Authorized users can view recurring appointments"
  ON recurring_appointments FOR SELECT
  USING (can_access_patient_data());

-- Therapists and receptionists can manage recurring appointments
CREATE POLICY "Therapists and receptionists can manage recurring appointments"
  ON recurring_appointments FOR ALL
  USING (is_admin() OR has_role('therapist') OR has_role('receptionist'));

-- ============================================================================
-- REPORTS POLICIES
-- ============================================================================

-- Authorized users can view reports
CREATE POLICY "Authorized users can view reports"
  ON reports FOR SELECT
  USING (can_access_patient_data());

-- Therapists can create reports
CREATE POLICY "Therapists can create reports"
  ON reports FOR INSERT
  WITH CHECK (is_admin() OR has_role('therapist'));

-- Therapists can update reports
CREATE POLICY "Therapists can update reports"
  ON reports FOR UPDATE
  USING (is_admin() OR has_role('therapist'));

-- Admins can delete reports
CREATE POLICY "Admins can delete reports"
  ON reports FOR DELETE
  USING (is_admin());

-- ============================================================================
-- FILES POLICIES
-- ============================================================================

-- Authorized users can view files
CREATE POLICY "Authorized users can view files"
  ON files FOR SELECT
  USING (can_access_patient_data());

-- Authorized users can upload files
CREATE POLICY "Authorized users can upload files"
  ON files FOR INSERT
  WITH CHECK (can_access_patient_data());

-- Users can update their own uploaded files
CREATE POLICY "Users can update own files"
  ON files FOR UPDATE
  USING (auth.uid() = uploaded_by OR is_admin());

-- Admins and file owners can delete files
CREATE POLICY "Admins and owners can delete files"
  ON files FOR DELETE
  USING (auth.uid() = uploaded_by OR is_admin());

-- ============================================================================
-- TASKS POLICIES
-- ============================================================================

-- Users can view tasks assigned to them or created by them
CREATE POLICY "Users can view relevant tasks"
  ON tasks FOR SELECT
  USING (
    can_access_patient_data() OR
    auth.uid() = ANY(assigned_to) OR
    auth.uid() = completed_by
  );

-- Authorized users can create tasks
CREATE POLICY "Authorized users can create tasks"
  ON tasks FOR INSERT
  WITH CHECK (can_access_patient_data());

-- Authorized users can update tasks
CREATE POLICY "Authorized users can update tasks"
  ON tasks FOR UPDATE
  USING (can_access_patient_data());

-- Admins can delete tasks
CREATE POLICY "Admins can delete tasks"
  ON tasks FOR DELETE
  USING (is_admin());

-- ============================================================================
-- ACTIVITIES POLICIES
-- ============================================================================

-- Authorized users can view activities
CREATE POLICY "Authorized users can view activities"
  ON activities FOR SELECT
  USING (can_access_patient_data());

-- Therapists can create activities
CREATE POLICY "Therapists can create activities"
  ON activities FOR INSERT
  WITH CHECK (is_admin() OR has_role('therapist'));

-- Therapists can update activities
CREATE POLICY "Therapists can update activities"
  ON activities FOR UPDATE
  USING (is_admin() OR has_role('therapist'));

-- Admins can delete activities
CREATE POLICY "Admins can delete activities"
  ON activities FOR DELETE
  USING (is_admin());

-- ============================================================================
-- AUDIT LOG POLICIES
-- ============================================================================

-- Only admins and supervisors can view audit logs
CREATE POLICY "Admins and supervisors can view audit logs"
  ON audit_log FOR SELECT
  USING (is_admin() OR has_role('supervisor'));

-- System can insert audit logs (handled by triggers)
CREATE POLICY "System can insert audit logs"
  ON audit_log FOR INSERT
  WITH CHECK (true);

-- Nobody can update or delete audit logs
-- (no policies needed - defaults to no access)
