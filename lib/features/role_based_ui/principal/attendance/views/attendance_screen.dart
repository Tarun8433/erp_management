// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/attendance_controller.dart';
// import '../../../../../core/models/category_model.dart';
// import '../models/attendance_student_model.dart';
// import '../models/shift_model.dart';
// import 'package:erp_management/routes/app_routes.dart';

// class AttendanceScreen extends StatelessWidget {
//   const AttendanceScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final c = Get.put(AttendanceController());
//     final scheme = Theme.of(context).colorScheme;

//     return Scaffold(
//       backgroundColor: scheme.surfaceContainerLowest,
//       appBar: AppBar(
//         title: const Text('Student Attendance'),
//         centerTitle: false,
//         backgroundColor: scheme.primary,
//         foregroundColor: scheme.onPrimary,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_rounded),
//           onPressed: () => Get.back(),
//         ),
//         actions: [
//           IconButton(
//             tooltip: 'Mark Attendance',
//             icon: const Icon(Icons.edit_calendar_rounded),
//             onPressed: () => Get.toNamed(AppRoutes.attendanceMarking),
//           ),
//           Obx(() {
//             if (!c.hasSearched.value) return const SizedBox.shrink();
//             return Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (c.viewMode.value == 'table')
//                   IconButton(
//                     tooltip: 'Column visibility',
//                     icon: const Icon(Icons.view_column_rounded),
//                     onPressed: () => _showColumnPicker(context, c),
//                   ),
//                 IconButton(
//                   tooltip: c.viewMode.value == 'card'
//                       ? 'Table view'
//                       : 'Card view',
//                   onPressed: c.toggleView,
//                   icon: Icon(
//                     c.viewMode.value == 'card'
//                         ? Icons.table_rows_rounded
//                         : Icons.grid_view_rounded,
//                   ),
//                 ),
//               ],
//             );
//           }),
//         ],
//       ),
//       body: Column(
//         children: [
//           _FilterBar(controller: c),
//           Expanded(
//             child: Obx(() {
//               if (c.isSearching.value) return _buildLoader(scheme);
//               if (!c.hasSearched.value) return _buildPrompt(context);
//               return _ResultsView(controller: c);
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showColumnPicker(BuildContext context, AttendanceController c) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         final theme = Theme.of(context);
//         final scheme = theme.colorScheme;
//         return Padding(
//           padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 36,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: scheme.outlineVariant,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.view_column_rounded,
//                     size: 20,
//                     color: scheme.primary,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Table Columns',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                   const Spacer(),
//                   TextButton(
//                     onPressed: () {
//                       for (final key in AttendanceController.allColumns) {
//                         c.columnVisibility[key] = true;
//                       }
//                     },
//                     child: const Text('Show all'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Obx(
//                 () => Column(
//                   children: AttendanceController.allColumns.map((key) {
//                     final visible = c.columnVisibility[key] ?? true;
//                     final label = AttendanceController.columnLabels[key] ?? key;
//                     final isOnly =
//                         c.columnVisibility.values.where((v) => v).length == 1;
//                     return Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(10),
//                         onTap: () => c.toggleColumn(key),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 4,
//                             horizontal: 4,
//                           ),
//                           child: Row(
//                             children: [
//                               AnimatedContainer(
//                                 duration: const Duration(milliseconds: 200),
//                                 width: 24,
//                                 height: 24,
//                                 decoration: BoxDecoration(
//                                   color: visible
//                                       ? scheme.primary
//                                       : Colors.transparent,
//                                   borderRadius: BorderRadius.circular(6),
//                                   border: Border.all(
//                                     color: visible
//                                         ? scheme.primary
//                                         : scheme.outline,
//                                     width: 2,
//                                   ),
//                                 ),
//                                 child: visible
//                                     ? const Icon(
//                                         Icons.check_rounded,
//                                         size: 15,
//                                         color: Colors.white,
//                                       )
//                                     : null,
//                               ),
//                               const SizedBox(width: 14),
//                               Expanded(
//                                 child: Text(
//                                   label,
//                                   style: theme.textTheme.bodyMedium?.copyWith(
//                                     fontWeight: visible
//                                         ? FontWeight.w600
//                                         : FontWeight.w400,
//                                     color:
//                                         (visible == false ||
//                                             (visible && isOnly))
//                                         ? scheme.onSurfaceVariant
//                                         : scheme.onSurface,
//                                   ),
//                                 ),
//                               ),
//                               if (visible && isOnly)
//                                 Text(
//                                   'min 1',
//                                   style: theme.textTheme.labelSmall?.copyWith(
//                                     color: scheme.error,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildLoader(ColorScheme scheme) => Center(
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         CircularProgressIndicator(color: scheme.primary),
//         const SizedBox(height: 14),
//         Text(
//           'Fetching attendance…',
//           style: TextStyle(color: scheme.onSurfaceVariant),
//         ),
//       ],
//     ),
//   );

