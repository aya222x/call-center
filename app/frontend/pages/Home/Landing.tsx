import { Link } from '@inertiajs/react'
import { Button } from '@/components/ui/button'
import {
  Sparkles,
  Zap,
  Shield,
  ArrowRight,
  Bot,
  PhoneCall,
  BarChart3,
  Mic,
  Star,
  TrendingUp,
  Users,
  CheckCircle2,
  Play
} from 'lucide-react'

export default function Landing() {
  return (
    <div className="relative min-h-screen overflow-hidden bg-background">
      {/* Animated Background */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-1/2 -right-1/4 size-[800px] rounded-full bg-primary/10 blur-3xl animate-blob" />
        <div className="absolute -bottom-1/2 -left-1/4 size-[800px] rounded-full bg-accent/10 blur-3xl animate-blob animation-delay-2000" />
        <div className="absolute top-1/2 left-1/2 size-[600px] -translate-x-1/2 -translate-y-1/2 rounded-full bg-primary/5 blur-3xl animate-blob animation-delay-4000" />
      </div>

      {/* Grid Pattern Overlay */}
      <div className="absolute inset-0 bg-grid-pattern opacity-[0.02]" />

      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 z-50 border-b border-border/40 bg-background/60 backdrop-blur-xl">
        <div className="container mx-auto flex h-16 items-center justify-between px-4">
          <div className="flex items-center gap-3">
            <div className="relative flex size-10 items-center justify-center rounded-xl bg-gradient-to-br from-primary via-primary/90 to-accent shadow-lg shadow-primary/20">
              <PhoneCall className="size-5 text-primary-foreground" />
              <div className="absolute -inset-0.5 rounded-xl bg-gradient-to-br from-primary to-accent opacity-20 blur-sm" />
            </div>
            <span className="text-xl font-bold bg-gradient-to-r from-foreground to-foreground/70 bg-clip-text text-transparent">
              Call Center KPI
            </span>
          </div>
          <Link href="/login">
            <Button variant="outline" className="border-primary/20 hover:bg-primary/5">
              Log In
            </Button>
          </Link>
        </div>
      </nav>

      {/* Hero Section */}
      <main className="relative">
        <div className="container mx-auto px-4 pt-32 pb-16">
          <div className="flex flex-col items-center text-center">
            {/* Floating Badge */}
            <div className="group mb-8 inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary/5 px-5 py-2.5 text-sm font-medium transition-all hover:border-primary/30 hover:bg-primary/10 animate-fade-in-up">
              <div className="relative">
                <Bot className="size-4 text-primary" />
                <div className="absolute inset-0 animate-ping">
                  <Bot className="size-4 text-primary opacity-20" />
                </div>
              </div>
              <span className="text-foreground/80">Powered by OpenAI GPT-4 & Whisper</span>
              <Sparkles className="size-3 text-primary/60" />
            </div>

            {/* Main Headline with artistic styling */}
            <h1 className="mb-6 max-w-5xl animate-fade-in-up animation-delay-200">
              <span className="block text-5xl font-black leading-tight tracking-tight md:text-6xl lg:text-7xl">
                Transform Your
              </span>
              <span className="relative mt-2 block text-5xl font-black leading-tight tracking-tight md:text-6xl lg:text-7xl">
                <span className="relative bg-gradient-to-r from-primary via-accent to-primary bg-clip-text text-transparent animate-gradient-x">
                  Call Center Quality
                </span>
                <div className="absolute -inset-x-4 -inset-y-2 -z-10 bg-gradient-to-r from-primary/20 via-accent/20 to-primary/20 blur-2xl" />
              </span>
              <span className="mt-2 block text-5xl font-black leading-tight tracking-tight md:text-6xl lg:text-7xl">
                with AI
              </span>
            </h1>

            {/* Subheadline */}
            <p className="mb-10 max-w-2xl text-lg leading-relaxed text-muted-foreground md:text-xl animate-fade-in-up animation-delay-400">
              Automatically transcribe and evaluate call recordings in{' '}
              <span className="font-semibold text-foreground">3 languages</span>.
              Get instant{' '}
              <span className="font-semibold text-foreground">KPI scores</span>,{' '}
              AI-powered recommendations, and actionable insights.
            </p>

            {/* CTA Buttons */}
            <div className="flex flex-col gap-4 sm:flex-row animate-fade-in-up animation-delay-600">
              <Link href="/login">
                <Button
                  size="lg"
                  className="group relative overflow-hidden bg-gradient-to-r from-primary to-accent px-8 text-base font-semibold shadow-lg shadow-primary/25 transition-all hover:shadow-xl hover:shadow-primary/40 hover:scale-105"
                >
                  <span className="relative z-10 flex items-center gap-2">
                    Start Free Trial
                    <ArrowRight className="size-4 transition-transform group-hover:translate-x-1" />
                  </span>
                  <div className="absolute inset-0 -z-0 bg-gradient-to-r from-primary/0 via-white/20 to-primary/0 opacity-0 transition-opacity group-hover:opacity-100" />
                </Button>
              </Link>
              <Button
                size="lg"
                variant="outline"
                className="group border-2 border-primary/20 bg-background/50 px-8 text-base font-semibold backdrop-blur-sm hover:border-primary/40 hover:bg-primary/5"
              >
                <Play className="mr-2 size-4" />
                Watch Demo
              </Button>
            </div>

            {/* Social Proof */}
            <div className="mt-12 flex items-center gap-8 text-sm text-muted-foreground animate-fade-in-up animation-delay-800">
              <div className="flex items-center gap-2">
                <div className="flex -space-x-2">
                  {[1, 2, 3].map((i) => (
                    <div key={i} className="size-8 rounded-full border-2 border-background bg-gradient-to-br from-primary/20 to-accent/20" />
                  ))}
                </div>
                <span className="font-medium">Trusted by 500+ teams</span>
              </div>
              <div className="hidden sm:block h-4 w-px bg-border" />
              <div className="hidden sm:flex items-center gap-1.5">
                {[1, 2, 3, 4, 5].map((i) => (
                  <Star key={i} className="size-4 fill-primary text-primary" />
                ))}
                <span className="ml-1 font-medium">4.9/5 rating</span>
              </div>
            </div>
          </div>
        </div>

        {/* Stats Section */}
        <div className="container mx-auto px-4 py-16">
          <div className="mx-auto grid max-w-5xl grid-cols-2 gap-8 md:grid-cols-4 animate-fade-in-up animation-delay-1000">
            {[
              { value: '3', label: 'Languages', sublabel: 'Supported' },
              { value: '5', label: 'KPI Metrics', sublabel: 'Tracked' },
              { value: '99%', label: 'Accuracy', sublabel: 'Rate' },
              { value: '<2min', label: 'Processing', sublabel: 'Time' },
            ].map((stat, i) => (
              <div
                key={i}
                className="group relative overflow-hidden rounded-2xl border border-border/50 bg-card/50 p-6 text-center backdrop-blur-sm transition-all hover:border-primary/30 hover:bg-card/80 hover:shadow-lg"
              >
                <div className="absolute inset-0 bg-gradient-to-br from-primary/5 to-accent/5 opacity-0 transition-opacity group-hover:opacity-100" />
                <div className="relative">
                  <div className="text-4xl font-black text-primary">{stat.value}</div>
                  <div className="mt-2 text-sm font-semibold text-foreground">{stat.label}</div>
                  <div className="text-xs text-muted-foreground">{stat.sublabel}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Features Section */}
        <div className="container mx-auto px-4 py-24">
          <div className="mx-auto max-w-6xl">
            <div className="mb-16 text-center animate-fade-in-up">
              <h2 className="mb-4 text-4xl font-black md:text-5xl">
                Everything you need to{' '}
                <span className="bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
                  excel
                </span>
              </h2>
              <p className="mx-auto max-w-2xl text-lg text-muted-foreground">
                Comprehensive quality evaluation powered by cutting-edge AI technology
              </p>
            </div>

            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
              {[
                {
                  icon: Mic,
                  title: 'Multi-Language Support',
                  description: 'Automatic transcription in Kyrgyz, Russian, and English using OpenAI Whisper.',
                  gradient: 'from-blue-500 to-cyan-500',
                },
                {
                  icon: Star,
                  title: '5 Key Performance Indicators',
                  description: 'Script adherence, politeness, resolution speed, terminology usage, and call success.',
                  gradient: 'from-purple-500 to-pink-500',
                },
                {
                  icon: TrendingUp,
                  title: 'AI-Powered Insights',
                  description: 'GPT-4 analyzes each call and provides personalized recommendations for improvement.',
                  gradient: 'from-orange-500 to-red-500',
                },
                {
                  icon: Users,
                  title: 'Role-Based Access',
                  description: '4 user roles: Operators, Supervisors, Managers, and Admins with tailored permissions.',
                  gradient: 'from-green-500 to-emerald-500',
                },
                {
                  icon: BarChart3,
                  title: 'Real-Time Analytics',
                  description: 'Dashboard with KPI trends, top performers, and team performance metrics.',
                  gradient: 'from-indigo-500 to-blue-500',
                },
                {
                  icon: Shield,
                  title: 'Secure & Audited',
                  description: 'JWT authentication, encrypted data, and complete audit trail for all changes.',
                  gradient: 'from-pink-500 to-rose-500',
                },
              ].map((feature, i) => (
                <div
                  key={i}
                  className="group relative overflow-hidden rounded-2xl border border-border/50 bg-card/50 p-8 backdrop-blur-sm transition-all hover:border-primary/30 hover:bg-card/80 hover:shadow-xl animate-fade-in-up"
                  style={{ animationDelay: `${i * 100}ms` }}
                >
                  <div className="absolute inset-0 bg-gradient-to-br from-primary/5 to-accent/5 opacity-0 transition-opacity group-hover:opacity-100" />
                  <div className="relative">
                    <div className={`mb-4 inline-flex size-14 items-center justify-center rounded-xl bg-gradient-to-br ${feature.gradient} p-0.5 shadow-lg`}>
                      <div className="flex size-full items-center justify-center rounded-[10px] bg-background">
                        <feature.icon className={`size-6 bg-gradient-to-br ${feature.gradient} bg-clip-text text-transparent`} />
                      </div>
                    </div>
                    <h3 className="mb-3 text-xl font-bold text-foreground">{feature.title}</h3>
                    <p className="text-sm leading-relaxed text-muted-foreground">{feature.description}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* How It Works Section */}
        <div className="container mx-auto px-4 py-24">
          <div className="mx-auto max-w-6xl">
            <div className="mb-16 text-center animate-fade-in-up">
              <h2 className="mb-4 text-4xl font-black md:text-5xl">
                Simple, powerful workflow
              </h2>
              <p className="mx-auto max-w-2xl text-lg text-muted-foreground">
                Get started in minutes with our streamlined process
              </p>
            </div>

            <div className="grid gap-12 md:grid-cols-3">
              {[
                {
                  step: '01',
                  title: 'Upload Recording',
                  description: 'Upload your call recording in MP3 or WAV format. Supports calls up to 25MB.',
                  icon: Mic,
                },
                {
                  step: '02',
                  title: 'AI Processing',
                  description: 'Our AI transcribes and analyzes the call against your custom scripts and KPIs.',
                  icon: Bot,
                },
                {
                  step: '03',
                  title: 'Get Insights',
                  description: 'Receive detailed scores, recommendations, and actionable insights instantly.',
                  icon: TrendingUp,
                },
              ].map((item, i) => (
                <div key={i} className="relative animate-fade-in-up" style={{ animationDelay: `${i * 150}ms` }}>
                  <div className="group relative">
                    <div className="mb-6 inline-flex items-center gap-4">
                      <div className="flex size-16 items-center justify-center rounded-2xl bg-gradient-to-br from-primary to-accent p-0.5 shadow-xl">
                        <div className="flex size-full items-center justify-center rounded-[14px] bg-background">
                          <item.icon className="size-7 text-primary" />
                        </div>
                      </div>
                      <span className="text-6xl font-black text-primary/10">{item.step}</span>
                    </div>
                    <h3 className="mb-3 text-2xl font-bold">{item.title}</h3>
                    <p className="text-muted-foreground leading-relaxed">{item.description}</p>
                  </div>
                  {i < 2 && (
                    <div className="absolute -right-6 top-8 hidden md:block">
                      <ArrowRight className="size-6 text-primary/20" />
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Final CTA Section */}
        <div className="container mx-auto px-4 py-24">
          <div className="relative mx-auto max-w-5xl overflow-hidden rounded-3xl border border-primary/20 bg-gradient-to-br from-primary/10 via-background to-accent/10 p-12 md:p-16 animate-fade-in-up">
            <div className="absolute -right-1/4 -top-1/4 size-96 rounded-full bg-primary/10 blur-3xl" />
            <div className="absolute -left-1/4 -bottom-1/4 size-96 rounded-full bg-accent/10 blur-3xl" />

            <div className="relative text-center">
              <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary/10 px-4 py-2 text-sm font-semibold text-primary">
                <Zap className="size-4" />
                Limited Time Offer
              </div>
              <h2 className="mb-6 text-4xl font-black md:text-5xl">
                Ready to transform your call center?
              </h2>
              <p className="mb-8 text-lg text-muted-foreground md:text-xl">
                Start your 14-day free trial. No credit card required.
              </p>

              <div className="flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
                <Link href="/login">
                  <Button
                    size="lg"
                    className="group relative overflow-hidden bg-gradient-to-r from-primary to-accent px-10 py-6 text-lg font-bold shadow-2xl shadow-primary/30 transition-all hover:shadow-2xl hover:shadow-primary/50 hover:scale-105"
                  >
                    Start Free Trial
                    <ArrowRight className="ml-2 size-5 transition-transform group-hover:translate-x-1" />
                  </Button>
                </Link>
              </div>

              <div className="mt-8 flex flex-wrap items-center justify-center gap-6 text-sm text-muted-foreground">
                {[
                  'No credit card required',
                  '14-day free trial',
                  'Cancel anytime',
                ].map((item, i) => (
                  <div key={i} className="flex items-center gap-2">
                    <CheckCircle2 className="size-4 text-primary" />
                    <span>{item}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="relative border-t border-border/40 py-12">
        <div className="container mx-auto px-4">
          <div className="flex flex-col items-center gap-6 text-center">
            <div className="flex items-center gap-3">
              <div className="flex size-10 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-accent shadow-lg">
                <PhoneCall className="size-5 text-primary-foreground" />
              </div>
              <span className="text-xl font-bold">Call Center KPI</span>
            </div>
            <p className="max-w-md text-sm text-muted-foreground">
              AI-powered quality evaluation for modern call centers.
              Transform your team's performance with cutting-edge technology.
            </p>
            <div className="text-sm text-muted-foreground">
              © 2025 Call Center KPI. Built with{' '}
              <a
                href="https://cayu.ai"
                target="_blank"
                rel="noopener noreferrer"
                className="font-medium text-primary transition-colors hover:text-primary/80"
              >
                Cayu AI
              </a>
            </div>
          </div>
        </div>
      </footer>

      <style>{`
        @keyframes fade-in-up {
          from {
            opacity: 0;
            transform: translateY(20px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        @keyframes gradient-x {
          0%, 100% {
            background-position: 0% 50%;
          }
          50% {
            background-position: 100% 50%;
          }
        }

        @keyframes blob {
          0%, 100% {
            transform: translate(0, 0) scale(1);
          }
          25% {
            transform: translate(20px, -20px) scale(1.1);
          }
          50% {
            transform: translate(-20px, 20px) scale(0.9);
          }
          75% {
            transform: translate(20px, 20px) scale(1.05);
          }
        }

        .animate-fade-in-up {
          animation: fade-in-up 0.8s ease-out forwards;
          opacity: 0;
        }

        .animate-gradient-x {
          background-size: 200% auto;
          animation: gradient-x 3s linear infinite;
        }

        .animate-blob {
          animation: blob 7s ease-in-out infinite;
        }

        .animation-delay-200 {
          animation-delay: 200ms;
        }

        .animation-delay-400 {
          animation-delay: 400ms;
        }

        .animation-delay-600 {
          animation-delay: 600ms;
        }

        .animation-delay-800 {
          animation-delay: 800ms;
        }

        .animation-delay-1000 {
          animation-delay: 1000ms;
        }

        .animation-delay-2000 {
          animation-delay: 2s;
        }

        .animation-delay-4000 {
          animation-delay: 4s;
        }

        .bg-grid-pattern {
          background-image:
            linear-gradient(to right, rgb(var(--border) / 0.1) 1px, transparent 1px),
            linear-gradient(to bottom, rgb(var(--border) / 0.1) 1px, transparent 1px);
          background-size: 50px 50px;
        }
      `}</style>
    </div>
  )
}
