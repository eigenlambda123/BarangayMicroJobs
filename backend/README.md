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

**Prerequisites:** User must be authenticated and verified

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

Invoke-RestMethod -Uri http://localhost:8000/jobs/ -Method POST -Body $body -Headers $headers -ContentType "application/json"
```

**Expected Response (201 Created):**
```json
{
    "id": "job-uuid-here",
    "title": "House Cleaning",
    "description": "Need help cleaning house",
    "poster_id": "job_poster-uuid-here",
    "status": "open",
    "last_modified": "2026-03-07T10:30:00",
    "is_synced": true
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

### 3. Accept a Job Post

**Prerequisites:** User must be authenticated and the job must be in "open" status

```powershell
$token = "put_your_jwt_token_here"  # Token from login
$job_id = "put_job_id_here"  # Job ID to accept

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri "http://localhost:8000/transactions/accept/$job_id" -Method POST -Headers $headers
```

**Expected Response (200 OK):**
```json
{
    "message": "Job accepted successfully",
    "transaction_id": "transaction-uuid-here"
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
curl -X POST http://localhost:8000/jobs/ -H "Authorization: Bearer YOUR_TOKEN_HERE" -H "Content-Type: application/json" -d "{\"title\":\"House Cleaning\",\"description\":\"Need help cleaning house\"}"
```

**Accept Job Post:**
```powershell
curl -X POST http://localhost:8000/transactions/accept/JOB_ID_HERE -H "Authorization: Bearer YOUR_TOKEN_HERE" -H "Content-Type: application/json"
```

---

## Important Notes

- **Token Format:** Always use `Authorization: Bearer <token>` header for protected endpoints
- **Token Expiration:** Tokens expire after 7 days
- **Invalid Credentials:** Returns 401 Unauthorized
- **Token Validation:** If token is invalid or expired, you'll receive a 401 error with message "Could not validate credentials"
- **User Verification:** User must be verified to access certain endpoints
