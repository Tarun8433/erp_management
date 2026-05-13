import 'dart:io';
import 'package:erp_management/core/widgets/searchable_dropdown.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/service/document_upload_tile.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/service/image_picker_service.dart';
import 'package:erp_management/features/role_based_ui/principal/new_student_list/controllers/student_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EditStudentScreen extends StatefulWidget {
  const EditStudentScreen({super.key});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final StudentListController c = Get.find<StudentListController>();
  final ImagePickerService imagePickerService = ImagePickerService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: scheme.surfaceContainerLowest,
        appBar: AppBar(
          title: const Text('Update Student Info'),
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
              _HorizontalStepIndicator(controller: c, isMobile: isMobile),
              Expanded(child: _buildStepContent(c.currentStep.value, isMobile)),
              _BottomActionButton(controller: c, isMobile: isMobile),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(int step, bool isMobile) {
    switch (step) {
      case 0:
        return _BasicInformationStep(controller: c, isMobile: isMobile);
      case 1:
        return _GuardianDetailsStep(controller: c, isMobile: isMobile);
      case 2:
        return _ClassAndGroupStep(controller: c, isMobile: isMobile);
      case 3:
        return _PreviousSchoolStep(controller: c, isMobile: isMobile);
      case 4:
        return _SRNoAndTransportStep(controller: c, isMobile: isMobile);
      case 5:
        return _UploadDocumentsTab(
          controller: c,
          imagePickerService: imagePickerService,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _HorizontalStepIndicator extends StatelessWidget {
  final StudentListController controller;
  final bool isMobile;
  const _HorizontalStepIndicator({
    required this.controller,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final totalSteps = controller.totalSteps;

    final List<Map<String, dynamic>> steps = [
      {'title': 'Basic Info', 'icon': Icons.person_outline},
      {'title': 'Guardian', 'icon': Icons.supervisor_account_outlined},
      {'title': 'Class/Group', 'icon': Icons.school_outlined},
      {'title': 'Prev School', 'icon': Icons.history_edu_outlined},
      {'title': 'Transport', 'icon': Icons.directions_bus_outlined},
      {'title': 'Documents', 'icon': Icons.cloud_upload_outlined},
    ];

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: scheme.surface,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${controller.currentStep.value + 1} of $totalSteps',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                Text(
                  steps[controller.currentStep.value]['title'],
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (controller.currentStep.value + 1) / totalSteps,
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: scheme.primaryContainer.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
      color: scheme.surface,
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = controller.currentStep.value == index;
          final isCompleted = controller.currentStep.value > index;

          return Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => controller.goToStep(index),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green
                              : (isActive
                                    ? scheme.primary
                                    : scheme.surfaceContainer),
                          shape: BoxShape.circle,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: scheme.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : steps[index]['icon'],
                          color: (isActive || isCompleted)
                              ? Colors.white
                              : scheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        steps[index]['title'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
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
                      margin: const EdgeInsets.only(
                        bottom: 24,
                        left: 8,
                        right: 8,
                      ),
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
  }
}

class _BasicInformationStep extends StatelessWidget {
  final StudentListController controller;
  final bool isMobile;
  const _BasicInformationStep({
    required this.controller,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormSection(
            theme,
            scheme,
            'PERSONAL DETAILS',
            Icons.person_outline,
            [
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  Obx(
                    () => SearchableDropdown<String>(
                      label: 'ACADEMIC YEAR',
                      hint: 'Select Year',
                      value: controller.editAcademicYear.value.isEmpty
                          ? null
                          : controller.editAcademicYear.value,
                      items: controller.academicYearList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) =>
                          controller.editAcademicYear.value = v ?? '',
                    ),
                  ),
                  _buildTextField(
                    context,
                    'STUDENT NAME *',
                    controller.nameCtrl,
                    Icons.person_outline,
                  ),
                ],
              ),
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  _buildTextField(
                    context,
                    'DATE OF BIRTH',
                    controller.dobCtrl,
                    Icons.calendar_today,
                    readOnly: true,
                    onTap: () => controller.pickDate(context),
                  ),
                  Obx(
                    () => SearchableDropdown<String>(
                      label: 'GENDER',
                      hint: 'Select Gender',
                      value: controller.editGender.value.isEmpty
                          ? null
                          : controller.editGender.value,
                      items: controller.genderList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) => controller.editGender.value = v ?? '',
                    ),
                  ),
                ],
              ),
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  Obx(
                    () => SearchableDropdown<String>(
                      label: 'RELIGION',
                      hint: 'Select Religion',
                      value: controller.editReligion.value.isEmpty
                          ? null
                          : controller.editReligion.value,
                      items: controller.religionList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) => controller.editReligion.value = v ?? '',
                    ),
                  ),
                  Obx(
                    () => SearchableDropdown<String>(
                      label: 'CASTE',
                      hint: 'Select Caste',
                      value: controller.editCategory.value.isEmpty
                          ? null
                          : controller.editCategory.value,
                      items: controller.categoryList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) => controller.editCategory.value = v ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFormSection(
            theme,
            scheme,
            'IDENTITY DETAILS',
            Icons.badge_outlined,
            [
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  _buildTextField(
                    context,
                    'AADHAAR NUMBER',
                    controller.aadhaarCtrl,
                    Icons.credit_card,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                      _AadhaarFormatter(),
                    ],
                  ),
                  _buildTextField(
                    context,
                    'PEN / PAN NO',
                    controller.penNoCtrl,
                    Icons.assignment_ind_outlined,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      _PanCardFormatter(),
                    ],
                  ),
                ],
              ),
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  _buildTextField(
                    context,
                    'APAAR ID',
                    controller.apaarIdCtrl,
                    Icons.fingerprint,
                  ),
                  const SizedBox.shrink(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFormSection(
            theme,
            scheme,
            'PARENTAL INFORMATION',
            Icons.family_restroom_outlined,
            [
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  _buildTextField(
                    context,
                    'FATHER NAME',
                    controller.fatherNameCtrl,
                    Icons.person_outline,
                  ),
                  _buildTextField(
                    context,
                    'FATHER MOBILE *',
                    controller.fatherMobileCtrl,
                    Icons.phone_android,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                ],
              ),
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  _buildTextField(
                    context,
                    'FATHER OCCUPATION',
                    controller.fatherOccupationCtrl,
                    Icons.work_outline,
                  ),
                  const SizedBox.shrink(),
                ],
              ),
              const Divider(height: 32),
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  _buildTextField(
                    context,
                    'MOTHER NAME',
                    controller.motherNameCtrl,
                    Icons.person_outline,
                  ),
                  _buildTextField(
                    context,
                    'MOTHER MOBILE',
                    controller.motherMobileCtrl,
                    Icons.phone_android,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                ],
              ),
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  _buildTextField(
                    context,
                    'MOTHER OCCUPATION',
                    controller.motherOccupationCtrl,
                    Icons.work_outline,
                  ),
                  const SizedBox.shrink(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFormSection(
            theme,
            scheme,
            'ADDRESS DETAILS',
            Icons.location_on_outlined,
            [
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  _buildTextField(
                    context,
                    'VILLAGE / MOHALLA',
                    controller.villageCtrl,
                    Icons.home_outlined,
                  ),
                  _buildTextField(
                    context,
                    'TEHSIL',
                    controller.tehsilCtrl,
                    Icons.location_city_outlined,
                  ),
                ],
              ),
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  _buildTextField(
                    context,
                    'DISTRICT',
                    controller.districtCtrl,
                    Icons.map_outlined,
                  ),
                  _buildTextField(
                    context,
                    'STATE',
                    controller.stateCtrl,
                    Icons.public,
                  ),
                ],
              ),
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  _buildTextField(
                    context,
                    'PIN CODE',
                    controller.pinCodeCtrl,
                    Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                  ),
                  const SizedBox.shrink(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFormSection(
            theme,
            scheme,
            'ADDITIONAL NOTES',
            Icons.note_alt_outlined,
            [
              _buildTextField(
                context,
                'REMARK / NOTES',
                controller.remarkCtrl,
                Icons.note_alt_outlined,
                maxLines: 3,
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _GuardianDetailsStep extends StatelessWidget {
  final StudentListController controller;
  final bool isMobile;
  const _GuardianDetailsStep({
    required this.controller,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormSection(
            theme,
            scheme,
            'GUARDIAN DETAILS',
            Icons.supervisor_account_outlined,
            [
              Text(
                'GUARDIAN SAME AS FATHER?',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: controller.isGuardianSameAsFather.value,
                      onChanged: (v) =>
                          controller.isGuardianSameAsFather.value = v ?? true,
                    ),
                    const Text('YES'),
                    const SizedBox(width: 24),
                    Radio<bool>(
                      value: false,
                      groupValue: controller.isGuardianSameAsFather.value,
                      onChanged: (v) =>
                          controller.isGuardianSameAsFather.value = v ?? false,
                    ),
                    const Text('NO'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => Visibility(
                  visible: !controller.isGuardianSameAsFather.value,
                  child: Column(
                    children: [
                      _ResponsiveRow(
                        isMobile: isMobile,
                        children: [
                          _buildTextField(
                            context,
                            'GUARDIAN NAME',
                            controller.guardianNameCtrl,
                            Icons.person_outline,
                          ),
                          _buildTextField(
                            context,
                            'GUARDIAN MOBILE',
                            controller.guardianMobileCtrl,
                            Icons.phone_android,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                        ],
                      ),
                      _ResponsiveRow(
                        isMobile: isMobile,
                        children: [
                          _buildTextField(
                            context,
                            'OCCUPATION',
                            controller.guardianOccupationCtrl,
                            Icons.work_outline,
                          ),
                          _buildTextField(
                            context,
                            'VILLAGE / MOHALLA',
                            controller.guardianVillageCtrl,
                            Icons.home_outlined,
                          ),
                        ],
                      ),
                      _ResponsiveRow(
                        isMobile: isMobile,
                        children: [
                          _buildTextField(
                            context,
                            'TEHSIL',
                            controller.guardianTehsilCtrl,
                            Icons.location_city_outlined,
                          ),
                          _buildTextField(
                            context,
                            'DISTRICT',
                            controller.guardianDistrictCtrl,
                            Icons.map_outlined,
                          ),
                        ],
                      ),
                      _ResponsiveRow(
                        isMobile: isMobile,
                        children: [
                          _buildTextField(
                            context,
                            'STATE',
                            controller.guardianStateCtrl,
                            Icons.public,
                          ),
                          _buildTextField(
                            context,
                            'PIN CODE',
                            controller.guardianPinCodeCtrl,
                            Icons.pin_drop_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Obx(
                () => Visibility(
                  visible: controller.isGuardianSameAsFather.value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: scheme.primary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Guardian details will be automatically used from Father information.',
                          ),
                        ),
                      ],
                    ),
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

class _ClassAndGroupStep extends StatelessWidget {
  final StudentListController controller;
  final bool isMobile;
  const _ClassAndGroupStep({required this.controller, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        children: [
          _buildFormSection(
            theme,
            scheme,
            'SELECT ACADEMIC GROUP & CLASS',
            Icons.school_outlined,
            [
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  Obx(
                    () => SearchableDropdown<String>(
                      label: 'GROUP *',
                      hint: 'Select Group',
                      value: controller.editGroup.value.isEmpty
                          ? null
                          : controller.editGroup.value,
                      items: controller.groupList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) => controller.editGroup.value = v ?? '',
                    ),
                  ),
                  Obx(
                    () => SearchableDropdown<String>(
                      label: 'CLASS *',
                      hint: 'Select Class',
                      value: controller.editClass.value.isEmpty
                          ? null
                          : controller.editClass.value,
                      items: controller.classList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) => controller.editClass.value = v ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviousSchoolStep extends StatelessWidget {
  final StudentListController controller;
  final bool isMobile;
  const _PreviousSchoolStep({required this.controller, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        children: [
          _buildFormSection(
            theme,
            scheme,
            'PREVIOUS SCHOOL DETAILS',
            Icons.history_edu_outlined,
            [
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  _buildTextField(
                    context,
                    'PREVIOUS SCHOOL / COLLEGE',
                    controller.prevSchoolNameCtrl,
                    Icons.school_outlined,
                  ),
                  _buildTextField(
                    context,
                    'PREVIOUS CLASS',
                    controller.prevClassCtrl,
                    Icons.class_outlined,
                  ),
                ],
              ),
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  Obx(
                    () => SearchableDropdown<String>(
                      label: 'PASSED / FAILED',
                      hint: 'Select Result',
                      value: controller.selectedPrevResult.value.isEmpty
                          ? null
                          : controller.selectedPrevResult.value,
                      items: controller.resultList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) =>
                          controller.selectedPrevResult.value = v ?? '',
                    ),
                  ),
                  Obx(
                    () => SearchableDropdown<String>(
                      label: 'PREVIOUS SESSION YEAR',
                      hint: 'Select Year',
                      value: controller.selectedPrevSessionYear.value.isEmpty
                          ? null
                          : controller.selectedPrevSessionYear.value,
                      items: controller.sessionYearList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) =>
                          controller.selectedPrevSessionYear.value = v ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SRNoAndTransportStep extends StatelessWidget {
  final StudentListController controller;
  final bool isMobile;
  const _SRNoAndTransportStep({
    required this.controller,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        children: [
          _buildFormSection(
            theme,
            scheme,
            'GENERATE SR NO?',
            Icons.numbers_outlined,
            [
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CustomRadioButton(
                      label: 'YES',
                      isSelected: controller.generateSrNo.value,
                      icon: Icons.check_circle,
                      color: Colors.green,
                      onTap: () => controller.generateSrNo.value = true,
                    ),
                    const SizedBox(width: 40),
                    _CustomRadioButton(
                      label: 'NO',
                      isSelected: !controller.generateSrNo.value,
                      icon: Icons.cancel,
                      color: Colors.red,
                      onTap: () => controller.generateSrNo.value = false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.push_pin, size: 16, color: scheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'IMPORTANT NOTE:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• IF ALL THE FIELDS AND DOCUMENTS HAVE BEEN SUBMITTED THEN CLICK YES OTHERWISE CLICK NO.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFormSection(
            theme,
            scheme,
            'TRANSPORT FACILITY',
            Icons.directions_bus_outlined,
            [
              Text(
                'AVAIL TRANSPORT FACILITY?',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CustomRadioButton(
                      label: 'YES',
                      isSelected: controller.availTransport.value,
                      icon: Icons.check_circle,
                      color: Colors.green,
                      onTap: () => controller.availTransport.value = true,
                    ),
                    const SizedBox(width: 40),
                    _CustomRadioButton(
                      label: 'NO',
                      isSelected: !controller.availTransport.value,
                      icon: Icons.cancel,
                      color: Colors.red,
                      onTap: () => controller.availTransport.value = false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomRadioButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CustomRadioButton({
    required this.label,
    required this.isSelected,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadDocumentsTab extends StatelessWidget {
  final StudentListController controller;
  final ImagePickerService imagePickerService;
  const _UploadDocumentsTab({
    required this.controller,
    required this.imagePickerService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final c = controller;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Obx(() {
      final requiredDocs = StudentListController.requiredDocuments;
      final docNames = StudentListController.documentNames;
      final docIcons = StudentListController.documentIcons;

      return SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormSection(
                    theme,
                    scheme,
                    'UPLOAD DOCUMENTS',
                    Icons.cloud_upload_outlined,
                    [
                      ...requiredDocs.map(
                        (docKey) => DocumentUploadTile(
                          docKey: docKey,
                          label: docNames[docKey]!,
                          icon: docIcons[docKey]!,
                          uploadedFile: c.uploadedFiles[docKey],
                          isRequired: true,
                          isUploading: c.uploadProgress[docKey] ?? false,
                          uploadProgress: c.uploadPercent[docKey] ?? 0,
                          onUpload: () => _showImagePicker(context, docKey),
                          onRemove: () => c.removeUploadedFile(docKey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildFormSection(
                      theme,
                      scheme,
                      'UPLOADED FILES',
                      Icons.folder_open_outlined,
                      [
                        if (c.uploadedFiles.values.every((f) => f == null))
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.folder_off_outlined,
                                    size: 48,
                                    color: scheme.onSurfaceVariant.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No documents uploaded yet.',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...c.uploadedFiles.entries
                              .where((e) => e.value != null)
                              .map(
                                (e) => ListTile(
                                  leading: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  title: Text(
                                    docNames[e.key]!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.remove_red_eye_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () {}, // Implement preview
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  void _showImagePicker(BuildContext context, String docKey) {
    imagePickerService.showImagePickerOptions(
      context: context,
      onImageSelected: (file) => controller.setUploadedFile(docKey, file),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  final StudentListController controller;
  final bool isMobile;
  const _BottomActionButton({required this.controller, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const Spacer(),
          SizedBox(
            height: 52,
            child: Obx(() {
              final isLast =
                  controller.currentStep.value == controller.totalSteps - 1;
              return Row(
                children: [
                  if (isLast) ...[
                    if (isMobile)
                      IconButton.filled(
                        onPressed: () {},
                        icon: const Icon(Icons.download, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    else
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                        label: const Text('Download Form'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                  ],
                  FilledButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (isLast) {
                              controller.updateStudent();
                            } else {
                              controller.nextStep();
                            }
                          },
                    icon: Icon(
                      isLast ? Icons.check_circle_rounded : Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    label: Text(
                      isLast
                          ? (isMobile ? 'Update' : 'Update Student')
                          : 'SAVE & NEXT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.white,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: isLast ? Colors.green : scheme.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Custom Formatters
class _AadhaarFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(' ', '');
    if (text.length > 12) text = text.substring(0, 12);

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != 12) {
        buffer.write(' ');
      }
    }

    String formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }
}

class _PanCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.toUpperCase();
    if (text.length > 10) text = text.substring(0, 10);

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i < 5 || i == 9) {
        // Must be letter
        if (RegExp(r'[A-Z]').hasMatch(text[i])) {
          buffer.write(text[i]);
        }
      } else {
        // Must be digit
        if (RegExp(r'[0-9]').hasMatch(text[i])) {
          buffer.write(text[i]);
        }
      }
    }

    String formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }
}

InputDecoration _getInputDecoration(
  BuildContext context,
  String label,
  IconData icon,
) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.dividerColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.dividerColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.primary, width: 1.4),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    isDense: true,
    prefixIcon: Icon(icon, size: 20),
  );
}

Widget _buildFormSection(
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
      const SizedBox(height: 16),
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

Widget _buildTextField(
  BuildContext context,
  String label,
  TextEditingController controller,
  IconData icon, {
  TextInputType? keyboardType,
  int maxLines = 1,
  bool readOnly = false,
  VoidCallback? onTap,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    readOnly: readOnly,
    onTap: onTap,
    inputFormatters: inputFormatters,
    decoration: _getInputDecoration(context, label, icon),
  );
}

class _ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final bool isMobile;
  const _ResponsiveRow({required this.children, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: children
            .map(
              (w) =>
                  Padding(padding: const EdgeInsets.only(bottom: 16), child: w),
            )
            .toList(),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: children
            .map(
              (w) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: w,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
