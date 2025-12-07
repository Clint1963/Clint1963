import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { AuthProvider } from '@/contexts/AuthContext'
import { ThemeProvider } from '@/contexts/ThemeContext'
import Layout from '@/components/layout/Layout'
import Dashboard from '@/pages/Dashboard'
import Patients from '@/pages/Patients'
import Calendar from '@/pages/Calendar'
import Sessions from '@/pages/Sessions'
import Reports from '@/pages/Reports'
import Files from '@/pages/Files'
import Tasks from '@/pages/Tasks'
import Activities from '@/pages/Activities'
import Settings from '@/pages/Settings'
import Login from '@/pages/Login'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      refetchOnWindowFocus: false,
    },
  },
})

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider>
        <AuthProvider>
          <Router>
            <Routes>
              <Route path="/login" element={<Login />} />
              <Route path="/" element={<Layout />}>
                <Route index element={<Navigate to="/dashboard" replace />} />
                <Route path="dashboard" element={<Dashboard />} />
                <Route path="patients" element={<Patients />} />
                <Route path="calendar" element={<Calendar />} />
                <Route path="sessions" element={<Sessions />} />
                <Route path="reports" element={<Reports />} />
                <Route path="files" element={<Files />} />
                <Route path="tasks" element={<Tasks />} />
                <Route path="activities" element={<Activities />} />
                <Route path="settings" element={<Settings />} />
              </Route>
            </Routes>
          </Router>
        </AuthProvider>
      </ThemeProvider>
    </QueryClientProvider>
  )
}

export default App
