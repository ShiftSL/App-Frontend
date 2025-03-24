class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String firebaseUid;
  final String phoneNo;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.firebaseUid,
    required this.phoneNo,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      firebaseUid: json['firebaseUid'],
      phoneNo: json['phoneNo'],
      email: json['email'],
      role: json['role'],
    );
  }

  get profileImageUrl => null;

  get hospitalName => null;
}
