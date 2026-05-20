class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8000';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String sessions = '/sessions';
  static const String dashboard = '/stats/dashboard';
  static const String weeklyStats = '/stats/weekly';
  static const String monthlyStats = '/stats/monthly';
}
