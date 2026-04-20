# Endpoint Commands

## Authentication Flow

### 1. Register a New User

```powershell
$body = @{
    full_name = "John Doe"
    phone_number = "09876543210"
    role = "resident"
    password = "your_password"
    is_verified = $true
} | ConvertTo-Json

Invoke-RestMethod -Uri http://localhost:8000/auth/register -Method POST -Body $body -ContentType "application/json"
```

**Response:**
```json
{
    "message": "User created successfully",
    "user_id": "uuid-here"
}
```


### 2. Login and Get JWT Token

```powershell
$body = @{
    phone_number = "09876543210"
    password = "your_password"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri http://localhost:8000/auth/login -Method POST -Body $body -ContentType "application/json"
$token = $response.access_token
$token  # Display the token
```

**Response:**
```json
{
    "access_token": "put_your_jwt_token_here",
    "token_type": "bearer",
    "user": {
        "id": "uuid-here",
        "full_name": "John Doe",
        "is_verified": false
    }
}
```


### 3. Sanity Check with Protected Endpoint

Once you have the token from login, use it to access protected endpoints:

```powershell
# Store the token from login response
$token = "put_your_jwt_token_here" 

# Access protected endpoint
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri http://localhost:8000/auth/me -Method GET -Headers $headers
```

**Expected Response:**
```json
{
    "id": "uuid-here",
    "full_name": "John Doe",
    "phone_number": "09876543210",
    "role": "resident",
    "is_verified": false
}
```

---

## Job Management

### 1. Create a New Job Post

**Prerequisites:** User must be authenticated

```powershell
$token = "put_your_jwt_token_here"  # Token from login

$body = @{
    title = "House Cleaning"
    description = "Need help cleaning house"
    location = "123 Main St"
    salary = 500.00
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri http://localhost:8000/jobs/create -Method POST -Body $body -Headers $headers -ContentType "application/json"
```

**Expected Response:**
```json
{
    "message": "Job posted successfully",
    "job_id": "job-uuid-here"
}
```

### 2. Get All Job Posts

```powershell
Invoke-RestMethod -Uri http://localhost:8000/jobs/ -Method GET
```

#### Search and Filter Jobs

You can combine query parameters to find specific jobs.

Supported params:
- `q`: keyword in title/description
- `location`: exact barangay/location
- `status`: `open`, `assigned`, `completed`
- `min_salary`, `max_salary`
- `poster_id`
- `skills`: comma-separated keywords matched against title/description

```powershell
Invoke-RestMethod -Uri "http://localhost:8000/jobs/?q=cleaning&location=Gulang-Gulang&status=open&min_salary=300&max_salary=800&skills=cleaning,laundry" -Method GET
```

**Expected Response:**
```json
[
    {
        "id": "job-uuid-here",
        "title": "House Cleaning",
        "description": "Need help cleaning house",
        "poster_id": "job_poster-uuid-here",
        "status": "open",
        "last_modified": "2026-03-07T10:30:00",
        "is_synced": true
    },
    ...
]
```

---

## Job Applications & Transactions

### 1. Apply for a Job

**Prerequisites:** User must be authenticated

```powershell
$token = "put_your_jwt_token_here"  # Token from login 
$job_id = "job-uuid-here"  # Job ID to apply for

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri "http://localhost:8000/transactions/apply/$job_id" -Method POST -Headers $headers
```

**Expected Response:**
```json
{
    "message": "Application Submitted"
}
```

### 2. Hire a Provider

**Prerequisites:** User must be the job poster (requester)

```powershell
$token = "put_your_jwt_token_here"  # Token from login (job poster)
$transaction_id = "transaction-uuid-here"  # Transaction ID of the application to hire

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri "http://localhost:8000/transactions/hire/$transaction_id" -Method PATCH -Headers $headers
```

**Expected Response:**
```json
{
    "message": "Provider hired successfully",
    "transaction_id": "transaction-uuid-here"
}
```

### 3. Get Applications for a Job

**Prerequisites:** User must be the job poster (requester)

```powershell
$token = "put_your_jwt_token_here"  # Token from login (job poster)
$job_id = "job-uuid-here"  # Job ID to get applicants

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri "http://localhost:8000/transactions/$job_id/applicants" -Method GET -Headers $headers
```

#### Search and Filter Applications

Supported params:
- `q`: applicant name or phone
- `status`: application status (`applied`, `hired`, `completed`, `canceled`)
- `min_rating`: minimum applicant rating
- `min_jobs_done`: minimum number of completed jobs
- `skills`: comma-separated applicant skills (all listed skills are required)

```powershell
Invoke-RestMethod -Uri "http://localhost:8000/transactions/$job_id/applicants?status=applied&min_rating=4&min_jobs_done=3&skills=plumbing,electrical&q=juan" -Method GET -Headers $headers
```

### 4. Filter My Transactions

You can also filter the authenticated user's transactions:

Supported params:
- `q`: keyword in job title/location/counterpart name
- `status`: transaction status
- `location`: exact job location
- `role`: `requester` or `provider`

