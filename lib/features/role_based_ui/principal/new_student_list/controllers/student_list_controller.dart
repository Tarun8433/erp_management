import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:erp_management/core/controllers/session_controller.dart';
import 'package:erp_management/core/utils/image/image_utils.dart';
import 'package:erp_management/core/models/category_model.dart';
import 'package:erp_management/core/models/transport_model.dart';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/core/services/category_service.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/service/image_picker_service.dart';
import '../models/student_list_response.dart';

class Student {
  final String id;
  final String sid;
  final String een;
  final String name;
  final String rollNo;
  final String group;
  final String className;
  final String photoUrl;
  final String finishedImage;
  final String fatherName;
  final String motherName;
  final String email;
  final String phone;
  final String aadhaar;
  final String dob;
  final String gender;
  final String religion;
  final String category;
  final String subCategory;
  final String district;
  final String tehsil;
  final String village;
  final String status;
  final String srNo;
  final String entryAt;

  final String state;
  final String pinCode;
  final String remark;
  final String apaarId;
  final String penNo;
  final String fatherOccupation;
  final String motherOccupation;
  final bool isGuardianSameAsFather;
  final String guardianName;
  final String guardianMobile;
  final String guardianOccupation;
  final String guardianVillage;
  final String guardianTehsil;
  final String guardianDistrict;
  final String guardianState;
  final String guardianPinCode;
  final String prevSchoolName;
  final String prevClass;
  final String prevResult;
  final String prevSessionYear;
  final bool generateSrNo;
  final bool availTransport;

  // Server-side values carried through the edit flow so that saving an edit
  // never blanks a field the edit screen does not expose.
  final int sessionId;
  final int groupId;
  final int classId;
  final String session;
  final String motherMobile;
  final int parentUserId;
  final int vehicleId;
  final int routeId;
  final int pickUpId;

  Student({
    required this.id,
    this.sid = '',
    this.een = '',
    required this.name,
    required this.rollNo,
    required this.group,
    required this.className,
    required this.photoUrl,
    this.finishedImage = '',
    this.fatherName = '',
    this.motherName = '',
    this.email = '',
    this.phone = '',
    this.aadhaar = '',
    this.dob = '',
    this.gender = '',
    this.religion = '',
    this.category = '',
    this.subCategory = '',
    this.district = '',
    this.tehsil = '',
    this.village = '',
    this.status = '',
    this.srNo = '',
    this.entryAt = '',
    this.state = '',
    this.pinCode = '',
    this.remark = '',
    this.apaarId = '',
    this.penNo = '',
    this.fatherOccupation = '',
    this.motherOccupation = '',
    this.isGuardianSameAsFather = true,
    this.guardianName = '',
    this.guardianMobile = '',
    this.guardianOccupation = '',
    this.guardianVillage = '',
    this.guardianTehsil = '',
    this.guardianDistrict = '',
    this.guardianState = '',
    this.guardianPinCode = '',
    this.prevSchoolName = '',
    this.prevClass = '',
    this.prevResult = '',
    this.prevSessionYear = '',
    this.generateSrNo = true,
    this.availTransport = false,
    this.sessionId = 0,
    this.groupId = 0,
    this.classId = 0,
    this.session = '',
    this.motherMobile = '',
    this.parentUserId = 0,
    this.vehicleId = 0,
    this.routeId = 0,
    this.pickUpId = 0,
  });
}

/// Thrown when DocumentSettings/UploadDocuments returns statusCode == -1.
class StudentUploadException implements Exception {
  final String message;
  StudentUploadException(this.message);
  @override
  String toString() => message;
}

class StudentListController extends GetxController {
  final RxString selectedGroup = ''.obs;
  final RxString selectedClass = ''.obs;
  final RxString selectedStatus = ''.obs;
  final RxString selectedSession = ''.obs;
  final RxString searchText = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<Student> students = <Student>[].obs;
  final RxList<Student> filteredStudents = <Student>[].obs;
  final RxString viewMode = 'card'.obs;
  final RxDouble baseFontSize = 12.0.obs;

  void toggleViewMode() {
    viewMode.value = viewMode.value == 'table' ? 'card' : 'table';
  }

  void updateFontSize(double delta) {
    baseFontSize.value = (baseFontSize.value + delta).clamp(8, 24);
  }

  final RxList<String> groupList = <String>[].obs;
  final RxList<String> classList = <String>[].obs;
  final List<String> genderList = ['Male', 'Female', 'Other'];
  final List<String> religionList = [
    'Hindu',
    'Muslim',
    'Sikh',
    'Christian',
    'Other',
  ];
  // Category (General/OBC/SC/ST) and Caste (sub-category) come from the API.
  final RxList<String> categoryList = <String>[].obs;
  final RxList<String> casteList = <String>[].obs;
  final Map<String, int> _categoryIds = {}; // categoryName -> categoryId
  final Map<String, int> _casteIds = {}; // subCategoryName -> id
  final CategoryService _categoryService = CategoryService();
  final List<String> subCategoryList = ['None', 'PWD', 'Ex-Serviceman'];
  final List<String> academicYearList = ['2024-2025', '2025-2026', '2026-2027'];
  final List<String> resultList = ['Passed', 'Failed', 'Promoted', 'Awaited'];
  final RxList<String> sessionYearList = <String>[].obs;
  final SessionController sessionController = Get.put(SessionController());

