/// A staff member returned by `Staff/GetStaff`.
class StaffModel {
  final int id;
  final int userId;
  final bool isActive;
  final String name;
  final String email;
  final String fatherName;
  final String dob;
  final String designation;
  final int designationId;
  final String qualification;
  final String gender;
  final String maritalStatus;
  final String religion;
  final String caste;
  final String mobileNo;
  final String villageMohalla;
  final String tehsil;
  final String district;
  final String userName;
  final String entryAt;
  final String photoUrl;
  final String groupId;
  final String classId;

  StaffModel({
    required this.id,
    required this.userId,
    required this.isActive,
    required this.name,
    required this.email,
    required this.fatherName,
    required this.dob,
    required this.designation,
    required this.designationId,
    required this.qualification,
    required this.gender,
    required this.maritalStatus,
    required this.religion,
    required this.caste,
    required this.mobileNo,
    required this.villageMohalla,
    required this.tehsil,
    required this.district,
    required this.userName,
    required this.entryAt,
    required this.photoUrl,
    required this.groupId,
    required this.classId,
  });

  /// Human-readable gender label.
  String get genderLabel {
    switch (gender.toUpperCase()) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      default:
        return gender;
    }
  }

  /// Combined "village, tehsil, district" address (skips blanks).
  String get address => [villageMohalla, tehsil, district]
      .where((e) => e.trim().isNotEmpty)
      .join(', ');

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => v?.toString() ?? '';
    int i(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return StaffModel(
      id: i(json['id']),
      userId: i(json['userId']),
      isActive: json['isActive'] == true,
      name: s(json['name']).trim(),
      email: s(json['email']),
      fatherName: s(json['fatherName']),
      dob: s(json['dob']),
      designation: s(json['designation']),
      designationId: i(json['designationId']),
      qualification: s(json['qualification']),
      gender: s(json['gender']),
      maritalStatus: s(json['maritalStatus']),
      religion: s(json['religion']),
      caste: s(json['caste']),
      mobileNo: s(json['mobileNo']),
      villageMohalla: s(json['villageMohalla']),
      tehsil: s(json['tehsil']),
      district: s(json['district']),
      userName: s(json['userName']),
      entryAt: s(json['entryAt']),
      photoUrl: s(json['photoUrl']),
      groupId: s(json['groupId']),
      classId: s(json['classId']),
    );
  }
}
