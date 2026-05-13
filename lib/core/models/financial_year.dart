class FinancialYear {
  final String? code;
  final String? label;
  final String? startDate;
  final String? endDate;

  FinancialYear({
    this.code,
    this.label,
    this.startDate,
    this.endDate,
  });

  factory FinancialYear.fromJson(Map<String, dynamic> json) {
    return FinancialYear(
      code: json['code'],
      label: json['label'],
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'label': label,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