  List<CategoryModel> _loadedGroups = [];
  List<CategoryModel> _loadedClasses = [];

  @override
  void onInit() {
    super.onInit();
    selectedStatus.value = 'All'; // Set default status to All
    _loadSessions();
    ever(selectedSession, (_) => _fetchGroups());
    ever(selectedGroup, (_) => _fetchClasses());
    ever(editCategory, (_) => _loadSubCategories());
    _loadCategories();
    _keepNamePrefixes();
    // Transport cascade: load vehicles when the toggle turns on, then routes
    // and pickup points as the user drills down (same as new admission).
    ever(availTransport, (bool on) {
      if (on) _loadVehicles();
    });
    ever(selectedVehicle, (_) => _onVehicleChanged());
    ever(selectedRoute, (_) => _onRouteChanged());
  }

  Future<void> _loadVehicles() async {
    vehicleList.clear();
    _loadedVehicles = [];
    isVehicleLoading.value = true;
    try {
      final response =
          await ApiService().postJsonWithoutBody(Endpoints.getVehicle());
      if (response is List) {
        _loadedVehicles = response
            .whereType<Map<String, dynamic>>()
            .map(VehicleModel.fromJson)
            .toList();
        vehicleList.assignAll(_loadedVehicles.map((v) => v.displayLabel));
      }
    } catch (e) {
      log('_loadVehicles error: $e');
    } finally {
      isVehicleLoading.value = false;
    }
  }

  Future<void> _onVehicleChanged() async {
    selectedRoute.value = '';
    selectedPickupPoint.value = '';
    routeList.clear();
    pickupPointList.clear();
    _loadedRoutes = [];
    _loadedPickupPoints = [];
    if (_vehicleId == 0) return;
    isRouteLoading.value = true;
    try {
      final response =
          await ApiService().getJson(Endpoints.getRoutesByVehicleId(_vehicleId));
      if (response is List) {
        _loadedRoutes = response
            .whereType<Map<String, dynamic>>()
            .map(RouteModel.fromJson)
            .toList();
        routeList.assignAll(_loadedRoutes.map((r) => r.fullName));
      }
    } catch (e) {
      log('_onVehicleChanged error: $e');
    } finally {
      isRouteLoading.value = false;
    }
  }

  Future<void> _onRouteChanged() async {
    selectedPickupPoint.value = '';
    pickupPointList.clear();
    _loadedPickupPoints = [];
    if (_routeId == 0 || _vehicleId == 0) return;
    isPickupLoading.value = true;
    try {
      final response = await ApiService().getJson(
        Endpoints.getPickupPointByRouteAndVehicle(
          _routeId,
          _vehicleId,
          _transportSessionId,
        ),
      );
      if (response is List) {
        _loadedPickupPoints = response
            .whereType<Map<String, dynamic>>()
            .map(PickupPointModel.fromJson)
            .toList();
        pickupPointList.assignAll(_loadedPickupPoints.map((p) => p.name));
      }
    } catch (e) {
      log('_onRouteChanged error: $e');
    } finally {
      isPickupLoading.value = false;
    }
  }

  /// Keeps a fixed 'MR. ' / 'MRS. ' prefix on the parent name fields, matching
  /// the new-admission form. The user edits only the name after the prefix.
  void _keepNamePrefixes() {
    fatherNameCtrl.addListener(() {
      if (!fatherNameCtrl.text.startsWith('Mr. ')) {
        final text = fatherNameCtrl.text
            .replaceFirst(RegExp(r'^(Mr\.?\s*)?', caseSensitive: false), '');
        fatherNameCtrl.value = TextEditingValue(
          text: 'Mr. $text',
          selection: TextSelection.collapsed(offset: 'Mr. $text'.length),
        );
      }
    });
    motherNameCtrl.addListener(() {
      if (!motherNameCtrl.text.startsWith('Mrs. ')) {
        final text = motherNameCtrl.text
            .replaceFirst(RegExp(r'^(Mrs\.?\s*)?', caseSensitive: false), '');
        motherNameCtrl.value = TextEditingValue(
          text: 'Mrs. $text',
          selection: TextSelection.collapsed(offset: 'Mrs. $text'.length),
        );
      }
    });
  }

  Future<void> _loadCategories() async {
    final list = await _categoryService.getCategories();
    _categoryIds
      ..clear()
      ..addEntries(list.map((e) => MapEntry(e.name, e.id)));
    categoryList.assignAll(list.map((e) => e.name));
  }

