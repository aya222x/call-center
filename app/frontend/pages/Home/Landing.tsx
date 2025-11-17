import { Link } from '@inertiajs/react'
import { Button } from '@/components/ui/button'
import {
  Sparkles,
  Zap,
  Shield,
  Layout,
  Code2,
  ArrowRight
} from 'lucide-react'

export default function Landing() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary/5 via-background to-accent/5">
      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 z-50 border-b bg-background/80 backdrop-blur-sm">
        <div className="container mx-auto flex h-16 items-center justify-between px-4">
          <div className="flex items-center gap-2">
            <div className="flex size-8 items-center justify-center rounded-lg bg-gradient-to-br from-primary to-accent">
              <Sparkles className="size-5 text-primary-foreground" />
            </div>
            <span className="text-xl font-bold">My App</span>
          </div>
          <Link href="/login">
            <Button variant="outline">Log In</Button>
          </Link>
        </div>
      </nav>

      {/* Hero Section */}
      <main className="container mx-auto px-4 pt-32 pb-16">
        <div className="flex flex-col items-center text-center">
          {/* Animated Badge */}
          <div className="mb-6 inline-flex items-center gap-2 rounded-full border bg-card px-4 py-2 text-sm animate-fade-in">
            <Zap className="size-4 text-primary" />
            <span className="text-muted-foreground">Build production-ready apps in minutes</span>
          </div>

          {/* Main Headline */}
          <h1 className="mb-6 max-w-4xl text-4xl font-bold leading-tight tracking-tight md:text-5xl lg:text-6xl">
            Build Full-Stack Apps{' '}
            <span className="bg-gradient-to-r from-primary via-accent to-primary bg-clip-text text-transparent animate-gradient">
              Faster
            </span>
          </h1>

          {/* Subheadline */}
          <p className="mb-8 max-w-2xl text-lg text-muted-foreground md:text-xl">
            Start with authentication, admin dashboard, and modern UI components.
            Add features using AI-powered development and ship your application in record time.
          </p>

          {/* CTA Buttons */}
          <div className="flex flex-col gap-4 sm:flex-row">
            <Link href="/login">
              <Button size="lg" className="group bg-gradient-to-r from-primary to-accent hover:shadow-lg hover:shadow-primary/50 transition-all">
                Get Started Free
                <ArrowRight className="ml-2 size-4 transition-transform group-hover:translate-x-1" />
              </Button>
            </Link>
            <Button size="lg" variant="outline">
              View Features
            </Button>
          </div>

          {/* Tech Stack */}
          <div className="mt-16 w-full max-w-4xl">
            <p className="mb-6 text-sm font-medium text-muted-foreground uppercase tracking-wide">
              Built with modern technology
            </p>
            <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
              {[
                { name: 'Rails 8', icon: Code2 },
                { name: 'React + Inertia', icon: Layout },
                { name: 'Authentication', icon: Shield },
                { name: 'Admin Panel', icon: Sparkles },
              ].map((tech) => (
                <div
                  key={tech.name}
                  className="flex flex-col items-center gap-2 rounded-lg border bg-card p-4 transition-all hover:border-primary/50 hover:shadow-md"
                >
                  <tech.icon className="size-6 text-primary" />
                  <span className="text-sm font-medium">{tech.name}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Features Section */}
          <div className="mt-24 w-full max-w-6xl">
            <h2 className="mb-4 text-3xl font-bold">Everything you need to build faster</h2>
            <p className="mb-12 text-lg text-muted-foreground">
              A complete starter template with all the essentials
            </p>

            <div className="grid gap-8 md:grid-cols-3">
              {[
                {
                  icon: Shield,
                  title: 'Authentication Ready',
                  description: 'JWT-based auth with login, password reset, and user invitations built-in.',
                },
                {
                  icon: Layout,
                  title: 'Admin Dashboard',
                  description: 'Complete admin panel with user management, audit logs, and permissions.',
                },
                {
                  icon: Sparkles,
                  title: 'Modern UI Components',
                  description: 'shadcn/ui components with Tailwind CSS v4 and dark mode support.',
                },
              ].map((feature) => (
                <div
                  key={feature.title}
                  className="rounded-xl border bg-card p-6 transition-all hover:border-primary/50 hover:shadow-lg"
                >
                  <div className="mb-4 inline-flex size-12 items-center justify-center rounded-lg bg-primary/10">
                    <feature.icon className="size-6 text-primary" />
                  </div>
                  <h3 className="mb-2 text-xl font-semibold">{feature.title}</h3>
                  <p className="text-muted-foreground">{feature.description}</p>
                </div>
              ))}
            </div>
          </div>

          {/* Final CTA */}
          <div className="mt-24 w-full max-w-4xl rounded-2xl border bg-gradient-to-br from-primary/10 via-background to-accent/10 p-12">
            <h2 className="mb-4 text-3xl font-bold">Ready to build something amazing?</h2>
            <p className="mb-8 text-lg text-muted-foreground">
              Start with a solid foundation and add features as you need them.
            </p>
            <Link href="/login">
              <Button size="lg" className="bg-gradient-to-r from-primary to-accent hover:shadow-lg hover:shadow-primary/50 transition-all">
                Get Started Now
              </Button>
            </Link>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t py-8">
        <div className="container mx-auto px-4 text-center text-sm text-muted-foreground">
          <p>Built with Rails, React, Inertia, and Tailwind CSS</p>
        </div>
      </footer>

      <style>{`
        @keyframes fade-in {
          from {
            opacity: 0;
            transform: translateY(-10px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        @keyframes gradient {
          0%, 100% {
            background-position: 0% 50%;
          }
          50% {
            background-position: 100% 50%;
          }
        }

        .animate-fade-in {
          animation: fade-in 0.6s ease-out;
        }

        .animate-gradient {
          background-size: 200% auto;
          animation: gradient 3s linear 3 forwards;
        }
      `}</style>
    </div>
  )
}
