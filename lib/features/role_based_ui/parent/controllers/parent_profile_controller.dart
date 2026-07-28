import 'dart:developer';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/core/utils/local_storage/storage_helper.dart';
import 'package:erp_management/features/role_based_ui/principal/new_student_list/controllers/student_list_controller.dart';
import 'package:erp_management/features/role_based_ui/principal/new_student_list/models/student_list_response.dart';
import 'package:get/get.dart';

class ParentProfileController extends GetxController {
  final ApiService _api = ApiService();

  // Parent (logged-in user) info
  final RxString parentName = ''.obs;
  final RxString parentMobile = ''.obs;
  final RxString parentEmail = ''.obs;
  final RxString parentUserId = ''.obs;

  // Children
  final RxList<Student> children = <Student>[].obs;
  final RxInt selectedChildIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Selected child tab
  final RxInt selectedTab = 0.obs;

  Student? get selectedChild =>
      children.isNotEmpty ? children[selectedChildIndex.value] : null;

  @override
  void onInit() {
    super.onInit();
    _loadParentInfo();
  }

  Future<void> _loadParentInfo() async {
    isLoading.value = true;
    try {
      final userData = await StorageHelper.getUserData();
      if (userData != null) {
        parentName.value = userData.name ?? '';
        parentMobile.value = userData.mobile ?? '';
        parentEmail.value = userData.email ?? '';
        parentUserId.value = userData.userId ?? '';
      }
      final userDetails = await StorageHelper.getUserDetails();
      if (userDetails != null) {
        if (parentName.value.isEmpty) {
          parentName.value = userDetails.displayName;
        }
        if (parentMobile.value.isEmpty) {
          parentMobile.value = userDetails.phoneNumber ?? '';
        }
        if (parentEmail.value.isEmpty) {
          parentEmail.value = userDetails.email ?? '';
        }
      }
      await _fetchChildren();
    } catch (e) {
      log('ParentProfileController._loadParentInfo error: $e');
      errorMessage.value = 'Failed to load profile';
      if (children.isEmpty) children.assignAll(_sampleChildren());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchChildren() async {
    try {
      // getStudentList with empty filters returns all students; we then filter
      // by parentUserId matching the logged-in user. In production, use the
      // dedicated parent-children endpoint when available.
      final payload = {
        'isActive': 1,
        'branchId': 0,
        'sessionId': 0,
        'groupId': 0,
        'classId': 0,
        'top': 0,
        'searchText': '',
      };
      final response = await _api.postJson(Endpoints.getStudentList(), payload);

      List<dynamic> listData = [];
      if (response is Map<String, dynamic>) {
        listData = response['result'] ?? response['data'] ?? [];
      } else if (response is List) {
        listData = response;
      }

      final int loggedInUserId = int.tryParse(parentUserId.value) ?? 0;

      final all = listData
          .whereType<Map<String, dynamic>>()
          .map(StudentListResponse.fromJson)
          .toList();

      // Filter by parentUserId if we have one, otherwise show all (dev fallback)
      final matched = loggedInUserId > 0
          ? all.where((s) => s.parentUserId == loggedInUserId).toList()
          : all;

      final mapped = matched.map(_toStudent).toList();
      children.assignAll(mapped.isNotEmpty ? mapped : _sampleChildren());
    } catch (e) {
      log('_fetchChildren error: $e');
      // Fallback to sample data so the UI is never empty
      children.assignAll(_sampleChildren());
    }
  }

  Student _toStudent(StudentListResponse s) {
    return Student(
      id: s.id?.toString() ?? '',
      sid: s.sid ?? '',
      een: s.penno ?? '',
      name: '${s.firstName ?? ''} ${s.lastName ?? ''}'.trim(),
      rollNo: s.rollNumber ?? '',
      group: s.groupName ?? '',
      className: s.className ?? '',
      photoUrl: (s.photo != null && s.photo!.isNotEmpty) ? s.photo! : '',
      finishedImage: s.finishedPhoto ?? '',
      fatherName: s.fatherName ?? '',
      motherName: s.motherName ?? '',
      email: s.emailId ?? '',
      phone: s.fatherMobile ?? '',
      aadhaar: s.aadharNo ?? '',
      dob: s.dob ?? '',
      gender: s.gender ?? '',
      religion: s.religion ?? '',
      category: s.category ?? '',
      subCategory: s.subCategory ?? '',
      district: s.district ?? '',
      tehsil: s.tehsil ?? '',
      village: s.villageMohalla ?? '',
      status: (s.isActive == true) ? 'Active' : 'Inactive',
      srNo: s.srno ?? '',
      entryAt: s.entryOn ?? '',
      apaarId: s.apaarId ?? '',
      penNo: s.penno ?? '',
      fatherOccupation: s.fatherOccupation ?? '',
      motherOccupation: s.motherOccupation ?? '',
    );
  }

  List<Student> _sampleChildren() => [
        Student(
          id: '1',
          sid: 'STU-2024-001',
          name: 'Aiden Smith',
          rollNo: '12',
          group: 'Primary',
          className: 'Class 4',
          photoUrl: '',
          fatherName: 'Robert Smith',
          motherName: 'Emily Smith',
          phone: '9876543210',
          aadhaar: '1234 5678 9012',
          dob: '2015-06-20',
          gender: 'Male',
          religion: 'Hindu',
          category: 'General',
          srNo: 'SR-2024-001',
          district: 'Lucknow',
          tehsil: 'Lucknow',
          village: 'Hazratganj',
          state: 'Uttar Pradesh',
          pinCode: '226001',
          fatherOccupation: 'Business',
          motherOccupation: 'Housewife',
        ),
        Student(
          id: '2',
          sid: 'STU-2024-002',
          name: 'Emma Smith',
          rollNo: '8',
          group: 'Primary',
          className: 'Class 2',
          photoUrl: '',
          fatherName: 'Robert Smith',
          motherName: 'Emily Smith',
          phone: '9876543210',
          aadhaar: '9876 5432 1098',
          dob: '2017-03-15',
          gender: 'Female',
          religion: 'Hindu',
          category: 'General',
          srNo: 'SR-2024-002',
          district: 'Lucknow',
          tehsil: 'Lucknow',
          village: 'Hazratganj',
          state: 'Uttar Pradesh',
          pinCode: '226001',
          fatherOccupation: 'Business',
          motherOccupation: 'Housewife',
        ),
      ];
}
