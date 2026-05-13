class LoginResponse {
  final int? statusCode;
  final String? responseText;
  final LoginResult? result;

  LoginResponse({this.statusCode, this.responseText, this.result});

  /// Returns true when the API indicates success (statusCode == 1).
  bool get isSuccess => statusCode == 1;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      statusCode: json['statusCode'],
      responseText: json['responseText'],
      result: json['result'] != null
          ? LoginResult.fromJson(json['result'])
          : null,
    );
  }
}

class LoginResult {
  final int? userId;
  final String? userName;
  final String? loginName;
  final String? name;
  final String? email;
  final String? token;
  final List<String>? role;
  final String? phoneNumber;
  final String? refreshToken;
  final int? branchId;
  final int? tenantId;
  final int? status;
  final String? address;
  final String? branchContactNo;
  final String? branchLogo;
  final bool? isChangePasswordRequired;

  LoginResult({
    this.userId,
    this.userName,
    this.loginName,
    this.name,
    this.email,
    this.token,
    this.role,
    this.phoneNumber,
    this.refreshToken,
    this.branchId,
    this.tenantId,
    this.status,
    this.address,
    this.branchContactNo,
    this.branchLogo,
    this.isChangePasswordRequired,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      userId: json['userId'],
      userName: json['userName'],
      loginName: json['loginName'],
      name: json['name'],
      email: json['email'],
      token: json['token'],
      role: json['role'] != null ? List<String>.from(json['role']) : null,
      phoneNumber: json['phoneNumber'],
      refreshToken: json['refreshToken'],
      branchId: json['branchId'],
      tenantId: json['tenantId'],
      status: json['status'],
      address: json['address'],
      branchContactNo: json['branchContactNo'],
      branchLogo: json['branchLogo'],
      isChangePasswordRequired: json['isChangePasswordRequired'],
    );
  }
}

class LanguageData {
  final String? code;
  final String? name;
  final String? nativeName;
  final bool? isActive;

  LanguageData({this.code, this.name, this.nativeName, this.isActive});

  factory LanguageData.fromJson(Map<String, dynamic> json) {
    return LanguageData(
      code: json['code'],
      name: json['name'],
      nativeName: json['nativeName'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
      'isActive': isActive,
    };
  }
}
