class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNo;
  final String role;

  User({required this.id, required this.firstName, required this.lastName, required this.email, required this.phoneNo, required this.role});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    email: json['email'],
    phoneNo: json['phoneNo'],
    role: json['role'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phoneNo': phoneNo,
    'role': role,
  };
}
