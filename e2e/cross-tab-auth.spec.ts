import { test, expect } from '@playwright/test'
import { logout } from './fixtures/auth'

/**
 * Cross-Tab Authentication Tests
 *
 * These tests verify that authentication state is properly synchronized
 * across multiple browser tabs/windows using localStorage events.
 *
 * Scenarios covered:
 * 1. Logout in one tab logs out all tabs
 * 2. Password change invalidates JWTs in all tabs
 */

test.describe('Cross-Tab Authentication Sync', () => {
  test('logout in one tab redirects all tabs to login', async ({ browser }) => {
    // Create two browser contexts (tabs)
    const context = await browser.newContext()
    const page1 = await context.newPage()
    const page2 = await context.newPage()

    try {
      // Tab 1: Login
      await page1.goto('/login')
      await page1.fill('#email', 'admin@example.com')
      await page1.fill('#password', 'password123')
      await page1.click('button[type="submit"]')
      await expect(page1).toHaveURL(/\/dashboard/, { timeout: 10000 })

      // Tab 2: Navigate to dashboard (should work with shared localStorage)
      await page2.goto('/dashboard')
      await expect(page2).toHaveURL(/\/dashboard/, { timeout: 10000 })
      await expect(page2.locator('text=admin@example.com').first()).toBeVisible()

      // Tab 1: Logout using the helper
      await logout(page1)

      // Wait for Tab 1 to be at login page
      await expect(page1).toHaveURL(/\/login/, { timeout: 10000 })

      // Tab 2: Should detect logout via storage event and redirect to login
      // Give it a moment to process the storage event
      await page2.waitForTimeout(1000)

      // Try to navigate in Tab 2 - should redirect to login
      await page2.goto('/dashboard')
      await expect(page2).toHaveURL(/\/login/, { timeout: 10000 })
    } finally {
      await context.close()
    }
  })

  test('password change invalidates JWT in other tabs', async ({ browser }) => {
    // Create two browser contexts (tabs)
    const context = await browser.newContext()
    const page1 = await context.newPage()
    const page2 = await context.newPage()

    try {
      // Tab 1: Login as user1
      await page1.goto('/login')
      await page1.fill('#email', 'user1@example.com')
      await page1.fill('#password', 'password123')
      await page1.click('button[type="submit"]')
      await page1.waitForURL(/\/dashboard/, { timeout: 10000 })

      // Tab 2: Navigate to dashboard (shared session)
      await page2.goto('/dashboard')
      await page2.waitForURL(/\/dashboard/, { timeout: 10000 })

      // Tab 1: Change password
      await page1.goto('/profile/edit')

      // Fill in password fields
      await page1.fill('input[id="password"]', 'newpassword123')
      await page1.fill('input[id="password_confirmation"]', 'newpassword123')
      await page1.click('button[type="submit"]:has-text("Save Changes")')

      // Wait for success (redirect to profile or success message)
      await page1.waitForURL(/\/profile/, { timeout: 10000 })

      // Tab 2: Try to navigate - JWT should be invalidated
      // Wait a moment for the password change to complete
      await page2.waitForTimeout(1000)

      // Try to access a protected page - should redirect to login
      await page2.goto('/admin/users')
      await page2.waitForURL(/\/login/, { timeout: 10000 })

      // Verify we're at login page
      await expect(page2).toHaveURL(/\/login/)
    } finally {
      // Cleanup: Reset password back to original
      // Login with new password
      await page1.goto('/login')
      await page1.fill('#email', 'user1@example.com')
      await page1.fill('#password', 'newpassword123')
      await page1.click('button[type="submit"]')
      await page1.waitForURL(/\/dashboard/, { timeout: 10000 })

      // Change password back
      await page1.goto('/profile/edit')
      await page1.fill('input[id="password"]', 'password123')
      await page1.fill('input[id="password_confirmation"]', 'password123')
      await page1.click('button[type="submit"]:has-text("Save Changes")')
      await page1.waitForURL(/\/profile/, { timeout: 10000 })

      await context.close()
    }
  })

  test('login in one tab does not auto-login other tabs', async ({ browser }) => {
    // Create two browser contexts (tabs)
    const context = await browser.newContext()
    const page1 = await context.newPage()
    const page2 = await context.newPage()

    try {
      // Tab 1: Navigate to login
      await page1.goto('/login')

      // Tab 2: Also at login page
      await page2.goto('/login')
      await expect(page2).toHaveURL(/\/login/)

      // Tab 1: Login
      await page1.fill('#email', 'admin@example.com')
      await page1.fill('#password', 'password123')
      await page1.click('button[type="submit"]')
      await expect(page1).toHaveURL(/\/dashboard/, { timeout: 10000 })

      // Tab 2: Should still be at login page (no auto-login)
      await expect(page2).toHaveURL(/\/login/)

      // But Tab 2 can manually navigate to dashboard now (shared localStorage)
      await page2.goto('/dashboard')
      await expect(page2).toHaveURL(/\/dashboard/, { timeout: 10000 })
    } finally {
      await context.close()
    }
  })
})
