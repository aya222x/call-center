# Starter Base Inertia - Project Guidelines

> **For Claude Code instances working on this project.**
> **Read `~/.claude/CLAUDE.md` first, then this file.**
> **Purpose: Prevent errors, ensure consistency, point to reference code.**

---

## Tech Stack

- **Backend**: Rails 8.0.2.1 + Ruby 3.3.6
- **Frontend**: Vite + Inertia.js + React + TypeScript
- **Styling**: Tailwind CSS v4
- **UI Components**: shadcn/ui (Shadcn Studio Premium)
- **Database**: SQLite
- **Testing**:
  - Backend: RSpec + Inertia Rails test helpers
  - Frontend: Vitest + React Testing Library + Jest DOM
- **Services**: ActiveInteraction
- **Pagination**: pagy
- **Authorization**: Pundit

---

## Key Architecture Notes

### Rails Patterns

**Service Objects (ActiveInteraction)**:
- **CRITICAL**: Namespace by directory, NOT by `Services::` prefix
  - ✅ `Auth::JwtService`, `Invitations::SendInvitation`
  - ❌ `Services::Auth::JwtService`, `Services::Invitations::SendInvitation`
- Must specify class for object filters: `object :user, class: User`
- Use `string` for dates (not `date` filter - forms send strings)
- Reference: `app/services/invitations/send_invitation.rb`, `app/services/auth/login.rb`

**Authorization (Pundit)**:
- All resources require policies in `app/policies/`
- Controllers must call `authorize @resource` before actions
- Use `policy_scope(Resource)` for index actions
- Reference: `app/policies/user_policy.rb`

**Active Record**:
- Integer-backed enums: `enum :status, { pending: 0, active: 1 }`
- **CRITICAL**: Validate at both model AND database levels

### Authentication & Authorization
- **JWT-based** (not cookies) - tokens in localStorage for iframe compatibility
- Authenticatable concern in ApplicationController provides `current_user`
- Reference: `app/controllers/sessions_controller.rb`, `app/controllers/concerns/authenticatable.rb`

### Inertia.js
- Controller responses use `render inertia:` for pages
- Shared props auto-injected: `auth`, `flash`, `errors`
- Create `_props` helper methods for consistent serialization
- Reference: `app/controllers/admin/users_controller.rb` (example with _props methods)

### Frontend Stack
- **Forms**: React Hook Form + Zod validation
- **UI**: Shadcn UI Premium (priority: `@ss-components` > `@ss-themes` > `@ss-blocks` > `@shadcn`)
- **CRITICAL**: Use Inertia router, NOT browser navigation (`router.visit()` not `window.location`)
- **CRITICAL - UI Components**:
  - ❌ NEVER use browser defaults: `window.confirm()`, `window.alert()`, `<input type="date">`, `<select>`, HTML5 validation
  - ✅ ALWAYS use shadcn components: `AlertDialog`, `toast()`, `Calendar`, `Select`, Zod + React Hook Form
  - Reference: `DeleteConfirmationDialog`, `DateRangePicker`, `Admin/Users/New.tsx`
- Reference: `app/is frontend/pages/Profile/Edit.tsx` (form example)

---

## Reference Examples - Study Before Building Similar Features

### Complete CRUD with Authorization + Inertia
- **User Management**: `app/controllers/admin/users_controller.rb`, `app/policies/user_policy.rb`, `app/frontend/pages/Admin/Users/`

### Service Objects + Email + Public Pages
- **Invitation System**: `app/services/invitations/`, `app/controllers/invitations_controller.rb`, `app/mailers/user_mailer.rb`, `app/frontend/pages/Invitations/Accept.tsx`

### File Uploads + Forms
- **Profile Management**: `app/controllers/profiles_controller.rb`, `app/frontend/pages/Profile/Edit.tsx`

### Components
- **Sidebar**: `app/frontend/components/app-sidebar.tsx`
- **Dialog**: `app/frontend/components/delete-confirmation-dialog.tsx`
- **All UI**: `app/frontend/components/ui/`

---

## Testing

### Backend (RSpec + Inertia Rails)

**CRITICAL - Common Errors:**
- ❌ Props use **string keys**, NOT symbols: `inertia.props["stats"]` not `inertia.props[:stats]`
- ❌ Must add `inertia: true` flag to describe block for Inertia matchers to work
- ❌ Must use `auth_headers(user, inertia: true)` for Inertia requests
- ✅ Inertia matchers: `render_component()`, `include_props()`, `have_exact_props()`

**Reference Files:**
- Pagination/search: `spec/requests/admin/users_spec.rb:38-94`
- Error handling: `spec/requests/admin/users_spec.rb:141-172,209-239`
- Flash messages: `spec/requests/admin/users_spec.rb:210-221`
- Props testing: `spec/requests/invitations_spec.rb:24-45`
- Basic example: `spec/requests/admin/console_spec.rb`
- Auth helper: `spec/support/authentication_helpers.rb`