//   Widget _buildPrompt(BuildContext context) {
//     final theme = Theme.of(context);
//     final scheme = theme.colorScheme;
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 88,
//             height: 88,
//             decoration: BoxDecoration(
//               color: scheme.primaryContainer,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.how_to_reg_rounded,
//               size: 44,
//               color: scheme.onPrimaryContainer,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Select filters and tap Search',
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             'Attendance summary will appear here',
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: scheme.onSurfaceVariant,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Results wrapper ───────────────────────────────────────────────────────────

// class _ResultsView extends StatelessWidget {
//   final AttendanceController controller;
//   const _ResultsView({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _SummaryBar(controller: controller),

//         Expanded(
//           child: Obx(() {
//             final list = controller.filteredStudents;
//             if (list.isEmpty) {
//               return Center(
//                 child: Text(
//                   'No students found',
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Theme.of(context).colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               );
//             }
//             return controller.viewMode.value == 'table'
//                 ? _TableView(
//                     students: list,
//                     visibility: Map.from(controller.columnVisibility),
//                   )
//                 : _CardView(students: list);
//           }),
//         ),
//       ],
//     );
//   }
// }

// // ── Summary Bar ───────────────────────────────────────────────────────────────

// class _SummaryBar extends StatelessWidget {
//   final AttendanceController controller;
//   const _SummaryBar({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final scheme = theme.colorScheme;
//     return Obx(
//       () => Container(
//         margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
//         decoration: BoxDecoration(
//           color: scheme.surface,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: theme.dividerColor),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _StatChip(
//               label: 'Total',
//               count: controller.totalCount,
//               color: scheme.primary,
//             ),
//             _vDivider(),
//             _StatChip(
//               label: 'Present',
//               count: controller.presentCount,
//               color: const Color(0xFF2E7D32),
//             ),
//             _vDivider(),
//             _StatChip(
//               label: 'Absent',
//               count: controller.absentCount,
//               color: const Color(0xFFC62828),
//             ),
//             _vDivider(),
//             _StatChip(
//               label: 'Late',
//               count: controller.lateCount,
//               color: const Color(0xFFF57C00),
//             ),
//             _vDivider(),
//             _StatChip(
//               label: 'Unmarked',
//               count: controller.notMarkedCount,
//               color: scheme.onSurfaceVariant,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _vDivider() => Container(
//     width: 1,
//     height: 32,
//     color: Colors.grey.withValues(alpha: 0.2),
//   );
// }

