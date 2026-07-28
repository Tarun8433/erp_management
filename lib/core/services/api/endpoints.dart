class Endpoints {
  // Master switch for the Dev/Prod environment selector.
  // false  -> selector hidden on login screen, app always runs on Prod (Play Store).
  // true   -> selector visible again and saved environment is restored.
  static const bool showEnvironmentSelector = true;

  static const Map<String, String> environments = {
    'Dev': 'https://devapi.schoolclub.in',
    'Prod': 'https://api.schoolclub.in',
  };

  static String baseUrl = environments['Prod']!;

  // Loginetra API base URL (separate service)
  static const String loginetraBaseUrl = 'http://dev.loginetra.com';

  // CN Management
  static Uri addGc() => Uri.parse('$loginetraBaseUrl/api/gc/add-gc');

  // Auth
  static Uri login() => Uri.parse('$baseUrl/api/Account/Login');
  static Uri changePassword() =>
      Uri.parse('$baseUrl/api/Account/ChangePassword');
  static Uri sendResetPasswordLink() =>
      Uri.parse('$baseUrl/api/Account/SendResetPasswordLink');
  static Uri resetPassword() => Uri.parse('$baseUrl/api/Account/ResetPassword');

  // Student
  static Uri getStudentList() =>
      Uri.parse('$baseUrl/api/Student/GetStudentList');
  static Uri getNewStudentList() =>
      Uri.parse('$baseUrl/api/Student/GetNewStudentList');
  static Uri getStudentListForPromotion() =>
      Uri.parse('$baseUrl/api/Student/GetStudentListForPromotion');
  static Uri promoteStudent() =>
      Uri.parse('$baseUrl/api/Student/PromoteStudent');
  static Uri studentSectionUpdate() =>
      Uri.parse('$baseUrl/api/Student/StudentSectionUpdate');
  static Uri saveBasicInformation() =>
      Uri.parse('$baseUrl/api/Student/save-basic-information');
  static Uri saveGuardianDetail() =>
      Uri.parse('$baseUrl/api/Student/save-guardian-detail');
  static Uri savePreviousSchool() =>
      Uri.parse('$baseUrl/api/Student/save-previous-school');
  static Uri saveTransportDetail() =>
      Uri.parse('$baseUrl/api/Student/save-transport-detail');
  static Uri saveAdmissionDocument() =>
      Uri.parse('$baseUrl/api/Student/save-admission-document');
  static Uri uploadDocuments({int documentFor = 2}) => Uri.parse(
    '$baseUrl/api/DocumentSettings/UploadDocuments?documentFor=$documentFor',
  );
  static Uri studentAdmissionDetails(int studentId) =>
      Uri.parse('$baseUrl/api/Student/StudentAdmissionDetails/$studentId');
  static Uri uploadStudentDocument() =>
      Uri.parse('$baseUrl/api/Student/UploadStudentDocument');
  static Uri updateStudentImageName(
    int studentId,
    String fileName,
  ) => Uri.parse(
    '$baseUrl/api/Student/UpdateStudentImageName?studentId=$studentId&fileName=$fileName&isfinished=false',
  );

  // Fees
  static Uri getDueFeeReport() =>
      Uri.parse('$baseUrl/api/Fees/GetDueFeeReport');

  // Dashboard
  static Uri getDashboardData() =>
      Uri.parse('$baseUrl/api/Dashboard/GetDashboardData');

  // Category / Caste masters
  static Uri getCategories() => Uri.parse('$baseUrl/api/User/GetCategories');
  static Uri getSubCategories(int categoryId) =>
      Uri.parse('$baseUrl/api/User/GetSubCategories/$categoryId');

  // Staff
  static Uri getStaff() => Uri.parse('$baseUrl/api/Staff/GetStaff');
  static Uri getStaffDetailsById(int id) =>
      Uri.parse('$baseUrl/api/Staff/GetStaffDetailsById?Id=$id');
  static Uri addStaff() => Uri.parse('$baseUrl/api/Staff/AddStaff');
  static Uri getDesignation() => Uri.parse('$baseUrl/api/Staff/GetDesignation');
  static Uri getRoleForStaff() =>
      Uri.parse('$baseUrl/api/RolePermission/GetRoleForStaff');

  // Master
  static Uri getClassGroupList(int sessionId) => Uri.parse(
    '$baseUrl/api/ClassMaster/ClassGroupList?isActive=1&sessionId=$sessionId',
  );
  static Uri getClassMasterList(int groupId, int sessionId) =>
      Uri.parse('$baseUrl/api/ClassMaster/ClassMasterList/$groupId/$sessionId');

  // Number Sheet / Examination
  static Uri getExamType() => Uri.parse('$baseUrl/api/Examination/GetExamType');
  static Uri getStudentExamNumbers() =>
      Uri.parse('$baseUrl/api/Examination/GetStudentExaminationNumber');
  static Uri bulkSaveMarks() =>
      Uri.parse('$baseUrl/api/Examination/BulkStudentExamNumberSheet');
  static Uri getOnlySubject(
    int groupId,
    int classId,
    int sessionId,
  ) => Uri.parse(
    '$baseUrl/api/SubjectMaster/GetOnlySubject?GroupId=$groupId&ClassId=$classId&SessionId=$sessionId',
  );
  static Uri getMM() => Uri.parse('$baseUrl/api/SubjectMaster/GetMM');
  static Uri getStudentAssignedSubjects() =>
      Uri.parse('$baseUrl/api/Student/GetStudentAssignedSubjects');

  // TODO: Below endpoints need to be updated when the new API supports them
  static Uri register() => Uri.parse('$baseUrl/user/add-user');
  static Uri searchUser() => Uri.parse('$baseUrl/user/search-user');

  static Uri otpGenerate() => Uri.parse('$baseUrl/public/otpGenerate');
  static Uri loginOtpGenerate() =>
      Uri.parse('$baseUrl/public/loginOtpGenerate');
  static Uri verifyOtp() => Uri.parse('$baseUrl/public/verify-otp');
  static Uri forgotPassword() => Uri.parse('$baseUrl/public/forgot-password');
  static Uri forgotMpin() => Uri.parse('$baseUrl/public/forgot-mpin');
  static Uri userSetMpin() => Uri.parse('$baseUrl/user/set-mpin');

  // Role
  static Uri switchRole() => Uri.parse('$baseUrl/auth/switch-role');

  // Profile
  static Uri changeMpin() => Uri.parse('$baseUrl/user/change-mpin');

  // SignUp
  static Uri searchState() => Uri.parse('$baseUrl/state/search-state');
  static Uri searchStatusHandler() =>
      Uri.parse('$baseUrl/statusHandler/search-status-handler');
  static Uri searchCity() => Uri.parse('$baseUrl/city/search-city');
  static Uri searchPostalCode() =>
      Uri.parse('$baseUrl/postalCode/search-postalCode');
  static Uri searchCompany() => Uri.parse('$baseUrl/company/search-company');
  static Uri searchBranch() => Uri.parse('$baseUrl/location/search-location');
  static Uri searchRole() => Uri.parse('$baseUrl/role/search-role');

  // Attendance
  static Uri shiftList() =>
      Uri.parse('$baseUrl/api/Attendence/ShiftList?isActive=1');

  static Uri getStudentsForAttendance() =>
      Uri.parse('$baseUrl/api/Attendence/GetStudentsForAttendance');

  static Uri saveBulkAttendance() =>
      Uri.parse('$baseUrl/api/Attendence/SaveBulk');

  static Uri getAttendanceRegister() =>
      Uri.parse('$baseUrl/api/Attendence/GetAttendenceRegister');

  // Notification
  static Uri saveFirebaseToken() =>
      Uri.parse('$baseUrl/api/Notification/save-firebase-token');

  static Uri userPushNotifications({
    int page = 1,
    int pageSize = 20,
  }) => Uri.parse(
    '$baseUrl/api/Notification/user-push-notifications?pageNumber=$page&pageSize=$pageSize',
  );

  static Uri unreadNotificationCount() => Uri.parse(
    '$baseUrl/api/Notification/user-push-notifications/unread-count',
  );

  static Uri markNotificationAsRead(int id) => Uri.parse(
    '$baseUrl/api/Notification/user-push-notifications/mark-as-read/$id',
  );

  static Uri markAllNotificationsAsRead() => Uri.parse(
    '$baseUrl/api/Notification/user-push-notifications/mark-all-as-read',
  );

  // User
  static Uri userProfile(int userId) =>
      Uri.parse('$baseUrl/api/User/$userId/profile');

  // Menu
  static Uri getAppMenu(String roleId) => Uri.parse(
    '$baseUrl/api/AppMenu/GetAppMenu?isMobileAppRequest=true&roleId=$roleId',
  );

  // Common
  static Uri getSessionList() =>
      Uri.parse('$baseUrl/api/SessionMaster/GetSessionList');

  // Transport
  static Uri getVehicle() => Uri.parse('$baseUrl/api/Transport/GetVehicle');
  static Uri getRoutesByVehicleId(int vehicleId) =>
      Uri.parse('$baseUrl/api/Transport/GetRoutesByVehicleId/$vehicleId');
  static Uri getPickupPointByRouteAndVehicle(
    int routeId,
    int vehicleId,
    int sessionId,
  ) => Uri.parse(
    '$baseUrl/api/Transport/GetPickupPointByRouteAndVehicle/$routeId/$vehicleId/$sessionId',
  );
}
