import 'package:flutter/material.dart';

enum AttendenceSource {
  mobile(1, 'Mobile'),
  web(2, 'Web'),
  biometric(3, 'Biometric'),
  qr(4, 'QR');

  final int id;
  final String label;
  const AttendenceSource(this.id, this.label);
}

enum AttendanceTypeOption {
  present(1, 'Present', Color(0xFF2E7D32)),
  absent(2, 'Absent', Color(0xFFC62828)),
  late(3, 'Late', Color(0xFFF9A825)),
  halfDay(4, 'HalfDay', Color(0xFFF57C00)),
  holiday(5, 'Holiday', Color(0xFF1565C0));

  final int id;
  final String label;
  final Color color;
  const AttendanceTypeOption(this.id, this.label, this.color);

  static AttendanceTypeOption? fromId(int? id) {
    if (id == null) return null;
    for (final t in AttendanceTypeOption.values) {
      if (t.id == id) return t;
    }
    return null;
  }
}