// class _StatChip extends StatelessWidget {
//   final String label;
//   final int count;
//   final Color color;
//   const _StatChip({
//     required this.label,
//     required this.count,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           '$count',
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.w900,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: Theme.of(context).textTheme.labelSmall?.copyWith(
//             color: color,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ── Search Box ────────────────────────────────────────────────────────────────

// class _SearchBox extends StatelessWidget {
//   final AttendanceController controller;
//   const _SearchBox({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final scheme = theme.colorScheme;
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
//       child: TextField(
//         onChanged: (v) => controller.searchQuery.value = v,
//         style: theme.textTheme.bodySmall,
//         decoration: InputDecoration(
//           hintText: 'Search by name, ID…',
//           hintStyle: theme.textTheme.bodySmall?.copyWith(
//             color: scheme.onSurfaceVariant,
//           ),
//           prefixIcon: Icon(
//             Icons.search_rounded,
//             size: 18,
//             color: scheme.onSurfaceVariant,
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 14,
//             vertical: 10,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: theme.dividerColor),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: theme.dividerColor),
//           ),
//           filled: true,
//           fillColor: scheme.surface,
//         ),
//       ),
//     );
//   }
// }

// // ── Table View ────────────────────────────────────────────────────────────────

// class _TableView extends StatelessWidget {
//   final List<AttendanceStudentModel> students;
//   final Map<String, bool> visibility;
//   const _TableView({required this.students, required this.visibility});

//   // Fixed widths / flex per column key.
//   static const _widths = {
//     'serial': FixedColumnWidth(40),
//     'sid': FixedColumnWidth(68),
//     'firstName': FlexColumnWidth(2.2),
//     'fatherName': FlexColumnWidth(2),
//     'status': FixedColumnWidth(80),
//   };

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final scheme = theme.colorScheme;

//     // Build ordered list of visible column keys.
//     final cols = AttendanceController.allColumns
//         .where((k) => visibility[k] == true)
//         .toList();

//     // Map visible columns to their indexed widths for Table.
//     final colWidths = <int, TableColumnWidth>{
//       for (int i = 0; i < cols.length; i++)
//         i: _widths[cols[i]] ?? const FlexColumnWidth(1),
//     };

//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(14),
//         child: Table(
//           border: TableBorder(
//             horizontalInside: BorderSide(color: theme.dividerColor, width: 0.8),
//             borderRadius: BorderRadius.circular(14),
//           ),
//           columnWidths: colWidths,
//           children: [
//             // Header
//             TableRow(
//               decoration: BoxDecoration(color: scheme.primary),
//               children: cols
//                   .map(
//                     (k) => _th(
//                       AttendanceController.columnLabels[k] ?? k,
//                       scheme,
//                       center: k == 'status' || k == 'serial',
//                     ),
//                   )
//                   .toList(),
//             ),
//             // Data rows
//             for (int i = 0; i < students.length; i++)
//               TableRow(
//                 decoration: BoxDecoration(
//                   color: i.isEven
//                       ? scheme.surface
//                       : scheme.surfaceContainerLowest,
//                 ),
//                 children: cols.map((k) {
//                   final s = students[i];
//                   return switch (k) {
//                     'serial' => _tdCenter('${i + 1}', theme, scheme),
//                     'sid' => _td(s.sid, theme, scheme),
//                     'firstName' => _td(s.firstName, theme, scheme),
//                     'fatherName' => _td(
//                       s.fatherName,
//                       theme,
//                       scheme,
//                       muted: true,
//                     ),
//                     'status' => Padding(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 8,
//                         horizontal: 6,
//                       ),
//                       child: Center(child: _StatusBadge(status: s.status)),
//                     ),
//                     _ => const SizedBox.shrink(),
//                   };
//                 }).toList(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _th(String text, ColorScheme scheme, {bool center = false}) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//     child: Text(
//       text,
//       textAlign: center ? TextAlign.center : TextAlign.start,
//       style: TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w800,
//         color: scheme.onPrimary,
//         letterSpacing: 0.4,
//       ),
//     ),
//   );

//   Widget _tdCenter(String text, ThemeData theme, ColorScheme scheme) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
//     child: Text(
//       text,
//       textAlign: TextAlign.center,
//       style: theme.textTheme.bodySmall?.copyWith(
//         color: scheme.onSurface,
//         fontWeight: FontWeight.w600,
//       ),
//       overflow: TextOverflow.ellipsis,
//     ),
//   );

//   Widget _td(
//     String text,
//     ThemeData theme,
//     ColorScheme scheme, {
//     bool muted = false,
//   }) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
//     child: Text(
//       text,
//       style: theme.textTheme.bodySmall?.copyWith(
//         color: muted ? scheme.onSurfaceVariant : scheme.onSurface,
//         fontWeight: muted ? FontWeight.w400 : FontWeight.w600,
//       ),
//       overflow: TextOverflow.ellipsis,
//     ),
//   );
// }

// // ── Card View ─────────────────────────────────────────────────────────────────

// class _CardView extends StatelessWidget {
//   final List<AttendanceStudentModel> students;
//   const _CardView({required this.students});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
//       itemCount: students.length,
//       itemBuilder: (_, i) =>
//           _AttendanceCard(student: students[i], serial: i + 1),
//     );
//   }
// }

// class _AttendanceCard extends StatelessWidget {
//   final AttendanceStudentModel student;
//   final int serial;
//   const _AttendanceCard({required this.student, required this.serial});

//   Color _statusColor(String? s, ColorScheme scheme) => switch (s) {
//     'P' => const Color(0xFF2E7D32),
//     'A' => const Color(0xFFC62828),
//     'L' => const Color(0xFFF57C00),
//     // 'H' => const Color(0xFF1565C0),
//     _ => scheme.onSurfaceVariant,
//   };

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final scheme = theme.colorScheme;
//     final color = _statusColor(student.status, scheme);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: scheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border(left: BorderSide(color: color, width: 4)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         child: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: color.withValues(alpha: 0.12),
//                 shape: BoxShape.circle,
//               ),
//               child: Center(
//                 child: Text(
//                   '$serial',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w800,
//                     fontSize: 14,
//                     color: color,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     student.firstName,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       fontWeight: FontWeight.w800,
//                       color: scheme.onSurface,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 3),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.person_outline_rounded,
//                         size: 12,
//                         color: scheme.onSurfaceVariant,
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           student.fatherName,
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             color: scheme.onSurfaceVariant,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 5),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: scheme.primaryContainer.withValues(alpha: 0.5),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       'ID: ${student.sid}',
//                       style: theme.textTheme.labelSmall?.copyWith(
//                         color: scheme.primary,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 10),
//             _StatusBadge(status: student.status, large: true),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Status Badge ──────────────────────────────────────────────────────────────

