# Starter Base - Project Gotchas

> **Project-specific antipatterns and reference files. Read global ~/.claude/CLAUDE.md first.**

## Stack
Rails 8.0.2.1 + Ruby 3.3.6 | Vite + Inertia + React + TS | Tailwind v4 | shadcn Premium | ActiveInteraction | Pundit | pagy | RSpec + Vitest + Playwright

---

## Testing (NON-NEGOTIABLE)

**Feature is NOT complete without ALL three test types:**

1. **Backend (RSpec)** - models, services, policies, request specs
2. **Frontend (Vitest)** - `.test.tsx` for EVERY page and component
3. **E2E (Playwright)** - smoke test in `e2e/` for main user workflow

**Verification:** `npm run test:all` must show 100% pass (Vitest + RSpec + Playwright)

**If ANY test type is missing or failing, feature is INCOMPLETE.**

---
## Critical rules ##

- Be consistent with the codebase and implement items as detailed as existing ones
- Study reference files before implementing similar features.
- NEVER assume to avoid errors such as this: "Cannot read properties of undefined (reading 'map') at PageHeader"
- Keep the new feature's UI consistent with the existing UI: no horizontal overflows from components, tables, etc. Set gradient background in components if necessary.

## Critical Antipatterns.

### Service Objects (ActiveInteraction)
- ❌ `Services::Auth::JwtService` → ✅ `Auth::JwtService` (namespace by directory, NOT Services:: prefix)
- ❌ `object :user` → ✅ `object :user, class: User` (must specify class)
- ❌ `date :start_date` → ✅ `string :start_date` (forms send strings, not Date objects)
- Reference: `app/services/auth/login.rb`, `app/services/invitations/send_invitation.rb`

### Inertia.js
- ❌ `inertia.props[:stats]` → ✅ `inertia.props["stats"]` (RSpec props use STRING keys, not symbols)
- ❌ `describe "GET /admin" do` → ✅ `describe "GET /admin", inertia: true do` (must flag Inertia specs)
- ❌ `auth_headers(user)` → ✅ `auth_headers(user, inertia: true)` (for Inertia requests)
- Create `_props` helper methods in controllers for consistent serialization
- Reference: `app/controllers/admin/users_controller.rb`, `spec/requests/admin/users_spec.rb:38-94`

### Frontend
- ❌ `window.location.href = '/foo'` → ✅ `router.visit('/foo')` (use Inertia router)
- ❌ `window.confirm()` → ✅ `<AlertDialog>` (no browser defaults)
- ❌ `<input type="date">` → ✅ `<Calendar>` (no native inputs)
- ❌ `<select>` → ✅ shadcn `<Select>` (no HTML5 form elements)
- ❌ `import { render } from '@testing-library/react'` (for pages) → ✅ `import { render } from '@/test/utils'` (includes SidebarProvider)
- ✅ `import { render } from '@testing-library/react'` OK for simple components
- Must mock Inertia: `vi.mock('@inertiajs/react')`
- Reference: `app/frontend/pages/Admin/Users/New.tsx`, `app/frontend/components/delete-confirmation-dialog.tsx`

### E2E (Playwright)
- E2E server: port 3002 (test DB)
- RSpec needs CLEAN DB (factories) | E2E needs SEED data (admin@example.com, user1-5@example.com)
- ❌ `db:drop db:create db:migrate` → ✅ `db:drop && db:create && db:migrate` (separate commands)
- ❌ `await page.goto('/login')` → ✅ `await page.goto(/\/login/)` (use regex for URLs)
- ❌ `await page.getByText('Successfully created')` → ✅ `await page.getByText(/successfully created/i)` (regex for toasts)
- ❌ Hardcode user names → ✅ Use emails from seed data
- ✅ Use `.first()` when selectors match multiple elements
- Reference: `e2e/smoke.spec.ts`, `e2e/fixtures/auth.ts`

### Auth
- JWT-based (NOT cookies) - tokens in localStorage for iframe compatibility
- Reference: `app/controllers/sessions_controller.rb`, `app/controllers/concerns/authenticatable.rb`

---

## MCP Shadcn Premium
**Before building UI, search MCP first:** `mcp__shadcn__search_items_in_registries`
**Priority:** `@ss-blocks` > `@ss-components` > `@ss-themes` > `@shadcn`
Adapt premium components, don't build from scratch.
**CRITICAL** Always use shadcn components, no browser defaults

---

## Reference Files (Study Before Implementing)

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
- `e2e/smoke.spec.ts` - All E2E patterns

---

## Feature Checklist (A feature is complete when ALL of these pass)
- [ ] Ensure feature pages, components, buttons exist and work as expected (e2e smoke tests)
- [ ] Run `npm run test:all` (Vitest + RSpec + Playwright MUST all pass)
- [ ] Ensure when the feature is marked as COMPLETE, there are NO DEFERRED implementations
