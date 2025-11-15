<project_header>
# Starter Base - Project Gotchas

<stack_info>
Rails 8.0.2.1 + Ruby 3.3.6 | Vite + Inertia + React + TS | Tailwind v4 | shadcn Premium | ActiveInteraction | Pundit | pagy | RSpec + Vitest + Playwright
</stack_info>

<critical_rules_summary>
## ⚡ Critical Rules (Quick Reference)

**🚨 Must-Do Before Starting:**
- ALL features need: RSpec + Vitest + Playwright tests (see line 15)
- Run health check before marking complete (see line 527)
- Add data-testid to all interactive elements (see line 262)

**⚠️ Never Do:**
- Browser defaults: NO `<select>`, `<input type="date">` (see line 183)
- Assume component props - always verify interface (see line 189)
- Skip verification protocol (see line 519)

**✅ Always Do:**
- Use shadcn components, NOT native HTML (see line 481)
- Check existing examples before implementing (see line 353)
- Follow sidebar-aware layout patterns (see line 349)

**📖 Full Details**: See antipattern sections below
</critical_rules_summary>
</project_header>

---

<level_3_requirements>
**Level 3 Implementation Requirements (Production Ready):**

When implementing at Level 3, this project requires:
- **RSpec**: Model, service, policy, and request specs
- **Vitest**: `.test.tsx` files for all pages and components
- **Playwright**: E2E tests in `e2e/` directory for user workflows
- **Health Check**: `npm run test:health` must pass before completion

See `<critical_requirement type="testing">` section below for detailed testing patterns and commands.
</level_3_requirements>

---

<critical_requirement type="testing">
**Feature is NOT complete without ALL three test types:**

1. **Backend (RSpec)** - models, services, policies, request specs
   *Why: Ensures business logic, authorization, and API contracts work correctly*

2. **Frontend (Vitest)** - `.test.tsx` for EVERY page and component
   *Why: Catches UI bugs, validates form behavior, prevents regressions*

3. **E2E (Playwright)** - Add test to `e2e/` for feature-specific workflow
   *Why: Verifies the complete user journey works end-to-end*

### Test Execution Strategy

**During TDD Development (Fast Iteration - Goal: < 10 seconds per cycle):**

Run ONLY the specific test file you're working on:

```bash
# RSpec - use progress format for minimal output
bundle exec rspec spec/models/task_spec.rb --format progress

# Vitest - default output (shows only failures)
npm run test -- app/frontend/pages/Tasks/Index.test.tsx

# Playwright - single test with list reporter
npx playwright test e2e/tasks.spec.ts --reporter=list
```

**Also run directly affected tests:**
- Changed User model? → Run `spec/policies/user_policy_spec.rb` too
- Changed authentication? → Run auth-related specs
- Changed shared component? → Run tests that import it

**Before Feature Completion (Comprehensive Verification - Must complete in < 1 minute):**

```bash
npm run test:health
```

This runs `e2e/health-check.spec.ts` which verifies:
- ✅ Puma web server responds
- ✅ Vite assets load (JS/CSS)
- ✅ Database connection works
- ✅ Authentication system works
- ✅ Inertia.js integration works
- ✅ Critical routes render without errors

**If health check fails → Feature is INCOMPLETE**

### Test Output Configuration

**Keep output minimal during TDD to save context and time:**

- **RSpec**: `--format progress` shows dots (not verbose test names)
- **Vitest**: Default output is fine (shows only failures)
- **Playwright**: `--reporter=list` (not html/dot during dev)

**Only show detailed output on failures** - passing tests should be silent.
</critical_requirement>

---

<critical_rules>
- Be consistent with the codebase and implement items as detailed as existing ones
- Study reference files before implementing similar features
- Keep the new feature's UI consistent with the existing UI: no horizontal overflows from components, tables, etc. Set gradient background in components if necessary
</critical_rules>

---

<antipattern type="service_objects">
**Pattern violations that cause errors:**

- ❌ `Services::Auth::JwtService` → ✅ `Auth::JwtService`
  *Why: Directory structure is `app/services/auth/`, NOT `app/services/services/auth/`. Wrong namespace = constant not found error*

- ❌ `object :user` → ✅ `object :user, class: User`
  *Why: ActiveInteraction requires explicit class for object filters or validation fails*

- ❌ `date :start_date` → ✅ `string :start_date`
  *Why: HTML forms send strings. Using `date` filter causes type mismatch errors*

