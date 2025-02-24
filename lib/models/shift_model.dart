class Shift {
  final String id;
  final String timeRange;
  final String shiftType;
  final String status;

  Shift({
    required this.id,
    required this.timeRange,
    required this.shiftType,
    required this.status,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as String,
      timeRange: json['timeRange'] as String,
      shiftType: json['shiftType'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timeRange': timeRange,
      'shiftType': shiftType,
      'status': status,
    };
  }
}
