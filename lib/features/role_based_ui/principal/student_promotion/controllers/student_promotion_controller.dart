import 'dart:developer';

import 'package:erp_management/core/constants/app_colors.dart';
import 'package:erp_management/core/controllers/session_controller.dart';
import 'package:erp_management/core/models/category_model.dart';
import 'package:erp_management/core/services/api/api_service.dart';
import 'package:erp_management/core/services/api/endpoints.dart';
import 'package:erp_management/features/role_based_ui/principal/student_promotion/models/promotion_list_response.dart';
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
  final int id;
  final PromotionListResponse rawData;

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
    required this.id,
    required this.rawData,
    bool isSelected = false,
  }) : status = status.obs,
       promotedToClass = promotedToClass.obs,
       promotionDate = promotionDate.obs,
       isSelected = isSelected.obs;
}

class StudentPromotionController extends GetxController {
  final RxString viewMode = 'table'.obs;
  final RxDouble baseFontSize = 12.0.obs;

  // Filters
  final RxString selectedSession = ''.obs;
  final RxString selectedGroup = ''.obs;
  final RxString selectedClass = ''.obs;
  final RxString selectedStatus = 'All'.obs;
  final RxString searchText = ''.obs;

  final RxList<String> sessionYearList = <String>[].obs;
  final RxList<String> groupList = <String>[].obs;
  final RxList<String> classList = <String>[].obs;
  final List<String> statuses = ['All', 'Promoted', 'Not Promoted'];

  final RxList<StudentPromotionItem> allFetchedStudents =
      <StudentPromotionItem>[].obs;
  final RxList<StudentPromotionItem> students = <StudentPromotionItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool selectAll = false.obs;

  final SessionController sessionController = Get.put(SessionController());
  List<CategoryModel> _loadedGroups = [];
  List<CategoryModel> _loadedClasses = [];

  // ── "Promote To" dialog state (separate from the search filters above) ────
  final RxString selectedToSession = ''.obs;
  final RxString selectedToGroup = ''.obs;
  final RxString selectedToClass = ''.obs;
  final RxList<String> toGroupList = <String>[].obs;
  final RxList<String> toClassList = <String>[].obs;
  List<CategoryModel> _loadedToGroups = [];
  List<CategoryModel> _loadedToClasses = [];

  @override
  void onInit() {
    super.onInit();
    _loadSessions();
    ever(selectedSession, (_) => _fetchGroups());
    ever(selectedGroup, (_) => _fetchClasses());
    ever(selectedStatus, (_) => filterStudents());
    ever(selectedToGroup, (_) => _fetchToClasses());
  }

  void filterStudents() {
    if (selectedStatus.value == 'All') {
      students.assignAll(allFetchedStudents);
    } else {
      students.assignAll(
        allFetchedStudents.where((s) => s.status.value == selectedStatus.value),
      );
    }
  }

