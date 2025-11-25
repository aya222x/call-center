import { router } from '@inertiajs/react'
import { ArrowLeftIcon, PlayCircleIcon } from 'lucide-react'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'

interface Recording {
  id: number
  user: { name: string; email: string }
  call_script: { name: string; call_type: string }
  status: string
  language: string
  call_date: string
  duration: string
  customer_name: string | null
  customer_phone: string | null
  transcript: string | null
  error_message: string | null
  has_audio: boolean
  audio_url: string | null
}

interface Evaluation {
  overall_score: number
  script_adherence_score: number | null
  politeness_score: number | null
  resolution_speed_score: number | null
  terminology_score: number | null
  success_score: number | null
  recommendations: string | null
  score_label: string
  score_color: string
}

interface CallRecordingShowProps {
  recording: Recording
  evaluation: Evaluation | null
  can_update: boolean
  can_delete: boolean
}

export default function CallRecordingShow({
  recording,
  evaluation,
  can_update,
  can_delete,
}: CallRecordingShowProps) {
  const getScoreColor = (color: string) => {
    const colors: Record<string, string> = {
      green: 'text-green-600',
      yellow: 'text-yellow-600',
      orange: 'text-orange-600',
      red: 'text-red-600',
    }
    return colors[color] || colors.green
  }

  const getProgressColor = (score: number) => {
    if (score >= 80) return 'bg-green-500'
    if (score >= 60) return 'bg-yellow-500'
    if (score >= 40) return 'bg-orange-500'
    return 'bg-red-500'
  }

  return (
    <div className="flex flex-1 flex-col">
      <div className="@container/main flex flex-1 flex-col gap-2">
        <div className="flex flex-col gap-4 py-4 md:gap-6 md:py-6">
          <div className="px-4 lg:px-6">
            {/* Header */}
            <div className="mb-6">
              <Button
                variant="ghost"
                size="sm"
                onClick={() => router.visit('/call-recordings')}
                className="mb-4"
              >
                <ArrowLeftIcon className="mr-2 h-4 w-4" />
                Back to Recordings
              </Button>
              <h1 className="text-2xl font-bold">Call Recording #{recording.id}</h1>
            </div>

            <div className="grid gap-6 md:grid-cols-2">
              {/* Recording Details */}
              <Card>
                <CardHeader>
                  <CardTitle>Recording Details</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <div className="text-sm font-medium text-muted-foreground">Operator</div>
                    <div className="mt-1">{recording.user.name}</div>
                    <div className="text-sm text-muted-foreground">{recording.user.email}</div>
                  </div>

                  <div>
                    <div className="text-sm font-medium text-muted-foreground">Call Script</div>
                    <div className="mt-1">{recording.call_script.name}</div>
                    <Badge variant="outline" className="mt-1">
                      {recording.call_script.call_type}
                    </Badge>
                  </div>

                  <div>
                    <div className="text-sm font-medium text-muted-foreground">Customer</div>
                    <div className="mt-1">{recording.customer_name || 'N/A'}</div>
                    <div className="text-sm text-muted-foreground">
                      {recording.customer_phone || 'N/A'}
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <div className="text-sm font-medium text-muted-foreground">Date</div>
                      <div className="mt-1">
                        {new Date(recording.call_date).toLocaleDateString()}
                      </div>
                    </div>
                    <div>
                      <div className="text-sm font-medium text-muted-foreground">Duration</div>
                      <div className="mt-1">{recording.duration}</div>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <div className="text-sm font-medium text-muted-foreground">Language</div>
                      <Badge variant="outline" className="mt-1">
                        {recording.language}
                      </Badge>
                    </div>
                    <div>
                      <div className="text-sm font-medium text-muted-foreground">Status</div>
                      <Badge className="mt-1">{recording.status}</Badge>
                    </div>
                  </div>

                  {recording.has_audio && recording.audio_url && (
                    <div>
                      <div className="text-sm font-medium text-muted-foreground mb-2">
                        Audio Recording
                      </div>
                      <audio controls className="w-full">
                        <source src={recording.audio_url} type="audio/mpeg" />
                        Your browser does not support the audio element.
                      </audio>
                    </div>
                  )}
                </CardContent>
              </Card>

              {/* Evaluation */}
              {evaluation ? (
                <Card>
                  <CardHeader>
                    <CardTitle>AI Evaluation</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    <div className="text-center">
                      <div
                        className={`text-5xl font-bold ${getScoreColor(evaluation.score_color)}`}
                      >
                        {evaluation.overall_score}/100
                      </div>
                      <div className="text-lg font-medium mt-2">{evaluation.score_label}</div>
                    </div>

                    <div className="space-y-4">
                      {evaluation.script_adherence_score !== null && (
                        <div>
                          <div className="flex justify-between text-sm mb-2">
                            <span>Script Adherence</span>
                            <span className="font-medium">
                              {evaluation.script_adherence_score}/100
                            </span>
                          </div>
                          <Progress
                            value={evaluation.script_adherence_score}
                            className="h-2"
                          />
                        </div>
                      )}

                      {evaluation.politeness_score !== null && (
                        <div>
                          <div className="flex justify-between text-sm mb-2">
                            <span>Politeness & Tone</span>
                            <span className="font-medium">{evaluation.politeness_score}/100</span>
                          </div>
                          <Progress value={evaluation.politeness_score} className="h-2" />
                        </div>
                      )}

                      {evaluation.resolution_speed_score !== null && (
                        <div>
                          <div className="flex justify-between text-sm mb-2">
                            <span>Resolution Speed</span>
                            <span className="font-medium">
                              {evaluation.resolution_speed_score}/100
                            </span>
                          </div>
                          <Progress value={evaluation.resolution_speed_score} className="h-2" />
                        </div>
                      )}

                      {evaluation.terminology_score !== null && (
                        <div>
                          <div className="flex justify-between text-sm mb-2">
                            <span>Terminology</span>
                            <span className="font-medium">{evaluation.terminology_score}/100</span>
                          </div>
                          <Progress value={evaluation.terminology_score} className="h-2" />
                        </div>
                      )}

                      {evaluation.success_score !== null && (
                        <div>
                          <div className="flex justify-between text-sm mb-2">
                            <span>Call Success</span>
                            <span className="font-medium">{evaluation.success_score}/100</span>
                          </div>
                          <Progress value={evaluation.success_score} className="h-2" />
                        </div>
                      )}
                    </div>

                    {evaluation.recommendations && (
                      <div className="pt-4 border-t">
                        <div className="text-sm font-medium mb-2">Recommendations</div>
                        <p className="text-sm text-muted-foreground">
                          {evaluation.recommendations}
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              ) : (
                <Card>
                  <CardHeader>
                    <CardTitle>Evaluation</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="text-center py-8 text-muted-foreground">
                      {recording.status === 'failed' ? (
                        <>
                          <p className="mb-2">Evaluation failed</p>
                          {recording.error_message && (
                            <p className="text-sm text-red-600">{recording.error_message}</p>
                          )}
                        </>
                      ) : recording.status === 'completed' ? (
                        <p>No evaluation available</p>
                      ) : (
                        <p>Evaluation in progress...</p>
                      )}
                    </div>
                  </CardContent>
                </Card>
              )}
            </div>

            {/* Transcript */}
            {recording.transcript && (
              <Card className="mt-6">
                <CardHeader>
                  <CardTitle>Transcript</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="prose max-w-none">
                    <p className="whitespace-pre-wrap">{recording.transcript}</p>
                  </div>
                </CardContent>
              </Card>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