  Future<void> _loadSubCategories() async {
    final categoryId = _categoryIds[editCategory.value];
    if (categoryId == null) {
      casteList.clear();
      _casteIds.clear();
      editCaste.value = '';
      return;
    }
    final list = await _categoryService.getSubCategories(categoryId);
    _casteIds
      ..clear()
      ..addEntries(list.map((e) => MapEntry(e.name, e.id)));
    casteList.assignAll(list.map((e) => e.name));
    if (!casteList.contains(editCaste.value)) {
      editCaste.value = '';
    }
  }

  void _loadSessions() {
    ever(sessionController.sessionList, (sessions) {
      final names = sessions
          .map((e) => e.sessionName ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      sessionYearList.assignAll(names);
      if (selectedSession.value.isNotEmpty && !names.contains(selectedSession.value)) {
        selectedSession.value = '';
      }
    });
    if (sessionController.sessionList.isNotEmpty) {
      final names = sessionController.sessionList
          .map((e) => e.sessionName ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      sessionYearList.assignAll(names);
      if (selectedSession.value.isNotEmpty && !names.contains(selectedSession.value)) {
        selectedSession.value = '';
      }
    }
  }

  Future<void> _fetchGroups() async {
    final session = sessionController.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    if (session == null || session.sessionId == null) return;

    _loadedGroups = await sessionController.getGroupList(session.sessionId);
    groupList.assignAll(
      _loadedGroups
          .map((g) => g.name ?? '')
          .where((n) => n.isNotEmpty)
          .toList(),
    );

    if (selectedGroup.value.isNotEmpty && !groupList.contains(selectedGroup.value)) {
      selectedGroup.value = '';
    } else if (groupList.isEmpty) {
      selectedGroup.value = '';
    }
  }

  Future<void> _fetchClasses() async {
    final session = sessionController.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    final group = _loadedGroups.firstWhereOrNull(
      (g) => g.name == selectedGroup.value,
    );

    if (session == null ||
        session.sessionId == null ||
        group == null ||
        group.id == null)
      return;

    _loadedClasses = await sessionController.getClassList(
      group.id!,
      session.sessionId!,
    );
    classList.assignAll(
      _loadedClasses
          .map((c) => c.name ?? '')
          .where((n) => n.isNotEmpty)
          .toList(),
    );

    if (selectedClass.value.isNotEmpty && !classList.contains(selectedClass.value)) {
      selectedClass.value = '';
    } else if (classList.isEmpty) {
      selectedClass.value = '';
    }
  }

  // Locally updated profile photos, keyed by student id.
  final RxMap<String, File?> updatedPhotos = <String, File?>{}.obs;

  /// Opens the gallery/camera picker, uploads the chosen photo to the server
  /// and saves it against the student — same flow as the admission photo save
  /// (AdmissionController._saveStudentSrAndPhoto): upload → saveAdmissionDocument.
  void updatePhoto(BuildContext context, Student student) {
    ImagePickerService().showImagePickerOptions(
      context: context,
      onImageSelected: (file) async {
        // Reflect the new photo immediately in the UI.
        updatedPhotos[student.id] = file;
        isLoading.value = true;
        try {
          final studentId = int.tryParse(student.id) ?? 0;

          // 1. Upload student photo — documentFor=4 (Student).
          final studentPhotoName = await _uploadDocument(file, documentFor: 4);
          log('[UpdatePhoto] student=${student.id} photo uploaded: '
              '$studentPhotoName');

          // 2. Save document record — matches the admission payload exactly.
          final docPayload = <String, dynamic>{
            'studentId': studentId,
            'loginId': 0,
            'studentPhoto': studentPhotoName,
            'studentAadharFront': '',
            'studentAadharBack': '',
            'fatherAadharFront': '',
            'fatherAadharBack': '',
            'motherAadharFront': '',
            'motherAadharBack': '',
            'transferCertificate': '',
            'markSheet': '',
            'characterCertificate': '',
          };
          log('[UpdatePhoto] saveAdmissionDocument payload: $docPayload');
          final docResponse = await ApiService()
              .postJson(Endpoints.saveAdmissionDocument(), docPayload);
          log('[UpdatePhoto] saveAdmissionDocument response: $docResponse');

          final ok = docResponse is Map &&
              (docResponse['statusCode'] == 1 ||
                  docResponse['status'] == 'success');
          if (ok) {
            Get.snackbar(
              'Photo Updated',
              docResponse['responseText']?.toString() ??
                  'Student photo updated successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              'Error',
              (docResponse is Map
                      ? (docResponse['responseText'] ?? docResponse['message'])
                          ?.toString()
                      : null) ??
                  'Failed to update photo',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } on StudentUploadException catch (e) {
          Get.snackbar(
            'Upload Failed',
            e.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to update photo: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  /// Compresses [file] and uploads it to DocumentSettings/UploadDocuments.
  /// [documentFor]: 1=Staff, 2=Administrator, 3=Parent, 4=Student.
  /// Returns the server-assigned filename. Throws on statusCode == -1.
  Future<String> _uploadDocument(File file, {int documentFor = 4}) async {
    final bytes = await ImageUtils.compress(file);
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: file.path.split('/').last,
      contentType: MediaType('image', 'jpeg'),
    );
    final response = await ApiService().postMultipart(
      Endpoints.uploadDocuments(documentFor: documentFor),
      fields: {},
      headers: {},
      files: [multipartFile],
    );

    if (response is Map && response['statusCode'] == -1) {
      final msg =
          response['responseText']?.toString() ?? 'Document upload failed';
      log('_uploadDocument failed (documentFor=$documentFor): $msg');
      throw StudentUploadException(msg);
    }

    final name = (response is String)
        ? response
        : (response?['result'] ??
                  response?['fileName'] ??
                  response?['data'] ??
                  '')
              .toString();
    log('_uploadDocument(documentFor=$documentFor): '
        '${file.path.split('/').last} → $name');
    return name;
  }

  // Document upload state
  final RxMap<String, File?> uploadedFiles = <String, File?>{}.obs;
  final RxMap<String, bool> uploadProgress = <String, bool>{}.obs;
  final RxMap<String, double> uploadPercent = <String, double>{}.obs;

  /// Every document is optional — nothing here blocks saving an edit.
  static const List<String> documents = [
    'student_photo',
    'student_aadhar_front',
    'student_aadhar_back',
    'father_aadhar_front',
    'father_aadhar_back',
    'mother_aadhar_front',
    'mother_aadhar_back',
    'transfer_certificate',
    'marksheet',
    'character_certificate',
  ];

  static const Map<String, String> documentNames = {
    'student_photo': 'Student Photo',
    'student_aadhar_front': 'Student Aadhaar Front',
    'student_aadhar_back': 'Student Aadhaar Back',
    'father_aadhar_front': 'Father Aadhaar Front',
    'father_aadhar_back': 'Father Aadhaar Back',
    'mother_aadhar_front': 'Mother Aadhaar Front',
    'mother_aadhar_back': 'Mother Aadhaar Back',
    'transfer_certificate': 'Transfer Certificate',
    'marksheet': 'Marksheet',
    'character_certificate': 'Character Certificate',
  };

  static const Map<String, IconData> documentIcons = {
    'student_photo': Icons.camera_alt_outlined,
    'student_aadhar_front': Icons.badge_outlined,
    'student_aadhar_back': Icons.badge_outlined,
    'father_aadhar_front': Icons.badge_outlined,
    'father_aadhar_back': Icons.badge_outlined,
    'mother_aadhar_front': Icons.badge_outlined,
    'mother_aadhar_back': Icons.badge_outlined,
    'transfer_certificate': Icons.description_outlined,
    'marksheet': Icons.assessment_outlined,
    'character_certificate': Icons.verified_user_outlined,
  };

  // Step Management
  final RxInt currentStep = 0.obs;
  // Matches the New Admission flow: Basic Info, Guardian, Prev School,
  // SR & Transport, Documents.
  final int totalSteps = 5;

  // Edit form controllers
  final nameCtrl = TextEditingController();
  final fatherNameCtrl = TextEditingController();
  final fatherMobileCtrl = TextEditingController();
  final fatherOccupationCtrl = TextEditingController();
  final motherNameCtrl = TextEditingController();
  final motherMobileCtrl = TextEditingController();
  final motherOccupationCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final aadhaarCtrl = TextEditingController();
  final penNoCtrl = TextEditingController();
  final apaarIdCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final tehsilCtrl = TextEditingController();
  final villageCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final pinCodeCtrl = TextEditingController();
  final remarkCtrl = TextEditingController();

  // Guardian Details
  final RxBool isGuardianSameAsFather = true.obs;
  final TextEditingController guardianNameCtrl = TextEditingController();
  final TextEditingController guardianMobileCtrl = TextEditingController();
  final TextEditingController guardianOccupationCtrl = TextEditingController();
  final TextEditingController guardianVillageCtrl = TextEditingController();
  final TextEditingController guardianTehsilCtrl = TextEditingController();
  final TextEditingController guardianDistrictCtrl = TextEditingController();
  final TextEditingController guardianStateCtrl = TextEditingController();
  final TextEditingController guardianPinCodeCtrl = TextEditingController();
  final FocusNode apaarIdFocus = FocusNode();
  // Previous School Details
  final TextEditingController prevSchoolNameCtrl = TextEditingController();
  final TextEditingController prevClassCtrl = TextEditingController();
  final RxString selectedPrevResult = ''.obs;
  final RxString selectedPrevSessionYear = ''.obs;

  // SR No & Transport
  final RxBool generateSrNo = true.obs;
  final RxBool availTransport = false.obs;

  // ── Transport cascade (mirrors AdmissionController) ────────────────────────
  final RxString selectedVehicle = ''.obs;
  final RxString selectedRoute = ''.obs;
  final RxString selectedPickupPoint = ''.obs;
  final RxList<String> vehicleList = <String>[].obs;
  final RxList<String> routeList = <String>[].obs;
  final RxList<String> pickupPointList = <String>[].obs;
  final RxBool isVehicleLoading = false.obs;
  final RxBool isRouteLoading = false.obs;
  final RxBool isPickupLoading = false.obs;

  List<VehicleModel> _loadedVehicles = [];
  List<RouteModel> _loadedRoutes = [];
  List<PickupPointModel> _loadedPickupPoints = [];

  int get _vehicleId =>
      _loadedVehicles
          .firstWhereOrNull((v) => v.displayLabel == selectedVehicle.value)
          ?.id ??
      0;
  int get _routeId =>
      _loadedRoutes
          .firstWhereOrNull((r) => r.fullName == selectedRoute.value)
          ?.id ??
      0;
  int get _pickupPointId =>
      _loadedPickupPoints
          .firstWhereOrNull((p) => p.name == selectedPickupPoint.value)
          ?.id ??
      0;

  /// The edited student's session, used to scope the pickup-point lookup.
  int get _transportSessionId => _editingStudent?.sessionId ?? 0;

  final RxString editAcademicYear = ''.obs;
  final RxString editGroup = ''.obs;
  final RxString editClass = ''.obs;
  final RxString editGender = ''.obs;
  final RxString editReligion = ''.obs;
  final RxString editCategory = ''.obs;
  final RxString editCaste = ''.obs;
  final RxString editSubCategory = ''.obs;

  /// Remembers which list the current results came from, so a refresh after an
  /// edit re-runs the same query.
  bool _lastIsNewStudent = false;

  void searchStudents({bool isNewStudent = false}) async {
    _lastIsNewStudent = isNewStudent;
    if (selectedGroup.value.isEmpty || selectedClass.value.isEmpty) {
      Get.snackbar(
        'Filter Required',
        'Please select both Group and Class',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      // return;
    }

    isLoading.value = true;

    try {
      final session = sessionController.sessionList.firstWhereOrNull(
        (e) => e.sessionName == selectedSession.value,
      );
      final sessionId = session?.sessionId ?? 0;

      final group = _loadedGroups.firstWhereOrNull(
        (g) => g.name == selectedGroup.value,
      );
      final groupId = group?.id ?? 0;

      final cls = _loadedClasses.firstWhereOrNull(
        (c) => c.name == selectedClass.value,
      );
      final classId = cls?.id ?? 0;

      int isActiveStatus = -1;
      if (selectedStatus.value == 'Active') isActiveStatus = 1;
      if (selectedStatus.value == 'Inactive') isActiveStatus = 0;

      final payload = {
        "isActive": isActiveStatus,
        "branchId": 0,
        "sessionId": sessionId,
        "groupId": groupId,
        "classId": classId,
        "top": 0,
        "searchText": "",
      };

      final uri = isNewStudent
          ? Endpoints.getNewStudentList()
          : Endpoints.getStudentList();
      final response = await ApiService().postJson(uri, payload);

      List<dynamic> listData = [];
      if (response is Map<String, dynamic>) {
        listData = response['result'] ?? response['data'] ?? [];
      } else if (response is List) {
        listData = response;
      }

      final fetchedStudents = listData
          .map((e) => StudentListResponse.fromJson(e))
          .toList();

      final mappedStudents = fetchedStudents.map((s) {
        return Student(
          id: s.id?.toString() ?? '',
          sid: s.sid ?? '',
          een: s.penno ?? '',
          name: '${s.firstName ?? ''} ${s.lastName ?? ''}'.trim(),
          rollNo: s.rollNumber ?? '',
          group: s.groupName ?? 'Unknown',
          className: s.className ?? 'Unknown',
          photoUrl: (s.photo != null && s.photo!.isNotEmpty) ? s.photo! : '',
          finishedImage: s.finishedPhoto ?? '',
          fatherName: s.fatherName ?? '',
          motherName: s.motherName ?? '',
          fatherOccupation: s.fatherOccupation ?? '',
          motherOccupation: s.motherOccupation ?? '',
          email: s.emailId ?? '',
          phone: s.fatherMobile ?? '',
          pinCode: (s.postalCode ?? 0) == 0 ? '' : s.postalCode.toString(),
          aadhaar: s.aadharNo ?? '',
          dob: s.dob ?? '',
          gender: s.gender ?? 'Unknown',
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
          sessionId: s.sessionId ?? 0,
          groupId: s.groupId ?? 0,
          classId: s.classId ?? 0,
          session: s.session ?? '',
          motherMobile: s.motherMobile ?? '',
          parentUserId: s.parentUserId ?? 0,
          vehicleId: s.vehicleId ?? 0,
          routeId: s.routeId ?? 0,
          pickUpId: s.pickUpId ?? 0,
        );
      }).toList();

      students.assignAll(mappedStudents);
      filterStudents(searchText.value);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch students: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterStudents(String query) {
    searchText.value = query;
    if (query.isEmpty) {
      filteredStudents.assignAll(students);
    } else {
      filteredStudents.assignAll(
        students
            .where(
              (s) =>
                  s.name.toLowerCase().contains(query.toLowerCase()) ||
                  s.rollNo.toLowerCase().contains(query.toLowerCase()),
            )
            .toList(),
      );
    }
  }

  /// The student currently being edited (used for its id on save).
  Student? _editingStudent;

  /// Returns [name] with [prefix] (e.g. 'MR. ') applied once. An empty name
  /// yields just the prefix; a name that already carries it is left as-is.
  String _withPrefix(String name, String prefix) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return prefix;
    if (trimmed.toUpperCase().startsWith(prefix.trim().toUpperCase())) {
      return trimmed;
    }
    return '$prefix$trimmed';
  }

  void prepareEdit(Student student) {
    _editingStudent = student;
    currentStep.value = 0;
    nameCtrl.text = student.name;
    fatherNameCtrl.text = _withPrefix(student.fatherName, 'MR. ');
    fatherMobileCtrl.text = student.phone;
    fatherOccupationCtrl.text = student.fatherOccupation;
    motherNameCtrl.text = _withPrefix(student.motherName, 'MRS. ');
    motherMobileCtrl.text = student.motherMobile;
    motherOccupationCtrl.text = student.motherOccupation;
    emailCtrl.text = student.email;
    phoneCtrl.text = student.phone;
    aadhaarCtrl.text = student.aadhaar;
    penNoCtrl.text = student.penNo;
    apaarIdCtrl.text = student.apaarId;
    dobCtrl.text = student.dob;
    districtCtrl.text = student.district;
    tehsilCtrl.text = student.tehsil;
    villageCtrl.text = student.village;
    stateCtrl.text =
        student.state.trim().isEmpty ? 'Uttar Pradesh' : student.state;
    pinCodeCtrl.text = student.pinCode;
    remarkCtrl.text = student.remark;

    isGuardianSameAsFather.value = student.isGuardianSameAsFather;
    guardianNameCtrl.text = student.guardianName;
    guardianMobileCtrl.text = student.guardianMobile;
    guardianOccupationCtrl.text = student.guardianOccupation;
    guardianVillageCtrl.text = student.guardianVillage;
    guardianTehsilCtrl.text = student.guardianTehsil;
    guardianDistrictCtrl.text = student.guardianDistrict;
    guardianStateCtrl.text = student.guardianState;
    guardianPinCodeCtrl.text = student.guardianPinCode;

    prevSchoolNameCtrl.text = student.prevSchoolName;
    prevClassCtrl.text = student.prevClass;
    selectedPrevResult.value = student.prevResult;
    selectedPrevSessionYear.value = student.prevSessionYear;

    generateSrNo.value = student.generateSrNo;
    // Reset the transport cascade for a clean edit; toggling availTransport on
    // reloads the vehicle list via the onInit worker.
    selectedVehicle.value = '';
    selectedRoute.value = '';
    selectedPickupPoint.value = '';
    vehicleList.clear();
    routeList.clear();
    pickupPointList.clear();
    availTransport.value = student.availTransport;

    editAcademicYear.value = student.session;
    editGroup.value = student.group;
    editClass.value = student.className;
    editGender.value = student.gender;
    editReligion.value = student.religion;
    editCategory.value = student.category;
    editCaste.value = '';
    editSubCategory.value = student.subCategory;
  }

  void nextStep() {
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      currentStep.value = step;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // Match the admission flow: DOB is stored/sent as dd/MM/yyyy.
      dobCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  void setUploadedFile(String key, File file) {
    uploadedFiles[key] = file;
  }

  void removeUploadedFile(String key) {
    uploadedFiles[key] = null;
  }

  /// Maps a display gender to the API's single-char code (matches admission).
  String _mapGender(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return 'M';
      case 'female':
        return 'F';
      default:
        return 'O';
    }
  }

  /// True when the API call succeeded.
  bool _isOk(dynamic response) =>
      response is Map &&
      (response['statusCode'] == 1 || response['status'] == 'success');

  /// Extracts a server error message, falling back to [fallback].
  String _errorText(dynamic response, String fallback) =>
      (response is Map
          ? (response['responseText'] ?? response['message'])?.toString()
          : null) ??
      fallback;

  void _showUpdateError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  /// Saves every section of the edit form that the user can actually change.
  ///
  /// Sections are saved in the same order as a new admission. The guardian and
  /// previous-school sections are only sent when the user filled them in:
  /// GetStudentList does not return those fields, so [prepareEdit] loads them
  /// empty and posting them unconditionally would blank the stored values.
  Future<void> updateStudent() async {
    final student = _editingStudent;
    final studentId = int.tryParse(student?.id ?? '') ?? 0;
    if (student == null || studentId == 0) {
      _showUpdateError('Cannot update: student id is missing');
      return;
    }

    isLoading.value = true;
    try {
      if (!await _updateBasicInformation(student, studentId)) return;
      if (!await _updateGuardianDetail(studentId)) return;
      if (!await _updatePreviousSchool(studentId)) return;
      if (!await _updateTransportDetail(student, studentId)) return;
      if (!await _updateDocuments(studentId)) return;

      Get.back();
      Get.snackbar(
        'Success',
        'Student details updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Re-run the same query so the list reflects the edit immediately,
      // without the user having to search again.
      searchStudents(isNewStudent: _lastIsNewStudent);
    } on StudentUploadException catch (e) {
      log('updateStudent upload error: $e');
      _showUpdateError(e.message);
    } catch (e) {
      log('updateStudent error: $e');
      _showUpdateError('Failed to update student: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _updateBasicInformation(Student student, int studentId) async {
    // Prefer what the user picked in the dropdowns; fall back to the student's
    // own stored ids so an untouched dropdown never posts 0.
    final sessionId = sessionController.sessionList
            .firstWhereOrNull((e) => e.sessionName == editAcademicYear.value)
            ?.sessionId ??
        student.sessionId;
    final groupId =
        _loadedGroups.firstWhereOrNull((g) => g.name == editGroup.value)?.id ??
            student.groupId;
    final classId =
        _loadedClasses.firstWhereOrNull((c) => c.name == editClass.value)?.id ??
            student.classId;

    // Same payload shape as AdmissionController._saveBasicInformation.
    // TODO(update-later): confirm studentType for edit — 1 is carried over from
    // the previous implementation and is not derived from the student record.
    final payload = <String, dynamic>{
      'studentId': studentId,
      'loginId': 0,
      'studentType': 1,
      'sessionId': sessionId,
      'groupId': groupId,
      'classId': classId,
      'studentName': nameCtrl.text.trim(),
      'aadharNo': aadhaarCtrl.text.replaceAll(' ', ''),
      'penNo': penNoCtrl.text.trim(),
      'apaarId': apaarIdCtrl.text.trim(),
      'dob': dobCtrl.text.trim(), // dd/MM/yyyy, same as admission.
      'fatherName': fatherNameCtrl.text.trim(),
      'fatherOccupation': fatherOccupationCtrl.text.trim(),
      'fatherMobile': fatherMobileCtrl.text.trim(),
      'motherName': motherNameCtrl.text.trim(),
      'motherOccupation': motherOccupationCtrl.text.trim(),
      'motherMobile': motherMobileCtrl.text.trim(),
      'gender': _mapGender(editGender.value),
      'religion': editReligion.value,
      'category': editCategory.value,
      'categoryId': _categoryIds[editCategory.value] ?? 0,
      'subCaste': editSubCategory.value,
      'villageMohalla': villageCtrl.text.trim(),
      'tehsil': tehsilCtrl.text.trim(),
      'district': districtCtrl.text.trim(),
      'pinCode': int.tryParse(pinCodeCtrl.text.trim()) ?? 0,
      'parentUserId': student.parentUserId,
      'applicationNo': '',
    };

    // Caste and state have no source field in GetStudentList, so they are only
    // sent when the user actually entered one — otherwise the stored value
    // would be blanked on every save.
    if (editCaste.value.isNotEmpty) {
      payload['caste'] = editCaste.value;
      payload['subCategoryId'] = _casteIds[editCaste.value] ?? 0;
    }
    if (stateCtrl.text.trim().isNotEmpty) {
      payload['state'] = stateCtrl.text.trim();
    }

    log('updateStudent saveBasicInformation payload: $payload');
    final response =
        await ApiService().postJson(Endpoints.saveBasicInformation(), payload);
    log('updateStudent saveBasicInformation response: $response');

    if (_isOk(response)) return true;
    _showUpdateError(_errorText(response, 'Failed to update basic information'));
    return false;
  }

  Future<bool> _updateGuardianDetail(int studentId) async {
    final hasGuardianInput = guardianNameCtrl.text.trim().isNotEmpty ||
        guardianMobileCtrl.text.trim().isNotEmpty ||
        guardianOccupationCtrl.text.trim().isNotEmpty ||
        guardianVillageCtrl.text.trim().isNotEmpty;
    if (!hasGuardianInput) {
      log('updateStudent: guardian section untouched, skipping save');
      return true;
    }

    final payload = <String, dynamic>{
      'studentId': studentId,
      'loginId': 0,
      'isGuardianSameAsFather': isGuardianSameAsFather.value,
      'guardianName': guardianNameCtrl.text.trim(),
      'guardianOccupation': guardianOccupationCtrl.text.trim(),
      'guardianMobile': guardianMobileCtrl.text.trim(),
      'guardianVillageMohalla': guardianVillageCtrl.text.trim(),
      'guardianTehsil': guardianTehsilCtrl.text.trim(),
      'guardianDistrict': guardianDistrictCtrl.text.trim(),
      'guardianState': guardianStateCtrl.text.trim(),
      'guardianPinCode': guardianPinCodeCtrl.text.trim(),
    };

    log('updateStudent saveGuardianDetail payload: $payload');
    final response =
        await ApiService().postJson(Endpoints.saveGuardianDetail(), payload);
    log('updateStudent saveGuardianDetail response: $response');

    if (_isOk(response)) return true;
    _showUpdateError(_errorText(response, 'Failed to update guardian details'));
    return false;
  }

  Future<bool> _updatePreviousSchool(int studentId) async {
    final hasPrevSchoolInput = prevSchoolNameCtrl.text.trim().isNotEmpty ||
        prevClassCtrl.text.trim().isNotEmpty ||
        selectedPrevResult.value.isNotEmpty ||
        selectedPrevSessionYear.value.isNotEmpty;
    if (!hasPrevSchoolInput) {
      log('updateStudent: previous school section untouched, skipping save');
      return true;
    }

    final payload = <String, dynamic>{
      'studentId': studentId,
      'loginId': 0,
      'previousSchoolName': prevSchoolNameCtrl.text.trim(),
      'previousClass': prevClassCtrl.text.trim(),
      'previousSessionResult': selectedPrevResult.value,
      'previousSession': selectedPrevSessionYear.value,
    };

    log('updateStudent savePreviousSchool payload: $payload');
    final response =
        await ApiService().postJson(Endpoints.savePreviousSchool(), payload);
    log('updateStudent savePreviousSchool response: $response');

    if (_isOk(response)) return true;
    _showUpdateError(_errorText(response, 'Failed to update previous school'));
    return false;
  }

  Future<bool> _updateTransportDetail(Student student, int studentId) async {
    // Prefer the vehicle/route/pickup the user picked in the cascade; fall back
    // to the student's stored assignment when a level was left untouched so an
    // unchanged transport section never wipes the existing allocation.
    final payload = <String, dynamic>{
      'studentId': studentId,
      'loginId': 0,
      'srNo': generateSrNo.value ? '' : student.srNo,
      'isAutoGenerateSrNo': generateSrNo.value,
      'isAvailTransport': availTransport.value,
      'vehicleId': _vehicleId != 0 ? _vehicleId : student.vehicleId,
      'routeId': _routeId != 0 ? _routeId : student.routeId,
      'pickupPointId': _pickupPointId != 0 ? _pickupPointId : student.pickUpId,
    };

    log('updateStudent saveTransportDetail payload: $payload');
    final response =
        await ApiService().postJson(Endpoints.saveTransportDetail(), payload);
    log('updateStudent saveTransportDetail response: $response');

    if (_isOk(response)) return true;
    _showUpdateError(_errorText(response, 'Failed to update transport details'));
    return false;
  }

  /// Uploads only the documents the user picked, mirroring [updatePhoto].
  /// Untouched slots are sent as empty strings, as the admission flow does.
  Future<bool> _updateDocuments(int studentId) async {
    final picked = uploadedFiles.entries.where((e) => e.value != null).toList();
    if (picked.isEmpty) {
      log('updateStudent: no documents picked, skipping save');
      return true;
    }

    final payload = <String, dynamic>{
      'studentId': studentId,
      'loginId': 0,
      'studentPhoto': await _uploadDocIfPicked('student_photo'),
      'studentAadharFront': await _uploadDocIfPicked('student_aadhar_front'),
      'studentAadharBack': await _uploadDocIfPicked('student_aadhar_back'),
      'fatherAadharFront': await _uploadDocIfPicked('father_aadhar_front'),
      'fatherAadharBack': await _uploadDocIfPicked('father_aadhar_back'),
      'motherAadharFront': await _uploadDocIfPicked('mother_aadhar_front'),
      'motherAadharBack': await _uploadDocIfPicked('mother_aadhar_back'),
      'transferCertificate': await _uploadDocIfPicked('transfer_certificate'),
      'markSheet': await _uploadDocIfPicked('marksheet'),
      'characterCertificate':
          await _uploadDocIfPicked('character_certificate'),
    };

    log('updateStudent saveAdmissionDocument payload: $payload');
    final response =
        await ApiService().postJson(Endpoints.saveAdmissionDocument(), payload);
    log('updateStudent saveAdmissionDocument response: $response');

    if (_isOk(response)) return true;
    _showUpdateError(_errorText(response, 'Failed to update documents'));
    return false;
  }

  /// Uploads the file at [key] if the user picked one, else returns ''.
  Future<String> _uploadDocIfPicked(String key) async {
    final file = uploadedFiles[key];
    if (file == null) return '';
    return _uploadDocument(file, documentFor: 4);
  }
}
