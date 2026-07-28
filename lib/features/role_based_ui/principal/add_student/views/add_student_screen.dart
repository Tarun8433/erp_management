import 'package:erp_management/features/role_based_ui/principal/admission/controllers/admission_controller.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/service/image_picker_service.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/views/new_admission_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddStudentScreen extends StatelessWidget {
  const AddStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AdmissionController());
    final imagePickerService = ImagePickerService();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: scheme.surfaceContainerLowest,
        appBar: AppBar(
          title: const Text('Add Student'),
          centerTitle: false,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Get.back(),
          ),
        ),
        body: Obx(() {
          return Column(
            children: [
              _StepIndicator(controller: c),
              Expanded(
                child: c.currentStep.value == 0
                    ? BasicInformationStep(controller: c, isMobile: isMobile)
                    : _SrAndPhotoStep(
                        controller: c,
                        isMobile: isMobile,
                        imagePickerService: imagePickerService,
                      ),
              ),
              _BottomBar(controller: c, isMobile: isMobile),
            ],
          );
        }),
      ),
    );
  }
}

// ── Step indicator (2 steps) ──────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final AdmissionController controller;
  const _StepIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    const steps = [
      {'title': 'Basic Info', 'icon': Icons.person_outline},
      {'title': 'SR & Photo', 'icon': Icons.badge_outlined},
    ];

    return Obx(() {
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;

      return Container(
        color: scheme.surface,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        child: Row(
          children: List.generate(steps.length, (index) {
            final isActive = controller.currentStep.value == index;
            final isCompleted = controller.currentStep.value > index;

            return Expanded(
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => controller.currentStep.value = index,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green
                                : (isActive ? scheme.primary : scheme.surfaceContainer),
                            shape: BoxShape.circle,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: scheme.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check
                                : (steps[index]['icon'] as IconData),
                            color: (isActive || isCompleted)
                                ? Colors.white
                                : scheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          steps[index]['title'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 22, left: 8, right: 8),
                        color: isCompleted
                            ? Colors.green
                            : scheme.surfaceContainerHighest,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      );
    });
  }
}

// ── Step 2: SR No & Photo ─────────────────────────────────────────────────────

class _SrAndPhotoStep extends StatelessWidget {
  final AdmissionController controller;
  final bool isMobile;
  final ImagePickerService imagePickerService;
  const _SrAndPhotoStep({
    required this.controller,
    required this.isMobile,
    required this.imagePickerService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final c = controller;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StudentSummaryCard(controller: c),
          const SizedBox(height: 28),

          // Photo section
          _buildSection(theme, scheme, 'STUDENT PHOTO', Icons.camera_alt_outlined, [
            Center(
              child: Obx(() {
                final photo = c.uploadedFiles['student_photo'];
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () => imagePickerService.showImagePickerOptions(
                        context: context,
                        onImageSelected: (file) =>
                            c.setUploadedFile('student_photo', file),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.surfaceContainerHighest,
                              border: Border.all(
                                color: photo != null
                                    ? scheme.primary
                                    : scheme.outlineVariant,
                                width: photo != null ? 3 : 1.5,
                              ),
                              image: photo != null
                                  ? DecorationImage(
                                      image: FileImage(photo),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: photo == null
                                ? Icon(
                                    Icons.person_outline,
                                    size: 52,
                                    color: scheme.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: scheme.surface, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      photo != null ? 'Tap to change photo' : 'Tap to add photo',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    if (photo != null) ...[
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: () => c.removeUploadedFile('student_photo'),
                        icon: const Icon(Icons.delete_outline,
                            size: 16, color: Colors.red),
                        label: const Text('Remove',
                            style: TextStyle(color: Colors.red)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ]),
          const SizedBox(height: 24),

          // SR Number section
          _buildSection(theme, scheme, 'SR NUMBER', Icons.numbers_outlined, [
            Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SrRadioOption(
                            label: 'Auto Generate',
                            selected: c.generateSrNo.value,
                            onTap: () => c.generateSrNo.value = true,
                            scheme: scheme,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SrRadioOption(
                            label: 'Manual Entry',
                            selected: !c.generateSrNo.value,
                            onTap: () => c.generateSrNo.value = false,
                            scheme: scheme,
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                    if (!c.generateSrNo.value) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: c.srNoCtrl,
                        focusNode: c.srNoFocus,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9\-/]')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'ENTER SR NUMBER',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: theme.dividerColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: theme.dividerColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: scheme.primary, width: 1.4),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          isDense: true,
                          prefixIcon:
                              const Icon(Icons.tag, size: 20),
                        ),
                      ),
                    ],
                    if (c.generateSrNo.value) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              scheme.primaryContainer.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 16, color: scheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'SR number will be assigned automatically.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                )),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Student summary card ──────────────────────────────────────────────────────

class _StudentSummaryCard extends StatelessWidget {
  final AdmissionController controller;
  const _StudentSummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final c = controller;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const Icon(Icons.school_outlined,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.fullNameCtrl.text.trim().isEmpty
                      ? 'Student'
                      : c.fullNameCtrl.text.trim(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (c.selectedClass.value.isNotEmpty) c.selectedClass.value,
                    if (c.selectedGroup.value.isNotEmpty) c.selectedGroup.value,
                    if (c.selectedAcademicYear.value.isNotEmpty)
                      c.selectedAcademicYear.value,
                  ].join(' · '),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Step 2 of 2',
              style:
                  theme.textTheme.labelSmall?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── SR radio option ───────────────────────────────────────────────────────────

class _SrRadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme scheme;
  final ThemeData theme;

  const _SrRadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.scheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 18,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom action bar ─────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final AdmissionController controller;
  final bool isMobile;
  const _BottomBar({required this.controller, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
            top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(
            () => controller.currentStep.value > 0
                ? OutlinedButton.icon(
                    onPressed: controller.previousStep,
                    icon: const Icon(Icons.chevron_left),
                    label: Text(isMobile ? '' : 'BACK'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const Spacer(),
          Obx(() {
            final isLast = controller.currentStep.value == 1;
            return FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 28,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: controller.isSubmitting.value
                  ? null
                  : () {
                      if (isLast) {
                        controller.submitAdmission();
                      } else {
                        controller.nextStep();
                      }
                    },
              icon: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      isLast ? Icons.check_circle_rounded : Icons.arrow_forward),
              label: Text(
                isLast ? 'COMPLETE' : 'SAVE & NEXT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _buildSection(
  ThemeData theme,
  ColorScheme scheme,
  String title,
  IconData icon,
  List<Widget> children,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: scheme.primary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    ],
  );
}
