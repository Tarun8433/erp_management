import 'package:erp_management/core/controllers/session_controller.dart';
import 'package:erp_management/core/models/category_model.dart';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/features/role_based_ui/principal/student_promotion/models/promotion_list_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeasonUpdateStudent {
  final int id;
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
    required this.id,
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
  final RxString selectedSession = ''.obs;
  final RxString selectedGroup = ''.obs;
  final RxString selectedClass = ''.obs;
  final RxString selectedRecords = 'WITHOUT RESULT'.obs;
  final RxString selectedExamType = ''.obs;
  final RxString percentFrom = ''.obs;
  final RxString percentTo = ''.obs;
  final RxString searchText = ''.obs;

  // Dynamic lists from API
  final RxList<String> sessions = <String>[].obs;
  final RxList<String> groups = <String>[].obs;
  final RxList<String> classes = <String>[].obs;

  // Static option lists
  final List<String> recordsOptions = [
    'WITH RESULT',
    'WITHOUT RESULT',
    'RESULT WISE',
  ];
  final List<String> examTypes = ['All', 'Final', 'Quarterly', 'Half Yearly'];

  final RxList<SeasonUpdateStudent> students = <SeasonUpdateStudent>[].obs;
  final RxBool selectAll = false.obs;

  // Target section state (used in update bottom sheet)
  final RxString selectedToGroup = ''.obs;
  final RxString selectedToClass = ''.obs;
  final RxList<String> toClasses = <String>[].obs;
  List<CategoryModel> _loadedToClasses = [];

  final SessionController _sessionCtrl = Get.put(SessionController());
  List<CategoryModel> _loadedGroups = [];
  List<CategoryModel> _loadedClasses = [];

  @override
  void onInit() {
    super.onInit();
    _loadSessions();
    ever(selectedSession, (_) => _fetchGroups());
    ever(selectedGroup, (_) => _fetchClasses());
  }

  void _loadSessions() {
    ever(_sessionCtrl.sessionList, (list) {
      _applySessionList(list);
    });
    if (_sessionCtrl.sessionList.isNotEmpty) {
      _applySessionList(_sessionCtrl.sessionList);
    }
  }

  void _applySessionList(List list) {
    final names = list
        .map((e) => e.sessionName ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    sessions.assignAll(names.cast<String>());
    if (selectedSession.value.isNotEmpty &&
        !names.contains(selectedSession.value)) {
      selectedSession.value = '';
    }
  }

  Future<void> _fetchGroups() async {
    groups.clear();
    _loadedGroups = [];
    selectedGroup.value = '';

    final session = _sessionCtrl.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    if (session == null || session.sessionId == null) return;

    _loadedGroups = await _sessionCtrl.getGroupList(session.sessionId!);
    final names = _loadedGroups
        .map((g) => g.name ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    groups.assignAll(names);
  }

  Future<void> _fetchClasses() async {
    classes.clear();
    _loadedClasses = [];
    selectedClass.value = '';

    final session = _sessionCtrl.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    final group = _loadedGroups.firstWhereOrNull(
      (g) => g.name == selectedGroup.value,
    );
    if (session == null || session.sessionId == null ||
        group == null || group.id == null) {
      return;
    }

    _loadedClasses = await _sessionCtrl.getClassList(
      group.id!,
      session.sessionId!,
    );
    final names = _loadedClasses
        .map((c) => c.name ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    classes.assignAll(names);
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

  int _mapRecordsToIsFinished(String records) {
    switch (records) {
      case 'WITH RESULT':
        return 1;
      case 'WITHOUT RESULT':
        return -1;
      default:
        return 0;
    }
  }

  Future<void> fetchStudents() async {
    if (selectedGroup.value.isEmpty || selectedClass.value.isEmpty) {
      Get.snackbar(
        'Filter Required',
        'Please select both Group and Class',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final session = _sessionCtrl.sessionList.firstWhereOrNull(
        (e) => e.sessionName == selectedSession.value,
      );
      final group = _loadedGroups.firstWhereOrNull(
        (g) => g.name == selectedGroup.value,
      );
      final cls = _loadedClasses.firstWhereOrNull(
        (c) => c.name == selectedClass.value,
      );

      final payload = {
        "isActive": 0,
        "branchId": 0,
        "sessionId": session?.sessionId ?? 0,
        "groupId": group?.id ?? 0,
        "classId": cls?.id ?? 0,
        "top": 0,
        "promotionStatus": 0,
        "searchText": searchText.value,
        "isFinished": _mapRecordsToIsFinished(selectedRecords.value),
        "isActual": 0,
        "group_Name": selectedGroup.value,
        "className": selectedClass.value,
        "pageSize": "",
        "examTypeId": 0,
        "isSectionUpdate": true,
      };

      final response = await ApiService().postJson(
        Endpoints.getStudentListForPromotion(),
        payload,
      );

      List<dynamic> listData = [];
      if (response is Map<String, dynamic>) {
        listData = response['result'] ?? response['data'] ?? [];
      } else if (response is List) {
        listData = response;
      }

      final mapped = listData
          .map((e) => PromotionListResponse.fromJson(e))
          .toList()
          .asMap()
          .entries
          .map((entry) {
        final s = entry.value;
        final isUpdated = s.sectionUpdated == true;
        return SeasonUpdateStudent(
          id: s.id ?? 0,
          sid: s.sid ?? '',
          name: '${s.firstName ?? ''} ${s.lastName ?? ''}'.trim(),
          fatherName: s.fatherName ?? '',
          motherName: s.motherName ?? '',
          mobileNo: s.fatherMobile ?? '',
          group: s.groupName ?? selectedGroup.value,
          className: s.className ?? selectedClass.value,
          session: s.session ?? selectedSession.value,
          status: isUpdated ? 'Updated' : 'Not Updated',
          updatedClass: s.promotedClass ?? '',
          updateDate: s.dateOfPromotion ?? '',
        );
      }).toList();

      students.assignAll(mapped);
      selectAll.value = false;
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

  Future<void> _fetchToClasses(String groupName) async {
    toClasses.clear();
    _loadedToClasses = [];
    selectedToClass.value = '';

    final session = _sessionCtrl.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    final group = _loadedGroups.firstWhereOrNull((g) => g.name == groupName);
    if (session == null || session.sessionId == null || group == null || group.id == null) return;

    _loadedToClasses = await _sessionCtrl.getClassList(group.id!, session.sessionId!);
    toClasses.assignAll(
      _loadedToClasses.map((c) => c.name ?? '').where((n) => n.isNotEmpty),
    );
  }

  Future<void> _callSectionUpdateApi(List<SeasonUpdateStudent> selected) async {
    final fromGroup = _loadedGroups.firstWhereOrNull((g) => g.name == selectedGroup.value);
    final fromClass = _loadedClasses.firstWhereOrNull((c) => c.name == selectedClass.value);
    final toGroup = _loadedGroups.firstWhereOrNull((g) => g.name == selectedToGroup.value);
    final toClass = _loadedToClasses.firstWhereOrNull((c) => c.name == selectedToClass.value);

    final payload = {
      "groupId": toGroup?.id ?? 0,
      "branchId": 0,
      "classId": toClass?.id ?? 0,
      "fromClassId": fromClass?.id ?? 0,
      "fromGroupId": fromGroup?.id ?? 0,
      "studentIds": selected.map((s) => s.id.toString()).join(','),
    };

    isLoading.value = true;
    try {
      final response = await ApiService().postJson(Endpoints.studentSectionUpdate(), payload);

      if (response is Map &&
          (response['statusCode'] == 1 || response['status'] == 'success')) {
        Get.snackbar(
          'Success',
          response['responseText']?.toString() ??
              '${selected.length} student(s) section updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchStudents();
      } else {
        Get.snackbar(
          'Failed',
          response?['responseText']?.toString() ??
              response?['message']?.toString() ??
              'Could not update section for selected students.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Section update failed: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateSection() {
    final selected = students.where((s) => s.isSelected.value).toList();
    if (selected.isEmpty) {
      Get.snackbar('No Selection', 'Please select at least one student to update section.');
      return;
    }

    selectedToGroup.value = '';
    selectedToClass.value = '';
    toClasses.clear();
    _loadedToClasses = [];

    Get.bottomSheet(
      _SectionUpdateBottomSheet(controller: this, selected: selected),
      isScrollControlled: true,
    );
  }
}

class _SectionUpdateBottomSheet extends StatelessWidget {
  final SeasonUpdateController controller;
  final List<SeasonUpdateStudent> selected;

  const _SectionUpdateBottomSheet({
    required this.controller,
    required this.selected,
  });

  Widget _buildDropdown({
    required String value,
    required String hint,
    required List<String> items,
    required void Function(String)? onChanged,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value.isEmpty ? null : value,
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: onChanged == null ? null : (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Update Section for ${selected.length} Student(s)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          Text('Select Target Group', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Obx(() => _buildDropdown(
            value: controller.selectedToGroup.value,
            hint: 'Select Group',
            items: controller.groups,
            onChanged: (v) {
              controller.selectedToGroup.value = v;
              controller._fetchToClasses(v);
            },
          )),
          const SizedBox(height: 14),
          Text('Select Target Class', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Obx(() => _buildDropdown(
            value: controller.selectedToClass.value,
            hint: controller.selectedToGroup.value.isEmpty ? 'Select a group first' : 'Select Class',
            items: controller.toClasses,
            onChanged: controller.toClasses.isEmpty
                ? null
                : (v) => controller.selectedToClass.value = v,
          )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (controller.selectedToGroup.value.isEmpty ||
                    controller.selectedToClass.value.isEmpty) {
                  Get.snackbar('Required', 'Please select target group and class');
                  return;
                }
                Get.back();
                await controller._callSectionUpdateApi(selected);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Confirm Update'),
            ),
          ),
        ],
      ),
    );
  }
}
