import { AlertCircle } from 'lucide-react'

export default function DemoModeBanner() {
  const hasSupabase = import.meta.env.VITE_SUPABASE_URL && import.meta.env.VITE_SUPABASE_ANON_KEY

  if (hasSupabase) return null

  return (
    <div className="bg-yellow-50 dark:bg-yellow-900/20 border-b border-yellow-200 dark:border-yellow-800">
      <div className="container mx-auto px-4 py-3">
        <div className="flex items-center gap-3 text-yellow-800 dark:text-yellow-200">
          <AlertCircle className="h-5 w-5 flex-shrink-0" />
          <div className="text-sm">
            <strong>מצב הדגמה:</strong> הפרויקט רץ ללא חיבור ל-Supabase.
            כדי להפעיל את כל התכונות, הגדר את משתני הסביבה (ראה{' '}
            <code className="bg-yellow-100 dark:bg-yellow-900/50 px-1.5 py-0.5 rounded">SUPABASE_SETUP.md</code>)
          </div>
        </div>
      </div>
    </div>
  )
}
