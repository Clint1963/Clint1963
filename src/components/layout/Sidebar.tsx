import { NavLink } from 'react-router-dom'
import {
  LayoutDashboard,
  Users,
  Calendar,
  FileText,
  File,
  CheckSquare,
  Activity,
  Settings,
  Briefcase
} from 'lucide-react'
import { cn } from '@/lib/utils'

const navItems = [
  { to: '/dashboard', label: 'דאשבורד', icon: LayoutDashboard },
  { to: '/patients', label: 'מטופלים', icon: Users },
  { to: '/calendar', label: 'יומן', icon: Calendar },
  { to: '/sessions', label: 'מפגשים', icon: Briefcase },
  { to: '/reports', label: 'דוחות', icon: FileText },
  { to: '/files', label: 'קבצים', icon: File },
  { to: '/tasks', label: 'משימות', icon: CheckSquare },
  { to: '/activities', label: 'פעילויות', icon: Activity },
  { to: '/settings', label: 'הגדרות', icon: Settings },
]

export default function Sidebar() {
  return (
    <aside className="w-64 border-l bg-card min-h-[calc(100vh-4rem)]">
      <nav className="p-4 space-y-2">
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) =>
              cn(
                'flex items-center gap-3 px-4 py-3 rounded-lg transition-colors',
                'hover:bg-accent hover:text-accent-foreground',
                isActive
                  ? 'bg-primary text-primary-foreground'
                  : 'text-muted-foreground'
              )
            }
          >
            <item.icon className="h-5 w-5" />
            <span>{item.label}</span>
          </NavLink>
        ))}
      </nav>
    </aside>
  )
}
