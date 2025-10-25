import React, { useState } from 'react'
import { router } from '@inertiajs/react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import * as z from 'zod'
import { UploadIcon } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Separator } from '@/components/ui/separator'
import { AppHeader } from '@/components/app-header'

interface User {
  id: number
  name: string
  email: string
  admin: boolean
  created_at: string
  avatar_url?: string | null
}

interface EditProfileProps {
  auth: {
    user: User
  }
  user: User
}

const profileEditSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters').max(100, 'Name must not exceed 100 characters'),
  email: z.string().email('Invalid email address'),
  password: z.string().optional(),
  password_confirmation: z.string().optional(),
}).refine((data) => {
  // If password is provided, it must be at least 8 characters
  if (data.password && data.password.length > 0 && data.password.length < 8) {
    return false
  }
  return true
}, {
  message: "Password must be at least 8 characters",
  path: ['password'],
}).refine((data) => {
  // If password is provided, confirmation must match
  if (data.password && data.password.length > 0) {
    return data.password === data.password_confirmation
  }
  return true
}, {
  message: "Passwords don't match",
  path: ['password_confirmation'],
})

type ProfileEditFormData = z.infer<typeof profileEditSchema>

export default function EditProfile({ user }: EditProfileProps) {
  const { register, handleSubmit, formState: { errors: formErrors, isSubmitting } } = useForm<ProfileEditFormData>({
    resolver: zodResolver(profileEditSchema),
    defaultValues: {
      name: user.name,
      email: user.email,
      password: '',
      password_confirmation: '',
    },
  })

  const [avatar, setAvatar] = useState<File | null>(null)
  const [avatarPreview, setAvatarPreview] = useState<string | null>(user.avatar_url || null)
  const [error, setError] = useState('')

  const getUserInitials = (name: string): string => {
    const parts = name.trim().split(/\s+/)
    if (parts.length >= 2) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
    }
    return name.substring(0, 2).toUpperCase()
  }

  const handleAvatarChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      setAvatar(file)
      const reader = new FileReader()
      reader.onloadend = () => {
        setAvatarPreview(reader.result as string)
      }
      reader.readAsDataURL(file)
    }
  }

  const onSubmit = async (data: ProfileEditFormData) => {
    setError('')

    try {
      const formDataToSend = new FormData()
      formDataToSend.append('user[name]', data.name)
      formDataToSend.append('user[email]', data.email)
      if (data.password && data.password.length > 0) {
        formDataToSend.append('user[password]', data.password)
        formDataToSend.append('user[password_confirmation]', data.password_confirmation || '')
      }
      if (avatar) {
        formDataToSend.append('user[avatar]', avatar)
      }

      const response = await fetch('/profile', {
        method: 'PATCH',
        headers: {
          'Accept': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
        },
        body: formDataToSend,
      })

      const responseData = await response.json()

      if (response.ok) {
        router.visit('/profile')
      } else {
        setError(responseData.errors?.join(', ') || 'Update failed')
      }
    } catch (err) {
      setError('An error occurred')
    }
  }

  return (
    <>
      <AppHeader
        breadcrumbs={[
          { label: 'Profile', href: '/profile' },
          { label: 'Edit' },
        ]}
      />

        <div className="flex flex-1 flex-col">
          <div className="@container/main flex flex-1 flex-col gap-2">
            <div className="flex flex-col gap-4 py-4 md:gap-6 md:py-6">
              <div className="px-4 lg:px-6">
          <Card className="from-primary/5 to-card bg-gradient-to-t shadow-xs">
            <CardHeader>
              <CardTitle>Edit Profile</CardTitle>
              <CardDescription>Update your account information</CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
                {error && (
                  <div className="rounded-md bg-destructive/15 p-3 text-sm text-destructive">
                    {error}
                  </div>
                )}

                <div className="flex items-center gap-6">
                  <Avatar className="size-24">
                    <AvatarImage src={avatarPreview || undefined} alt={user.name} />
                    <AvatarFallback className="text-2xl">{getUserInitials(user.name)}</AvatarFallback>
                  </Avatar>
                  <div className="space-y-2">
                    <Label htmlFor="avatar" className="cursor-pointer">
                      <div className="flex items-center gap-2 rounded-md border border-input bg-background px-4 py-2 hover:bg-accent hover:text-accent-foreground">
                        <UploadIcon className="size-4" />
                        <span>Upload Avatar</span>
                      </div>
                      <Input
                        id="avatar"
                        type="file"
                        accept="image/png,image/jpg,image/jpeg,image/gif"
                        onChange={handleAvatarChange}
                        className="hidden"
                      />
                    </Label>
                    <p className="text-xs text-muted-foreground">
                      PNG, JPG, or GIF. Max 5MB.
                    </p>
                  </div>
                </div>

                <Separator />

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
                </div>

                <div className="space-y-2">
                  <Label htmlFor="password">New Password (leave blank to keep current)</Label>
                  <Input
                    id="password"
                    type="password"
                    {...register('password')}
                  />
                  {formErrors.password && (
                    <p className="text-sm text-destructive">{formErrors.password.message}</p>
                  )}
                </div>

                <div className="space-y-2">
                  <Label htmlFor="password_confirmation">Confirm New Password</Label>
                  <Input
                    id="password_confirmation"
                    type="password"
                    {...register('password_confirmation')}
                  />
                  {formErrors.password_confirmation && (
                    <p className="text-sm text-destructive">{formErrors.password_confirmation.message}</p>
                  )}
                </div>

                <div className="flex gap-4">
                  <Button type="submit" disabled={isSubmitting}>
                    {isSubmitting ? 'Saving...' : 'Save Changes'}
                  </Button>
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => router.visit('/profile')}
                  >
                    Cancel
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
