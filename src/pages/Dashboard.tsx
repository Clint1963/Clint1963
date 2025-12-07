import { Users, Calendar, CheckSquare, TrendingUp } from 'lucide-react'
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card'

export default function Dashboard() {
  const stats = [
    {
      title: 'מטופלים פעילים',
      value: '42',
      icon: Users,
      color: 'text-blue-600',
    },
    {
      title: 'פגישות היום',
      value: '8',
      icon: Calendar,
      color: 'text-green-600',
    },
    {
      title: 'משימות ממתינות',
      value: '15',
      icon: CheckSquare,
      color: 'text-orange-600',
    },
    {
      title: 'התפתחות חודשית',
      value: '+12%',
      icon: TrendingUp,
      color: 'text-purple-600',
    },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">דאשבורד</h1>
        <p className="text-muted-foreground">מבט כללי על המערכת</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat) => (
          <Card key={stat.title}>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                {stat.title}
              </CardTitle>
              <stat.icon className={`h-5 w-5 ${stat.color}`} />
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold">{stat.value}</div>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>פגישות היום</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground">רשימת הפגישות המתוכננות להיום...</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>משימות אחרונות</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground">משימות שטרם בוצעו...</p>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