**Example** (see `app/services/auth/login.rb` for full implementation):
```ruby
# ✅ Correct pattern
class Auth::Login < ActiveInteraction::Base
  object :user, class: User  # Must specify class
  string :start_date, default: nil  # Forms send strings, not dates
  def execute; end
end
```
</antipattern>

---

<antipattern type="inertia">
**Test failures caused by incorrect patterns:**

- ❌ `inertia.props[:stats]` → ✅ `inertia.props["stats"]`
  *Why: Inertia Rails serializes to JSON, creating string keys. Symbol access returns nil, causing test failures*

- ❌ `describe "GET /admin" do` → ✅ `describe "GET /admin", inertia: true do`
  *Why: Without `inertia: true` flag, Inertia matchers (render_component, include_props) are not available*

- ❌ `auth_headers(user)` or manually building headers → ✅ `auth_headers(user, inertia: true)`
  *Why: **CRITICAL** - Helper provides JWT + X-Inertia + dynamic version from InertiaRails.configuration.version. Manual headers with hardcoded '1.0' cause 409 Conflict BEFORE authentication (Inertia checks version first)*

- Create `_props` helper methods in controllers for consistent serialization

**Example** (see `app/controllers/admin/users_controller.rb:25-35` and `spec/requests/admin/users_spec.rb:38-94` for full patterns):
```ruby
# ✅ Controller: render inertia: 'Page', props: index_props
# ✅ Test: auth_headers(user, inertia: true)  # Dynamic version
# ✅ Access: inertia.props["stats"]["total"]  # String keys
# ❌ Manual headers with '1.0' → 409 Conflict BEFORE auth check
```
</antipattern>

---

<antipattern type="frontend">
### UI Violations That Break User Experience

- ❌ `window.location.href = '/foo'` → ✅ `router.visit('/foo')`
  *Why: Inertia SPA navigation. window.location causes full page reload, breaking SPA experience*

- ❌ `window.confirm()` → ✅ `<AlertDialog>`
  *Why: Browser defaults don't match shadcn design system, look unprofessional*

- ❌ `<input type="date">` → ✅ `<Calendar>` from shadcn
  *Why: Native inputs have inconsistent styling across browsers*

- ❌ `<select>` → ✅ shadcn `<Select>`
  *Why: Native selects cannot be styled to match design system*

### Component Interface Errors (CAUSES RUNTIME ERRORS)

**NEVER assume component props - ALWAYS verify interface first:**

**Process:** (1) Read component file → (2) Check interface/props → (3) Grep for usage examples → (4) Use exact prop names

**Example** (see `app/frontend/components/app-header.tsx` for interface, `app/frontend/pages/Admin/Users/Index.tsx:17-21` for usage):
```tsx
// ❌ <AppHeader title="Tasks" actions={...} /> → Runtime Error
// ✅ <AppHeader heading="Tasks" rightContent={...} /> → Works
// Common mistakes: title→heading, actions→rightContent, onSubmit→handleSubmit, data→items
```

### Testing Patterns

- ❌ `import { render } from '@testing-library/react'` (for pages) → ✅ `import { render } from '@/test/utils'`
  *Why: Pages use SidebarProvider context. Tests fail without custom render that includes provider*

- ✅ `import { render } from '@testing-library/react'` OK for simple components
  *Why: Simple components don't need provider context*

- Must mock Inertia: `vi.mock('@inertiajs/react')`
  *Why: Inertia router not available in test environment without mock*

**Example** (see `app/frontend/pages/Admin/Users/New.test.tsx:7-14,37-43` for full pattern):
```tsx
// ✅ import { render } from '@/test/utils' + vi.mock('@inertiajs/react')
// ✅ Mock: router: { visit: vi.fn() }, usePage: () => ({ props })
// ✅ Assert: expect(router.visit).toHaveBeenCalledWith('/path')
```

Reference: `app/frontend/pages/Admin/Users/New.test.tsx`, `app/frontend/components/delete-confirmation-dialog.tsx`
</antipattern>

---

<antipattern type="e2e">
### Element Targeting Standards (CRITICAL for Test Stability)

**ALWAYS add data-testid to interactive elements when creating components:**

```tsx
// ✅ CORRECT - Unique, stable selector
<Button data-testid="create-task-button" onClick={handleCreate}>
  Create Task
</Button>

// ❌ WRONG - Relies on text that might change or multiple matches
<Button onClick={handleCreate}>Create Task</Button>
```

