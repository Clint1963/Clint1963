import { Upload } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card'

export default function Files() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">קבצים</h1>
          <p className="text-muted-foreground">ניהול קבצים ומסמכים</p>
        </div>
        <Button>
          <Upload className="h-4 w-4 ml-2" />
          העלה קובץ
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>רשימת קבצים</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground">
            רשימת כל הקבצים תוצג כאן...
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
