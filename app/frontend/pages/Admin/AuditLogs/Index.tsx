import { router } from '@inertiajs/react'
import { useState, useEffect } from 'react'

import {
  ChevronDownIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  ChevronUpIcon,
  FileTextIcon,
  SearchIcon,
  XIcon,
} from 'lucide-react'

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Pagination, PaginationContent, PaginationEllipsis, PaginationItem } from '@/components/ui/pagination'
import { AppHeader } from '@/components/app-header'
import { DateRangePicker } from '@/components/date-range-picker'

import { cn } from '@/lib/utils'

interface AuditLog {
  id: number
  action: string
  auditable_type: string
  auditable_id: number
  user_id: number | null
  user_name: string
  user_email: string | null
  audited_changes: Record<string, any>
  created_at: string
  remote_address: string | null
}

interface User {
  id: number
  name: string
  email: string
  role: string
  admin: boolean
}

interface Filters {
  search?: string
  action_filter?: string
  created_from?: string | null
  created_to?: string | null
  sort_column?: string
  sort_direction?: string
}

interface Pagination {
  page: number
  pages: number
  count: number
  from: number
  to: number
  prev: number | null
  next: number | null
}

interface AdminAuditLogsIndexProps {
  auth: {
    user: User
  }
  audits: AuditLog[]
  pagination: Pagination
  filters: Filters
}

// Removed separate filter component - filters are now inline in the main component for consistency with Admin Users

