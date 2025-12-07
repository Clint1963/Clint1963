// Database Types
export interface Patient {
  id: string
  full_name: string
  date_of_birth?: string
  age?: number
  phone?: string
  mobile?: string
  city?: string
  hmo?: string // קופת חולים
  school?: string
  company?: string
  referred_by?: string
  referred_contact?: string
  status: "active" | "inactive"
  notes?: string
  custom_fields?: Record<string, any>
  soft_deleted_at?: string
  created_at: string
  updated_at: string
}

export interface Session {
  id: string
  patient_id: string
  patient_name?: string
  session_number: number
  session_date: string
  session_time: string
  duration_minutes: number
  session_type?: string
  session_location?: string
  notes?: string
  notes_encrypted?: string
  summary?: string
  key_points?: string[]
  recommendations?: string[]
  payment_status?: "pending" | "paid" | "cancelled"
  payment_amount?: number
  created_at: string
  updated_at: string
}

export interface Appointment {
  id: string
  patient_id: string
  patient_name: string
  appointment_date: string
  appointment_time: string
  duration_minutes: number
  status: "scheduled" | "completed" | "cancelled"
  recurring_id?: string
  has_report: boolean
  notes?: string
  created_at: string
  updated_at: string
}

export interface RecurringAppointment {
  id: string
  patient_id: string
  patient_name: string
  day_of_week: number // 0-6 (Sunday-Saturday)
  time: string
  start_date: string
  end_date?: string
  duration_minutes: number
  is_active: boolean
  notes?: string
  created_at: string
  updated_at: string
}

export interface Report {
  id: string
  patient_id: string
  patient_name: string
  appointment_id?: string
  report_date: string
  content: string
  key_points?: string[]
  recommendations?: string[]
  created_at: string
  updated_at: string
}

export interface File {
  id: string
  name: string
  file_type: string
  file_size: number
  storage_key: string
  checksum?: string
  patient_id?: string
  folder_id?: string
  uploaded_by: string
  extracted_text?: string
  summary?: string
  metadata?: Record<string, any>
  created_at: string
  updated_at: string
}

export interface Task {
  id: string
  title: string
  description?: string
  patient_id?: string
  assigned_to?: string[]
  location?: string
  status: "pending" | "in_progress" | "completed"
  priority: "low" | "medium" | "high"
  task_type?: string
  due_date?: string
  completed_at?: string
  completed_by?: string
  created_at: string
  updated_at: string
}

export interface Activity {
  id: string
  title: string
  activity_type: string
  patient_id?: string
  start_date: string
  location?: string
  topic?: string
  label?: string
  reason?: string
  additional_info?: string
  paid: boolean
  payment_status?: "pending" | "paid" | "cancelled"
  created_at: string
  updated_at: string
}

export interface User {
  id: string
  username: string
  email: string
  password_hash: string
  is_admin: boolean
  twofa_secret?: string
  last_login_at?: string
  failed_login_attempts: number
  locked_until?: string
  force_password_change: boolean
  password_changed_at?: string
  created_at: string
  updated_at: string
}

export interface Profile {
  id: string
  username: string
  email: string
  is_admin: boolean
  twofa_secret?: string
  last_login_at?: string
  created_at: string
  updated_at: string
}

export interface UserRole {
  id: string
  user_id: string
  role: "admin" | "therapist" | "supervisor" | "receptionist" | "billing"
  granted_by: string
  granted_at: string
}

// UI Types
export interface DashboardStats {
  activePatients: number
  todayAppointments: number
  pendingTasks: number
  monthlyRevenue: number
  monthlyGrowth: number
}
