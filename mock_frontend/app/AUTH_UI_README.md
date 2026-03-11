# Authentication UI Implementation

## Overview
I've created a complete authentication UI for your Flutter app based on the auth endpoints in your backend.

## Files Created

### Screens
1. **login_screen.dart** - Login screen with phone number and password fields
   - Validates input before submission
   - Shows loading indicator during login
   - Links to registration screen
   - Navigates to `/home` route on successful login

2. **register_screen.dart** - Registration screen with the following fields:
   - Full Name
   - Phone Number
   - Account Type selector (Customer/Provider)
   - Password
   - Confirm Password
   - Validates password match and minimum length
   - Links to login screen

### Services
**auth_service.dart** - Service class for API calls with TODO placeholders for:
- `register()` - POST /auth/register
- `login()` - POST /auth/login
- `getCurrentUser()` - GET /auth/me

## How to Connect to Your Backend

### Step 1: Add HTTP Dependencies
Add to your `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
```

### Step 2: Update AuthService
Replace the TODO sections in `lib/services/auth_service.dart` with actual HTTP requests:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> register({
  required String fullName,
  required String phoneNumber,
  required String password,
  required String role,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'full_name': fullName,
      'phone_number': phoneNumber,
      'password': password,
      'role': role,
    }),
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Registration failed');
  }
}
```

### Step 3: Update Login/Register Screens
Replace the TODO comments and mock Future.delayed calls with actual AuthService calls:

In `login_screen.dart`:
```dart
Future<void> _handleLogin() async {
  // ... validation code ...
  
  try {
    final result = await AuthService().login(
      phoneNumber: _phoneController.text,
      password: _passwordController.text,
    );
    
    // Store token and navigate
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  } catch (e) {
    // Show error
  }
}
```

### Step 4: Update Main.dart Routes
Consider adding named routes for better navigation:
```dart
routes: {
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/home': (context) => const HomePage(),
},
```

## Current Flow
1. App starts at LoginScreen
2. User can register via RegisterScreen
3. After successful login, user is navigated to HomePage
4. User can log out from ProfileScreen (add logout functionality)

## Environment Configuration
Update the baseUrl in AuthService based on your environment:
- Development: `http://localhost:8000`
- Production: `https://your-production-api.com`

You can also create an environment configuration file to manage this:
```dart
class AppConfig {
  static const String apiBaseUrl = 'http://localhost:8000';
}
```

## Next Steps
1. Implement actual HTTP calls in AuthService
2. Add token storage (use shared_preferences or secure_storage)
3. Add token refresh logic for expired tokens
4. Implement logout functionality in ProfileScreen
5. Add error handling and validation messages
6. Test with your actual backend endpoints
