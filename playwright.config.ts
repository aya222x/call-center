import { defineConfig, devices } from '@playwright/test'

/**
 * Playwright E2E Test Configuration
 *
 * Tests verify critical user flows work end-to-end:
 * - Authentication (JWT)
 * - Authorization (Pundit)
 * - Inertia.js page rendering
 * - Forms and validation
 * - Database operations
 */
export default defineConfig({
  testDir: './e2e',

  // Maximum time one test can run (15s)
  timeout: 15 * 1000,

  // Fail fast - don't wait forever for missing elements
  expect: {
    timeout: 5 * 1000,  // Assertions fail after 5s (not 30s)
  },

  // Run tests serially for stability (parallel can cause flakiness with shared DB)
  fullyParallel: false,
  workers: 1,

  // Fail the build on CI if you accidentally left test.only in the source code
  forbidOnly: !!process.env.CI,

  // Retry on CI only
  retries: process.env.CI ? 2 : 0,

  // Reporter to use
  reporter: [
    ['html', { open: 'never' }],  // Don't auto-open browser (Claude doesn't need to see it)
    ['list']
  ],

  // Shared settings for all projects
  use: {
    // Base URL - can be overridden with BASE_URL env var for testing deployed apps
    baseURL: process.env.BASE_URL || 'http://localhost:3002',

    // Fail fast on interactions (clicks, fills) - most should be instant
    actionTimeout: 5 * 1000,

    // Navigation needs more time (page loads, redirects)
    navigationTimeout: 10 * 1000,

    // Collect trace when retrying the failed test
    trace: 'on-first-retry',

    // Screenshot on failure
    screenshot: 'only-on-failure',

    // Video on failure
    video: 'retain-on-failure',
  },

  // Configure projects for major browsers
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],

  // Automatically start/stop Rails server before/after tests
  // CRITICAL: Uses port 3002 (not 3001) to avoid conflicts with dev server
  // CRITICAL: Uses RAILS_ENV=test so e2e tests use test DB (not development)
  webServer: {
    command: 'RAILS_ENV=test bin/rails server -p 3002',
    url: 'http://localhost:3002',
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },
})
