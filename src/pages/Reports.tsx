import { Plus } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card'

export default function Reports() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">דוחות</h1>
          <p className="text-muted-foreground">ניהול דוחות</p>
        </div>
        <Button>
          <Plus className="h-4 w-4 ml-2" />
          דוח חדש
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>רשימת דוחות</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground">
            רשימת כל הדוחות תוצג כאן...
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
