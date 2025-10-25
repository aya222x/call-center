import { useState } from 'react'
import { router } from '@inertiajs/react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import * as z from 'zod'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'

interface ResetPasswordProps {
  token?: string
}

const resetPasswordSchema = z.object({
  password: z.string().min(8, 'Password must be at least 8 characters'),
  password_confirmation: z.string().min(8, 'Password confirmation must be at least 8 characters'),
}).refine((data) => data.password === data.password_confirmation, {
  message: "Passwords don't match",
  path: ['password_confirmation'],
})

type ResetPasswordFormData = z.infer<typeof resetPasswordSchema>

export default function ResetPassword({ token }: ResetPasswordProps) {
  const { register, handleSubmit, formState: { errors: formErrors, isSubmitting }, reset } = useForm<ResetPasswordFormData>({
    resolver: zodResolver(resetPasswordSchema),
  })

  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  const onSubmit = async (data: ResetPasswordFormData) => {
    setError('')
    setSuccess('')

    try {
      const response = await fetch('/password/reset', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({
          token,
          ...data,
        }),
      })

      const responseData = await response.json()

      if (response.ok) {
        setSuccess(responseData.message || 'Password has been reset successfully')
        reset()

        // Redirect to login after 2 seconds
        setTimeout(() => {
          router.visit('/login')
        }, 2000)
      } else {
        setError(responseData.error || 'Failed to reset password')
      }
    } catch (err) {
      setError('An error occurred. Please try again.')
    }
  }

  if (!token) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-muted/50">
        <Card className="w-full max-w-md">
          <CardHeader className="text-center">
            <CardTitle className="text-2xl">Invalid Reset Link</CardTitle>
            <CardDescription>
              This password reset link is invalid or has expired
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="text-center">
              <a href="/password/forgot" className="text-primary hover:underline">
                Request a new reset link
              </a>
            </div>
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-muted/50">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <CardTitle className="text-2xl">Reset Your Password</CardTitle>
          <CardDescription>
            Enter your new password below
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            {error && (
              <div className="rounded-md bg-destructive/15 p-3 text-sm text-destructive">
                {error}
              </div>
            )}

            {success && (
              <div className="rounded-md bg-green-500/15 p-3 text-sm text-green-600 dark:text-green-400">
                {success}
                <div className="mt-1 text-xs">Redirecting to login...</div>
              </div>
            )}

            <div className="space-y-2">
              <Label htmlFor="password">New Password</Label>
              <Input
                id="password"
                type="password"
                placeholder="••••••••"
                {...register('password')}
                disabled={!!success}
              />
              {formErrors.password && (
                <p className="text-sm text-destructive">{formErrors.password.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="password_confirmation">Confirm Password</Label>
              <Input
                id="password_confirmation"
                type="password"
                placeholder="••••••••"
                {...register('password_confirmation')}
                disabled={!!success}
              />
              {formErrors.password_confirmation && (
                <p className="text-sm text-destructive">{formErrors.password_confirmation.message}</p>
              )}
            </div>

            <Button type="submit" className="w-full" disabled={isSubmitting || !!success}>
              {isSubmitting ? 'Resetting...' : 'Reset Password'}
            </Button>

            <div className="text-center text-sm">
              <a href="/login" className="text-muted-foreground hover:text-primary">
                Back to login
              </a>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  )
}
