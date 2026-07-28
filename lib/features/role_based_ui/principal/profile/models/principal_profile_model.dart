class PrincipalProfileModel {
  final int? userId;
  final int? roleId;
  final String? profileType;
  final bool? isParent;
  final bool? isStaff;
  final bool? isBranch;
  final bool? isUserDetails;
  final int? profileId;
  final String? name;
  final String? mobileNo;
  final String? district;
  final String? tehsil;
  final String? villageMohalla;
  final String? gender;
  final String? dob;
  final String? religion;
  final String? category;
  final String? caste;
  final int? designationId;
  final String? designationName;
  final int? classId;
  final String? className;
  final int? groupId;
  final String? groupName;
  final String? branchName;
  final String? branchCode;
  final String? email;
  final String? contactNo;
  final String? contactPerson;
  final String? address;
  final String? logo;
  final String? signature;
  final bool? isSuccess;
  final String? responseMessage;

  const PrincipalProfileModel({
    this.userId,
    this.roleId,
    this.profileType,
    this.isParent,
    this.isStaff,
    this.isBranch,
    this.isUserDetails,
    this.profileId,
    this.name,
    this.mobileNo,
    this.district,
    this.tehsil,
    this.villageMohalla,
    this.gender,
    this.dob,
    this.religion,
    this.category,
    this.caste,
    this.designationId,
    this.designationName,
    this.classId,
    this.className,
    this.groupId,
    this.groupName,
    this.branchName,
    this.branchCode,
    this.email,
    this.contactNo,
    this.contactPerson,
    this.address,
    this.logo,
    this.signature,
    this.isSuccess,
    this.responseMessage,
  });

  factory PrincipalProfileModel.fromJson(Map<String, dynamic> json) {
    return PrincipalProfileModel(
      userId: json['userId'] as int?,
      roleId: json['roleId'] as int?,
      profileType: json['profileType'] as String?,
      isParent: json['isParent'] as bool?,
      isStaff: json['isStaff'] as bool?,
      isBranch: json['isBranch'] as bool?,
      isUserDetails: json['isUserDetails'] as bool?,
      profileId: json['profileId'] as int?,
      name: json['name'] as String?,
      mobileNo: json['mobileNo'] as String?,
      district: json['district'] as String?,
      tehsil: json['tehsil'] as String?,
      villageMohalla: json['villageMohalla'] as String?,
      gender: json['gender'] as String?,
      dob: json['dob'] as String?,
      religion: json['religion'] as String?,
      category: json['category'] as String?,
      caste: json['caste'] as String?,
      designationId: json['designationId'] as int?,
      designationName: json['designationName'] as String?,
      classId: json['classId'] as int?,
      className: json['className'] as String?,
      groupId: json['groupId'] as int?,
      groupName: json['groupName'] as String?,
      branchName: json['branchName'] as String?,
      branchCode: json['branchCode'] as String?,
      email: json['email'] as String?,
      contactNo: json['contactNo'] as String?,
      contactPerson: json['contactPerson'] as String?,
      address: json['address'] as String?,
      logo: json['logo'] as String?,
      signature: json['signature'] as String?,
      isSuccess: json['isSuccess'] as bool?,
      responseMessage: json['responseMessage'] as String?,
    );
  }
}
