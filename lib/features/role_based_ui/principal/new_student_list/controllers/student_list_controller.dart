import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

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
  final String pan;
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
    this.fatherName = 'John Doe Sr.',
    this.motherName = 'Jane Doe',
    this.email = 'student@example.com',
    this.phone = '9876543210',
    this.aadhaar = '1234 5678 9012',
    this.pan = 'ABCDE1234F',
    this.dob = '2008-05-20',
    this.gender = 'Male',
    this.religion = 'Hindu',
    this.category = 'General',
    this.subCategory = 'None',
    this.district = 'Lucknow',
    this.tehsil = 'Lucknow',
    this.village = 'Hazratganj',
    this.status = 'Active',
    this.srNo = '',
    this.entryAt = '',
    this.state = 'Uttar Pradesh',
    this.pinCode = '226001',
    this.remark = '',
    this.apaarId = '',
    this.penNo = '',
    this.fatherOccupation = 'Business',
    this.motherOccupation = 'Housewife',
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
  });
}

class StudentListController extends GetxController {
  final RxString selectedGroup = ''.obs;
  final RxString selectedClass = ''.obs;
  final RxString selectedStatus = 'All'.obs;
  final RxString selectedSession = '2025-2026'.obs;
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

  final List<String> groupList = ['Science', 'Commerce', 'Arts'];
  final List<String> classList = ['11th', '12th', '9th', '10th'];
  final List<String> genderList = ['Male', 'Female', 'Other'];
  final List<String> religionList = ['Hindu', 'Muslim', 'Sikh', 'Christian', 'Other'];
  final List<String> categoryList = ['General', 'OBC', 'SC', 'ST'];
  final List<String> subCategoryList = ['None', 'PWD', 'Ex-Serviceman'];
  final List<String> academicYearList = ['2024-2025', '2025-2026', '2026-2027'];
  final List<String> resultList = ['Passed', 'Failed', 'Promoted', 'Awaited'];
  final List<String> sessionYearList = ['2023-2024', '2024-2025', '2025-2026'];
  // Document upload state
  final RxMap<String, File?> uploadedFiles = <String, File?>{}.obs;
  final RxMap<String, bool> uploadProgress = <String, bool>{}.obs;
  final RxMap<String, double> uploadPercent = <String, double>{}.obs;

  static const List<String> requiredDocuments = [
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

  static const List<String> optionalDocuments = [];

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
  final int totalSteps = 6;

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

  // Previous School Details
  final TextEditingController prevSchoolNameCtrl = TextEditingController();
  final TextEditingController prevClassCtrl = TextEditingController();
  final RxString selectedPrevResult = ''.obs;
  final RxString selectedPrevSessionYear = ''.obs;

  // SR No & Transport
  final RxBool generateSrNo = true.obs;
  final RxBool availTransport = false.obs;
  
  final RxString editAcademicYear = ''.obs;
  final RxString editGroup = ''.obs;
  final RxString editClass = ''.obs;
  final RxString editGender = ''.obs;
  final RxString editReligion = ''.obs;
  final RxString editCategory = ''.obs;
  final RxString editSubCategory = ''.obs;

  void searchStudents() async {
    if (selectedGroup.value.isEmpty || selectedClass.value.isEmpty) {
      Get.snackbar(
        'Filter Required',
        'Please select both Group and Class',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    
    final mockData = List.generate(
      20,
      (index) => Student(
        id: '$index',
        sid: '1231${index + 5}',
        een: '202600${index + 33}',
        srNo: '1223${index + 5}',
        name: 'Student ${index + 1}',
        rollNo: '2024${index.toString().padLeft(3, '0')}',
        group: selectedGroup.value,
        className: selectedClass.value,
        status: 'Active',
        entryAt: '2026-05-11',
        photoUrl: 'https://i.pravatar.cc/150?u=$index',
        finishedImage: 'https://i.pravatar.cc/150?u=${index + 100}',
        fatherName: 'Father Name $index',
        motherName: 'Mother Name $index',
        phone: '63922654$index',
        district: 'BARABANKI',
        tehsil: 'NAWABGANJ',
        village: 'ARAURA',
        dob: '01-02-2014',
        religion: 'Hindu',
        category: 'OBC',
        gender: index % 2 == 0 ? 'Male' : 'Female',
      ),
    );

    students.assignAll(mockData);
    filterStudents(searchText.value);
    isLoading.value = false;
  }

  void filterStudents(String query) {
    searchText.value = query;
    if (query.isEmpty) {
      filteredStudents.assignAll(students);
    } else {
      filteredStudents.assignAll(
        students.where((s) =>
          s.name.toLowerCase().contains(query.toLowerCase()) ||
          s.rollNo.toLowerCase().contains(query.toLowerCase()),
        ).toList(),
      );
    }
  }

  void prepareEdit(Student student) {
    currentStep.value = 0;
    nameCtrl.text = student.name;
    fatherNameCtrl.text = student.fatherName;
    fatherMobileCtrl.text = student.phone;
    fatherOccupationCtrl.text = student.fatherOccupation;
    motherNameCtrl.text = student.motherName;
    motherMobileCtrl.text = ''; // Add to Student model if needed
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
    stateCtrl.text = student.state;
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
    availTransport.value = student.availTransport;
    
    editAcademicYear.value = ''; // Add to Student model if needed
    editGroup.value = student.group;
    editClass.value = student.className;
    editGender.value = student.gender;
    editReligion.value = student.religion;
    editCategory.value = student.category;
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
      dobCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  void setUploadedFile(String key, File file) {
    uploadedFiles[key] = file;
  }

  void removeUploadedFile(String key) {
    uploadedFiles[key] = null;
  }

  bool get areAllRequiredUploaded {
    return requiredDocuments.every((key) => uploadedFiles[key] != null);
  }

  Future<void> updateStudent() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    Get.back();
    Get.snackbar('Success', 'Student details updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
    isLoading.value = false;
  }
}
