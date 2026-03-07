# Endpoint Commands

## Authentication Flow

### 1. Register a New User

```powershell
$body = @{
    full_name = "John Doe"
    phone_number = "09876543210"
    role = "resident"
    password = "your_password"
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

---

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
    "access_token": "eyJhbGc...",
    "token_type": "bearer",
    "user": {
        "id": "uuid-here",
        "full_name": "John Doe",
        "is_verified": false
    }
}
```

---

### 3. Access Protected Endpoints (Using Token)

Once you have the token from login, use it to access protected endpoints:

```powershell
# Store the token from login response
$token = "eyJhbGc..."

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

---

## Important Notes

- **Token Format:** Always use `Authorization: Bearer <token>` header for protected endpoints
- **Token Expiration:** Tokens expire after 7 days
- **Invalid Credentials:** Returns 401 Unauthorized
- **Token Validation:** If token is invalid or expired, you'll receive a 401 error with message "Could not validate credentials"
- **User Verification:** User must be verified to access certain endpoints
