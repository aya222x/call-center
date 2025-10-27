/**
 * Inertia.js Application Entry Point
 *
 * KEY ARCHITECTURAL DECISIONS:
 *
 * 1. NO InertiaThemeSync component wrapper (CRITICAL)
 *    - usePage() subscribes to ALL prop changes, causing full re-renders on every request
 *    - This was THE ROOT CAUSE of input focus loss during typing
 *    - Solution: Theme/preferences initialized once in setup() instead
 *
 * 2. Using 'only' parameter in filter requests (REQUIRED)
 *    - Pages that update via filters (search, pagination) MUST use:
 *      router.get(url, params, { only: ['data', 'pagination', 'filters'] })
 *    - This prevents shared props (auth, preferences, flash) from updating
 *    - Maintains input focus during typing by avoiding unnecessary re-renders
 *
 * 3. NO React.StrictMode wrapper (OPTIONAL)
 *    - Removed for consistency with temp-starter-base (working reference)
 *    - Note: StrictMode only double-renders in development, not production
 *    - Can be added back if needed - InertiaThemeSync was the real culprit
 *
 * 4. Eager loading with import.meta.glob (OPTIONAL)
 *    - Loads all pages at build time for better initial performance
 *    - Alternative: Remove { eager: true } for code splitting and lazy loading
 */

import { createRoot } from 'react-dom/client'
import { createInertiaApp, router } from '@inertiajs/react'
import { AppLayout } from '@/layouts/app-layout'

// Import CSS
import './application.css'

const appElement = document.getElementById('app')

if (appElement) {
  // Check and migrate localStorage tokens if needed
  // This helps when we rename fields in the user model (e.g., super_admin -> owner)
  const authVersion = localStorage.getItem('auth_version')
  const currentVersion = '3.0' // Increment this when user model structure changes

  if (authVersion !== currentVersion) {
    // Clear old tokens when version mismatch
    localStorage.removeItem('auth_token')
    localStorage.removeItem('refresh_token')
    localStorage.setItem('auth_version', currentVersion)
    console.log('Auth tokens cleared due to version update')
  }

  // Configure Inertia to include JWT token in all requests
  router.on('before', (event) => {
    const token = localStorage.getItem('auth_token')
    if (token) {
      // Add Authorization header to all Inertia requests
      event.detail.visit.headers = {
        ...event.detail.visit.headers,
        'Authorization': `Bearer ${token}`,
      }
    }
  })

  // Handle authentication and authorization errors
  // Use 'invalid' event for non-Inertia responses (401, 403, etc.)
  router.on('invalid', (event) => {
    const response = event.detail.response

    // 401 Unauthorized - JWT expired/invalid
    if (response && response.status === 401) {
      // Clear invalid tokens
      localStorage.removeItem('auth_token')
      localStorage.removeItem('refresh_token')

      // Redirect to login page (preserving return_to URL)
      const currentPath = window.location.pathname
      const returnTo = currentPath !== '/login' ? currentPath : null

      router.visit('/login' + (returnTo ? `?return_to=${encodeURIComponent(returnTo)}` : ''), {
        replace: true, // Replace history entry instead of pushing
      })

      // Prevent default error handling
      event.preventDefault()
    }

    // 403 Forbidden - Insufficient permissions
    if (response && response.status === 403) {
      // Redirect to dashboard with error message
      router.visit('/', {
        replace: true,
        onFinish: () => {
          // Error message will be shown by error handler in the component
          console.error('Access forbidden: You do not have permission to access this resource')
        }
      })

      // Prevent default error handling
      event.preventDefault()
    }
  })

  // Handle cross-tab logout - redirect to login when logged out in another tab
  window.addEventListener('auth:logout', (event: Event) => {
    const customEvent = event as CustomEvent
    if (customEvent.detail?.crossTab) {
      console.log('Detected logout in another tab, redirecting to login')
      router.visit('/login', { replace: true })
    }
  })

  // Handle cross-tab login - optionally reload current page to get fresh data
  window.addEventListener('auth:login', (event: Event) => {
    const customEvent = event as CustomEvent
    if (customEvent.detail?.crossTab) {
      console.log('Detected login in another tab')
      // Optionally reload the current page to get fresh data
      // router.reload()
    }
  })

  // Add global loading indicator
  let loadingTimeout: NodeJS.Timeout | null = null

  router.on('start', () => {
    // Show loading indicator after 250ms (prevents flash for fast requests)
    loadingTimeout = setTimeout(() => {
      document.body.classList.add('inertia-loading')
    }, 250)
  })

  router.on('finish', () => {
    // Clear timeout and hide loading indicator
    if (loadingTimeout) {
      clearTimeout(loadingTimeout)
      loadingTimeout = null
    }
    document.body.classList.remove('inertia-loading')
  })

  createInertiaApp({
    // Resolve page components with eager loading
    // NOTE: We don't wrap components with InertiaThemeSync here because it uses usePage()
    // which causes re-renders on every Inertia request, breaking input focus.
    // Theme/preferences are initialized once in setup() instead.
    resolve: (name) => {
      // Load all .tsx files EXCEPT test files using negative glob patterns
      // CRITICAL: Must exclude test files at glob level, not after import,
      // otherwise Vitest mocks get bundled causing runtime errors
      const pages = import.meta.glob<{ default: any }>([
        '../pages/**/*.tsx',
        '!../pages/**/*.test.tsx',
        '!../pages/**/*.spec.tsx',
      ], { eager: true })

      const page = pages[`../pages/${name}.tsx`]

      if (!page) {
        throw new Error(`Page not found: ${name}`)
      }

      // Set default layout for all pages (Inertia best practice)
      // This allows using usePage() hook for flash messages
      page.default.layout = page.default.layout || ((page: React.ReactNode) => (
        <AppLayout>{page}</AppLayout>
      ))

      return page
    },

    // Setup the app
    setup({ el, App, props }) {
      createRoot(el).render(<App {...props} />)
    },

    // Progress bar at top of page
    progress: {
      color: '#3b82f6',
      showSpinner: false,
    },
  })
}
