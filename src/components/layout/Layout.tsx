import { Outlet } from 'react-router-dom'
import Navbar from './Navbar'
import Sidebar from './Sidebar'
import DemoModeBanner from './DemoModeBanner'

export default function Layout() {
  return (
    <div className="min-h-screen bg-background" dir="rtl">
      <Navbar />
      <DemoModeBanner />
      <div className="flex">
        <Sidebar />
        <main className="flex-1 p-6">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