  void _loadSessions() {
    ever(sessionController.sessionList, (sessions) {
      log(
        '[Promotion] sessionList changed: count=${sessions.length} '
        'raw=${sessions.map((e) => '${e.sessionName}(active=${e.isActive})').toList()}',
      );
      final names = sessions
          .map((e) => e.sessionName ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      sessionYearList.assignAll(names);
      log('[Promotion] sessionYearList = $names');
      if (selectedSession.value.isNotEmpty &&
          !names.contains(selectedSession.value)) {
        selectedSession.value = '';
      }
    });

    if (sessionController.sessionList.isNotEmpty) {
      log(
        '[Promotion] sessionList already loaded: count=${sessionController.sessionList.length} '
        'raw=${sessionController.sessionList.map((e) => '${e.sessionName}(active=${e.isActive})').toList()}',
      );
      final names = sessionController.sessionList
          .map((e) => e.sessionName ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      sessionYearList.assignAll(names);
      log('[Promotion] sessionYearList = $names');
      if (selectedSession.value.isNotEmpty &&
          !names.contains(selectedSession.value)) {
        selectedSession.value = '';
      }
    }
  }

  Future<void> _fetchGroups() async {
    final session = sessionController.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedSession.value,
    );
    log(
      '[Promotion] _fetchGroups: selectedSession="${selectedSession.value}" '
      'matchedSessionId=${session?.sessionId}',
    );
    if (session == null || session.sessionId == null) return;

    _loadedGroups = await sessionController.getGroupList(session.sessionId!);
    groupList.assignAll(
      _loadedGroups
          .map((g) => g.name ?? '')
          .where((n) => n.isNotEmpty)
          .toList(),
    );
    log(
      '[Promotion] groupList = ${groupList.toList()} '
      '(loaded ${_loadedGroups.length} groups)',
    );

    if (selectedGroup.value.isNotEmpty &&
        !groupList.contains(selectedGroup.value)) {
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
    log(
      '[Promotion] classList = ${classList.toList()} '
      '(loaded ${_loadedClasses.length} classes for group=${group.name})',
    );

    if (selectedClass.value.isNotEmpty &&
        !classList.contains(selectedClass.value)) {
      selectedClass.value = '';
    } else if (classList.isEmpty) {
      selectedClass.value = '';
    }
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
      final session = sessionController.sessionList.firstWhereOrNull(
        (e) => e.sessionName == selectedSession.value,
      );
      final group = _loadedGroups.firstWhereOrNull(
        (g) => g.name == selectedGroup.value,
      );
      final cls = _loadedClasses.firstWhereOrNull(
        (c) => c.name == selectedClass.value,
      );

      final sessionId = session?.sessionId ?? 0;
      final groupId = group?.id ?? 0;
      final classId = cls?.id ?? 0;

      final payload = {
        "isActive": -1,
        "branchId": 0,
        "sessionId": sessionId,
        "groupId": groupId,
        "classId": classId,
        "top": 0,
        "promotionStatus": selectedStatus.value == 'All'
            ? -1
            : selectedStatus.value == 'Promoted'
            ? 1
            : 0, // promoted = 1 // nonpromoted = 0 / all = -1
        "searchText": searchText.value,
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

      final fetchedList = listData
          .map((e) => PromotionListResponse.fromJson(e))
          .toList();

      final mappedStudents = fetchedList.asMap().entries.map((entry) {
        final index = entry.key;
        final s = entry.value;
        final isPromoted = s.isPromoted == true;

        return StudentPromotionItem(
          sNo: index + 1,
          id: s.id ?? 0,
          sid: s.sid ?? '',
          group: s.groupName ?? selectedGroup.value,
          currentClass: s.className ?? selectedClass.value,
          currentSession: s.session ?? selectedSession.value,
          status: isPromoted ? 'Promoted' : 'Not Promoted',
          promotedToClass: s.promotedClass ?? '',
          promotionDate: s.dateOfPromotion ?? '',
          name: '${s.firstName ?? ''} ${s.lastName ?? ''}'.trim(),
          fatherName: s.fatherName ?? '',
          motherName: s.motherName ?? '',
          mobileNo: s.fatherMobile ?? '',
          rawData: s,
        );
      }).toList();

      allFetchedStudents.assignAll(mappedStudents);
      filterStudents();
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

  /// Bound to the "Promote Student" button — validates a selection exists,
  /// then opens the top sheet where the destination Session/Group/Class are
  /// chosen.
  void promoteSelected() {
    final selected = students.where((s) => s.isSelected.value).toList();
    if (selected.isEmpty) {
      Get.snackbar(
        'Selection Required',
        'Please select students to promote',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    _openPromoteToSheet();
  }

  void _openPromoteToSheet() {
    // Destination session is fixed to the current/active session.
    final active = sessionController.sessionList.firstWhereOrNull(
      (e) => e.isActive == true,
    );
    selectedToSession.value = active?.sessionName ?? '';
    selectedToGroup.value = '';
    selectedToClass.value = '';
    toGroupList.clear();
    toClassList.clear();
    _loadedToGroups = [];
    _loadedToClasses = [];

    if (active?.sessionId != null) {
      _fetchToGroups(active!.sessionId!);
    }

    Get.generalDialog(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const _PromoteToSheet(),
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }

  Future<void> _fetchToGroups(int sessionId) async {
    _loadedToGroups = await sessionController.getGroupList(sessionId);
    toGroupList.assignAll(
      _loadedToGroups.map((g) => g.name ?? '').where((n) => n.isNotEmpty),
    );
    log('[Promotion] toGroupList = ${toGroupList.toList()}');
  }

  Future<void> _fetchToClasses() async {
    final session = sessionController.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedToSession.value,
    );
    final group = _loadedToGroups.firstWhereOrNull(
      (g) => g.name == selectedToGroup.value,
    );
    toClassList.clear();
    selectedToClass.value = '';
    if (session?.sessionId == null || group?.id == null) return;

    _loadedToClasses = await sessionController.getClassList(
      group!.id!,
      session!.sessionId!,
    );
    toClassList.assignAll(
      _loadedToClasses.map((c) => c.name ?? '').where((n) => n.isNotEmpty),
    );
    log('[Promotion] toClassList = ${toClassList.toList()}');
  }

  /// Bound to the sheet's "Promote" button — calls the promote-student API
  /// using the chosen destination Session/Group/Class.
  Future<void> confirmPromote() async {
    if (selectedToGroup.value.isEmpty || selectedToClass.value.isEmpty) {
      Get.snackbar(
        'Selection Required',
        'Please select Group and Class',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final selected = students.where((s) => s.isSelected.value).toList();
    if (selected.isEmpty) {
      Get.back();
      return;
    }

    final session = sessionController.sessionList.firstWhereOrNull(
      (e) => e.sessionName == selectedToSession.value,
    );
    final group = _loadedToGroups.firstWhereOrNull(
      (g) => g.name == selectedToGroup.value,
    );
    final cls = _loadedToClasses.firstWhereOrNull(
      (c) => c.name == selectedToClass.value,
    );

    final sessionId = session?.sessionId ?? 0;
    final groupId = group?.id ?? 0;
    final classId = cls?.id ?? 0;
    final studentIds = selected.map((s) => s.id.toString()).join(',');

    isLoading.value = true;
    try {
      final payload = {
        "branchId": 0,
        "sessionId": sessionId,
        "groupId": groupId,
        "classId": classId,
        "studentIds": studentIds,
      };

      final response = await ApiService().postJson(
        Endpoints.promoteStudent(),
        payload,
      );

      if (response is Map &&
          (response['statusCode'] == 1 || response['status'] == 'success')) {
        Get.back(); // close the sheet
        Get.snackbar(
          'Success',
          response['responseText']?.toString() ??
              '${selected.length} student(s) promoted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchStudents();
      } else {
        Get.snackbar(
          'Failed',
          response?['responseText']?.toString() ??
              response?['message']?.toString() ??
              'Could not promote selected students.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Promotion failed: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void undoPromotion(StudentPromotionItem student) {
    student.status.value = 'Not Promoted';
    student.promotedToClass.value = '';
    Get.snackbar('Action', 'Promotion undone for ${student.name}', backgroundColor: AppColors.background);
  }

  void showProfileDetails(StudentPromotionItem student) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Student Profile: ${student.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              _buildDetailRow(
                'Roll Number',
                student.rawData.rollNumber ?? 'N/A',
              ),
              _buildDetailRow('SID', student.rawData.sid ?? 'N/A'),
              _buildDetailRow(
                'Admission No',
                student.rawData.admissionNo ?? 'N/A',
              ),
              _buildDetailRow('Gender', student.rawData.gender ?? 'N/A'),
              _buildDetailRow('DOB', student.rawData.dob ?? 'N/A'),
              _buildDetailRow('Religion', student.rawData.religion ?? 'N/A'),
              _buildDetailRow('Category', student.rawData.category ?? 'N/A'),
              const Divider(),
              const Text(
                'Contact Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Father Name',
                student.rawData.fatherName ?? 'N/A',
              ),
              _buildDetailRow(
                'Father Mobile',
                student.rawData.fatherMobile ?? 'N/A',
              ),
              _buildDetailRow(
                'Mother Name',
                student.rawData.motherName ?? 'N/A',
              ),
              _buildDetailRow(
                'Mother Mobile',
                student.rawData.motherMobile ?? 'N/A',
              ),
              _buildDetailRow('Address', student.rawData.address ?? 'N/A'),
              _buildDetailRow('District', student.rawData.district ?? 'N/A'),
              const Divider(),
              const Text(
                'Academic Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Current Session',
                student.rawData.session ?? 'N/A',
              ),
              _buildDetailRow(
                'Current Group',
                student.rawData.groupName ?? 'N/A',
              ),
              _buildDetailRow(
                'Current Class',
                student.rawData.className ?? 'N/A',
              ),
              _buildDetailRow('Status', student.status.value),
              if (student.status.value == 'Promoted') ...[
                _buildDetailRow(
                  'Promoted Class',
                  student.rawData.promotedClass ?? 'N/A',
                ),
                _buildDetailRow(
                  'Promotion Date',
                  student.rawData.dateOfPromotion ?? 'N/A',
                ),
              ],
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

/// The "Promote To" top sheet — lets the principal pick the destination
/// Group and Class (Session is fixed to the current session) before
/// confirming the promotion.
class _PromoteToSheet extends StatelessWidget {
  const _PromoteToSheet();

  Widget _buildDropdown({
    required ColorScheme scheme,
    required String value,
    required String hint,
    required List<String> items,
    required void Function(String)? onChanged,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value.isEmpty ? null : value,
          hint: Text(
            hint,
            style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(fontSize: 14, color: scheme.onSurface),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged == null
              ? null
              : (v) {
                  if (v != null) onChanged(v);
                },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentPromotionController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mq = MediaQuery.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: mq.padding.top + 16, left: 16, right: 16),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Promote Student',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Session',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => Container(
                      height: 50,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        border: Border.all(color: scheme.outlineVariant),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.selectedToSession.value.isEmpty
                            ? '—'
                            : controller.selectedToSession.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Group *',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => _buildDropdown(
                      scheme: scheme,
                      value: controller.selectedToGroup.value,
                      hint: 'Select Group',
                      items: controller.toGroupList,
                      onChanged: (v) => controller.selectedToGroup.value = v,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Class *',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => _buildDropdown(
                      scheme: scheme,
                      value: controller.selectedToClass.value,
                      hint: controller.selectedToGroup.value.isEmpty
                          ? 'Select a group first'
                          : 'Select Class',
                      items: controller.toClassList,
                      onChanged: controller.toClassList.isEmpty
                          ? null
                          : (v) => controller.selectedToClass.value = v,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: scheme.error,
                            side: BorderSide(
                              color: scheme.error.withValues(alpha: 0.4),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.confirmPromote,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: scheme.onPrimary,
                                    ),
                                  )
                                : const Text('Promote'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
