class UserDetails {
  final int? userId;
  final String? userName;
  final String? loginName;
  final String? name; // school / branch name
  final String? email;
  final String? token;
  final String? refreshToken;
  final String? phoneNumber;
  final List<String>? role;
  final int? roleId;
  final int? branchId;
  final int? tenantId;
  final int? status;
  final String? address;
  final String? branchContactNo;
  final String? branchLogo;
  final bool? isChangePasswordRequired;

  const UserDetails({
    this.userId,
    this.userName,
    this.loginName,
    this.name,
    this.email,
    this.token,
    this.refreshToken,
    this.phoneNumber,
    this.role,
    this.roleId,
    this.branchId,
    this.tenantId,
    this.status,
    this.address,
    this.branchContactNo,
    this.branchLogo,
    this.isChangePasswordRequired,
  });

  /// Full display name (loginName if present, otherwise userName).
  String get displayName {
    if (loginName != null && loginName!.isNotEmpty) return loginName!;
    if (userName != null && userName!.isNotEmpty) return userName!;
    return '';
  }

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId']?.toString() ?? ''),
      userName: json['userName']?.toString(),
      loginName: json['loginName']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      token: json['token']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      role: json['role'] != null ? List<String>.from(json['role']) : null,
      roleId: json['roleId'] is int
          ? json['roleId']
          : int.tryParse(json['roleId']?.toString() ?? ''),
      branchId: json['branchId'] is int
          ? json['branchId']
          : int.tryParse(json['branchId']?.toString() ?? ''),
      tenantId: json['tenantId'] is int
          ? json['tenantId']
          : int.tryParse(json['tenantId']?.toString() ?? ''),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? ''),
      address: json['address']?.toString(),
      branchContactNo: json['branchContactNo']?.toString(),
      branchLogo: json['branchLogo']?.toString(),
      isChangePasswordRequired: json['isChangePasswordRequired'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'loginName': loginName,
        'name': name,
        'email': email,
        'token': token,
        'refreshToken': refreshToken,
        'phoneNumber': phoneNumber,
        'role': role,
        'roleId': roleId,
        'branchId': branchId,
        'tenantId': tenantId,
        'status': status,
        'address': address,
        'branchContactNo': branchContactNo,
        'branchLogo': branchLogo,
        'isChangePasswordRequired': isChangePasswordRequired,
      };
}
