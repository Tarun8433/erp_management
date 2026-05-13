import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeasonUpdateStudent {
  final String sid;
  final String name;
  final String fatherName;
  final String motherName;
  final String mobileNo;
  final String group;
  final String className;
  final String session;
  final RxString status; // 'Updated' or 'Not Updated'
  final RxString updatedClass;
  final RxString updateDate;
  final RxBool isSelected;

  SeasonUpdateStudent({
    required this.sid,
    required this.name,
    required this.fatherName,
    required this.motherName,
    required this.mobileNo,
    required this.group,
    required this.className,
    required this.session,
    String status = 'Not Updated',
    String updatedClass = '',
    String updateDate = '',
    bool isSelected = false,
  })  : status = status.obs,
        updatedClass = updatedClass.obs,
        updateDate = updateDate.obs,
        isSelected = isSelected.obs;
}

class SeasonUpdateController extends GetxController {
  final RxString viewMode = 'table'.obs;
  final RxDouble baseFontSize = 12.0.obs;
  final RxBool isLoading = false.obs;

  // Filter States
  final RxString selectedSession = '2025-2026'.obs;
  final RxString selectedGroup = 'PLAY GROUP EM'.obs;
  final RxString selectedClass = 'LKG A'.obs;
  final RxString selectedRecords = 'WITHOUT RESULT'.obs;
  final RxString selectedExamType = 'All'.obs;
  final RxString percentFrom = ''.obs;
  final RxString percentTo = ''.obs;
  final RxString searchText = ''.obs;

  // Lists
  final List<String> sessions = ['2023-2024', '2024-2025', '2025-2026'];
  final List<String> groups = ['PLAY GROUP EM', 'PRIMARY', 'SECONDARY'];
  final List<String> classes = ['NURSERY A', 'LKG A', 'UKG A', '1st A'];
  final List<String> recordsOptions = ['WITH RESULT', 'WITHOUT RESULT', 'RESULT WISE'];
  final List<String> examTypes = ['All', 'Final', 'Quarterly', 'Half Yearly'];

  final RxList<SeasonUpdateStudent> students = <SeasonUpdateStudent>[].obs;
  final RxBool selectAll = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load some mock data for demonstration
    _loadMockData();
  }

  void _loadMockData() {
    students.assignAll([
      SeasonUpdateStudent(
        sid: '1001',
        name: 'ADEEP CHATURVEDI',
        fatherName: 'SANDEEP KUMAR',
        motherName: 'ANNU DEVI',
        mobileNo: '8299650401',
        group: 'PLAY GROUP EM',
        className: 'LKG A',
        session: '2025-2026',
        status: 'Updated',
        updatedClass: 'UKG A',
        updateDate: '22 Feb 2026 22:53:37',
      ),
      SeasonUpdateStudent(
        sid: '1002',
        name: 'SURYANSH',
        fatherName: 'VINAY KUMAR PORWAL',
        motherName: 'LAXMI PORWAL',
        mobileNo: '8957896031',
        group: 'PLAY GROUP EM',
        className: 'LKG A',
        session: '2025-2026',
        status: 'Updated',
        updatedClass: 'UKG A',
        updateDate: '21 Feb 2026 11:46:10',
      ),
      SeasonUpdateStudent(
        sid: '1003',
        name: 'VEER SINGH',
        fatherName: 'DHARMENDRA',
        motherName: 'RASHMI',
        mobileNo: '7984040014',
        group: 'PLAY GROUP EM',
        className: 'LKG A',
        session: '2025-2026',
      ),
      SeasonUpdateStudent(
        sid: '1004',
        name: 'YOGESH',
        fatherName: 'SHAILENDRA',
        motherName: 'RENU',
        mobileNo: '9415963813',
        group: 'PLAY GROUP EM',
        className: 'LKG A',
        session: '2025-2026',
      ),
      SeasonUpdateStudent(
        sid: '1005',
        name: 'REJWAN',
        fatherName: 'MUNNA KHAN',
        motherName: 'ZAMEELA',
        mobileNo: '8953900810',
        group: 'PLAY GROUP EM',
        className: 'LKG A',
        session: '2025-2026',
        status: 'Updated',
        updatedClass: 'UKG A',
        updateDate: '19 Feb 2026 16:30:04',
      ),
    ]);
  }

  void toggleViewMode() {
    viewMode.value = viewMode.value == 'table' ? 'card' : 'table';
  }

  void updateFontSize(double delta) {
    baseFontSize.value = (baseFontSize.value + delta).clamp(10.0, 18.0);
  }

  void toggleSelectAll(bool? value) {
    selectAll.value = value ?? false;
    for (var student in students) {
      if (student.status.value == 'Not Updated') {
        student.isSelected.value = selectAll.value;
      }
    }
  }

  void fetchStudents() {
    isLoading.value = true;
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
      _loadMockData();
    });
  }

  void updateSection() {
    final selectedCount = students.where((s) => s.isSelected.value).length;
    if (selectedCount == 0) {
      Get.snackbar('No Selection', 'Please select at least one student to update section.');
      return;
    }
    
    Get.snackbar('Processing', 'Updating section for $selectedCount students...');
    // Implement actual update logic here
  }
}
