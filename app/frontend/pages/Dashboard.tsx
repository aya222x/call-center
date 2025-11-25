import { router } from '@inertiajs/react'
import {
  PhoneIcon,
  CheckCircleIcon,
  ClockIcon,
  XCircleIcon,
  TrendingUpIcon,
  UsersIcon,
  EyeIcon,
} from 'lucide-react'

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'

interface Stats {
  total_recordings: number
  completed_count: number
  pending_count: number
  failed_count: number
  avg_overall_score: number
  avg_adherence: number
  avg_politeness: number
  avg_speed: number
  avg_terminology: number
  avg_success: number
}

interface Recording {
  id: number
  user_name: string
  call_script_name: string
  status: string
  language: string
  call_date: string
  overall_score: number | null
  score_color: string | null
  created_at: string
}

interface Operator {
  id: number
  name: string
  email: string
  avg_score: number
  recordings_count: number
}

interface DashboardProps {
  stats: Stats
  language_breakdown: Record<string, number>
  recent_recordings: Recording[]
  top_performers: Operator[]
  can_view_operators: boolean
}

export default function Dashboard({
  stats,
  language_breakdown,
  recent_recordings,
  top_performers,
  can_view_operators,
}: DashboardProps) {
  const getStatusBadge = (status: string) => {
    const variants: Record<string, 'default' | 'secondary' | 'destructive' | 'outline'> = {
      uploaded: 'secondary',
      transcribing: 'default',
      analyzing: 'default',
      completed: 'default',
      failed: 'destructive',
    }
    return <Badge variant={variants[status] || 'default'}>{status}</Badge>
  }

  const getScoreBadge = (score: number | null, color: string | null) => {
    if (!score) return null

    const colorMap: Record<string, string> = {
      green: 'bg-green-100 text-green-800',
      yellow: 'bg-yellow-100 text-yellow-800',
      orange: 'bg-orange-100 text-orange-800',
      red: 'bg-red-100 text-red-800',
    }

    return (
      <div
        className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${colorMap[color || 'green'] || colorMap.green}`}
      >
        {score}/100
      </div>
    )
  }

  return (
    <div className="flex flex-1 flex-col">
      <div className="@container/main flex flex-1 flex-col gap-2">
        <div className="flex flex-col gap-4 py-4 md:gap-6 md:py-6">
          <div className="px-4 lg:px-6">
            {/* Header */}
            <div className="mb-6">
              <h1 className="text-2xl font-bold">Dashboard</h1>
              <p className="text-muted-foreground mt-1">
                Call center KPI overview and statistics
              </p>
            </div>

            {/* Stats Cards */}
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4 mb-6">
              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Total Recordings</CardTitle>
                  <PhoneIcon className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats.total_recordings}</div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Completed</CardTitle>
                  <CheckCircleIcon className="h-4 w-4 text-green-600" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats.completed_count}</div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Pending</CardTitle>
                  <ClockIcon className="h-4 w-4 text-yellow-600" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats.pending_count}</div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Failed</CardTitle>
                  <XCircleIcon className="h-4 w-4 text-red-600" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats.failed_count}</div>
                </CardContent>
              </Card>
            </div>

            {/* KPI Scores */}
            <Card className="mb-6">
              <CardHeader>
                <CardTitle>Average KPI Scores</CardTitle>
                <CardDescription>Overall performance metrics across all evaluations</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <div className="flex justify-between text-sm mb-2">
                    <span className="font-medium">Overall Score</span>
                    <span className="text-muted-foreground">{stats.avg_overall_score}/100</span>
                  </div>
                  <Progress value={stats.avg_overall_score} className="h-2" />
                </div>

                <div>
                  <div className="flex justify-between text-sm mb-2">
                    <span className="font-medium">Script Adherence</span>
                    <span className="text-muted-foreground">{stats.avg_adherence}/100</span>
                  </div>
                  <Progress value={stats.avg_adherence} className="h-2" />
                </div>

                <div>
                  <div className="flex justify-between text-sm mb-2">
                    <span className="font-medium">Politeness & Tone</span>
                    <span className="text-muted-foreground">{stats.avg_politeness}/100</span>
                  </div>
                  <Progress value={stats.avg_politeness} className="h-2" />
                </div>

                <div>
                  <div className="flex justify-between text-sm mb-2">
                    <span className="font-medium">Resolution Speed</span>
                    <span className="text-muted-foreground">{stats.avg_speed}/100</span>
                  </div>
                  <Progress value={stats.avg_speed} className="h-2" />
                </div>

                <div>
                  <div className="flex justify-between text-sm mb-2">
                    <span className="font-medium">Terminology</span>
                    <span className="text-muted-foreground">{stats.avg_terminology}/100</span>
                  </div>
                  <Progress value={stats.avg_terminology} className="h-2" />
                </div>

                <div>
                  <div className="flex justify-between text-sm mb-2">
                    <span className="font-medium">Call Success</span>
                    <span className="text-muted-foreground">{stats.avg_success}/100</span>
                  </div>
                  <Progress value={stats.avg_success} className="h-2" />
                </div>
              </CardContent>
            </Card>

            <div className="grid gap-6 md:grid-cols-2">
              {/* Recent Recordings */}
              <Card>
                <CardHeader>
                  <CardTitle>Recent Recordings</CardTitle>
                  <CardDescription>Latest call recordings and evaluations</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {recent_recordings.length > 0 ? (
                      recent_recordings.map((recording) => (
                        <div
                          key={recording.id}
                          className="flex items-center justify-between space-x-4 border-b pb-3 last:border-0 last:pb-0"
                        >
                          <div className="flex-1 min-w-0">
                            <p className="text-sm font-medium truncate">{recording.user_name}</p>
                            <p className="text-xs text-muted-foreground truncate">
                              {recording.call_script_name}
                            </p>
                            <div className="flex items-center gap-2 mt-1">
                              {getStatusBadge(recording.status)}
                              <Badge variant="outline" className="text-xs">
                                {recording.language}
                              </Badge>
                            </div>
                          </div>
                          <div className="flex flex-col items-end gap-2">
                            {recording.overall_score && (
                              <div>{getScoreBadge(recording.overall_score, recording.score_color)}</div>
                            )}
                            <Button
                              size="sm"
                              variant="ghost"
                              onClick={() => router.visit(`/call_recordings/${recording.id}`)}
                            >
                              <EyeIcon className="h-4 w-4" />
                            </Button>
                          </div>
                        </div>
                      ))
                    ) : (
                      <p className="text-sm text-muted-foreground text-center py-4">
                        No recordings yet
                      </p>
                    )}
                  </div>
                  {recent_recordings.length > 0 && (
                    <Button
                      variant="outline"
                      className="w-full mt-4"
                      onClick={() => router.visit('/call_recordings')}
                    >
                      View All Recordings
                    </Button>
                  )}
                </CardContent>
              </Card>

              {/* Top Performers */}
              {can_view_operators && (
                <Card>
                  <CardHeader>
                    <CardTitle>Top Performers</CardTitle>
                    <CardDescription>Operators with highest average scores</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-4">
                      {top_performers.length > 0 ? (
                        top_performers.map((operator, index) => (
                          <div
                            key={operator.id}
                            className="flex items-center justify-between space-x-4 border-b pb-3 last:border-0 last:pb-0"
                          >
                            <div className="flex items-center gap-3 flex-1 min-w-0">
                              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary text-primary-foreground text-xs font-bold">
                                #{index + 1}
                              </div>
                              <div className="flex-1 min-w-0">
                                <p className="text-sm font-medium truncate">{operator.name}</p>
                                <p className="text-xs text-muted-foreground truncate">
                                  {operator.recordings_count} recordings
                                </p>
                              </div>
                            </div>
                            <div className="text-right">
                              <div className="text-lg font-bold text-primary">
                                {operator.avg_score}
                              </div>
                              <p className="text-xs text-muted-foreground">avg score</p>
                            </div>
                          </div>
                        ))
                      ) : (
                        <p className="text-sm text-muted-foreground text-center py-4">
                          No evaluations yet
                        </p>
                      )}
                    </div>
                  </CardContent>
                </Card>
              )}

              {/* Language Breakdown */}
              {!can_view_operators && (
                <Card>
                  <CardHeader>
                    <CardTitle>Language Breakdown</CardTitle>
                    <CardDescription>Recordings by language</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-4">
                      {Object.entries(language_breakdown).map(([language, count]) => (
                        <div key={language} className="flex items-center justify-between">
                          <span className="text-sm font-medium capitalize">{language}</span>
                          <div className="flex items-center gap-2">
                            <div className="w-32 bg-secondary rounded-full h-2">
                              <div
                                className="bg-primary h-2 rounded-full"
                                style={{
                                  width: `${(count / stats.total_recordings) * 100}%`,
                                }}
                              />
                            </div>
                            <span className="text-sm text-muted-foreground w-12 text-right">
                              {count}
                            </span>
                          </div>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
