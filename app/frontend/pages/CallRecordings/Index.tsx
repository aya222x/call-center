import { router } from '@inertiajs/react'
import { useState } from 'react'
import {
  PhoneIcon,
  PlusIcon,
  EyeIcon,
  FilterIcon,
} from 'lucide-react'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Badge } from '@/components/ui/badge'

interface User {
  id: number
  name: string
  email: string
}

interface CallScript {
  id: number
  name: string
  call_type: string
}

interface Recording {
  id: number
  user: User
  call_script: CallScript
  status: string
  language: string
  call_date: string
  duration: string
  customer_name: string | null
  customer_phone: string | null
  overall_score: number | null
  score_label: string | null
  score_color: string | null
  created_at: string
}

interface Pagination {
  page: number
  pages: number
  count: number
  from: number
  to: number
}

interface Filters {
  search?: string | null
  status?: string
  language?: string
  date_from?: string | null
  date_to?: string | null
}

interface CallRecordingsIndexProps {
  recordings: Recording[]
  pagination: Pagination
  filters: Filters
  statuses: string[]
  languages: string[]
  can_create: boolean
}

export default function CallRecordingsIndex({
  recordings,
  pagination,
  filters,
  statuses,
  languages,
  can_create,
}: CallRecordingsIndexProps) {
  const [searchTerm, setSearchTerm] = useState(filters.search || '')

  const handleFilter = (key: string, value: string) => {
    router.get(
      '/call_recordings',
      {
        ...filters,
        [key]: value === 'all' ? undefined : value,
        page: 1,
      },
      {
        preserveState: true,
        preserveScroll: true,
      }
    )
  }

  const handleSearch = () => {
    router.get(
      '/call_recordings',
      {
        ...filters,
        search: searchTerm || undefined,
        page: 1,
      },
      {
        preserveState: true,
        preserveScroll: true,
      }
    )
  }

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

  const getScoreBadge = (score: number | null, label: string | null, color: string | null) => {
    if (!score) return null

    const colorMap: Record<string, string> = {
      green: 'bg-green-100 text-green-800',
      yellow: 'bg-yellow-100 text-yellow-800',
      orange: 'bg-orange-100 text-orange-800',
      red: 'bg-red-100 text-red-800',
    }

    return (
      <div className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${colorMap[color || 'green'] || colorMap.green}`}>
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
            <div className="flex items-center justify-between mb-6">
              <div>
                <h1 className="text-2xl font-bold">Call Recordings</h1>
                <p className="text-sm text-muted-foreground mt-1">
                  {pagination.count} total recordings
                </p>
              </div>
              {can_create && (
                <Button onClick={() => router.visit('/call_recordings/new')}>
                  <PlusIcon className="mr-2 h-4 w-4" />
                  Upload Recording
                </Button>
              )}
            </div>

            {/* Filters */}
            <Card className="mb-6">
              <CardContent className="pt-6">
                <div className="grid gap-4 md:grid-cols-4">
                  <div>
                    <Input
                      placeholder="Search customer..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
                    />
                  </div>
                  <div>
                    <Select
                      value={filters.status || 'all'}
                      onValueChange={(value) => handleFilter('status', value)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Status" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">All Statuses</SelectItem>
                        {statuses.map((status) => (
                          <SelectItem key={status} value={status}>
                            {status}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div>
                    <Select
                      value={filters.language || 'all'}
                      onValueChange={(value) => handleFilter('language', value)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Language" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">All Languages</SelectItem>
                        {languages.map((lang) => (
                          <SelectItem key={lang} value={lang}>
                            {lang}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <Button variant="outline" onClick={handleSearch}>
                    <FilterIcon className="mr-2 h-4 w-4" />
                    Apply
                  </Button>
                </div>
              </CardContent>
            </Card>

            {/* Table */}
            <Card>
              <CardContent className="p-0">
                <div className="overflow-x-auto">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Operator</TableHead>
                        <TableHead>Customer</TableHead>
                        <TableHead>Date</TableHead>
                        <TableHead>Duration</TableHead>
                        <TableHead>Language</TableHead>
                        <TableHead>Status</TableHead>
                        <TableHead>Score</TableHead>
                        <TableHead className="text-right">Actions</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {recordings.length === 0 ? (
                        <TableRow>
                          <TableCell colSpan={8} className="text-center py-8 text-muted-foreground">
                            No recordings found
                          </TableCell>
                        </TableRow>
                      ) : (
                        recordings.map((recording) => (
                          <TableRow key={recording.id}>
                            <TableCell>
                              <div>
                                <div className="font-medium">{recording.user.name}</div>
                                <div className="text-sm text-muted-foreground">
                                  {recording.call_script.name}
                                </div>
                              </div>
                            </TableCell>
                            <TableCell>
                              <div>
                                <div className="font-medium">
                                  {recording.customer_name || '-'}
                                </div>
                                <div className="text-sm text-muted-foreground">
                                  {recording.customer_phone || '-'}
                                </div>
                              </div>
                            </TableCell>
                            <TableCell>
                              {new Date(recording.call_date).toLocaleDateString()}
                            </TableCell>
                            <TableCell>{recording.duration}</TableCell>
                            <TableCell>
                              <Badge variant="outline">{recording.language}</Badge>
                            </TableCell>
                            <TableCell>{getStatusBadge(recording.status)}</TableCell>
                            <TableCell>
                              {getScoreBadge(
                                recording.overall_score,
                                recording.score_label,
                                recording.score_color
                              )}
                            </TableCell>
                            <TableCell className="text-right">
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => router.visit(`/call_recordings/${recording.id}`)}
                              >
                                <EyeIcon className="h-4 w-4" />
                              </Button>
                            </TableCell>
                          </TableRow>
                        ))
                      )}
                    </TableBody>
                  </Table>
                </div>
              </CardContent>
            </Card>

            {/* Pagination */}
            {pagination.pages > 1 && (
              <div className="mt-4 flex justify-center">
                <div className="flex gap-2">
                  {pagination.page > 1 && (
                    <Button
                      variant="outline"
                      onClick={() =>
                        router.get('/call_recordings', { ...filters, page: pagination.page - 1 })
                      }
                    >
                      Previous
                    </Button>
                  )}
                  <div className="flex items-center px-4">
                    Page {pagination.page} of {pagination.pages}
                  </div>
                  {pagination.page < pagination.pages && (
                    <Button
                      variant="outline"
                      onClick={() =>
                        router.get('/call_recordings', { ...filters, page: pagination.page + 1 })
                      }
                    >
                      Next
                    </Button>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
