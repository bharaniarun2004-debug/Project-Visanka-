class Constants {
  static const String baseUrl = 'http://10.23.21.57/online-appointment-booking-final/backend';
  
  // Auth endpoints
  static const String googleLoginUrl = '$baseUrl/auth/google_login.php';
  static const String loginUrl = '$baseUrl/auth/login.php';
  static const String registerUrl = '$baseUrl/auth/register.php';
  
  // API endpoints
  static const String providersUrl = '$baseUrl/api/providers.php';
  static const String appointmentsUrl = '$baseUrl/api/appointments.php';
  static const String myAppointmentsUrl = '$baseUrl/api/my_appointments.php';
  static const String providerRequestsUrl = '$baseUrl/api/provider_requests.php';
  static const String updateStatusUrl = '$baseUrl/api/update_status.php';
  
  // SharedPreferences keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}