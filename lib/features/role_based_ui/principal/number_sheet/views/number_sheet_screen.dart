import 'package:erp_management/core/constants/app_colors.dart';
import 'package:erp_management/features/role_based_ui/principal/number_sheet/controllers/number_sheet_controller.dart';
import 'package:erp_management/features/role_based_ui/principal/number_sheet/models/number_sheet_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NumberSheetScreen extends StatelessWidget {
  const NumberSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(NumberSheetController());
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: scheme.surfaceContainerLowest,
        appBar: AppBar(
          title: const Text('Number Sheet'),
          centerTitle: false,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Get.back(),
          ),
          actions: [
            Obx(() => TextButton.icon(
                  icon: Icon(
                    c.isShowFilter.value
                        ? Icons.filter_alt
                        : Icons.filter_alt_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text('Filter',
                      style: TextStyle(color: Colors.white)),
                  onPressed: c.toggleFilter,
                )),
            Obx(() => c.isSaving.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))),
                  )
                : TextButton.icon(
                    icon: const Icon(Icons.save_rounded,
                        color: Colors.white, size: 20),
                    label: const Text('Save',
                        style: TextStyle(color: Colors.white)),
                    onPressed: c.saveMarks,
                  )),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          children: [
            _FilterBar(c: c, scheme: scheme),
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary));
                }
                if (c.students.isEmpty) {
                  return _EmptyState(
                    icon: Icons.assignment_outlined,
                    message: 'No students loaded',
                    sub: 'Apply filters, fetch MM, then tap Search',
                  );
                }
                return _StudentTable(c: c, scheme: scheme);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Bar ─────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final NumberSheetController c;
  final ColorScheme scheme;
  const _FilterBar({required this.c, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: c.isShowFilter.value
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Container(
            color: scheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session
                _DropdownField(
                  label: 'Session',
                  value: c.selectedSession,
                  items: c.sessionYearList,
                ),
                const SizedBox(height: 10),
                // Group + Class
                Row(children: [
                  Expanded(
                    child: _DropdownField(
                        label: 'Group',
                        value: c.selectedGroup,
                        items: c.groupList),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DropdownField(
                        label: 'Class',
                        value: c.selectedClass,
                        items: c.classList),
                  ),
                ]),
                const SizedBox(height: 10),
                // Exam Type + Subject
                Row(children: [
                  Expanded(
                    child: _DropdownField(
                        label: 'Exam Type',
                        value: c.selectedExamType,
                        items: c.examTypeList),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DropdownField(
                        label: 'Subject',
                        value: c.selectedSubject,
                        items: c.subjectList),
                  ),
                ]),
                const SizedBox(height: 12),
                // MM row
                Row(children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: Obx(() => TextField(
                            controller: c.mmCtrl,
                            readOnly: true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Maximum Marks (MM)',
                              hintStyle:
                                  TextStyle(color: Colors.grey.shade500, fontSize: 13),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300)),
                              suffixText: c.mmValue.value > 0
                                  ? 'MM: ${c.mmValue.value}'
                                  : null,
                              suffixStyle: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Obx(() => _ActionButton(
                        label: 'Find MM',
                        color: Colors.indigo,
                        isLoading: c.isFetchingMM.value,
                        onTap: c.fetchMM,
                      )),
                  const SizedBox(width: 8),
                  _ActionButton(
                    label: 'Search',
                    color: AppColors.primary,
                    onTap: c.searchStudents,
                  ),
                ]),
                // Locked badge
                Obx(() => c.isExamLocked.value
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(children: [
                          Icon(Icons.lock_rounded,
                              size: 14, color: Colors.red.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'This exam is locked — marks are read-only',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.w500),
                          ),
                        ]),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          secondChild: _SummaryChips(c: c, scheme: scheme),
        ));
  }
}

// ── Collapsed filter summary chips ─────────────────────────────────────────
class _SummaryChips extends StatelessWidget {
  final NumberSheetController c;
  final ColorScheme scheme;
  const _SummaryChips({required this.c, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final exam = c.selectedExamType.value;
      final subject = c.selectedSubject.value;
      final mm = c.mmValue.value;

      if (exam.isEmpty && subject.isEmpty && mm <= 0) {
        return const SizedBox.shrink();
      }

      return Container(
        color: scheme.surface,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            if (exam.isNotEmpty) _chip(exam),
            if (subject.isNotEmpty) _chip(subject),
            if (mm > 0) _chip('M.M.-$mm'),
          ],
        ),
      );
    });
  }

  Widget _chip(String text) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text.toUpperCase(),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ── Dropdown field ─────────────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String label;
  final RxString value;
  final RxList<String> items;
  const _DropdownField(
      {required this.label, required this.value, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Obx(() => Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: items.contains(value.value) ? value.value : null,
                  hint: Text('Select $label',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                  items: items
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) value.value = v;
                  },
                ),
              ),
            )),
      ],
    );
  }
}

