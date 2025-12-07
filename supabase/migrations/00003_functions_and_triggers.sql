-- Database Functions and Triggers

-- ============================================================================
-- AUTO-INCREMENT SESSION NUMBER
-- ============================================================================
CREATE OR REPLACE FUNCTION set_session_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.session_number IS NULL OR NEW.session_number = 1 THEN
    SELECT COALESCE(MAX(session_number), 0) + 1
    INTO NEW.session_number
    FROM sessions
    WHERE patient_id = NEW.patient_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_set_session_number
  BEFORE INSERT ON sessions
  FOR EACH ROW
  EXECUTE FUNCTION set_session_number();

-- ============================================================================
-- DENORMALIZE PATIENT NAME
-- ============================================================================
CREATE OR REPLACE FUNCTION set_patient_name()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.patient_id IS NOT NULL AND (NEW.patient_name IS NULL OR NEW.patient_name = '') THEN
    SELECT full_name INTO NEW.patient_name
    FROM patients
    WHERE id = NEW.patient_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to sessions
CREATE TRIGGER auto_set_patient_name_sessions
  BEFORE INSERT OR UPDATE ON sessions
  FOR EACH ROW
  EXECUTE FUNCTION set_patient_name();

-- Apply to appointments
CREATE TRIGGER auto_set_patient_name_appointments
  BEFORE INSERT OR UPDATE ON appointments
  FOR EACH ROW
  EXECUTE FUNCTION set_patient_name();

-- Apply to reports
CREATE TRIGGER auto_set_patient_name_reports
  BEFORE INSERT OR UPDATE ON reports
  FOR EACH ROW
  EXECUTE FUNCTION set_patient_name();

-- ============================================================================
-- UPDATE APPOINTMENT HAS_REPORT FLAG
-- ============================================================================
CREATE OR REPLACE FUNCTION update_appointment_has_report()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.appointment_id IS NOT NULL THEN
    UPDATE appointments
    SET has_report = TRUE
    WHERE id = NEW.appointment_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_update_appointment_report
  AFTER INSERT ON reports
  FOR EACH ROW
  EXECUTE FUNCTION update_appointment_has_report();

-- ============================================================================
-- CREATE PROFILE ON USER SIGNUP
-- ============================================================================
CREATE OR REPLACE FUNCTION create_profile_for_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, username, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    NEW.email
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_profile_for_user();

-- ============================================================================
-- AUDIT LOG TRIGGER
-- ============================================================================
CREATE OR REPLACE FUNCTION log_audit_trail()
RETURNS TRIGGER AS $$
DECLARE
  old_data JSONB;
  new_data JSONB;
  action_type TEXT;
BEGIN
  -- Determine action type
  IF TG_OP = 'INSERT' THEN
    action_type := 'CREATE';
    old_data := NULL;
    new_data := to_jsonb(NEW);
  ELSIF TG_OP = 'UPDATE' THEN
    action_type := 'UPDATE';
    old_data := to_jsonb(OLD);
    new_data := to_jsonb(NEW);
  ELSIF TG_OP = 'DELETE' THEN
    action_type := 'DELETE';
    old_data := to_jsonb(OLD);
    new_data := NULL;
  END IF;

  -- Insert audit log entry
  INSERT INTO audit_log (
    user_id,
    action,
    entity_type,
    entity_id,
    old_values,
    new_values,
    ip_address,
    user_agent
  ) VALUES (
    auth.uid(),
    action_type,
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    old_data,
    new_data,
    inet_client_addr(),
    current_setting('request.headers', true)::json->>'user-agent'
  );

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply audit logging to sensitive tables
CREATE TRIGGER audit_patients
  AFTER INSERT OR UPDATE OR DELETE ON patients
  FOR EACH ROW EXECUTE FUNCTION log_audit_trail();

CREATE TRIGGER audit_sessions
  AFTER INSERT OR UPDATE OR DELETE ON sessions
  FOR EACH ROW EXECUTE FUNCTION log_audit_trail();

CREATE TRIGGER audit_reports
  AFTER INSERT OR UPDATE OR DELETE ON reports
  FOR EACH ROW EXECUTE FUNCTION log_audit_trail();

-- ============================================================================
-- GENERATE RECURRING APPOINTMENTS
-- ============================================================================
CREATE OR REPLACE FUNCTION generate_recurring_appointments(
  recurring_id UUID,
  from_date DATE,
  to_date DATE
)
RETURNS INTEGER AS $$
DECLARE
  recurring_record RECORD;
  current_date DATE;
  appointments_created INTEGER := 0;
BEGIN
  -- Get recurring appointment details
  SELECT * INTO recurring_record
  FROM recurring_appointments
  WHERE id = recurring_id AND is_active = TRUE;

  IF NOT FOUND THEN
    RETURN 0;
  END IF;

  -- Loop through dates
  current_date := from_date;
  WHILE current_date <= to_date LOOP
    -- Check if it's the correct day of week
    IF EXTRACT(DOW FROM current_date) = recurring_record.day_of_week THEN
      -- Check if appointment doesn't already exist
      IF NOT EXISTS (
        SELECT 1 FROM appointments
        WHERE patient_id = recurring_record.patient_id
          AND appointment_date = current_date
          AND appointment_time = recurring_record.time
      ) THEN
        -- Create appointment
        INSERT INTO appointments (
          patient_id,
          patient_name,
          appointment_date,
          appointment_time,
          duration_minutes,
          recurring_id,
          notes
        ) VALUES (
          recurring_record.patient_id,
          recurring_record.patient_name,
          current_date,
          recurring_record.time,
          recurring_record.duration_minutes,
          recurring_id,
          'נוצר אוטומטית מפגישה חוזרת'
        );
        appointments_created := appointments_created + 1;
      END IF;
    END IF;

    current_date := current_date + INTERVAL '1 day';
  END LOOP;

  RETURN appointments_created;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- ENCRYPT SENSITIVE NOTES
