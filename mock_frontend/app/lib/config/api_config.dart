// class ApiConfig {
//   // Use --dart-define=API_BASE_URL=http://<your-laptop-ip>:8000 for real devices.
//   static const String baseUrl = String.fromEnvironment(
//     'API_BASE_URL',
//     defaultValue: 'http://10.0.2.2:8000',
//   );
// }

class ApiConfig {
  // Override with --dart-define=API_BASE_URL=... when testing against local or staging backends.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://barangaymicrojobs.onrender.com',
  );
}
