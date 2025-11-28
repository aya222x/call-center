# Modern Rails + Inertia.js + React Starter Template

A production-ready Rails 8 application template with React, TypeScript, Inertia.js, and JWT authentication. Built with TDD principles and modern best practices.

## 🚀 Tech Stack

### Backend
- **Rails 8.0.3** - Latest stable Rails version
- **Ruby 3.3.6** - Modern Ruby
- **SQLite** - Database (easily swappable to PostgreSQL)
- **JWT** - Token-based authentication (no cookies, iframe-safe)
- **ActiveInteraction** - Service objects for business logic
- **Pundit** - Authorization policies
- **Pagy** - Fast pagination
- **RSpec** - Test framework with 84 passing tests

### Frontend
- **React 19** - Latest React with concurrent features
- **TypeScript** - Type-safe components
- **Inertia.js** - SPA experience without API complexity
- **Vite** - Lightning-fast asset bundling with HMR
- **Tailwind CSS v4** - Modern utility-first CSS
- **shadcn/ui** - Beautiful, accessible components
  - Dashboard-01 template (sidebar, charts, data tables)
  - Login-03 template (authentication pages)

## ✨ Features

### Authentication & Security
- ✅ JWT-based authentication (localStorage, no cookies)
- ✅ Automatic token refresh (30-day expiration)
- ✅ Refresh token rotation for security
- ✅ Password reset flow
- ✅ CORS configuration for production
- ✅ Secure password hashing with bcrypt

### User Management
- ✅ Three-tier role system (user, admin, super_admin)
- ✅ Super Admin dashboard with user management
- ✅ User CRUD operations (create, read, update, delete)
- ✅ Profile management for all users
- ✅ Pagination with Pagy

### Developer Experience
- ✅ Full TypeScript support
- ✅ TDD with 84 passing specs
- ✅ Factory Bot for test data
- ✅ Shoulda Matchers for clean specs
- ✅ Hot module replacement (HMR)
- ✅ Code quality with RuboCop

## 📦 Installation

### Prerequisites
- Ruby 3.3.6
- Node.js 18+
- SQLite3

### Setup

1. **Clone and install dependencies:**
   ```bash
   bundle install
   npm install
   ```

2. **Setup database:**
   ```bash
   bundle exec rails db:create db:migrate db:seed
   ```

3. **Start development servers:**
   ```bash
   bin/dev
   ```

   This starts both Rails (port 3000) and Vite dev server

4. **Visit http://localhost:3000**

### Default Credentials

After running `db:seed`, you can login with:

- **Super Admin:** admin@example.com / password123
- **Admin:** admin.user@example.com / password123
- **Users:** user1@example.com ... user5@example.com / password123

## 🧪 Testing

Run the full test suite:
```bash
bundle exec rspec
```

Run specific tests:
```bash
bundle exec rspec spec/models
bundle exec rspec spec/services
bundle exec rspec spec/requests
```

## 📁 Project Structure

```
app/
├── controllers/
│   ├── concerns/
│   │   └── authenticatable.rb          # JWT authentication logic
│   ├── admin/
│   │   ├── dashboard_controller.rb
│   │   └── users_controller.rb
│   ├── password/
│   │   └── reset_controller.rb
│   ├── dashboard_controller.rb
│   ├── profiles_controller.rb
│   └── sessions_controller.rb
├── frontend/
│   ├── components/
│   │   └── ui/                          # shadcn/ui components
│   ├── entrypoints/
│   │   ├── inertia.tsx                  # Main Inertia app
│   │   └── application.css              # Tailwind styles
│   ├── lib/
│   │   ├── auth.ts                      # Frontend auth service
│   │   └── utils.ts                     # Utility functions
│   └── pages/
│       ├── Auth/
│       │   └── Login.tsx
│       ├── Admin/
│       │   ├── Dashboard.tsx
│       │   └── Users/Index.tsx
│       ├── Profile/
│       │   └── Show.tsx
│       └── Dashboard.tsx
├── models/
│   ├── user.rb
│   └── refresh_token.rb
└── services/
    └── auth/
        ├── jwt_service.rb               # JWT encoding/decoding
        ├── login.rb                     # Login service
        ├── refresh_token_service.rb     # Token refresh
        ├── request_password_reset.rb
        └── reset_password.rb

spec/
├── models/                              # 33 model specs
├── services/                            # 46 service specs
└── requests/                            # 5 request specs
```

## 🔐 Authentication Flow

### Login
1. User submits email/password to `/session`
2. Backend validates credentials
3. Returns JWT token (24h) + refresh token (30d)
4. Frontend stores tokens in localStorage
5. Automatic token refresh every 20 hours

### Token Refresh
1. Frontend detects token near expiration
2. Sends refresh token to `/session/refresh`
3. Backend validates refresh token
4. Returns new JWT + new refresh token
5. Old refresh token is revoked

