class AuthService {
  // Mock sign in
  static Future<bool> signIn(String email, String password) async {
    // In a real app, perform an API request or Firebase auth
    await Future.delayed(const Duration(seconds: 1));
    // Return true if success, false if failure
    return (email == 'test@example.com' && password == 'password123');
  }

  // Mock sign up
  static Future<bool> signUp(String name, String email, String password) async {

    await Future.delayed(const Duration(seconds: 1));
    return true; // Return false if something fails
  }
}
