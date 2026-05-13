import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentPromotionItem {
  final int sNo;
  final String sid;
  final String group;
  final String currentClass;
  final String currentSession;
  final RxString status; // 'Promoted' or 'Not Promoted'
  final RxString promotedToClass;
  final RxString promotionDate;
  final String name;
  final String fatherName;
  final String motherName;
  final String mobileNo;
  final RxBool isSelected;

  StudentPromotionItem({
    required this.sNo,
    required this.sid,
    required this.group,
    required this.currentClass,
    required this.currentSession,
    required String status,
    required String promotedToClass,
    required String promotionDate,
    required this.name,
    required this.fatherName,
    required this.motherName,
    required this.mobileNo,
    bool isSelected = false,
  })  : status = status.obs,
        promotedToClass = promotedToClass.obs,
        promotionDate = promotionDate.obs,
        isSelected = isSelected.obs;
}

class StudentPromotionController extends GetxController {
  final RxString viewMode = 'table'.obs;
  final RxDouble baseFontSize = 12.0.obs;

  // Filters
  final RxString selectedSession = '2025 - 2026'.obs;
  final RxString selectedGroup = 'JUNIOR EM'.obs;
  final RxString selectedClass = '6 A'.obs;
  final RxString selectedStatus = 'All'.obs;
  final RxString searchText = ''.obs;

  final List<String> sessions = ['2024 - 2025', '2025 - 2026', '2026 - 2027'];
  final List<String> groups = ['JUNIOR EM', 'SENIOR EM', 'PLAY GROUP EM'];
  final List<String> classes = ['6 A', '7 A', '8 A', '9 A'];
  final List<String> statuses = ['All', 'Promoted', 'Not Promoted'];

  final RxList<StudentPromotionItem> students = <StudentPromotionItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool selectAll = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStudents();
  }

  void toggleViewMode() {
    viewMode.value = viewMode.value == 'table' ? 'card' : 'table';
  }

  void updateFontSize(double delta) {
    baseFontSize.value = (baseFontSize.value + delta).clamp(10.0, 20.0);
  }

  void toggleSelectAll(bool? val) {
    selectAll.value = val ?? false;
    for (var s in students) {
      s.isSelected.value = selectAll.value;
    }
  }

  void fetchStudents() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));

    // Mock data based on screenshot
    students.assignAll([
      StudentPromotionItem(
        sNo: 1,
        sid: '12314',
        group: 'JUNIOR EM',
        currentClass: '7 A',
        currentSession: '2025 - 2026',
        status: 'Promoted',
        promotedToClass: '8 A',
        promotionDate: '15 Apr 2026 14:22:03',
        name: 'ALISHA KHAN3232',
        fatherName: 'SHAREEF AHMAD',
        motherName: 'NAGMA',
        mobileNo: '9956672084',
      ),
      StudentPromotionItem(
        sNo: 2,
        sid: '12315',
        group: 'JUNIOR EM',
        currentClass: '6 A',
        currentSession: '2025 - 2026',
        status: 'Not Promoted',
        promotedToClass: '',
        promotionDate: '21 Feb 2026 15:37:49',
        name: 'RAUNAK',
        fatherName: 'MULAYAM SINGH',
        motherName: 'RITA DEVI',
        mobileNo: '8601706763',
      ),
      StudentPromotionItem(
        sNo: 3,
        sid: '12316',
        group: 'JUNIOR EM',
        currentClass: '6 A',
        currentSession: '2025 - 2026',
        status: 'Promoted',
        promotedToClass: '7 A',
        promotionDate: '26 Apr 2026 22:27:47',
        name: 'SHIVANK',
        fatherName: 'KUNDAN SINGH',
        motherName: 'SANDHYA DEVI',
        mobileNo: '9919541806',
      ),
    ]);
    isLoading.value = false;
  }

  void promoteSelected() {
    final selected = students.where((s) => s.isSelected.value).toList();
    if (selected.isEmpty) {
      Get.snackbar('Selection Required', 'Please select students to promote',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    // Logic to promote students
    Get.snackbar('Success', '${selected.length} students promoted successfully',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  void undoPromotion(StudentPromotionItem student) {
    student.status.value = 'Not Promoted';
    student.promotedToClass.value = '';
    Get.snackbar('Action', 'Promotion undone for ${student.name}');
  }
}