```powershell
Invoke-RestMethod -Uri "http://localhost:8000/transactions/me?status=hired&role=provider&q=repair" -Method GET -Headers $headers
```

**Expected Response:**
```json
{
    "applicants": [
        {
            "id": "transaction-uuid-1",
            "job_id": "job-uuid-here",
            "provider_id": "provider-uuid-1",
            "requester_id": "job_poster-uuid-here",
            "status": "applied",
            "accepted_at": "2026-03-08T10:30:00"
        },
        {
            "id": "transaction-uuid-2",
            "job_id": "job-uuid-here",
            "provider_id": "provider-uuid-2",
            "requester_id": "job_poster-uuid-here",
            "status": "applied",
            "accepted_at": "2026-03-08T11:00:00"
        }
    ]
}
```

### 4. Mark Job as Completed (Dual Confirmation)

**Prerequisites:** User must be authenticated (either requester or provider). Both parties must confirm completion separately.

```powershell
$token = "put_your_jwt_token_here"  # Token from login
$transaction_id = "transaction-uuid-here"  # Transaction ID to mark as completed

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri "http://localhost:8000/transactions/complete/$transaction_id" -Method PATCH -Headers $headers
```

**Expected Response:**
```json
{
    "message": "Completion marked by one party. Waiting for the other party to confirm.",
    "transaction_id": "transaction-uuid-here"
}
```

**Expected Response:**
```json
{
    "message": "Job marked as completed by both parties",
    "transaction_id": "transaction-uuid-here"
}
```

### 5. Rate a Service Provider

**Prerequisites:** User must be the job poster (requester) and the job must be completed

```powershell
$token = "put_your_jwt_token_here"  # Token from login (job poster)
$transaction_id = "transaction-uuid-here"  # Transaction ID to rate

$body = @{
    score = 5
    comment = "Great work! The provider did an excellent job."
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri "http://localhost:8000/ratings/$transaction_id/rate" -Method POST -Body $body -Headers $headers
```

**Expected Response:**
```json
{
    "message": "Rating submitted successfully",
    "rating_id": "rating-uuid-here",
    "score": 5
}
```

### 6. Get Provider's Rating

```powershell
$provider_id = "provider-uuid-here"

Invoke-RestMethod -Uri "http://localhost:8000/ratings/providers/$provider_id" -Method GET
```

**Expected Response (200 OK):**
```json
{
    "provider_id": "provider-uuid-here",
    "average_rating": 4.5,
    "total_ratings": 10,
    "ratings": [
        {
            "score": 5,
            "comment": "Excellent work!",
            "created_at": "2026-03-09T15:30:00"
        },
        {
            "score": 4,
            "comment": "Good job, very responsive",
            "created_at": "2026-03-08T10:20:00"
        }
    ]
}
```

---

## Quick Reference

### Using Curl (Windows PowerShell)

**Register:**
```powershell
curl -X POST http://localhost:8000/auth/register -H "Content-Type: application/json" -d "{\"full_name\":\"John Doe\",\"phone_number\":\"09123456789\",\"role\":\"resident\",\"password\":\"your_password\"}"
```

**Login:**
```powershell
curl -X POST http://localhost:8000/auth/login -H "Content-Type: application/json" -d "{\"phone_number\":\"09123456789\",\"password\":\"your_password\"}"
```

**Access Protected Endpoint:**
```powershell
curl -X GET http://localhost:8000/auth/me -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Create Job Post:**
```powershell
curl -X POST http://localhost:8000/jobs/create -H "Authorization: Bearer YOUR_TOKEN_HERE" -H "Content-Type: application/json" -d "{\"title\":\"House Cleaning\",\"description\":\"Need help cleaning house\",\"location\":\"123 Main St\",\"salary\":500}"
```

**Get Job Posts:**
```powershell
curl -X GET http://localhost:8000/jobs/
```

**Apply for Job:**
```powershell
curl -X POST http://localhost:8000/transactions/apply/JOB_ID_HERE -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Hire a Provider:**
```powershell
curl -X PATCH http://localhost:8000/transactions/hire/TRANSACTION_ID_HERE -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Get Job Applicants:**
```powershell
curl -X GET http://localhost:8000/transactions/JOB_ID_HERE/applicants -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Mark Job as Completed:**
```powershell
curl -X PATCH http://localhost:8000/transactions/complete/TRANSACTION_ID_HERE -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Rate a Provider:**
```powershell
curl -X POST http://localhost:8000/transactions/TRANSACTION_ID_HERE/rate -H "Authorization: Bearer YOUR_TOKEN_HERE" -H "Content-Type: application/json" -d "{\"score\":5,\"comment\":\"Great work!\"}"
```

**Get Provider Rating:**
```powershell
curl -X GET http://localhost:8000/providers/PROVIDER_ID_HERE/rating
```

---

## Important Notes

- **Token Format:** Always use `Authorization: Bearer <token>` header for protected endpoints
- **Token Expiration:** Tokens expire after 7 days
- **Invalid Credentials:** Returns 401 Unauthorized
- **Token Validation:** If token is invalid or expired, you'll receive a 401 error with message "Could not validate credentials"
- **User Verification:** User must be verified to access certain endpoints
