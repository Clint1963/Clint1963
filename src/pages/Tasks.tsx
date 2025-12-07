import { Plus } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card'

export default function Tasks() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">משימות</h1>
          <p className="text-muted-foreground">ניהול משימות</p>
        </div>
        <Button>
          <Plus className="h-4 w-4 ml-2" />
          משימה חדשה
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>רשימת משימות</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground">
            רשימת כל המשימות תוצג כאן...
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
