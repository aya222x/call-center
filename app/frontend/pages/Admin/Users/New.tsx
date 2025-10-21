import { router } from '@inertiajs/react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import * as z from 'zod'

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { SidebarTrigger } from '@/components/ui/sidebar'
import { Separator } from '@/components/ui/separator'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from '@/components/ui/breadcrumb'

interface User {
  id: number
  name: string
  email: string
  owner: boolean
}

interface AdminUserNewProps {
  auth: {
    user: User
  }
  errors?: {
    name?: string[]
    email?: string[]
  }
}

const userSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters').max(100, 'Name must not exceed 100 characters'),
  email: z.string().email('Invalid email address'),
})

type UserFormData = z.infer<typeof userSchema>

export default function AdminUserNew({ auth, errors }: AdminUserNewProps) {
  const { register, handleSubmit, formState: { errors: formErrors, isSubmitting } } = useForm<UserFormData>({
    resolver: zodResolver(userSchema),
  })

  const onSubmit = (data: UserFormData) => {
    router.post('/admin/users', { user: data })
  }

  return (
    <>
      <header className="flex h-(--header-height) shrink-0 items-center gap-2 border-b transition-[width,height] ease-linear group-has-data-[collapsible=icon]/sidebar-wrapper:h-(--header-height)">
          <div className="flex w-full items-center gap-1 px-4 lg:gap-2 lg:px-6">
            <SidebarTrigger className="-ml-1" />
            <Separator orientation="vertical" className="mx-2 data-[orientation=vertical]:h-4" />
            <Breadcrumb>
              <BreadcrumbList>
                <BreadcrumbItem>
                  <BreadcrumbLink href="/admin/console">Owner Panel</BreadcrumbLink>
                </BreadcrumbItem>
                <BreadcrumbSeparator />
                <BreadcrumbItem>
                  <BreadcrumbLink href="/admin/users">Manage Users</BreadcrumbLink>
                </BreadcrumbItem>
                <BreadcrumbSeparator />
                <BreadcrumbItem>
                  <BreadcrumbPage>Invite User</BreadcrumbPage>
                </BreadcrumbItem>
              </BreadcrumbList>
            </Breadcrumb>
          </div>
        </header>

        <div className="flex flex-1 flex-col">
          <div className="@container/main flex flex-1 flex-col gap-2">
            <div className="flex flex-col gap-4 py-4 md:gap-6 md:py-6">
              <div className="px-4 lg:px-6">
                <Card className="from-primary/5 to-card bg-gradient-to-t shadow-xs max-w-2xl">
                  <CardHeader>
                    <CardTitle>Invite New User</CardTitle>
                    <CardDescription>Send an invitation email to a new user. They will set their own password.</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
                      <div className="space-y-2">
                        <Label htmlFor="name">Name</Label>
                        <Input
                          id="name"
                          type="text"
                          {...register('name')}
                        />
                        {formErrors.name && (
                          <p className="text-sm text-destructive">{formErrors.name.message}</p>
                        )}
                        {errors?.name && (
                          <p className="text-sm text-destructive">{errors.name[0]}</p>
                        )}
                      </div>

                      <div className="space-y-2">
                        <Label htmlFor="email">Email</Label>
                        <Input
                          id="email"
                          type="email"
                          {...register('email')}
                        />
                        {formErrors.email && (
                          <p className="text-sm text-destructive">{formErrors.email.message}</p>
                        )}
                        {errors?.email && (
                          <p className="text-sm text-destructive">{errors.email[0]}</p>
                        )}
                      </div>

                      <div className="flex justify-end gap-2 pt-4">
                        <Button
                          type="button"
                          variant="outline"
                          onClick={() => router.visit('/admin/users')}
                        >
                          Cancel
                        </Button>
                        <Button type="submit" disabled={isSubmitting}>
                          {isSubmitting ? 'Sending Invitation...' : 'Send Invitation'}
                        </Button>
                      </div>
                    </form>
                  </CardContent>
                </Card>
              </div>
            </div>
          </div>
        </div>
    </>
  )
}
