import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card'

export default function Settings() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">הגדרות</h1>
        <p className="text-muted-foreground">הגדרות מערכת ופרופיל</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>הגדרות כלליות</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground">
            הגדרות המערכת יוצגו כאן...
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
