import { router } from '@inertiajs/react'
import { FileTextIcon, PlusIcon, EyeIcon } from 'lucide-react'

import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Badge } from '@/components/ui/badge'

interface Department {
  id: number
  name: string
}

interface Script {
  id: number
  name: string
  call_type: string
  department: Department
  active: boolean
  created_at: string
}

interface Filters {
  department_id?: string | null
  call_type?: string
  active?: string | null
}

interface CallScriptsIndexProps {
  scripts: Script[]
  departments: Department[]
  call_types: string[]
  filters: Filters
  can_create: boolean
}

export default function CallScriptsIndex({
  scripts,
  departments,
  call_types,
  filters,
  can_create,
}: CallScriptsIndexProps) {
  const handleFilter = (key: string, value: string) => {
    router.get(
      '/call_scripts',
      {
        ...filters,
        [key]: value === 'all' ? undefined : value,
      },
      {
        preserveState: true,
        preserveScroll: true,
      }
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
                <h1 className="text-2xl font-bold">Call Scripts</h1>
                <p className="text-sm text-muted-foreground mt-1">
                  {scripts.length} total scripts
                </p>
              </div>
              {can_create && (
                <Button onClick={() => router.visit('/call_scripts/new')}>
                  <PlusIcon className="mr-2 h-4 w-4" />
                  Create Script
                </Button>
              )}
            </div>

            {/* Filters */}
            <Card className="mb-6">
              <CardContent className="pt-6">
                <div className="grid gap-4 md:grid-cols-3">
                  <div>
                    <Select
                      value={filters.department_id || 'all'}
                      onValueChange={(value) => handleFilter('department_id', value)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Department" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">All Departments</SelectItem>
                        {departments.map((dept) => (
                          <SelectItem key={dept.id} value={dept.id.toString()}>
                            {dept.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div>
                    <Select
                      value={filters.call_type || 'all'}
                      onValueChange={(value) => handleFilter('call_type', value)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Call Type" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">All Types</SelectItem>
                        {call_types.map((type) => (
                          <SelectItem key={type} value={type}>
                            {type}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div>
                    <Select
                      value={filters.active || 'all'}
                      onValueChange={(value) => handleFilter('active', value)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Status" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">All Status</SelectItem>
                        <SelectItem value="true">Active</SelectItem>
                        <SelectItem value="false">Inactive</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
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
                        <TableHead>Name</TableHead>
                        <TableHead>Department</TableHead>
                        <TableHead>Call Type</TableHead>
                        <TableHead>Status</TableHead>
                        <TableHead>Created</TableHead>
                        <TableHead className="text-right">Actions</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {scripts.length === 0 ? (
                        <TableRow>
                          <TableCell colSpan={6} className="text-center py-8 text-muted-foreground">
                            No call scripts found
                          </TableCell>
                        </TableRow>
                      ) : (
                        scripts.map((script) => (
                          <TableRow key={script.id}>
                            <TableCell>
                              <div className="font-medium">{script.name}</div>
                            </TableCell>
                            <TableCell>{script.department.name}</TableCell>
                            <TableCell>
                              <Badge variant="outline" className="capitalize">
                                {script.call_type}
                              </Badge>
                            </TableCell>
                            <TableCell>
                              <Badge variant={script.active ? 'default' : 'secondary'}>
                                {script.active ? 'Active' : 'Inactive'}
                              </Badge>
                            </TableCell>
                            <TableCell>
                              {new Date(script.created_at).toLocaleDateString()}
                            </TableCell>
                            <TableCell className="text-right">
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => router.visit(`/call_scripts/${script.id}`)}
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
          </div>
        </div>
      </div>
    </div>
  )
}
