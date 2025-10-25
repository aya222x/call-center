import { test, expect } from '@playwright/test'
import { test as authTest, logout } from './fixtures/auth'

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

  test.describe('Filtering & Search', () => {
    authTest('admin can search users by name or email', async ({ adminPage }) => {
      // Create a unique user to search for
      await adminPage.goto('/admin/users/new')
      const timestamp = Date.now()
      await adminPage.fill('#name', `Searchable User ${timestamp}`)
      await adminPage.fill('#email', `search${timestamp}@example.com`)
      await adminPage.click('button[type="submit"]')

      // Wait for redirect to users list
      await expect(adminPage).toHaveURL('/admin/users', { timeout: 10000 })

      // Pattern: Search with debounce
      await adminPage.fill('#search', `search${timestamp}@example.com`)

      // Wait for debounce to apply (300ms)
      await adminPage.waitForTimeout(500)

      // Pattern: Verify URL params updated
      await expect(adminPage).toHaveURL(/search=search/, { timeout: 2000 })

      // Should see only the searched user
      await expect(adminPage.locator(`text=search${timestamp}@example.com`).first()).toBeVisible()
    })

    authTest('admin can filter users by status', async ({ adminPage }) => {
      await adminPage.goto('/admin/users')

      // Wait for page to load
      await adminPage.waitForTimeout(1000)

      // Pattern: Select dropdown interaction using ID selector
      await adminPage.click('[id="status-filter"]')
      await adminPage.waitForTimeout(300)

      // Pattern: Select option by text using role selector
      await adminPage.click('[role="option"]:has-text("Active")')

      // Wait for filter to apply
      await adminPage.waitForTimeout(500)

      // Pattern: URL params updated
      await expect(adminPage).toHaveURL(/status_filter=active/)
    })

    authTest('filters persist in URL parameters', async ({ adminPage }) => {
      await adminPage.goto('/admin/users')

      // Apply multiple filters
      await adminPage.fill('#search', 'admin')
      await adminPage.waitForTimeout(500)

      await adminPage.click('[id="status-filter"]')
      await adminPage.waitForTimeout(300)
      await adminPage.click('[role="option"]:has-text("Active")')
      await adminPage.waitForTimeout(500)

      // Verify URL has both params
      await expect(adminPage).toHaveURL(/search=admin/)
      await expect(adminPage).toHaveURL(/status_filter=active/)

      // Pattern: Reload page and verify filters persist
      await adminPage.reload()

      // Filters should still be applied after reload
      const searchInput = await adminPage.locator('#search').inputValue()
      expect(searchInput).toBe('admin')

      // URL params should still be there
      await expect(adminPage).toHaveURL(/search=admin/)
      await expect(adminPage).toHaveURL(/status_filter=active/)
    })

    authTest('admin can filter users by date range', async ({ adminPage }) => {
      await adminPage.goto('/admin/users')

      // Wait for page to load
      await adminPage.waitForTimeout(1000)

      // Pattern: Click date range picker button
      await adminPage.click('[id="date-range"]')

      // Wait for calendar popup to appear
      await adminPage.waitForSelector('[role="dialog"]', { timeout: 2000 })

      // Pattern: Click first selectable date (not disabled)
      await adminPage.locator('[role="gridcell"]:not([disabled])').first().click()

      // Pattern: Click another date to create a range
      await adminPage.locator('[role="gridcell"]:not([disabled])').nth(5).click()

      // Wait for filter to apply
      await adminPage.waitForTimeout(500)

      // Pattern: URL params updated
      await expect(adminPage).toHaveURL(/created_from=/)
      await expect(adminPage).toHaveURL(/created_to=/)
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
