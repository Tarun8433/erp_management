class SessionModel {
  final dynamic sessionId;
  final String? sessionName;
  final String? startDate;
  final String? endDate;
  final bool? isActive;

  SessionModel({
    this.sessionId,
    this.sessionName,
    this.startDate,
    this.endDate,
    this.isActive,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    String? parsedName = json['sessionName'] ?? json['SessionName'] ?? json['name'] ?? json['Name'];
    if (parsedName == null && json['from'] != null && json['to'] != null) {
      parsedName = '${json['from']}-${json['to']}';
    }

    return SessionModel(
      sessionId: json['sessionId'] ?? json['SessionId'] ?? json['id'] ?? json['Id'],
      sessionName: parsedName,
      startDate: json['startDate'] ?? json['StartDate'],
      endDate: json['endDate'] ?? json['EndDate'],
      isActive: json['isActive'] ?? json['IsActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'sessionName': sessionName,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
    };
  }
}
