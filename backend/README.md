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

**Expected Response (201 Created):**
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

**Expected Response (201 Created):**
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

**Expected Response (200 OK):**
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
$job_id = "job-uuid-here"  # Job ID to get applications for

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri "http://localhost:8000/transactions/$job_id/applicants" -Method GET -Headers $headers
```

**Expected Response (200 OK):**
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

---

## Important Notes

- **Token Format:** Always use `Authorization: Bearer <token>` header for protected endpoints
- **Token Expiration:** Tokens expire after 7 days
- **Invalid Credentials:** Returns 401 Unauthorized
- **Token Validation:** If token is invalid or expired, you'll receive a 401 error with message "Could not validate credentials"
- **User Verification:** User must be verified to access certain endpoints