-- ============================================================================
CREATE OR REPLACE FUNCTION encrypt_sensitive_notes()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.notes IS NOT NULL AND NEW.notes != '' THEN
    -- Simple encryption using pgcrypto
    -- In production, use a proper encryption key from environment
    NEW.notes_encrypted := pgp_sym_encrypt(NEW.notes, current_setting('app.encryption_key', true));
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Note: Encryption trigger is optional and should only be enabled if encryption key is set
-- CREATE TRIGGER encrypt_session_notes
--   BEFORE INSERT OR UPDATE ON sessions
--   FOR EACH ROW
--   WHEN (NEW.notes IS NOT NULL)
--   EXECUTE FUNCTION encrypt_sensitive_notes();

-- ============================================================================
-- DECRYPT NOTES FUNCTION (for application use)
-- ============================================================================
CREATE OR REPLACE FUNCTION decrypt_session_notes(encrypted_notes TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN pgp_sym_decrypt(encrypted_notes::bytea, current_setting('app.encryption_key', true));
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- CALCULATE AGE FROM DATE OF BIRTH
-- ============================================================================
CREATE OR REPLACE FUNCTION calculate_age()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.date_of_birth IS NOT NULL THEN
    NEW.age := DATE_PART('year', AGE(NEW.date_of_birth));
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_calculate_age
  BEFORE INSERT OR UPDATE ON patients
  FOR EACH ROW
  WHEN (NEW.date_of_birth IS NOT NULL)
  EXECUTE FUNCTION calculate_age();

-- ============================================================================
-- SOFT DELETE FUNCTION
-- ============================================================================
CREATE OR REPLACE FUNCTION soft_delete_patient(patient_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE patients
  SET soft_deleted_at = NOW()
  WHERE id = patient_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- RESTORE SOFT DELETED PATIENT
-- ============================================================================
CREATE OR REPLACE FUNCTION restore_patient(patient_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE patients
  SET soft_deleted_at = NULL
  WHERE id = patient_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- GET PATIENT STATISTICS
-- ============================================================================
CREATE OR REPLACE FUNCTION get_patient_statistics(patient_id UUID)
RETURNS TABLE (
  total_sessions INTEGER,
  total_appointments INTEGER,
  total_reports INTEGER,
  total_tasks INTEGER,
  pending_tasks INTEGER,
  total_files INTEGER,
  last_session_date DATE,
  next_appointment_date DATE
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    (SELECT COUNT(*)::INTEGER FROM sessions WHERE sessions.patient_id = get_patient_statistics.patient_id),
    (SELECT COUNT(*)::INTEGER FROM appointments WHERE appointments.patient_id = get_patient_statistics.patient_id),
    (SELECT COUNT(*)::INTEGER FROM reports WHERE reports.patient_id = get_patient_statistics.patient_id),
    (SELECT COUNT(*)::INTEGER FROM tasks WHERE tasks.patient_id = get_patient_statistics.patient_id),
    (SELECT COUNT(*)::INTEGER FROM tasks WHERE tasks.patient_id = get_patient_statistics.patient_id AND status != 'completed'),
    (SELECT COUNT(*)::INTEGER FROM files WHERE files.patient_id = get_patient_statistics.patient_id),
    (SELECT MAX(session_date) FROM sessions WHERE sessions.patient_id = get_patient_statistics.patient_id),
    (SELECT MIN(appointment_date) FROM appointments WHERE appointments.patient_id = get_patient_statistics.patient_id AND appointment_date >= CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- GET DASHBOARD STATISTICS
-- ============================================================================
CREATE OR REPLACE FUNCTION get_dashboard_stats()
RETURNS TABLE (
  active_patients INTEGER,
  today_appointments INTEGER,
  pending_tasks INTEGER,
  this_month_sessions INTEGER,
  last_month_sessions INTEGER,
  growth_percentage DECIMAL
) AS $$
DECLARE
  this_month INT;
  last_month INT;
BEGIN
  SELECT COUNT(*)::INTEGER INTO this_month
  FROM sessions
  WHERE session_date >= DATE_TRUNC('month', CURRENT_DATE);

  SELECT COUNT(*)::INTEGER INTO last_month
  FROM sessions
  WHERE session_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
    AND session_date < DATE_TRUNC('month', CURRENT_DATE);

  RETURN QUERY
  SELECT
    (SELECT COUNT(*)::INTEGER FROM patients WHERE status = 'active' AND soft_deleted_at IS NULL),
    (SELECT COUNT(*)::INTEGER FROM appointments WHERE appointment_date = CURRENT_DATE),
    (SELECT COUNT(*)::INTEGER FROM tasks WHERE status != 'completed'),
    this_month,
    last_month,
    CASE
      WHEN last_month = 0 THEN 0
      ELSE ROUND(((this_month - last_month)::DECIMAL / last_month * 100), 2)
    END;
END;
$$ LANGUAGE plpgsql;
