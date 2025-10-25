import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { router } from '@inertiajs/react'
import { AppHeader } from '@/components/app-header'

interface User {
  id: number
  name: string
  email: string
  admin: boolean
}

interface AdminConsoleProps {
  auth: {
    user: User
  }
  stats: {
    total_users: number
    admins: number
    regular_users: number
    active_sessions: number
  }
}

export default function AdminConsole({ stats }: AdminConsoleProps) {
  return (
    <>
      <AppHeader
        breadcrumbs={[{ label: 'Admin Panel' }]}
        actions={
          <>
            <Button size="sm" onClick={() => router.visit('/admin/users')}>
              Manage Users
            </Button>
            <Button size="sm" variant="outline" onClick={() => router.visit('/admin/audit_logs')}>
              Audit Logs
            </Button>
          </>
        }
      />

      <div className="flex flex-1 flex-col">
        <div className="@container/main flex flex-1 flex-col gap-2">
          <div className="flex flex-col gap-4 py-4 md:gap-6 md:py-6">
            <div className="*:data-[slot=card]:from-primary/5 *:data-[slot=card]:to-card dark:*:data-[slot=card]:bg-card grid grid-cols-1 gap-4 px-4 *:data-[slot=card]:bg-gradient-to-t *:data-[slot=card]:shadow-xs lg:px-6 @xl/main:grid-cols-2 @5xl/main:grid-cols-3">
              <Card className="@container/card">
                <CardHeader>
                  <CardDescription>Total Users</CardDescription>
                  <CardTitle className="text-2xl font-semibold tabular-nums @[250px]/card:text-3xl">
                    {stats.total_users}
                  </CardTitle>
                </CardHeader>
                <CardContent className="flex-col items-start gap-1.5 text-sm">
                  <div className="text-muted-foreground">
                    All registered users
                  </div>
                </CardContent>
              </Card>

              <Card className="@container/card">
                <CardHeader>
                  <CardDescription>Admins</CardDescription>
                  <CardTitle className="text-2xl font-semibold tabular-nums @[250px]/card:text-3xl">
                    {stats.admins}
                  </CardTitle>
                </CardHeader>
                <CardContent className="flex-col items-start gap-1.5 text-sm">
                  <div className="text-muted-foreground">
                    Full system access
                  </div>
                </CardContent>
              </Card>

              <Card className="@container/card">
                <CardHeader>
                  <CardDescription>Regular Users</CardDescription>
                  <CardTitle className="text-2xl font-semibold tabular-nums @[250px]/card:text-3xl">
                    {stats.regular_users}
                  </CardTitle>
                </CardHeader>
                <CardContent className="flex-col items-start gap-1.5 text-sm">
                  <div className="text-muted-foreground">
                    Standard accounts
                  </div>
                </CardContent>
              </Card>
            </div>

            <div className="px-4 lg:px-6">
              <Card className="from-primary/5 to-card bg-gradient-to-t shadow-xs">
                <CardHeader>
                  <CardDescription>System Activity</CardDescription>
                  <CardTitle className="text-2xl font-semibold tabular-nums">Active Sessions</CardTitle>
                </CardHeader>
                <CardContent className="flex-col items-start gap-1.5 text-sm">
                  <div className="text-3xl font-bold tabular-nums">{stats.active_sessions}</div>
                  <div className="text-muted-foreground">Valid refresh tokens</div>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </div>
    </>
  )
}
