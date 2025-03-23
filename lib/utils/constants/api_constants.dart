class ApiConstants {
  // Replace with your actual deployment URL
  static const String baseUrl = 'https://spring-app-284647065201.us-central1.run.app/api';

  // Auth endpoints
  static const String loginUrl = '$baseUrl/auth/login';

  // User endpoints
  static String userById(int userId) => '$baseUrl/user/$userId';
  static String usersByRole(String role) => '$baseUrl/user/role/$role';

  // Shift endpoints
  static String shiftsByDoctorId(int doctorId) => '$baseUrl/shift/$doctorId';
  static const String availableShifts = '$baseUrl/shift/available';

  // Leave endpoints
  static const String leaveRequest = '$baseUrl/leave/request';
  static const String allLeaves = '$baseUrl/leave';
  static String leaveById(int leaveId) => '$baseUrl/leave/$leaveId';
}