### Logout
1. User clicks logout
2. Frontend sends DELETE to `/session` with JWT
3. Backend revokes all user's refresh tokens
4. Frontend clears tokens from localStorage

## 🎨 UI Components

This template includes shadcn/ui components:

- **dashboard-01**: Full dashboard layout with sidebar, charts, and data tables
- **login-03**: Beautiful login page design
- All shadcn/ui primitives (Button, Card, Input, Table, Badge, etc.)

Add more components:
```bash
npx shadcn@latest add [component-name]
```

## 🛠 Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure:

```env
RAILS_ENV=development
ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com
```

### CORS

CORS is configured in `config/initializers/cors.rb`:
- Development: Allows localhost origins
- Production: Uses `ALLOWED_ORIGINS` environment variable

## 📝 API Endpoints

### Authentication
- `POST /session` - Login
- `DELETE /session` - Logout
- `POST /session/refresh` - Refresh JWT token

### Password Reset
- `POST /password/forgot` - Request password reset
- `GET /password/reset?token=xyz` - Show reset form
- `PUT /password/reset` - Update password

### User Management (Super Admin)
- `GET /admin/users` - List all users
- `POST /admin/users` - Create user
- `GET /admin/users/:id` - Show user
- `PATCH /admin/users/:id` - Update user
- `DELETE /admin/users/:id` - Delete user

### Profile
- `GET /profile` - View own profile
- `PATCH /profile` - Update own profile

## 🚢 Deployment

### Production Checklist

1. Set environment variables:
   ```env
   RAILS_ENV=production
   SECRET_KEY_BASE=<your-secret>
   ALLOWED_ORIGINS=https://yourdomain.com
   ```

2. Precompile assets:
   ```bash
   npm run build
   bundle exec rails assets:precompile
   ```

3. Run migrations:
   ```bash
   bundle exec rails db:migrate
   ```

4. Create initial super admin:
   ```bash
   bundle exec rails db:seed
   ```

### Security Considerations

- ✅ JWT tokens stored in localStorage (not cookies)
- ✅ Automatic token rotation
- ✅ CORS properly configured
- ✅ CSRF protection enabled
- ✅ SQL injection prevention via ActiveRecord
- ✅ Password validation (minimum 8 characters)
- ✅ Bcrypt for password hashing

## 🎯 What Makes This Template Different?

1. **Iframe-Safe**: JWT-only approach works in iframes (no third-party cookie issues)
2. **TDD from Start**: 84 passing tests covering all critical paths
3. **Modern Stack**: Latest Rails 8, React 19, TypeScript, Tailwind v4
4. **Production-Ready**: CORS, security headers, token refresh, pagination
5. **Beautiful UI**: shadcn/ui components with dark mode support
6. **Clean Architecture**: Service objects, concerns, proper separation
7. **Type-Safe**: TypeScript on frontend for better DX

## 📚 Learn More

- [Inertia.js Documentation](https://inertiajs.com)
- [shadcn/ui Components](https://ui.shadcn.com)
- [Rails Guides](https://guides.rubyonrails.org)
- [Tailwind CSS](https://tailwindcss.com)

## 🎭 Demo Mode

The system includes a **Demo Mode** for presentations and testing without using OpenAI API credits.

### Enabling Demo Mode

Add to your `.env` file:

```bash
USE_DEMO_MODE=true
```

### What Demo Mode Does

When enabled, the system will:

✅ **Generate Realistic Transcripts**
- Creates demo transcripts in 3 languages (Kyrgyz, Russian, English)
- Simulates natural call center conversations
- Includes random variations for each recording

✅ **Generate Realistic Evaluations**
- Creates scores between 70-95 for each KPI metric
- Provides context-appropriate recommendations in multiple languages
- Simulates processing delays (1-4 seconds) for realism

✅ **No OpenAI API Calls**
- Zero cost for demonstrations
- No rate limits
- Instant results (with simulated delays)

### Use Cases

- **Client Demonstrations**: Show full system functionality without API costs
- **UI/UX Testing**: Test interface with various score ranges
- **Training**: Familiarize team with the system before production
- **Development**: Work on features without API dependencies

### Disabling Demo Mode

To use real OpenAI API:

```bash
# In .env file, change to:
USE_DEMO_MODE=false

# Or remove the line entirely
```

Then ensure your `OPENAI_API_KEY` is set correctly.

### Demo Mode vs Production

| Feature | Demo Mode | Production (OpenAI) |
|---------|-----------|---------------------|
| Cost | Free | ~$0.03 per call |
| Processing Time | 3-7 seconds | 10-30 seconds |
| Transcript Quality | Pre-written templates | Actual audio transcription |
| Evaluation Accuracy | Random (70-95) | AI-powered analysis |
| Languages | All 3 supported | All 3 supported |
| Recommendations | Template-based | Context-aware |

