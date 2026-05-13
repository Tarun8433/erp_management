class UserDetails {
  final String userId;
  final String firstName;
  final String lastName;
  final String mobile;
  final String gender;
  final String email;
  final String dob;
  final String profilePicture;
  final String roleType;
  final String userNumber;

  UserDetails({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.gender,
    required this.email,
    required this.dob,
    required this.profilePicture,
    required this.roleType,
    required this.userNumber,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      userId: json['UserId']?.toString() ?? '',
      firstName: json['FirstName']?.toString() ?? '',
      lastName: json['LastName']?.toString() ?? '',
      mobile: json['Mobile']?.toString() ?? '',
      gender: json['Gender']?.toString() ?? '',
      email: json['Email']?.toString() ?? '',
      dob: json['DOB']?.toString() ?? '',
      profilePicture: json['ProfilePicture']?.toString() ?? '',
      roleType: json['RoleType']?.toString() ?? '',
      userNumber: (json['User_Number'] ?? json['UserNumber'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'FirstName': firstName,
      'LastName': lastName,
      'Mobile': mobile,
      'Gender': gender,
      'Email': email,
      'DOB': dob,
      'ProfilePicture': profilePicture,
      'RoleType': roleType,
      'User_Number': userNumber,
    };
  }
}
