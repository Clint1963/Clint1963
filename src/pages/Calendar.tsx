import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card'

export default function Calendar() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">יומן</h1>
        <p className="text-muted-foreground">ניהול פגישות ויומן</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>לוח שנה</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground">
            לוח השנה יוצג כאן...
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
