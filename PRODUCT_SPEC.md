# Product Specification

## Call Center KPI Evaluation System

An AI-powered application for evaluating call center operator performance through automated analysis of call recordings. The system transcribes audio calls in multiple languages (Kyrgyz, Russian, English) and evaluates operators against 5 key performance indicators using OpenAI's GPT-4.

---

## Core Features

### 1. Multi-Language Call Analysis
- **Audio Transcription**: Automatic transcription using OpenAI Whisper API
- **Supported Languages**: Kyrgyz, Russian, English
- **AI Evaluation**: GPT-4 powered analysis against call scripts and KPIs
- **5 KPI Metrics**:
  - Script Adherence (how well operator follows script)
  - Politeness & Tone (professionalism and friendliness)
  - Resolution Speed (efficiency in addressing customer needs)
  - Terminology Usage (correct use of professional terms)
  - Call Success (achievement of call goals)

### 2. Organizational Structure
- **Departments**: Two departments (Sales, Bank)
- **Teams**: Groups within departments with assigned supervisors
- **Call Scripts**: Department-specific scripts for different call types (sales, support, survey)
- **Role-Based Access**: 4 roles with different permissions

### 3. User Roles & Permissions

#### Admin
- Manage all departments and teams
- Create and edit call scripts
- View all recordings and evaluations across organization
- Full system configuration access

#### Manager
- View all recordings and evaluations
- Monitor performance across all departments
- Generate and export reports
- Manage operators (add, edit, deactivate)

#### Supervisor
- View recordings for their assigned team only
- Monitor team performance
- Cannot modify recordings or scripts

#### Operator
- Upload call recordings
- View only their own recordings and evaluations
- Track personal performance over time

### 4. Call Recording Management
- **Manual Upload**: Operators upload audio files (mp3, wav formats)
- **Metadata**: Customer name, phone, call date, duration
- **Processing States**: Uploaded → Transcribing → Analyzing → Completed/Failed
- **Error Handling**: Failed recordings show error messages for troubleshooting

### 5. Evaluation & Scoring
- **Overall Score**: 0-100 scale calculated from 5 KPI averages
- **Individual Scores**: Each KPI scored 0-100
- **AI Recommendations**: Personalized improvement suggestions
- **Score Labels**: Excellent (90+), Good (80-89), Satisfactory (70-79), Needs Improvement (60-69), Poor (<60)
- **Color Coding**: Green (80+), Yellow (60-79), Orange (40-59), Red (<40)

### 6. Analytics & Reporting
- **Dashboard**: Overview statistics with key metrics
- **Performance Trends**: Graphs showing score changes over time
- **Comparative Analysis**: Team and individual comparisons
- **Export Options**: PDF and Excel report generation
- **Time Periods**: Daily, weekly, monthly aggregations

---

## Technical Implementation

### Backend Architecture
- **Framework**: Rails 8.0.2.1 with Ruby 3.3.6
- **Database**: SQLite with 6 main tables (users, departments, teams, call_scripts, call_recordings, evaluations)
- **Service Objects**: ActiveInteraction for business logic (OpenAI transcription/evaluation)
- **Authorization**: Pundit policies for role-based access control
- **Audit Trail**: Audited gem tracks all changes

### Frontend Stack
- **UI**: React with TypeScript via Inertia.js (SPA experience)
- **Styling**: Tailwind CSS v4 with shadcn/ui components
- **Build**: Vite for fast hot module replacement
- **State**: Inertia.js page props (no separate state management needed)

### AI Integration
- **Provider**: OpenAI API (GPT-4 for evaluation, Whisper for transcription)
- **Transcription**: Whisper-1 model with language detection
- **Evaluation**: GPT-4 with custom prompts for structured JSON responses
- **Error Handling**: Automatic retry logic and detailed error messages

### Testing Strategy (Level 3 - Production Ready)
- **Backend**: RSpec for models, services, policies, controllers
- **Frontend**: Vitest for React components and pages
- **E2E**: Playwright for user workflows
- **Coverage**: 175+ specs ensuring comprehensive test coverage

---

## Key Workflows

### Call Upload & Evaluation Flow
1. Operator uploads audio file with metadata
2. System validates file and creates recording (status: uploaded)
3. Background job triggers OpenAI Whisper transcription (status: transcribing)
4. Transcript saved, AI evaluation begins (status: analyzing)
5. GPT-4 analyzes transcript against script, scores 5 KPIs
6. Evaluation created with scores and recommendations (status: completed)
7. Operator receives notification of results

### Performance Review Flow
1. Supervisor/Manager accesses dashboard
2. Views team performance metrics and trends
3. Drills down to individual operator details
4. Reviews specific call recordings and evaluations
5. Identifies training needs from AI recommendations
6. Exports reports for management review