**Commands:**
```bash
bundle exec rspec                       # All tests
bundle exec rspec spec/path/file.rb:42  # Single test at line 42
```

### Frontend (Vitest + React Testing Library)

**CRITICAL - Common Errors:**
- ❌ Pages using SidebarProvider will fail without custom render
- ✅ Import `render` from `@/test/utils` for pages (includes SidebarProvider)
- ✅ Import `render` from `@testing-library/react` for simple components
- ✅ window.matchMedia already mocked in `app/frontend/test/setup.ts`
- ❌ Must mock Inertia router: `vi.mock('@inertiajs/react')`

**Reference Files:**
- Form + validation: `app/frontend/pages/Admin/Users/New.test.tsx`
- Dialog + events: `app/frontend/components/delete-confirmation-dialog.test.tsx`
- Basic component: `app/frontend/components/ui/button.test.tsx`
- Basic page: `app/frontend/pages/Dashboard.test.tsx`
- Test utils: `app/frontend/test/utils.tsx`

**During Implementation (watch mode gives instant feedback):**
```bash
npm test              # Keep running, auto-reruns on changes
```

**Before Marking Feature Complete:**
```bash
npm run test:all      # Vitest + RSpec + Playwright (recommended)
# OR if skipping e2e:
npm test -- --run && bundle exec rspec    # Vitest + RSpec only
```

### E2E / Smoke Tests (Playwright)

**CRITICAL - Port Separation:**
- Dev server runs on port **3000** (development DB)
- E2E tests run on port **3002** (test DB with RAILS_ENV=test)
- This prevents e2e from interfering with dev DB
- You can keep `bin/dev` running while running e2e tests

**CRITICAL - Database State:**
- RSpec needs CLEAN database (no seed data, uses factories)
- E2E needs SEED data (admin@example.com, user1@example.com)
- `npm run test:all` handles DB seeding and cleanup automatically

**CRITICAL - Database Cleanup:**
- All e2e commands (`test:e2e`, `test:e2e:ui`, etc.) automatically seed before and reset after
- `npm run test:all` automatically cleans test DB before RSpec and after e2e
- Test DB is always left in clean state - safe to run `bundle exec rspec` anytime
- **IMPORTANT**: Rails tasks MUST be separate commands: `bundle exec rails db:drop && bundle exec rails db:create && bundle exec rails db:migrate` (NOT `db:drop db:create db:migrate` in single command)

**CRITICAL - Test Stability:**
- ❌ NEVER hardcode user names - use emails from seed data
- ✅ Use `.first()` when selectors match multiple elements
- ✅ Use regex for URLs (allows query params): `/\/login/` not `'/login'`
- ✅ Use regex for toast messages (flexible matching): `text=/successfully created/i`

**Reference Files:**
- **All E2E patterns**: `e2e/smoke.spec.ts` (Toast, Dialog, Calendar, Search, Filters, Auth)
- **Auth helpers**: `e2e/fixtures/auth.ts`

**Commands:**
```bash
npm test -- --run                    # Vitest only
bundle exec rspec                    # RSpec only
npm run test:e2e                     # E2E only (seeds before, resets after)
npm run test:e2e:ui                  # E2E with Playwright UI (debugging)
npm run test:all                     # All tests (recommended)
BASE_URL=https://your-domain.com npm run test:e2e  # Test deployed app
```

**Summary - How It All Works:**
1. Dev server: Port 3000 (development DB) - never touched by tests
2. E2E server: Port 3002 (test DB with RAILS_ENV=test) - isolated from dev
3. `npm run test:all` flow:
   - Vitest runs (no DB)
   - Test DB reset (drop/create/migrate) → clean slate
   - RSpec runs with factories on clean DB
   - Test DB reset + seeded → admin@example.com, user1-5@example.com
   - Playwright runs e2e tests on seeded DB
   - Test DB reset (drop/create/migrate) → clean for next RSpec run

---

## File Structure

```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── admin/
│   │   └── users_controller.rb
│   ├── dashboard_controller.rb
│   ├── invitations_controller.rb
│   ├── profiles_controller.rb
│   └── sessions_controller.rb
├── frontend/
│   ├── components/
│   │   ├── ui/              # shadcn components
│   │   │   └── button.test.tsx
│   │   ├── app-sidebar.tsx
│   │   └── delete-confirmation-dialog.tsx
│   ├── pages/
│   │   ├── Admin/
│   │   │   └── Users/
│   │   ├── Dashboard.tsx
│   │   ├── Dashboard.test.tsx
│   │   ├── Invitations/
│   │   ├── Login.tsx
│   │   └── Profile/
│   ├── test/
│   │   ├── setup.ts         # Test setup (matchMedia mock)
│   │   └── utils.tsx        # Custom render with providers
│   └── lib/
│       ├── auth-service.ts
│       └── utils.ts
├── models/
│   ├── user.rb
│   ├── refresh_token.rb
│   └── user_preference.rb
├── policies/
│   └── user_policy.rb
└── services/
    ├── auth/
    │   ├── jwt_service.rb
    │   └── login.rb
    └── invitations/
        ├── send_invitation.rb
        ├── accept_invitation.rb
        └── resend_invitation.rb

spec/
├── models/
├── services/
│   ├── auth/
│   └── invitations/
├── policies/
├── requests/
│   ├── admin/
│   │   ├── console_spec.rb  # Inertia test example
│   │   └── users_spec.rb
│   ├── sessions_spec.rb
│   └── invitations_spec.rb
└── support/
    └── authentication_helpers.rb

e2e/
├── fixtures/
│   └── auth.ts              # Auth helpers for e2e tests
└── smoke.spec.ts            # Smoke tests

vitest.config.ts             # Frontend test config
playwright.config.ts         # E2E test config
```

