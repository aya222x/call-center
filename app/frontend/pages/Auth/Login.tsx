import { useState, useEffect } from 'react'
import { router } from '@inertiajs/react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import * as z from 'zod'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'
import authService from '@/lib/auth'

interface LoginProps {
  return_to?: string
}

const loginSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
  password: z.string().min(1, 'Password is required'),
})

type LoginFormData = z.infer<typeof loginSchema>

export default function Login({ return_to }: LoginProps) {
  const [error, setError] = useState('')
  const [isCheckingAuth, setIsCheckingAuth] = useState(true)

  const { register, handleSubmit, formState: { errors: formErrors, isSubmitting } } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  })

  // Check if user is already authenticated with existing token
  useEffect(() => {
    const checkExistingAuth = () => {
      const token = authService.getToken()

      if (token && !authService.isTokenExpired()) {
        // User has a valid token, redirect to intended destination
        const redirectUrl = return_to || '/dashboard'
        router.visit(redirectUrl, {
          replace: true,
          onError: () => {
            // If the visit fails (e.g., 401), clear the invalid token
            authService.clearTokens()
            setIsCheckingAuth(false)
          },
        })
      } else {
        // No token or expired token
        if (token) {
          authService.clearTokens()
        }
        setIsCheckingAuth(false)
      }
    }

    checkExistingAuth()
  }, [return_to])

  const onSubmit = async (formData: LoginFormData) => {
    setError('')

    try {
      const response = await fetch('/session', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify(formData),
      })

      const data = await response.json()

      if (response.ok) {
        authService.handleLoginResponse(data)
        // Redirect to intended destination
        const redirectUrl = return_to || '/dashboard'
        router.visit(redirectUrl, { replace: true })
      } else {
        setError(data.error || 'Login failed')
      }
    } catch (err) {
      setError('An error occurred during login')
    }
  }

  // Show loading state while checking authentication
  if (isCheckingAuth) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-primary border-r-transparent"></div>
      </div>
    )
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-muted/50">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <CardTitle className="text-2xl">Welcome Back</CardTitle>
          <CardDescription>Sign in to your account to continue</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            {error && (
              <div className="rounded-md bg-destructive/15 p-3 text-sm text-destructive">
                {error}
              </div>
            )}

            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                placeholder="you@example.com"
                {...register('email')}
              />
              {formErrors.email && (
                <p className="text-sm text-destructive">{formErrors.email.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                placeholder="••••••••"
                {...register('password')}
              />
              {formErrors.password && (
                <p className="text-sm text-destructive">{formErrors.password.message}</p>
              )}
            </div>

            <Button type="submit" className="w-full" disabled={isSubmitting}>
              {isSubmitting ? 'Signing in...' : 'Sign In'}
            </Button>

            <div className="text-center text-sm">
              <a href="/password/forgot" className="text-muted-foreground hover:text-primary">
                Forgot your password?
              </a>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  )
}