### Script Management Flow (Admin Only)
1. Admin creates new call script for department
2. Defines script content and call type
3. Associates with specific department
4. Activates script for operator use
5. Updates script based on performance data

---

## Data Models

### Department
- **Fields**: name, deactivated_at
- **Relations**: has many teams, call_scripts
- **Examples**: "Sales Department", "Bank Department"

### Team
- **Fields**: name, department_id, supervisor_id, deactivated_at
- **Relations**: belongs to department, has supervisor (User), has many users
- **Examples**: "Sales Team Alpha", "Bank Support Team"

### User
- **Fields**: email, name, password, role, team_id, admin
- **Roles**: operator, supervisor, manager, admin
- **Relations**: belongs to team (optional), has many call_recordings

### CallScript
- **Fields**: name, call_type, content, department_id, active
- **Call Types**: sales, support, survey, other
- **Relations**: belongs to department, has many call_recordings

### CallRecording
- **Fields**: user_id, call_script_id, status, language, call_date, duration_seconds, transcript, customer_name, customer_phone, error_message
- **Statuses**: uploaded, transcribing, analyzing, completed, failed
- **Languages**: kyrgyz, russian, english
- **Relations**: belongs to user, call_script; has one evaluation

### Evaluation
- **Fields**: call_recording_id, overall_score, script_adherence_score, politeness_score, resolution_speed_score, terminology_score, success_score, recommendations
- **Score Range**: 0-100 (decimal with 2 precision)
- **Relations**: belongs to call_recording (unique constraint)

---

## Security & Authorization

### Authorization Matrix

| Action | Operator | Supervisor | Manager | Admin |
|--------|----------|------------|---------|-------|
| View own recordings | ✅ | ✅ | ✅ | ✅ |
| View team recordings | ❌ | ✅ (own team) | ✅ (all) | ✅ (all) |
| Upload recordings | ✅ | ✅ | ✅ | ✅ |
| Edit recordings | ❌ | ❌ | ✅ | ✅ |
| Delete recordings | ❌ | ❌ | ✅ | ✅ |
| View call scripts | ✅ | ✅ | ✅ | ✅ |
| Create/edit scripts | ❌ | ❌ | ❌ | ✅ |
| View departments | ❌ | ❌ | ✅ | ✅ |
| Manage departments | ❌ | ❌ | ❌ | ✅ |
| Generate reports | ❌ | ✅ | ✅ | ✅ |

### Data Protection
- **JWT Authentication**: Secure token-based auth (iframe compatible)
- **Encrypted Passwords**: BCrypt with secure password requirements
- **Audit Logging**: All changes tracked with user attribution
- **Access Control**: Pundit policies enforce role-based restrictions
- **File Validation**: Audio file size and type restrictions

---

## Deployment Configuration

### Environment Variables
- `OPENAI_API_KEY`: Required for transcription and evaluation
- `DATABASE_URL`: SQLite database location
- `RAILS_ENV`: production/development/test
- `SECRET_KEY_BASE`: Rails secret for sessions

### Infrastructure Requirements
- **Web Server**: Puma (multi-threaded)
- **Background Jobs**: Solid Queue for async processing
- **File Storage**: Active Storage (local or S3-compatible)
- **Database**: SQLite (upgradeable to PostgreSQL)

---

## Future Enhancements (TODO NEXT)

### Phase 2 Features
- [ ] Real-time transcription during live calls
- [ ] Automated email reports to supervisors
- [ ] Custom KPI weights per department
- [ ] Integration with CRM systems (Salesforce, HubSpot)
- [ ] Voice analytics (tone detection, speech rate)
- [ ] Multi-tenant support for agencies

### Phase 3 Features
- [ ] Live call monitoring with real-time scoring
- [ ] Gamification with leaderboards and badges
- [ ] Advanced analytics with predictive insights
- [ ] Mobile app for operators
- [ ] Speech-to-text live coaching
- [ ] Sentiment analysis integration

---

## Development Status

### ✅ Completed (Production Ready - Level 3)
- Database schema with 6 tables and proper indexes
- 5 ActiveRecord models with validations and associations
- 3 Pundit policies for role-based authorization
- 2 OpenAI service objects (transcription + evaluation)
- User authentication with JWT tokens
- Audit trail for all model changes
- **Test Coverage**: 175 specs (88 models + 51 policies + 36 services) - ALL GREEN ✅

### 🚧 In Progress
- Controllers with request specs (departments, call_scripts, call_recordings, dashboard)
- React UI pages with Vitest tests
- Playwright E2E tests for user workflows

### 📋 Planned
- Final health check and integration testing
- Documentation and deployment guide

---

*This system transforms call center quality assurance from manual review to AI-powered automated evaluation, enabling data-driven training and performance improvement at scale.*