---

## Pre-Implementation Checklist

**CRITICAL - Before implementing any feature:**

- [ ] **FIRST: Check MCP Shadcn Studio Premium for existing components**
  * Use `mcp__shadcn__search_items_in_registries` to search for relevant UI components
  * Search keywords related to your feature (e.g., "task", "kanban", "form", "table")
  * Priority: Use `@ss-blocks` > `@ss-components` > `@ss-themes` > `@shadcn`
  * Adapt premium components instead of building from scratch
- [ ] Study existing similar features (see Reference Examples above)
- [ ] **Service Objects**: Namespace by directory (`Auth::`, `Invitations::`), NOT `Services::`
- [ ] **Navigation**: Use `router.visit()`, NOT `window.location` or `<a href>`
- [ ] **Authorization**: Create Pundit policy and tests
- [ ] **Props**: Create `_props` helper methods in controllers
- [ ] **TypeScript**: Define interfaces for all Inertia props

---

## Testing Requirements (MANDATORY)

**Follow TDD - Write tests BEFORE implementation:**

### 1. Backend Tests (RSpec)
- [ ] Model specs: validations, associations, scopes
- [ ] Service specs: business logic, error handling
- [ ] Policy specs: authorization rules
- [ ] Request specs: endpoints, props, filters, pagination

### 2. Frontend Tests (Vitest) - REQUIRED for every page/component
- [ ] Create `.test.tsx` file for EACH new page in `app/frontend/pages/`
- [ ] Create `.test.tsx` file for EACH new component in `app/frontend/components/`
- [ ] Test form validation (if applicable)
- [ ] Test user interactions (clicks, inputs)
- [ ] Run `npm test` in watch mode during development

**Reference Files:**
- Form + validation: `app/frontend/pages/Admin/Users/New.test.tsx`
- Page with data: `app/frontend/pages/Dashboard.test.tsx`
- Component: `app/frontend/components/ui/button.test.tsx`

### 3. E2E Tests (Playwright) - REQUIRED for main user workflow
- [ ] Add smoke test in `e2e/` directory for primary feature workflow
- [ ] Test complete user journey (e.g., create → view → edit → delete)
- [ ] Use seed data (admin@example.com, user1@example.com)

**Reference:** `e2e/smoke.spec.ts`

---

## Feature Complete Definition

**A feature is ONLY complete when ALL of these pass:**

1. ✅ **All backend tests pass** (RSpec - models, services, policies, requests)
2. ✅ **All frontend tests pass** (Vitest - ALL pages and components have .test.tsx files)
3. ✅ **All E2E tests pass** (Playwright - main user workflow tested)
4. ✅ **`npm run test:all` shows 100% pass rate** (Vitest + RSpec + Playwright)
5. ✅ **UI consistency verified** (all pages use same header/layout pattern)
6. ✅ **MCP Shadcn components used** (checked `@ss-blocks`, `@ss-components` first)
7. ✅ **PRODUCT_SPEC.md updated** (module added to Core Modules, workflows documented)

**Example for Tasks feature:**
```
✅ spec/models/task_spec.rb
✅ spec/services/tasks/create_spec.rb
✅ spec/services/tasks/update_spec.rb
✅ spec/services/tasks/destroy_spec.rb
✅ spec/policies/task_policy_spec.rb
✅ spec/requests/tasks_spec.rb
❌ app/frontend/pages/Tasks/Index.test.tsx ← MISSING (REQUIRED)
❌ app/frontend/pages/Tasks/New.test.tsx ← MISSING (REQUIRED)
❌ app/frontend/pages/Tasks/Edit.test.tsx ← MISSING (REQUIRED)
❌ e2e/tasks.spec.ts ← MISSING (REQUIRED)
```

**If ANY of these fail or are missing, the feature is NOT complete.**

**Commands to verify:**
```bash
npm run test:all      # Must show ALL tests passing
# Output should show:
# - Vitest: X passed
# - RSpec: X examples, 0 failures
# - Playwright: X passed
```

---

**Remember**: Always check reference files before implementing. Consistency > reinvention.
