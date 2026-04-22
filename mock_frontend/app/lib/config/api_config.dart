class ApiConfig {
  // Use --dart-define=API_BASE_URL=http://<your-laptop-ip>:8000 for real devices.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
