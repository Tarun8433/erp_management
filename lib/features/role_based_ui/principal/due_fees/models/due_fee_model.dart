/// A single due-fee report row returned by `Fees/GetDueFeeReport`.
class DueFeeModel {
  final int studentId;
  final int sessionId;
  final String sid;
  final String studentName;
  final String fatherName;
  final String motherName;
  final String mobileNo;
  final String className;
  final String address;
  final String monthName;
  final double amount;
  final double penalty;
  final double specialDiscount;
  final double extraDiscountAmount;
  final double paidAmount;
  final double balanceAmount;

  DueFeeModel({
    required this.studentId,
    required this.sessionId,
    required this.sid,
    required this.studentName,
    required this.fatherName,
    required this.motherName,
    required this.mobileNo,
    required this.className,
    required this.address,
    required this.monthName,
    required this.amount,
    required this.penalty,
    required this.specialDiscount,
    required this.extraDiscountAmount,
    required this.paidAmount,
    required this.balanceAmount,
  });

  /// Net amount the student still owes for the month.
  double get totalDue =>
      (amount + penalty - specialDiscount - extraDiscountAmount - paidAmount)
          .clamp(0, double.infinity);

  factory DueFeeModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    String toStr(dynamic v) => v?.toString() ?? '';

    return DueFeeModel(
      studentId: toInt(json['studentId']),
      sessionId: toInt(json['sessionId']),
      sid: toStr(json['sid']),
      studentName: toStr(json['studentName']),
      fatherName: toStr(json['fatherName']),
      motherName: toStr(json['motherName']),
      mobileNo: toStr(json['mobileNo']),
      className: toStr(json['className']),
      address: toStr(json['address']),
      monthName: toStr(json['monthName']),
      amount: toDouble(json['amount']),
      penalty: toDouble(json['penalty']),
      specialDiscount: toDouble(json['specialDiscount']),
      extraDiscountAmount: toDouble(json['extraDiscountAmount']),
      paidAmount: toDouble(json['paidAmount']),
      balanceAmount: toDouble(json['balanceAmount']),
    );
  }
}