// ── Action button ──────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;
  const _ActionButton(
      {required this.label,
      required this.color,
      required this.onTap,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        onPressed: isLoading ? null : onTap,
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Student table ──────────────────────────────────────────────────────────
class _StudentTable extends StatelessWidget {
  final NumberSheetController c;
  final ColorScheme scheme;
  const _StudentTable({required this.c, required this.scheme});

  // Fixed column widths; Student Name takes the remaining space so the table
  // fits the screen and never needs horizontal page scrolling.
  static const double _wSno = 44;
  static const double _wRoll = 82;
  static const double _wMarks = 100;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final students = c.students;
      return Column(
        children: [
          // Summary bar
          Container(
            color: AppColors.primary.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              Icon(Icons.people_outline_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('${students.length} students',
                  style: textTheme.bodySmall?.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (c.mmValue.value > 0) ...[
                Icon(Icons.score_rounded, size: 16, color: Colors.green.shade700),
                const SizedBox(width: 4),
                Text('MM: ${c.mmValue.value}',
                    style: textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600)),
              ],
            ]),
          ),
          // Fixed header — stays in place while only the rows below scroll.
          _buildHeader(),
          // Scrollable rows only (the page itself does not scroll).
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final isReadOnly =
                    c.isExamLocked.value || !student.isSubjectAssigned;
                return _buildRow(textTheme, student, index, isReadOnly);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHeader() {
    const style = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
    return Container(
      color: AppColors.primary,
      child: Row(
        children: [
          _cell(width: _wSno, align: Alignment.center,
              child: const Text('S.No', style: style, textAlign: TextAlign.center)),
          _cell(width: _wRoll,
              child: const Text('Roll No', style: style)),
          _cell(expanded: true,
              child: const Text('Student Name', style: style)),
          _cell(width: _wMarks, align: Alignment.center,
              child: Text('M.M.-${c.mmValue.value}',
                  style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildRow(
      TextTheme textTheme, NumberSheetStudent student, int index, bool isReadOnly) {
    return Container(
      decoration: BoxDecoration(
        color: index.isOdd
            ? AppColors.primary.withValues(alpha: 0.04)
            : scheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _cell(width: _wSno, align: Alignment.center,
              child: Text('${index + 1}',
                  style: textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w500))),
          _cell(width: _wRoll,
              child: Text(student.rollNumber.isEmpty ? '-' : student.rollNumber,
                  style: textTheme.bodySmall)),
          _cell(expanded: true,
              child: Row(children: [
                if (!student.isSubjectAssigned) ...[
                  Tooltip(
                    message: 'Subject not assigned',
                    child: Icon(Icons.info_outline_rounded,
                        size: 15, color: Colors.orange.shade600),
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(student.name,
                      style: textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis),
                ),
              ])),
          _cell(width: _wMarks, align: Alignment.center,
              child: _MarksField(
                student: student,
                index: index,
                isReadOnly: isReadOnly,
                controller: c,
              )),
        ],
      ),
    );
  }

  Widget _cell({
    required Widget child,
    double? width,
    bool expanded = false,
    Alignment align = Alignment.centerLeft,
  }) {
    final content = Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      alignment: align,
      child: child,
    );
    if (expanded) return Expanded(child: content);
    return SizedBox(width: width, child: content);
  }
}

// ── Marks input field ──────────────────────────────────────────────────────
class _MarksField extends StatefulWidget {
  final NumberSheetStudent student;
  final int index;
  final bool isReadOnly;
  final NumberSheetController controller;

  const _MarksField({
    required this.student,
    required this.index,
    required this.isReadOnly,
    required this.controller,
  });

  @override
  State<_MarksField> createState() => _MarksFieldState();
}

class _MarksFieldState extends State<_MarksField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.student.marks != null ? '${widget.student.marks}' : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 80,
      child: TextFormField(
        controller: _ctrl,
        readOnly: widget.isReadOnly,
        maxLength: 3,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: widget.isReadOnly ? Colors.grey : scheme.onSurface),
        decoration: InputDecoration(
          counterText: '',
          hintText: widget.isReadOnly ? '-' : 'Marks',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          filled: widget.isReadOnly,
          fillColor: widget.isReadOnly ? Colors.grey.shade100 : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
        onChanged: (v) => widget.controller
            .onMarkChanged(widget.student.id, v, widget.index),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String sub;
  const _EmptyState(
      {required this.icon, required this.message, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(sub,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade400),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
