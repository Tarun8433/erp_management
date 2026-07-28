class AttendanceStudentModel {
  final int id;
  final String sid;
  final String firstName;
  final String fatherName;
  final int? attendanceId;
  final int? attendenceTypeId;
  final String? attendenceDate;
  final int? shiftId;
  final String? note;
  final String? attendenceType;

  const AttendanceStudentModel({
    required this.id,
    required this.sid,
    required this.firstName,
    required this.fatherName,
    this.attendanceId,
    this.attendenceTypeId,
    this.attendenceDate,
    this.shiftId,
    this.note,
    this.attendenceType,
  });

  factory AttendanceStudentModel.fromJson(Map<String, dynamic> json) =>
      AttendanceStudentModel(
        id: (json['id'] ?? 0) as int,
        sid: (json['sid'] ?? '').toString(),
        firstName: (json['firstName'] ?? '').toString(),
        fatherName: (json['fatherName'] ?? '').toString(),
        attendanceId: json['attendanceId'] as int?,
        attendenceTypeId: json['attendenceTypeId'] as int?,
        attendenceDate: json['attendenceDate']?.toString(),
        shiftId: json['shiftId'] as int?,
        note: json['note']?.toString(),
        attendenceType: json['attendenceType']?.toString(),
      );

  bool get isMarked => attendenceType != null;

  /// Normalised single-char status: P / A / L / H / null
  String? get status {
    final t = attendenceType?.trim().toUpperCase();
    if (t == null || t.isEmpty) return null;
    return t.substring(0, 1);
  }
}