**Naming Convention**: `{action}-{resource}-{element}` → Examples: `create-task-button` (actions), `task-title-input` (forms), `task-list-item-1` (lists), `task-details-panel` (containers)

**Selector Priority in Tests:**
1. **Preferred**: `page.getByTestId('create-task-button')` - Unique, stable, survives text changes
2. **Acceptable**: `page.getByRole('button', { name: /create task/i })` - If text is stable API requirement
3. **Last Resort**: `.first()` - Indicates missing data-testid (FIX the component instead!)

**Before Writing E2E Test:**
1. Check if target elements have data-testid attributes
2. If missing, add data-testid to components FIRST
3. Write test using stable selectors
4. Never rely on element order, text content alone, or CSS classes

### Test Stability Best Practices

- E2E server: port 3002 (test DB with RAILS_ENV=test)
  *Why: Isolated from dev server (port 3001) so tests don't corrupt dev database*

- RSpec needs CLEAN DB (factories) | E2E needs SEED data (admin@example.com, user1-5@example.com)
  *Why: RSpec isolation requires no seed data. E2E needs real users to login*

- ❌ `db:drop db:create db:migrate` → ✅ `db:drop && db:create && db:migrate`
  *Why: Rails doesn't support chained task syntax. Single command fails silently*

- ❌ `await page.goto('/login')` → ✅ `await page.goto(/\/login/)`
  *Why: Exact string match breaks when query params present. Regex handles ?param=value*

- ❌ `await page.getByText('Successfully created')` → ✅ `await page.getByText(/successfully created/i)`
  *Why: Case-sensitive exact match brittle. Regex with /i flag more flexible*

- ❌ Hardcode user names → ✅ Use emails from seed data
  *Why: Names can change, emails are stable identifiers*

### Common Errors and Fixes

**Error: "strict mode violation - selector resolved to multiple elements"**
- ❌ Bad: `page.getByRole('button').click()` - Multiple buttons on page
- ✅ Fix: Add data-testid to specific button → `page.getByTestId('create-task-button')`
- ⚠️ Temporary: `.first()` - Only use if you can't modify component

