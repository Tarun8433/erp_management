/// Response of `Staff/GetStaffDetailsById`.
class StaffDetailsModel {
  final int id;
  final int userId;
  final String name;
  final String fatherName;
  final String email;
  final String mobileNo;
  final String dob;
  final int designationId;
  final int roleId;
  final String designation;
  final String qualification;
  final String gender;
  final String maritalStatus;
  final String religion;
  final String caste;
  final String subCaste;
  final String villageMohalla;
  final String tehsil;
  final String district;
  final String userName;
  final String entryAt;
  final String aadharCardUrl;
  final String aadharCardBackUrl;
  final String panCardUrl;
  final String higherMarksheetUrl;
  final String experienceCertificateUrl;
  final String drivingLicenseUrl;
  final String photoUrl;
  final String interMarksheet;
  final String graduationMarksheet;
  final String postgraduationMarksheet;
  final String groupId;
  final String classId;
  final String groupName;
  final String className;
  final int classTeacherOf;

  StaffDetailsModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.fatherName,
    required this.email,
    required this.mobileNo,
    required this.dob,
    required this.designationId,
    required this.roleId,
    required this.designation,
    required this.qualification,
    required this.gender,
    required this.maritalStatus,
    required this.religion,
    required this.caste,
    required this.subCaste,
    required this.villageMohalla,
    required this.tehsil,
    required this.district,
    required this.userName,
    required this.entryAt,
    required this.aadharCardUrl,
    required this.aadharCardBackUrl,
    required this.panCardUrl,
    required this.higherMarksheetUrl,
    required this.experienceCertificateUrl,
    required this.drivingLicenseUrl,
    required this.photoUrl,
    required this.interMarksheet,
    required this.graduationMarksheet,
    required this.postgraduationMarksheet,
    required this.groupId,
    required this.classId,
    required this.groupName,
    required this.className,
    required this.classTeacherOf,
  });

  factory StaffDetailsModel.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => v?.toString() ?? '';
    int i(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return StaffDetailsModel(
      id: i(json['id'] ?? json['Id']),
      userId: i(json['userId'] ?? json['UserId']),
      name: s(json['name'] ?? json['Name']).trim(),
      fatherName: s(json['fatherName'] ?? json['FatherName']),
      email: s(json['email'] ?? json['Email']),
      mobileNo: s(json['mobileNo'] ?? json['MobileNo']),
      dob: s(json['dob'] ?? json['DOB']),
      designationId: i(json['designationId'] ?? json['DesignationId']),
      roleId: i(json['roleId'] ?? json['RoleId']),
      designation: s(json['designation'] ?? json['Designation']),
      qualification: s(json['qualification'] ?? json['Qualification']),
      gender: s(json['gender'] ?? json['Gender']),
      maritalStatus: s(json['maritalStatus'] ?? json['MaritalStatus']),
      religion: s(json['religion'] ?? json['Religion']),
      caste: s(json['caste'] ?? json['Caste']),
      subCaste: s(json['subCaste'] ?? json['SubCaste']),
      villageMohalla: s(json['villageMohalla'] ?? json['VillageMohalla']),
      tehsil: s(json['tehsil'] ?? json['Tehsil']),
      district: s(json['district'] ?? json['District']),
      userName: s(json['userName'] ?? json['UserName']),
      entryAt: s(json['entryAt'] ?? json['EntryAt']),
      aadharCardUrl: s(json['aadharCardUrl'] ?? json['AadharCardUrl']),
      aadharCardBackUrl:
          s(json['aadharCardBackUrl'] ?? json['AadharCardBackUrl']),
      panCardUrl: s(json['panCardUrl'] ?? json['PanCardUrl']),
      higherMarksheetUrl:
          s(json['higherMarksheetUrl'] ?? json['HigherMarksheetUrl']),
      experienceCertificateUrl:
          s(json['experienceCertificateUrl'] ?? json['ExperienceCertificateUrl']),
      drivingLicenseUrl:
          s(json['drivingLicenseUrl'] ?? json['DrivingLicenseUrl']),
      photoUrl: s(json['photoUrl'] ?? json['PhotoUrl']),
      interMarksheet: s(json['interMarksheet']),
      graduationMarksheet: s(json['graduationMarksheet']),
      postgraduationMarksheet: s(json['postgraduationMarksheet']),
      groupId: s(json['groupId'] ?? json['GroupId']),
      classId: s(json['classId'] ?? json['ClassId']),
      groupName: s(json['groupName'] ?? json['GroupName']),
      className: s(json['className'] ?? json['ClassName']),
      classTeacherOf: i(json['classTeacherOf'] ?? json['ClassTeacherOf']),
    );
  }
}
