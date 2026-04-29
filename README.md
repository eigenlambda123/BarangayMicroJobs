# BarangayMicroJobs

A Flutter-based community platform designed to connect local residents with micro-job opportunities within their barangay. The application enables residents to post jobs, offer services, and build a localized reputation through ratings and reviews.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [User Roles](#user-roles)
- [Application Screens](#application-screens)
- [Key Features in Detail](#key-features-in-detail)
- [Architecture](#architecture)
- [Development Setup](#development-setup)
- [Daily Workflow](#daily-workflow)
- [Technology Stack](#technology-stack)
- [Quality Attributes](#quality-attributes)

---

## Overview

**BarangayMicroJobs** is a mobile-first platform that promotes localized economic activity by connecting barangay residents for short-term tasks and skill-based services. The system supports offline functionality, ensuring accessibility even with unstable internet connectivity, and provides a safe, community-driven marketplace for micro-jobs.

### Key Objectives
- ✅ Provide a centralized platform for posting and browsing micro-jobs
- ✅ Enable residents to offer skills and services within their barangay
- ✅ Facilitate job acceptance, completion tracking, and feedback
- ✅ Support offline-first functionality with automatic synchronization
- ✅ Enable community reputation building through ratings and reviews

---

## Features

### 1. User Authentication & Profile Management
- **Phone Number Registration**: Residents register using a unique phone number and password
- **JWT Authentication**: Secure token-based authentication for API requests
- **Profile Management**: Users can update their information including:
  - Full name and contact details
  - Skills and specialties
  - Profile picture
  - Location information
  - Verification status (admin-controlled)
- **Role-based Access**: Support for regular users and administrator roles

### 2. Job Posting & Management
- **Create Job Posts**: Post micro-job requests with:
  - Job title and detailed description
  - Budget/salary information
  - Location within barangay
  - Optional job images
  - Job categories
- **Edit/Cancel Jobs**: Modify job details before assignment
- **Job Status Tracking**: Jobs progress through states:
  - `Open` - Available for applications
  - `Assigned` - Provider has been selected
  - `Completed` - Job is finished
  - `Cancelled` - Job was cancelled
- **View Posted Jobs**: Track all jobs you've posted

### 3. Job Marketplace & Discovery
- **Browse Available Jobs**: View all open jobs posted by other residents
- **Search & Filter**: Find jobs using:
  - Keywords/text search
  - Location filters
  - Salary range filters
  - Job status filters
  - Filter combinations
- **Job Details**: View comprehensive job information before applying
- **Marketplace Overview**: Dashboard showing:
  - Total available jobs count
  - Jobs you can apply to
  - Quick action buttons

### 4. Job Applications & Transactions
- **Apply for Jobs**: Submit applications to available job postings
- **Review Applicants**: Job posters can:
  - View all applicants for a job
  - Review applicant profiles and ratings
  - Select and hire desired providers
  - Prevent duplicate hiring (one provider per job)
- **Transaction Management**: Track application and hiring progress with states:
  - `Applied` - Initial application submitted
  - `Hired` - Provider selected by job poster
  - `Completed` - Work completed by both parties
- **Mark as Complete**: Either party can mark a transaction as completed

### 5. Offline-First Data Synchronization
- **Local Storage**: All data stored locally in SQLite database
- **Offline Operations**: Full functionality without internet:
  - Browse cached jobs
  - Create job posts
  - Apply for jobs
  - View profiles and history
- **Automatic Synchronization**: Data syncs automatically when connection is restored
- **Sync Status Tracking**: System tracks which records have been synced
- **Conflict Resolution**: Uses "Last Modified" timestamps to handle conflicts

### 6. Feedback & Ratings System
- **Leave Ratings**: Rate transaction counterparts (1-5 stars) after job completion
- **Comments**: Add optional feedback comments
- **Average Ratings**: System calculates and displays user average rating
- **Reputation Building**: Build community trust through consistent ratings
- **Rating Restrictions**: One rating per unique transaction

### 7. Activity & History Tracking
- **Job History**: View all your posted and completed jobs
- **Transaction History**: Track all job applications and hires
- **Performance Metrics**: See statistics like:
  - Jobs posted
  - Jobs completed
  - Total earnings/spent
  - Average rating
- **Status Timeline**: View chronological updates for each transaction

### 8. Administrative Features
- **User Verification**: Admins can verify/approve residents
- **Content Moderation**: Tools to monitor and manage job postings
- **Activity Monitoring**: View system-wide activity reports
- **Audit Trail**: Track synchronization events and data updates

---

## User Roles

### 1. Barangay Resident
**Primary users** who can:
- Register and maintain a profile
- Post micro-jobs (Job Poster role)
- Apply for jobs (Service Provider role)
- Rate transaction partners
- View and manage their jobs and applications
- Build community reputation

**Characteristics:**
- May have limited technical experience
- Use primarily on smartphones
- May experience intermittent internet connectivity

### 2. Service Provider
Residents who actively:
- Accept and complete jobs
- Build a reputation through ratings
- Earn from completed work
- Track their performance metrics

### 3. Barangay Admin/Moderator
Authorized personnel who:
- Verify resident accounts
- Monitor and moderate content
- Review activity reports
- Maintain system oversight
- Manage disputes and ensure community safety

---

## Application Screens

### Authentication Flow
| Screen | Purpose |
|--------|---------|
| **Login Screen** | Phone number and password authentication |
| **Register Screen** | New user registration and account creation |
| **Onboarding Screen** | Welcome and feature introduction |
| **Launch Gate** | Initial app routing based on auth status |

### Main Application
| Screen | Purpose |
|--------|---------|
| **Marketplace Screen** | Home page with job listings, filters, overview |
| **Post Job Screen** | Create and submit new job postings |
| **Job Details Screen** | Comprehensive job information and application |
| **Profile Screen** | User profile, stats, settings, and logout |
| **Activity Screen** | View job history and transaction details |
| **History Screen** | Detailed transaction and job history |
| **My Applications Screen** | Track jobs you've applied to |
| **Transaction Details Screen** | View details of completed transactions |

---

## Key Features in Detail

### 📱 Marketplace Screen
The main hub where users:
- View available jobs in a scrollable list
- Search jobs by keywords
- Filter by location, salary range, and status
- See overview statistics
- Post new jobs via floating action button
- Navigate to other sections via bottom navigation

**Features:**
- Real-time job listings with offline support
- Pull-to-refresh functionality
- Smart filtering with apply/reset buttons
- Job count overview card
- Marketplace background visual design

### 💼 Job Posting
Complete job creation form with:
- **Title**: What needs to be done (max 50 chars)
- **Description**: Detailed task explanation (max 500 chars)
- **Location**: Barangay location/zone
- **Budget**: Salary/payment amount
- **Image**: Optional job image upload
- **Draft Saving**: Automatically saves as you type
- **Validation**: Ensures all required fields before submission

### 🔍 Smart Search & Filters
Advanced filtering system with:
- **Text Search**: Keywords in job titles/descriptions
- **Location Filters**: Filter by specific zones
- **Salary Range**: Min and max budget filtering
- **Status Filters**: Open, assigned, or completed jobs
- **Combination Filters**: Apply multiple filters simultaneously
- **Clear Filters**: One-click reset to show all jobs

### ⭐ Rating & Feedback
Post-completion rating system:
- **Star Rating**: 1-5 star rating scale
- **Written Feedback**: Optional detailed comments
- **Rating Calculation**: Auto-calculated average rating
- **Reputation Building**: Public rating display
- **One Rating Per Transaction**: Prevents duplicate ratings

### 📊 Activity & Statistics
Dashboard showing:
- Total jobs posted
- Total jobs completed
- Total earnings/spent
- Average user rating
- Active and inactive transactions
- Complete transaction history with timestamps

### 🔄 Offline Synchronization
Intelligent sync system:
- **Automatic Detection**: Detects internet availability
- **Background Sync**: Syncs data without interrupting users
- **Sync Status Indicator**: Shows which records are synced
- **Conflict Prevention**: Last-modified timestamp resolution
- **Partial Sync**: Handles partial connectivity gracefully

---

## Architecture

### Technology Stack

**Frontend:**
- **Framework**: Flutter (Dart)
- **UI Components**: Material Design 3
- **State Management**: Provider pattern
- **Local Storage**: SQLite database
- **HTTP Client**: Dio for API calls
- **Image Handling**: Image picker for uploads

**Backend:**
- **Framework**: FastAPI (Python)
- **Database**: Relational database (configurable)
- **Authentication**: JWT tokens
- **Async Processing**: Uvicorn ASGI server
- **File Storage**: Local uploads directory

### Project Structure

```
barangay_microjobs/
├── mock_frontend/app/              # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart              # App entry point
│   │   ├── screens/               # All app screens
│   │   ├── services/              # API & sync services
│   │   ├── models/                # Data models
│   │   ├── widgets/               # Reusable components
│   │   ├── utils/                 # Helper utilities
│   │   └── config/                # Configuration files
│   ├── ios/                       # iOS build files
│   ├── android/                   # Android build files
│   └── pubspec.yaml               # Flutter dependencies
├── backend/                        # FastAPI backend
│   ├── app/
│   │   ├── main.py                # FastAPI app setup
│   │   ├── routers/               # API route handlers
│   │   ├── schemas/               # Pydantic models
│   │   ├── models.py              # Database models
│   │   └── database.py            # Database config
│   ├── scripts/                   # Utility scripts
│   ├── requirements.txt           # Python dependencies
│   └── README.md                  # Backend documentation
└── UMLDiagrams/                   # Design diagrams
```

### Data Model

**Core Entities:**
- **User**: Resident profile with ratings and verification status
- **JobPost**: Job listing with poster reference and status
- **JobTransaction**: Application/hiring relationship between users
- **Rating**: Feedback and ratings for completed transactions

**Relationships:**
- A User creates many JobPosts
- Multiple Users apply via JobTransactions for one JobPost
- A JobPost has one successful JobTransaction
- A Rating is created per JobTransaction

---

## Development Setup

### Frontend Setup (Flutter App)

1. **Navigate to frontend directory:**
   ```bash
   cd mock_frontend/app
   ```

2. **Get Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app (with backend running):**
   ```bash
   flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
   ```

4. **Build APK (for testing on Android):**
   ```bash
   flutter build apk --dart-define=API_BASE_URL=http://127.0.0.1:8000
   ```

### Backend Setup

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Create a virtual environment:**
   ```bash
   python -m venv venv
   ```

3. **Activate the virtual environment:**
   - On Windows:
     ```bash
     venv\Scripts\activate
     ```
   - On macOS/Linux:
     ```bash
     source venv/bin/activate
     ```

4. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

5. **Run the FastAPI server:**
   ```bash
   uvicorn app.main:app --reload
   ```
   - Server runs on `http://127.0.0.1:8000`
   - API docs available at `http://127.0.0.1:8000/docs`

---

## Daily Workflow

To keep your local code in sync with the team:

1. **Pull latest changes:**
   ```bash
   git pull origin main
   ```

2. **Create a feature branch (if working on new feature):**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Stage your changes:**
   ```bash
   git add .
   ```

4. **Commit with descriptive message:**
   ```bash
   git commit -m "feat: add feature description"
   ```

5. **Push to GitHub:**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request** for code review before merging to main

---

## Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Frontend | Flutter & Dart | Mobile app development |
| Backend | FastAPI & Python | REST API server |
| Database | SQLite (local) / PostgreSQL (server) | Data persistence |
| Auth | JWT Tokens | Secure authentication |
| Storage | File system | User uploads and images |
| Version Control | Git & GitHub | Code management |

---

## Quality Attributes

### Usability
- Simple mobile-first interface
- Intuitive navigation with bottom tab bar
- Clear icons and readable typography
- Minimal steps to post/apply for jobs
- No formal training required for new users

### Performance
- App fully interactive within 5 seconds on launch
- Page transitions load within 3 seconds
- Support for 30+ concurrent users
- Smooth scrolling without lag
- Background sync doesn't interrupt user tasks

### Security
- Phone number + password authentication
- Passwords encrypted/hashed before storage
- JWT token-based authorization
- Role-based access control
- Admin-only moderation functions

### Reliability
- Minimal crashes during normal use
- Data persists after app restart
- Graceful recovery from connection loss
- Regular backup of transaction data
- Safe error messages without exposing private data

### Offline Capability
- Full app functionality without internet
- Local SQLite database caching
- Automatic sync when online
- Conflict-free data synchronization
- Transparent offline/online status

### Localization
- English (Philippines) UI language
- Support for regional dialects (Tagalog, Visayan) in user content
- MM/DD/YYYY date format (local convention)
- Philippine Peso (₱) currency formatting
- Metric system for measurements

---

## API Documentation

### Backend API Routes

**Authentication:**
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login with phone & password
- `POST /auth/logout` - Logout and invalidate token

**Jobs:**
- `GET /jobs` - Get all jobs (with filters)
- `POST /jobs` - Create new job posting
- `GET /jobs/{id}` - Get job details
- `PUT /jobs/{id}` - Update job (poster only)
- `DELETE /jobs/{id}` - Cancel job (poster only)

**Transactions:**
- `GET /transactions` - Get user transactions
- `POST /transactions` - Create job application
- `PUT /transactions/{id}` - Update transaction status
- `GET /transactions/{id}` - Get transaction details

**Ratings:**
- `POST /ratings` - Submit rating for transaction
- `GET /ratings/{user_id}` - Get user ratings

**Users:**
- `GET /users/{id}` - Get user profile
- `PUT /users/{id}` - Update user profile
- `GET /users/{id}/stats` - Get user statistics

Full API documentation available at: `http://localhost:8000/docs`

---

## Data Privacy & Compliance

- Soft-delete policy for user data deletion
- Automatic removal of session tokens on logout
- Compliance with local privacy standards
- Audit trail for all transactions
- User data retention for community reputation

---

## Future Enhancements

Planned features for future releases:
- Advanced matching algorithms for job recommendations
- Payment integration for direct transfers
- Real-time notifications
- Reputation-based job recommendations
- Advanced analytics and reporting
- Multi-barangay support
- Video profiles and job previews
- In-app messaging system

---

## Support & Documentation

- **SRS Document**: See `Software Requirements Specification for Barangay MicroJobs`
- **Backend README**: See `backend/README.md` for detailed backend documentation
- **UML Diagrams**: See `UMLDiagrams/` for system architecture diagrams
- **Issue Tracking**: Report bugs and feature requests on GitHub Issues

---

## Contributors

- Alegre, Raphael Hugo I.
- Altamira, Lester Adriane D.
- Cadeliña, Iggy Michael V.
- Villa, Rodmark Bernard A.
- Villapando, Gabriel Salvadore E.

Manuel S. Enverga University Foundation - February 2026

---

**Version**: 1.0 (Approved)  
**Last Updated**: April 2026