**Error: "Target closed" or "Timeout waiting for element"**
- Usually means wrong selector (element doesn't exist with that ID)
- Check component file to verify exact data-testid value
- Use page.locator('[data-testid]').all() to see all available testids

**Example** (see `e2e/smoke.spec.ts:15-35` for full pattern):
```tsx
// ✅ Component: <Button data-testid="create-task-button">...</Button>
// ✅ Test: await page.getByTestId('create-task-button').click()
// ✅ Toast: await expect(page.getByText(/successfully created/i)).toBeVisible()
```

Reference: `e2e/health-check.spec.ts`, `e2e/smoke.spec.ts`, `e2e/fixtures/auth.ts`
</antipattern>

---

<antipattern type="layout">
**ALWAYS check existing similar pages before creating new layouts.**

### Preventing Sidebar Overflow (CRITICAL)

**❌ Simple container approach causes overflow when sidebar expands:**
```tsx
<div className="container mx-auto p-6">  {/* Breaks with sidebar */}
  <Card><Table /></Card>
</div>
```

**✅ Use sidebar-aware layout with @container/main:**
```tsx
<div className="flex flex-1 flex-col">
  <div className="@container/main flex flex-1 flex-col gap-2">
    <div className="flex flex-col gap-4 py-4 md:gap-6 md:py-6">
      <div className="px-4 lg:px-6">
        <Card><Table /></Card>
      </div>
    </div>
  </div>
</div>
```

*Why: `@container/main` enables container queries + responsive padding (`px-4 lg:px-6`) adapts to sidebar state*

### Standard Container Structure

**List/Table views** (see `app/frontend/pages/Admin/Users/Index.tsx:15-87`, `app/frontend/pages/Tasks/Index.tsx`):
```tsx
// ✅ @container/main flex layout → px-4 lg:px-6 → Card → w-full → Table
```

**Form/Detail views** (see `app/frontend/pages/Admin/Users/New.tsx`, `app/frontend/pages/Profile/Edit.tsx`):
```tsx
// ✅ flex-1 overflow-auto → container mx-auto p-6 max-w-4xl → AppHeader → mt-6 → Card → CardContent p-6
```

### Key Classes

- `@container/main` - Enables container queries for sidebar-aware responsive design
- `flex-1` - Takes remaining height after header/nav
- `overflow-auto` - Allows scrolling if content exceeds viewport
- `px-4 lg:px-6` - Responsive padding that adapts to sidebar state
- `w-full` - Tables use full container width (instead of overflow-x-auto)

### Common Mistakes

- ❌ `container mx-auto` for list views → ✅ Use `@container/main` flex layout
- ❌ Fixed padding `p-6` → ✅ Use responsive `px-4 lg:px-6` for list views
- ❌ `overflow-x-auto` on tables → ✅ Use `w-full` with proper container
- ❌ `<div className="w-[1200px]">` → ✅ Use responsive layout patterns
- ❌ Nested `overflow-auto` → Double scroll bars, confusing UX

### Process

1. Find similar page (list/form/detail)
2. Copy container structure exactly
3. Use `@container/main` for list views with tables
4. Use responsive padding for sidebar-aware layouts
5. Test with sidebar expanded/collapsed

Reference: `app/frontend/pages/Admin/Users/Index.tsx:15-87`, `app/frontend/pages/Tasks/Index.tsx` (sidebar-aware layout examples)
</antipattern>

---

<auth_config>
- JWT-based (NOT cookies) - tokens in localStorage for iframe compatibility
  *Why: Iframe restrictions block cookie access, breaking auth*
- Reference: `app/controllers/sessions_controller.rb`, `app/controllers/concerns/authenticatable.rb`
</auth_config>

---

<mcp_shadcn>
**Before building UI, search MCP first:** `mcp__shadcn__search_items_in_registries`
**Priority:** `@ss-blocks` > `@ss-components` > `@ss-themes` > `@shadcn`
Adapt premium components, don't build from scratch.
**CRITICAL** Always use shadcn components (see Frontend antipattern for UI standards)
</mcp_shadcn>

---

<reference_files>
### CRUD + Authorization
- `app/controllers/admin/users_controller.rb` - Controller with _props methods
- `app/policies/user_policy.rb` - Pundit policy
- `app/frontend/pages/Admin/Users/` - Full CRUD UI

### Services + Email
- `app/services/invitations/` - Service object patterns
- `app/controllers/invitations_controller.rb` - Public pages
- `app/mailers/user_mailer.rb` - ActionMailer

### Forms + Uploads
- `app/frontend/pages/Profile/Edit.tsx` - React Hook Form + Zod + file upload
- `app/controllers/profiles_controller.rb` - ActiveStorage

### Components
- `app/frontend/components/app-header.tsx` - Top navigation bar with breadcrumbs
- `app/frontend/components/delete-confirmation-dialog.tsx` - AlertDialog pattern
- `app/frontend/components/app-sidebar.tsx` - Sidebar layout

### Tests (with line numbers)
- `spec/requests/admin/users_spec.rb:38-94` - Pagination/search
- `spec/requests/admin/users_spec.rb:141-172,209-239` - Error handling
- `spec/requests/admin/users_spec.rb:210-221` - Flash messages
- `spec/requests/invitations_spec.rb:24-45` - Props testing
- `spec/requests/admin/console_spec.rb` - Basic Inertia spec
- `spec/support/authentication_helpers.rb` - Auth helper
- `app/frontend/pages/Admin/Users/New.test.tsx` - Form + validation
- `app/frontend/pages/Dashboard.test.tsx` - Page with data
- `app/frontend/components/ui/button.test.tsx` - Simple component
- `app/frontend/test/utils.tsx` - Custom render with providers
- `e2e/health-check.spec.ts` - Health check patterns (minimal system verification)
- `e2e/smoke.spec.ts` - Feature E2E patterns (comprehensive workflows)
</reference_files>

---

<verification_protocol>
**Step 1: Run health check**
```bash
npm run test:health
```
*See Testing section for details on what this verifies*

**Step 2: Verify health check passes**
```
✅ Health Check: 6 passed
```

**Step 3: Confirm feature completeness**
- [ ] All layer tests passed during TDD (Model, Service, Controller, View already green)
- [ ] All UI pages/components exist and render without errors
- [ ] E2E test covers main user workflow (create → view → edit → delete)
- [ ] NO deferred implementations (no TODO, FIXME, or "will implement later" comments)
- [ ] UI consistency: no horizontal overflows, matches existing page layouts

**If ANY step fails → Feature is INCOMPLETE**
</verification_protocol>
