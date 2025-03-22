class Shift {
  final DateTime startTime;
  final DateTime endTime;
  final Ward ward;
  final List<Doctor> doctors;

  Shift({
    required this.startTime,
    required this.endTime,
    required this.ward,
    required this.doctors,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      startTime: json['startTime'],
      endTime: json['endTime'],
      ward: Ward.fromJson(json['ward']),
      doctors: (json['doctors'] as List)
          .map((doctorJson) => Doctor.fromJson(doctorJson))
          .toList(),
    );
  }
}

class Ward {
  final int id;
  final String name;
  final WardAdmin wardAdmin;

  Ward({required this.id, required this.name, required this.wardAdmin});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      id: json['id'],
      name: json['name'],
      wardAdmin: WardAdmin.fromJson(json['wardAdmin']),
    );
  }
}

class WardAdmin {
  final int id;
  final String firstName;
  final String lastName;
  final String phoneNo;
  final String role;

  WardAdmin({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNo,
    required this.role,
  });

  factory WardAdmin.fromJson(Map<String, dynamic> json) {
    return WardAdmin(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNo: json['phoneNo'],
      role: json['role'],
    );
  }
}

class Doctor {
  final int id;
  final String firstName;
  final String lastName;
  final String phoneNo;
  final String role;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNo,
    required this.role,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNo: json['phoneNo'],
      role: json['role'],
    );
  }
}