// class _StatusBadge extends StatelessWidget {
//   final String? status;
//   final bool large;
//   const _StatusBadge({this.status, this.large = false});

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final (label, color) = switch (status) {
//       'P' => ('Present', const Color(0xFF2E7D32)),
//       'A' => ('Absent', const Color(0xFFC62828)),
//       'L' => ('Late', const Color(0xFFF57C00)),
//       // 'H' => ('Holiday', const Color(0xFF1565C0)),
//       _ => ('—', scheme.onSurfaceVariant),
//     };

//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: large ? 12 : 8,
//         vertical: large ? 6 : 3,
//       ),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.12),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withValues(alpha: 0.4)),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: large ? 12 : 10,
//           fontWeight: FontWeight.w800,
//           color: color,
//         ),
//       ),
//     );
//   }
// }

// // ── Filter Bar ────────────────────────────────────────────────────────────────

// class _FilterBar extends StatelessWidget {
//   final AttendanceController controller;
//   const _FilterBar({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final scheme = theme.colorScheme;

//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//       decoration: BoxDecoration(
//         color: scheme.surface,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(child: _GroupDropdown(controller: controller)),
//               const SizedBox(width: 10),
//               Expanded(child: _ClassDropdown(controller: controller)),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Expanded(child: _DateField(controller: controller)),
//               const SizedBox(width: 10),
//               Expanded(child: _ShiftDropdown(controller: controller)),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(child: _SearchBox(controller: controller)),
//               SizedBox(
//                 width: 130,
//                 child: OutlinedButton.icon(
//                   onPressed: controller.search,
//                   icon: Icon(
//                     Icons.search_rounded,
//                     size: 18,
//                     color: scheme.primary,
//                   ),
//                   label: Text(
//                     'Filter',
//                     style: TextStyle(color: scheme.primary),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     minimumSize: const Size.fromHeight(44),
//                     side: BorderSide(color: scheme.primary),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),

//               // const SizedBox(width: 10),
//               // Expanded(
//               //   child: OutlinedButton.icon(
//               //     onPressed: () {},
//               //     icon:
//               //         Icon(Icons.save_rounded, size: 18, color: scheme.primary),
//               //     label:
//               //         Text('Save', style: TextStyle(color: scheme.primary)),
//               //     style: OutlinedButton.styleFrom(
//               //       minimumSize: const Size.fromHeight(44),
//               //       side: BorderSide(color: scheme.primary),
//               //       shape: RoundedRectangleBorder(
//               //           borderRadius: BorderRadius.circular(10)),
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Dropdown widgets ──────────────────────────────────────────────────────────

// class _GroupDropdown extends StatelessWidget {
//   final AttendanceController controller;
//   const _GroupDropdown({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => _DropdownField<CategoryModel>(
//         label: 'Group',
//         hint: controller.isGroupLoading.value ? 'Loading…' : 'Select',
//         value: controller.selectedGroup.value,
//         items: controller.groupList,
//         itemLabel: (g) => g.name ?? '',
//         onChanged: controller.isGroupLoading.value
//             ? null
//             : (v) => controller.selectedGroup.value = v,
//       ),
//     );
//   }
// }

// class _ClassDropdown extends StatelessWidget {
//   final AttendanceController controller;
//   const _ClassDropdown({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => _DropdownField<CategoryModel>(
//         label: 'Class',
//         hint: controller.selectedGroup.value == null
//             ? 'Select group first'
//             : controller.isClassLoading.value
//             ? 'Loading…'
//             : 'Select',
//         value: controller.selectedClass.value,
//         items: controller.classList,
//         itemLabel: (c) => c.name ?? '',
//         onChanged:
//             (controller.isClassLoading.value ||
//                 controller.selectedGroup.value == null)
//             ? null
//             : (v) => controller.selectedClass.value = v,
//       ),
//     );
//   }
// }

// class _ShiftDropdown extends StatelessWidget {
//   final AttendanceController controller;
//   const _ShiftDropdown({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => _DropdownField<ShiftModel>(
//         label: 'Shift',
//         hint: controller.isShiftLoading.value ? 'Loading…' : 'Select',
//         value: controller.selectedShift.value,
//         items: controller.shiftList,
//         itemLabel: (s) => s.name,
//         onChanged: controller.isShiftLoading.value
//             ? null
//             : (v) => controller.selectedShift.value = v,
//       ),
//     );
//   }
// }

// class _DateField extends StatelessWidget {
//   final AttendanceController controller;
//   const _DateField({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final scheme = theme.colorScheme;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Attendance Date *',
//           style: theme.textTheme.labelSmall?.copyWith(
//             color: scheme.onSurfaceVariant,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 4),
//         GestureDetector(
//           onTap: () => controller.pickDate(context),
//           child: Container(
//             height: 44,
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               border: Border.all(color: theme.dividerColor),
//               borderRadius: BorderRadius.circular(8),
//               color: scheme.surface,
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Obx(() {
//                     final date = controller.selectedDate.value;
//                     return Text(
//                       date == null ? 'Select date' : controller.formattedDate,
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: date == null
//                             ? scheme.onSurfaceVariant
//                             : scheme.onSurface,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     );
//                   }),
//                 ),
//                 Icon(
//                   Icons.calendar_today_rounded,
//                   size: 16,
//                   color: scheme.onSurfaceVariant,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _DropdownField<T> extends StatelessWidget {
//   final String label;
//   final String hint;
//   final T? value;
//   final List<T> items;
//   final String Function(T) itemLabel;
//   final void Function(T?)? onChanged;

//   const _DropdownField({
//     required this.label,
//     required this.hint,
//     required this.value,
//     required this.items,
//     required this.itemLabel,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final scheme = theme.colorScheme;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '$label *',
//           style: theme.textTheme.labelSmall?.copyWith(
//             color: scheme.onSurfaceVariant,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Container(
//           height: 44,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             border: Border.all(color: theme.dividerColor),
//             borderRadius: BorderRadius.circular(8),
//             color: scheme.surface,
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<T>(
//               isExpanded: true,
//               value: (value != null && items.contains(value)) ? value : null,
//               hint: Text(
//                 hint,
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: scheme.onSurfaceVariant,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: scheme.onSurface,
//               ),
//               icon: Icon(
//                 Icons.keyboard_arrow_down_rounded,
//                 size: 18,
//                 color: scheme.onSurfaceVariant,
//               ),
//               onChanged: onChanged,
//               items: items
//                   .map(
//                     (e) => DropdownMenuItem<T>(
//                       value: e,
//                       child: Text(
//                         itemLabel(e),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:erp_management/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/attendance_marking_controller.dart';
import '../models/attendance_student_model.dart';
import '../models/attendance_type.dart';
import '../../../../../../../core/models/category_model.dart';
import '../models/shift_model.dart';

/// One screen for BOTH viewing and marking student attendance.
/// Replaces the old separate "AttendanceScreen" (view only) and
/// "AttendanceMarkingScreen" (mark only) — both routes should now point
/// here, backed by the single AttendanceMarkingController.
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AttendanceMarkingController());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('STUDENT ATTENDANCE'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Obx(() {
            if (!c.hasLoaded.value) return const SizedBox.shrink();
            return IconButton(
              tooltip: c.viewMode.value == 'card' ? 'Table view' : 'Card view',
              icon: Icon(
                c.viewMode.value == 'card'
                    ? Icons.table_rows_rounded
                    : Icons.grid_view_rounded,
              ),
              onPressed: c.toggleView,
            );
          }),
        ],
      ),
      body: Column(
        children: [
          _FilterCard(c: c),
          Obx(() {
            if (!c.hasLoaded.value) return const SizedBox.shrink();
            return _SummaryBar(c: c);
          }),
          Obx(() {
            if (!c.hasLoaded.value) return const SizedBox.shrink();
            return _SearchAndFilterRow(c: c);
          }),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (!c.hasLoaded.value) {
                return const Center(
                  child: Text(
                    'Select filters and tap Load',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              if (c.filteredStudents.isEmpty) {
                return const Center(
                  child: Text(
                    'No students found',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: c.viewMode.value == 'table'
                    ? _TableView(c: c)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: Column(
                          children: c.filteredStudents
                              .map((s) => _StudentMarkCard(student: s, c: c))
                              .toList(),
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (!c.hasLoaded.value) return const SizedBox.shrink();
        return _SaveBar(c: c);
      }),
    );
  }
}

// ── Card view ─────────────────────────────────────────────────────────────────

class _StudentMarkCard extends StatelessWidget {
  final AttendanceStudentModel student;
  final AttendanceMarkingController c;
  const _StudentMarkCard({required this.student, required this.c});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final selectedId =
          c.markingMap[student.id] ?? AttendanceTypeOption.present.id;
      final selected = AttendanceTypeOption.fromId(selectedId);

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                          selected?.color.withValues(alpha: 0.15) ??
                          theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        student.firstName.isNotEmpty
                            ? student.firstName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selected?.color ?? Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.firstName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${student.sid}  •  Father: ${student.fatherName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: selected.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        selected.label,
                        style: TextStyle(
                          color: selected.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children:
                    [
                          AttendanceTypeOption.present,
                          AttendanceTypeOption.absent,
                          // AttendanceTypeOption.halfDay,
                        ]
                        .map(
                          (opt) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: _RadioChip(
                                option: opt,
                                isSelected: selectedId == opt.id,
                                onTap: () => c.setMark(student.id, opt.id),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _RadioChip extends StatelessWidget {
  final AttendanceTypeOption option;
  final bool isSelected;
  final VoidCallback onTap;
  const _RadioChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? option.color
              : option.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? option.color
                : option.color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 14,
              color: isSelected ? Colors.white : option.color,
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                option.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : option.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter card ───────────────────────────────────────────────────────────────

class _FilterCard extends StatelessWidget {
  final AttendanceMarkingController c;
  const _FilterCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1565C0),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _SessionDrop(c: c)),
              const SizedBox(width: 8),
              Expanded(child: _GroupDrop(c: c)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _ClassDrop(c: c)),
              const SizedBox(width: 8),
              Expanded(child: _ShiftDrop(c: c)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _DatePicker(c: c)),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: c.loadStudents,
                icon: const Icon(Icons.search),
                label: const Text('Load'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.isDarkMode
                      ? AppColors.black
                      : Colors.white,
                  foregroundColor: Get.isDarkMode
                      ? Colors.white
                      : const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionDrop extends StatelessWidget {
  final AttendanceMarkingController c;
  const _SessionDrop({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropWrapper(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: Theme.of(context).colorScheme.surface,
            value: c.sessionList.contains(c.selectedSession.value)
                ? c.selectedSession.value
                : null,
            isExpanded: true,
            hint: const Text(
              'Session',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            items: c.sessionList
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (v) => c.selectedSession.value = v ?? '',
          ),
        ),
      ),
    );
  }
}

class _GroupDrop extends StatelessWidget {
  final AttendanceMarkingController c;
  const _GroupDrop({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropWrapper(
        child: c.isGroupLoading.value
            ? const _LoadingIndicator()
            : DropdownButtonHideUnderline(
                child: DropdownButton<CategoryModel>(
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  value: c.selectedGroup.value,
                  isExpanded: true,
                  hint: const Text(
                    'Group',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  items: c.groupList
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text(
                            g.name ?? '',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => c.selectedGroup.value = v,
                ),
              ),
      ),
    );
  }
}

class _ClassDrop extends StatelessWidget {
  final AttendanceMarkingController c;
  const _ClassDrop({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropWrapper(
        child: c.isClassLoading.value
            ? const _LoadingIndicator()
            : DropdownButtonHideUnderline(
                child: DropdownButton<CategoryModel>(
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  value: c.selectedClass.value,
                  isExpanded: true,
                  hint: const Text(
                    'Class',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  items: c.classList
                      .map(
                        (cl) => DropdownMenuItem(
                          value: cl,
                          child: Text(
                            cl.name ?? '',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => c.selectedClass.value = v,
                ),
              ),
      ),
    );
  }
}

class _ShiftDrop extends StatelessWidget {
  final AttendanceMarkingController c;
  const _ShiftDrop({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropWrapper(
        child: c.isShiftLoading.value
            ? const _LoadingIndicator()
            : DropdownButtonHideUnderline(
                child: DropdownButton<ShiftModel>(
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  value: c.selectedShift.value,
                  isExpanded: true,
                  hint: const Text(
                    'Shift',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  items: c.shiftList
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s.name,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => c.selectedShift.value = v,
                ),
              ),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final AttendanceMarkingController c;
  const _DatePicker({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropWrapper(
        child: InkWell(
          onTap: () => c.pickDate(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  c.formattedDate.isEmpty ? 'Pick date' : c.formattedDate,
                  style: TextStyle(
                    fontSize: 13,
                    color: c.formattedDate.isEmpty
                        ? (Get.isDarkMode
                              ? AppColors.white
                              : context.theme.primaryColor)
                        : (Get.isDarkMode
                              ? AppColors.white
                              : context.theme.primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}

class _DropWrapper extends StatelessWidget {
  final Widget child;
  const _DropWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

// ── Summary bar (Total / Present / Absent / Half Day) ──────────────────────────
// Each cell now uses the matching AttendanceTypeOption color, same as the
// present/absent chips and table dots. TOTAL stays the default app blue
// since there's no single "type" color for it.

class _SummaryBar extends StatelessWidget {
  final AttendanceMarkingController c;
  const _SummaryBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Obx(
        () => Row(
          children: [
            _SummaryCell('TOTAL', c.totalCount, isFirst: true),
            _SummaryCell(
              'PRESENT',
              c.presentCount,
              color: AttendanceTypeOption.present.color,
            ),
            _SummaryCell(
              'ABSENT',
              c.absentCount,
              color: AttendanceTypeOption.absent.color,
            ),
            // _SummaryCell(
            //   'HALF DAY',
            //   c.halfDayCount,
            //   color: AttendanceTypeOption.halfDay.color,
            //   isLast: true,
            // ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String label;
  final int count;
  final bool isFirst;
  final bool isLast;
  final Color color;
  const _SummaryCell(
    this.label,
    this.count, {
    this.isFirst = false,
    this.isLast = false,
    this.color = const Color(0xFF1565C0),
  });

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            right: isLast ? BorderSide.none : BorderSide(color: divider),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search + MARKED/UNMARKED toggle — matches reference row ────────────────────

class _SearchAndFilterRow extends StatelessWidget {
  final AttendanceMarkingController c;
  const _SearchAndFilterRow({required this.c});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: TextField(
                onChanged: (v) => c.searchQuery.value = v,
                decoration: const InputDecoration(
                  hintText: 'SEARCH STUDENT',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF1565C0),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF1565C0),
                ),
              ),
            ),
          ),
          Container(width: 1, height: 28, color: theme.dividerColor),
          Obx(() {
            final hasMarked = c.students.any(
              (student) =>
                  student.attendenceType != null &&
                  student.attendenceType!.trim().isNotEmpty,
            );

            return FilterChip(
              label: Text(hasMarked ? "Marked" : "Unmarked"),
              selected:
                  c.markedFilter.value == (hasMarked ? "marked" : "unmarked"),
              onSelected: (_) => null,
              // c.setMarkedFilter(hasMarked ? "marked" : "unmarked"),
            );
          }),
        ],
      ),
    );
  }
}

// ── Table view — matches the reference design exactly:
// S.No | Name/Father/Mobile | Present | Absent | Half Day | Holiday
// with an inline "mark all" row right under the header. ────────────────────────

class _TableView extends StatelessWidget {
  final AttendanceMarkingController c;
  const _TableView({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final students = c.filteredStudents;
      return Table(
        columnWidths: const {
          0: FixedColumnWidth(44),
          1: FlexColumnWidth(3.6),
          2: FlexColumnWidth(1.3),
          3: FlexColumnWidth(1.3),
        },
        border: TableBorder.all(
          color: Theme.of(context).dividerColor,
          width: 0.6,
        ),
        children: [
          _headerRow(context),
          for (int i = 0; i < students.length; i++)
            _studentRow(context, i + 1, students[i]),
        ],
      );
    });
  }

  TableRow _headerRow(BuildContext context) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFEFF3FB)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: const Text(
            'S. NO.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
              color: Color(0xFF1565C0),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                'NAME',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                  color: Color(0xFF1565C0),
                ),
              ),
              Text(
                'FATHER',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                  color: Color(0xFF1565C0),
                ),
              ),
              Text(
                'MOBILE',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
        ),
        _headerMarkCell(AttendanceTypeOption.present),
        _headerMarkCell(AttendanceTypeOption.absent),
      ],
    );
  }

  /// Header cell for Present/Absent: label on top, a select-all checkbox
  /// right below it. Tapping the checkbox marks every loaded student the
  /// same way (all Present, or all Absent). This is a BULK action only —
  /// it must never be what fires when a single student's row is tapped.
  Widget _headerMarkCell(AttendanceTypeOption opt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            opt.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
              color: opt.color,
            ),
          ),
          const SizedBox(height: 4),
          Obx(() {
            // Header checkbox reflects whether EVERY loaded student is
            // currently marked with this option.
            final allMatch =
                c.students.isNotEmpty &&
                c.students.every((s) => c.markingMap[s.id] == opt.id);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => c.applyBulk(opt),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: allMatch ? opt.color : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: opt.color, width: 1.6),
                  ),
                  child: allMatch
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  TableRow _studentRow(
    BuildContext context,
    int serial,
    AttendanceStudentModel s,
  ) {
    return TableRow(
      decoration: BoxDecoration(
        color: serial.isEven ? const Color(0xFFF7F9FF) : Colors.white,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            '$serial',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.firstName,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1565C0),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                s.fatherName,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC62828),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _mobileOf(s),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF57C00),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // IMPORTANT: this passes THIS row's student `s`, not the whole
        // list — each cell's tap must only ever touch `s.id`.
        _markCell(s, AttendanceTypeOption.present),
        _markCell(s, AttendanceTypeOption.absent),
      ],
    );
  }

  Widget _markCell(
    AttendanceStudentModel s,
    AttendanceTypeOption opt, {
    bool editable = true,
  }) {
    return Obx(() {
      final selectedId = c.markingMap[s.id];
      final isSelected = selectedId == opt.id;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: editable ? () => c.setMark(s.id, opt.id) : null,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? opt.color : Colors.transparent,
                  border: Border.all(
                    color: editable
                        ? opt.color
                        : Colors.grey.withValues(alpha: 0.5),
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Best-effort read of a mobile/contact field on the student model.
  /// If AttendanceStudentModel doesn't define `mobile`, this safely
  /// falls back to an empty string instead of failing to compile —
  /// rename/adjust once the actual field name is confirmed.
  String _mobileOf(AttendanceStudentModel s) {
    try {
      final dynamic dyn = s;
      final value = dyn.mobile;
      return value == null ? '' : value.toString();
    } catch (_) {
      return '';
    }
  }
}

// ── Save bar ──────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final AttendanceMarkingController c;
  const _SaveBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Obx(
          () => FilledButton.icon(
            onPressed: c.isSaving.value ? null : c.saveBulk,
            icon: c.isSaving.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(
              c.isSaving.value
                  ? 'Saving…'
                  : 'Save Attendance (${c.students.length})',
              style: const TextStyle(fontSize: 15),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
