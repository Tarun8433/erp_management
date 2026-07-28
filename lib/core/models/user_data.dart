class UserData {
  final String? id;
  final String? name;
  final String? email;
  final String? token;
  final String? refreshToken;
  final String? clientName;
  final String? userId;
  final String? mobile;
  final int? clientId;
  final String? lastLogin;
  final String? role;
  final int? roleId;
  final String? vendorId;
  final List<UserCompany>? userCompany;
  final bool? hasMpin;
  final String? defaultRoleName;

  UserData({
    this.id,
    this.name,
    this.email,
    this.token,
    this.refreshToken,
    this.clientName,
    this.userId,
    this.mobile,
    this.clientId,
    this.lastLogin,
    this.role,
    this.roleId,
    this.vendorId,
    this.userCompany,
    this.hasMpin,
    this.defaultRoleName,
  });

  static bool? _parseHasMpin(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final raw = value.toString().trim().toLowerCase();
    if (raw == 'true' || raw == '1' || raw == 'yes') return true;
    if (raw == 'false' || raw == '0' || raw == 'no') return false;
    return null;
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    final rootVendorId = json['vendorId']?.toString();
    String? derivedVendorId;
    if ((rootVendorId == null || rootVendorId.trim().isEmpty) &&
        json['userVendor'] is List &&
        (json['userVendor'] as List).isNotEmpty) {
      final first = (json['userVendor'] as List).first;
      if (first is Map) {
        derivedVendorId = first['vendorId']?.toString();
      }
    }
    return UserData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      token: json['token']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
      clientName: json['clientName'],
      userId: json['userId'],
      mobile: json['mobile'],
      clientId: json['clientId'],
      lastLogin: json['lastLogin'],
      role: json['role'],
      roleId: json['roleId'] is int
          ? json['roleId']
          : int.tryParse(json['roleId']?.toString() ?? ''),
      vendorId: (rootVendorId != null && rootVendorId.trim().isNotEmpty)
          ? rootVendorId.trim()
          : derivedVendorId?.trim(),
      defaultRoleName: json['defaultRoleName'],
      hasMpin: _parseHasMpin(json['hasMpin']),
      userCompany: json['userCompany'] != null
          ? (json['userCompany'] as List)
              .map((i) => UserCompany.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'refreshToken': refreshToken,
      'clientName': clientName,
      'userId': userId,
      'mobile': mobile,
      'clientId': clientId,
      'lastLogin': lastLogin,
      'role': role,
      'roleId': roleId,
      'vendorId': vendorId,
      'defaultRoleName': defaultRoleName,
      'hasMpin': hasMpin,
      'userCompany': userCompany?.map((e) => e.toJson()).toList(),
    };
  }
}

class UserCompany {
  final String? companyId;
  final CompanyInfo? company;
  final List<UserBranch>? userBranch;
  final List<UserRole>? userRole;

  UserCompany({
    this.companyId,
    this.company,
    this.userBranch,
    this.userRole,
  });

  factory UserCompany.fromJson(Map<String, dynamic> json) {
    return UserCompany(
      companyId: json['companyId'],
      company: json['company'] != null ? CompanyInfo.fromJson(json['company']) : null,
      userBranch: json['userBranch'] != null
          ? (json['userBranch'] as List).map((i) => UserBranch.fromJson(i)).toList()
          : null,
      userRole: json['userRole'] != null
          ? (json['userRole'] as List).map((i) => UserRole.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'company': company?.toJson(),
      'userBranch': userBranch?.map((e) => e.toJson()).toList(),
      'userRole': userRole?.map((e) => e.toJson()).toList(),
    };
  }
}

class CompanyInfo {
  final String? name;
  final String? email;
  final String? legalName;

  CompanyInfo({this.name, this.email, this.legalName});

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      name: json['name'],
      email: json['email'],
      legalName: json['legalName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'legalName': legalName,
    };
  }
}

class UserBranch {
  final String? id;
  final String? branchId;
  final BranchInfo? branch;

  UserBranch({this.id, this.branchId, this.branch});

  factory UserBranch.fromJson(Map<String, dynamic> json) {
    return UserBranch(
      id: json['id'],
      branchId: json['branchId'],
      branch: json['branch'] != null ? BranchInfo.fromJson(json['branch']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'branch': branch?.toJson(),
    };
  }
}

class BranchInfo {
  final String? id;
  final String? branchName;
  final String? branchCode;

  BranchInfo({this.id, this.branchName, this.branchCode});

  factory BranchInfo.fromJson(Map<String, dynamic> json) {
    return BranchInfo(
      id: json['id'],
      branchName: json['branchName'],
      branchCode: json['branchCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchName': branchName,
      'branchCode': branchCode,
    };
  }
}

class UserRole {
  final String? roleId;
  final RoleInfo? role;

  UserRole({this.roleId, this.role});

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      roleId: json['roleId'],
      role: json['role'] != null ? RoleInfo.fromJson(json['role']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'role': role?.toJson(),
    };
  }
}

class RoleInfo {
  final String? roleName;

  RoleInfo({this.roleName});

  factory RoleInfo.fromJson(Map<String, dynamic> json) {
    return RoleInfo(
      roleName: json['roleName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleName': roleName,
    };
  }
}