export default function AdminAuditLogsIndex({
  audits,
  pagination,
  filters,
}: AdminAuditLogsIndexProps) {
  const [searchTerm, setSearchTerm] = useState(filters.search || '')

  // Debounced search with 300ms delay
  // IMPORTANT: Uses 'only' parameter to prevent shared props from updating,
  // which maintains input focus during typing. See Admin Users for pattern.
  useEffect(() => {
    const timer = setTimeout(() => {
      // Normalize comparison: treat null/undefined as empty string
      const currentFilter = filters.search || ''
      if (searchTerm !== currentFilter) {
        handleSearch(searchTerm)
      }
    }, 300)

    return () => clearTimeout(timer)
  }, [searchTerm])

  const handleSearch = (search: string) => {
    router.get('/admin/audit_logs', {
      search: search || undefined,
      action_filter: filters.action_filter,
      created_from: filters.created_from,
      created_to: filters.created_to,
      sort_column: filters.sort_column,
      sort_direction: filters.sort_direction,
    }, {
      preserveState: true,
      preserveScroll: true,
      only: ['audits', 'pagination', 'filters'],
    })
  }

  const handleActionFilter = (value: string) => {
    router.get('/admin/audit_logs', {
      search: searchTerm || undefined,
      action_filter: value === 'all' ? undefined : value,
      created_from: filters.created_from,
      created_to: filters.created_to,
      sort_column: filters.sort_column,
      sort_direction: filters.sort_direction,
    }, {
      preserveState: true,
      preserveScroll: true,
      only: ['audits', 'pagination', 'filters'],
    })
  }

  const handleDateRangeChange = (range?: { from?: string; to?: string }) => {
    router.get('/admin/audit_logs', {
      search: searchTerm || undefined,
      action_filter: filters.action_filter,
      created_from: range?.from || undefined,
      created_to: range?.to || undefined,
      sort_column: filters.sort_column,
      sort_direction: filters.sort_direction,
    }, {
      preserveState: true,
      preserveScroll: true,
      only: ['audits', 'pagination', 'filters'],
    })
  }

  const handleSort = (column: string) => {
    const isCurrentColumn = filters.sort_column === column
    const newDirection = isCurrentColumn && filters.sort_direction === 'asc' ? 'desc' : 'asc'

    router.get('/admin/audit_logs', {
      search: searchTerm || undefined,
      action_filter: filters.action_filter,
      created_from: filters.created_from,
      created_to: filters.created_to,
      sort_column: column,
      sort_direction: newDirection,
    }, {
      preserveState: true,
      preserveScroll: true,
      only: ['audits', 'pagination', 'filters'],
    })
  }

  const handlePageChange = (page: number) => {
    router.get('/admin/audit_logs', {
      search: searchTerm || undefined,
      action_filter: filters.action_filter,
      created_from: filters.created_from,
      created_to: filters.created_to,
      sort_column: filters.sort_column,
      sort_direction: filters.sort_direction,
      page,
    }, {
      preserveState: true,
      preserveScroll: true,
      only: ['audits', 'pagination', 'filters'],
    })
  }

  const getSortIcon = (column: string) => {
    if (filters.sort_column !== column) return null

    return filters.sort_direction === 'asc' ? (
      <ChevronUpIcon className="shrink-0 opacity-60" size={16} aria-hidden="true" />
    ) : (
      <ChevronDownIcon className="shrink-0 opacity-60" size={16} aria-hidden="true" />
    )
  }

  const getActionBadge = (action: string) => {
    const badges = {
      create: { variant: 'default' as const, label: 'Created', color: 'bg-green-600/10 text-green-600 dark:bg-green-400/10 dark:text-green-400' },
      update: { variant: 'secondary' as const, label: 'Updated', color: 'bg-blue-600/10 text-blue-600 dark:bg-blue-400/10 dark:text-blue-400' },
      destroy: { variant: 'destructive' as const, label: 'Deleted', color: 'bg-destructive/10 text-destructive' },
    }

    const badge = badges[action as keyof typeof badges] || { variant: 'outline' as const, label: action, color: '' }

    return (
      <Badge className={cn('border-none capitalize focus-visible:outline-none', badge.color)}>
        {badge.label}
      </Badge>
    )
  }

  const renderChanges = (changes: Record<string, any>) => {
    const changeKeys = Object.keys(changes).filter(key => key !== 'password_digest' && key !== 'updated_at')

    if (changeKeys.length === 0) return <span className="text-muted-foreground text-sm">No changes</span>

    return (
      <div className="text-sm space-y-1">
        {changeKeys.slice(0, 3).map((key) => (
          <div key={key} className="text-muted-foreground">
            <span className="font-medium">{key}:</span>{' '}
            {Array.isArray(changes[key]) ? (
              <>
                <span className="text-destructive line-through">{String(changes[key][0])}</span>
                {' → '}
                <span className="text-green-600 dark:text-green-400">{String(changes[key][1])}</span>
              </>
            ) : (
              String(changes[key])
            )}
          </div>
        ))}
        {changeKeys.length > 3 && (
          <div className="text-muted-foreground text-xs">+{changeKeys.length - 3} more changes</div>
        )}
      </div>
    )
  }

  const renderPagination = () => {
    if (pagination.pages <= 1) return null

    const pages = []
    const maxPagesToShow = 5
    let startPage = Math.max(1, pagination.page - Math.floor(maxPagesToShow / 2))
    let endPage = Math.min(pagination.pages, startPage + maxPagesToShow - 1)

    if (endPage - startPage < maxPagesToShow - 1) {
      startPage = Math.max(1, endPage - maxPagesToShow + 1)
    }

    for (let i = startPage; i <= endPage; i++) {
      pages.push(i)
    }

    return (
      <Pagination>
        <PaginationContent>
          <PaginationItem>
            <Button
              className="disabled:pointer-events-none disabled:opacity-50"
              variant="ghost"
              onClick={() => handlePageChange(pagination.page - 1)}
              disabled={!pagination.prev}
              aria-label="Go to previous page"
            >
              <ChevronLeftIcon size={16} aria-hidden="true" />
              Previous
            </Button>
          </PaginationItem>

          {startPage > 1 && (
            <PaginationItem>
              <PaginationEllipsis />
            </PaginationItem>
          )}

          {pages.map((page) => {
            const isActive = page === pagination.page

            return (
              <PaginationItem key={page}>
                <Button
                  size="icon"
                  className={`${!isActive && 'bg-primary/10 text-primary hover:bg-primary/20 focus-visible:ring-primary/20 dark:focus-visible:ring-primary/40'}`}
                  onClick={() => handlePageChange(page)}
                  aria-current={isActive ? 'page' : undefined}
                >
                  {page}
                </Button>
              </PaginationItem>
            )
          })}

          {endPage < pagination.pages && (
            <PaginationItem>
              <PaginationEllipsis />
            </PaginationItem>
          )}

          <PaginationItem>
            <Button
              className="disabled:pointer-events-none disabled:opacity-50"
              variant="ghost"
              onClick={() => handlePageChange(pagination.page + 1)}
              disabled={!pagination.next}
              aria-label="Go to next page"
            >
              Next
              <ChevronRightIcon size={16} aria-hidden="true" />
            </Button>
          </PaginationItem>
        </PaginationContent>
      </Pagination>
    )
  }

  return (
    <>
      <AppHeader
        breadcrumbs={[
          { label: 'Admin Panel', href: '/admin/console' },
          { label: 'Audit Logs' },
        ]}
      />

        <div className="flex flex-1 flex-col">
          <div className="@container/main flex flex-1 flex-col gap-2">
            <div className="flex flex-col gap-4 py-4 md:gap-6 md:py-6">
              <div className="px-4 lg:px-6">
                <Card className="from-primary/5 to-card bg-gradient-to-t shadow-xs">
                  <CardHeader>
                    <CardTitle>Audit Logs ({pagination.count})</CardTitle>
                  </CardHeader>
                  <CardContent className="p-0">
                    <div className="w-full">
                      <div className="border-b">
                        <div className="flex flex-col gap-4 p-6">
                          <span className="text-xl font-semibold">Filter Logs</span>
                          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 [&>*]:min-w-0">
                            <div className="w-full space-y-2 min-w-0">
                              <Label htmlFor="search">Search by User Name or Email</Label>
                              <div className="relative">
                                <SearchIcon className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
                                <Input
                                  id="search"
                                  type="text"
                                  placeholder="Search audit logs..."
                                  value={searchTerm}
                                  onChange={(e) => setSearchTerm(e.target.value)}
                                  className="pl-9 pr-9"
                                />
                                {searchTerm && (
                                  <button
                                    type="button"
                                    onClick={() => setSearchTerm('')}
                                    className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                                  >
                                    <XIcon className="size-4" />
                                  </button>
                                )}
                              </div>
                            </div>

                            <div className="w-full space-y-2 min-w-0">
                              <Label htmlFor="action-filter">Select Action</Label>
                              <Select value={filters.action_filter || 'all'} onValueChange={handleActionFilter}>
                                <SelectTrigger id="action-filter" className="w-full capitalize">
                                  <SelectValue placeholder="Select Action" />
                                </SelectTrigger>
                                <SelectContent>
                                  <SelectItem value="all">All</SelectItem>
                                  <SelectItem value="create">Created</SelectItem>
                                  <SelectItem value="update">Updated</SelectItem>
                                  <SelectItem value="destroy">Deleted</SelectItem>
                                </SelectContent>
                              </Select>
                            </div>

                            <div className="w-full space-y-2 min-w-0">
                              <Label htmlFor="date-range">Filter by Creation Date</Label>
                              <DateRangePicker
                                value={{
                                  from: filters.created_from || undefined,
                                  to: filters.created_to || undefined,
                                }}
                                onChange={handleDateRangeChange}
                                placeholder="Pick a date range"
                              />
                            </div>
                          </div>
                        </div>
                        <Table>
                          <TableHeader>
                            <TableRow className="h-14 border-t">
                              <TableHead className="text-muted-foreground first:pl-4">
                                <div
                                  className="flex h-full cursor-pointer items-center justify-between gap-2 select-none"
                                  onClick={() => handleSort('created_at')}
                                  onKeyDown={(e) => {
                                    if (e.key === 'Enter' || e.key === ' ') {
                                      e.preventDefault()
                                      handleSort('created_at')
                                    }
                                  }}
                                  tabIndex={0}
                                >
                                  Timestamp
                                  {getSortIcon('created_at')}
                                </div>
                              </TableHead>
                              <TableHead className="text-muted-foreground">
                                <div
                                  className="flex h-full cursor-pointer items-center justify-between gap-2 select-none"
                                  onClick={() => handleSort('action')}
                                  onKeyDown={(e) => {
                                    if (e.key === 'Enter' || e.key === ' ') {
                                      e.preventDefault()
                                      handleSort('action')
                                    }
                                  }}
                                  tabIndex={0}
                                >
                                  Action
                                  {getSortIcon('action')}
                                </div>
                              </TableHead>
                              <TableHead className="text-muted-foreground">User</TableHead>
                              <TableHead className="text-muted-foreground">Resource</TableHead>
                              <TableHead className="text-muted-foreground">Changes</TableHead>
                            </TableRow>
                          </TableHeader>
                          <TableBody>
                            {audits.length > 0 ? (
                              audits.map((audit) => (
                                <TableRow key={audit.id} className="hover:bg-transparent">
                                  <TableCell className="h-14 first:pl-4">
                                    <div className="flex flex-col">
                                      <span className="font-medium">
                                        {new Date(audit.created_at).toLocaleDateString()}
                                      </span>
                                      <span className="text-muted-foreground text-xs">
                                        {new Date(audit.created_at).toLocaleTimeString()}
                                      </span>
                                    </div>
                                  </TableCell>
                                  <TableCell className="h-14">{getActionBadge(audit.action)}</TableCell>
                                  <TableCell className="h-14">
                                    <div className="flex flex-col">
                                      <span className="font-medium">{audit.user_name}</span>
                                      {audit.user_email && (
                                        <span className="text-muted-foreground text-xs">{audit.user_email}</span>
                                      )}
                                    </div>
                                  </TableCell>
                                  <TableCell className="h-14">
                                    <div className="flex items-center gap-2">
                                      <FileTextIcon className="size-4 text-muted-foreground" />
                                      <span className="text-muted-foreground">
                                        {audit.auditable_type} #{audit.auditable_id}
                                      </span>
                                    </div>
                                  </TableCell>
                                  <TableCell className="h-14">{renderChanges(audit.audited_changes)}</TableCell>
                                </TableRow>
                              ))
                            ) : (
                              <TableRow>
                                <TableCell colSpan={5} className="h-24 text-center">
                                  No audit logs found.
                                </TableCell>
                              </TableRow>
                            )}
                          </TableBody>
                        </Table>
                      </div>

                      <div className="flex items-center justify-between gap-3 px-6 py-4 max-sm:flex-col md:max-lg:flex-col">
                        <p className="text-muted-foreground text-sm whitespace-nowrap" aria-live="polite">
                          Showing <span>{pagination.from || 0}</span> to <span>{pagination.to || 0}</span> of{' '}
                          <span>{pagination.count} logs</span>
                        </p>

                        <div>{renderPagination()}</div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </div>
            </div>
          </div>
        </div>
    </>
  )
}
