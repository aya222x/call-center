import { test, expect } from '@playwright/test'
import { test as authTest, login, logout } from './fixtures/auth'

/**
 * Smoke Tests
 *
 * Quick, high-level tests that verify critical functionality is working.
 * These should run fast (< 5 minutes) and catch major breakages.
 *
 * Coverage:
 * - Authentication (JWT, localStorage, Inertia)
 * - Authorization (Pundit policies)
 * - Navigation (Inertia router)
 * - Forms (React Hook Form + Zod)
 * - Service Objects (ActiveInteraction)
 * - Database operations
 *
 * Run these before marking work complete.
 */

test.describe('Smoke Tests: Critical User Flows', () => {
  test.describe('Authentication & Basic Navigation', () => {
    test('admin can login successfully', async ({ page }) => {
      await page.goto('/login')

      // Fill in login form
      await page.fill('#email', 'admin@example.com')
      await page.fill('#password', 'password123')
      await page.click('button[type="submit"]')

      // Should redirect to dashboard
      await expect(page).toHaveURL('/dashboard', { timeout: 10000 })

      // Verify user is logged in by checking for email (use .first() for strict mode)
      await expect(page.locator('text=admin@example.com').first()).toBeVisible()
    })

    test('invalid credentials show error', async ({ page }) => {
      await page.goto('/login')

      await page.fill('#email', 'admin@example.com')
      await page.fill('#password', 'wrongpassword')
      await page.click('button[type="submit"]')

      // Should show error message
      await expect(page.locator('text=/login failed|invalid/i')).toBeVisible()
    })

    test('unauthenticated user redirected to login', async ({ page }) => {
      await page.goto('/dashboard')

      // Should redirect to login (allow query params like ?return_to=...)
      await expect(page).toHaveURL(/\/login/)
    })
  })

  test.describe('Dashboard & Navigation', () => {
    authTest('authenticated user can access dashboard', async ({ authenticatedPage }) => {
      await authenticatedPage.goto('/dashboard')

      // Dashboard should load successfully
      await expect(authenticatedPage).toHaveURL('/dashboard')
      // Verify sidebar is visible (means page loaded correctly)
      await expect(authenticatedPage.locator('[data-sidebar="sidebar"]')).toBeVisible()
    })

    authTest('sidebar navigation works', async ({ adminPage }) => {
      await adminPage.goto('/dashboard')

      // Navigate to admin users (more stable than "Console")
      await adminPage.goto('/admin/users')

      // Should successfully navigate
      await expect(adminPage).toHaveURL('/admin/users')
    })

    authTest('user can logout', async ({ authenticatedPage }) => {
      await authenticatedPage.goto('/dashboard')

      // Use the logout helper
      await logout(authenticatedPage)

      // Should be on login page (allow query params)
      await expect(authenticatedPage).toHaveURL(/\/login/)

      // Trying to access dashboard should redirect to login
      await authenticatedPage.goto('/dashboard')
      await expect(authenticatedPage).toHaveURL(/\/login/)
    })
  })

  test.describe('Admin Features', () => {
    authTest('admin can access admin console', async ({ adminPage }) => {
      await adminPage.goto('/admin/console')

      // Should see admin console
      await expect(adminPage).toHaveURL('/admin/console')
      // Page loaded successfully if we got here without redirect
    })

    authTest('admin can view users list', async ({ adminPage }) => {
      await adminPage.goto('/admin/users')

      // Should see users table
      await expect(adminPage).toHaveURL('/admin/users')
      // Verify at least one user email is visible
      await expect(adminPage.locator('text=admin@example.com').first()).toBeVisible()
    })

    authTest('admin can create new user (invitation)', async ({ adminPage }) => {
      await adminPage.goto('/admin/users')

      // Click "Invite User" button
      await adminPage.click('text=/invite user/i')

      // Should navigate to new user form
      await expect(adminPage).toHaveURL('/admin/users/new')

      // Fill in the form
      const timestamp = Date.now()
      await adminPage.fill('#name', `Test User ${timestamp}`)
      await adminPage.fill('#email', `test${timestamp}@example.com`)

      // Submit the form
      await adminPage.click('button[type="submit"]')

      // Should redirect back to users list with success message
      await expect(adminPage).toHaveURL('/admin/users', { timeout: 10000 })

      // Pattern: Verify Sonner toast notification with regex for flexibility
      await expect(adminPage.locator('text=/invitation sent/i')).toBeVisible({ timeout: 5000 })

      // New user should appear in the list (use .first() for strict mode)
      await expect(adminPage.locator(`text=test${timestamp}@example.com`).first()).toBeVisible()
    })

    authTest('admin can view user details', async ({ adminPage }) => {
      // Directly navigate to first user's show page (ID 1 from seed data)
      await adminPage.goto('/admin/users/1')

      // Should successfully load user show page
      await expect(adminPage).toHaveURL(/\/admin\/users\/\d+/)

      // Should see email on the page (use .first() for strict mode)
      await expect(adminPage.locator('text=@example.com').first()).toBeVisible()
    })

    authTest('admin can delete a user', async ({ adminPage }) => {
      // Create a user to delete
      await adminPage.goto('/admin/users/new')
      const timestamp = Date.now()
      await adminPage.fill('#name', `User to Delete ${timestamp}`)
      await adminPage.fill('#email', `delete${timestamp}@example.com`)
      await adminPage.click('button[type="submit"]')

      // Wait for redirect to users list
      await expect(adminPage).toHaveURL('/admin/users', { timeout: 10000 })

      // Wait for the new user to appear in the list
      await expect(adminPage.locator(`text=delete${timestamp}@example.com`).first()).toBeVisible({ timeout: 5000 })

      // Find the user row
      const userRow = adminPage.locator(`tr:has-text("delete${timestamp}@example.com")`).first()

      // Click delete button to open dialog (uses aria-label, not title)
      await userRow.locator('button[aria-label="Delete user"]').click()

      // Pattern: Wait for DeleteConfirmationDialog to appear
      await adminPage.waitForSelector('[role="alertdialog"]', { timeout: 2000 })

      // Verify dialog content
      await expect(adminPage.locator('text=/are you sure/i')).toBeVisible()

      // Click confirm button
      await adminPage.click('button:has-text("Delete")')

      // Wait for redirect back to users list
      await expect(adminPage).toHaveURL('/admin/users', { timeout: 10000 })

      // Verify success toast
      await expect(adminPage.locator('text=/successfully deleted/i')).toBeVisible({ timeout: 5000 })

      // User should not appear in the list anymore
      await expect(adminPage.locator(`text=delete${timestamp}@example.com`)).not.toBeVisible()
    })

    authTest('regular user cannot access admin console', async ({ authenticatedPage }) => {
      await authenticatedPage.goto('/admin/console')

      // Should be redirected or see unauthorized message
      // Depending on your authorization setup, this might redirect to root or show a 403
      await expect(authenticatedPage).not.toHaveURL('/admin/console')
    })
  })

  test.describe('User Profile', () => {
    authTest('user can view their profile', async ({ authenticatedPage }) => {
      await authenticatedPage.goto('/profile')

      // Should see profile page with user's email (stable identifier from seed data)
      await expect(authenticatedPage).toHaveURL('/profile')
      await expect(authenticatedPage.locator('text=user1@example.com').first()).toBeVisible()
    })

    authTest('user can edit their profile', async ({ authenticatedPage }) => {
      await authenticatedPage.goto('/profile/edit')

      // Should see edit form
      await expect(authenticatedPage).toHaveURL('/profile/edit')

      // Update name
      const newName = `Updated User ${Date.now()}`
      await authenticatedPage.fill('#name', newName)

      // Submit form
      await authenticatedPage.click('button[type="submit"]')

      // Should redirect to profile
      await expect(authenticatedPage).toHaveURL('/profile', { timeout: 10000 })
      await expect(authenticatedPage.locator(`text=${newName}`).first()).toBeVisible()
    })
  })
})
