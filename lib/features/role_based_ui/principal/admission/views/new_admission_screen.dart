import 'package:erp_management/core/widgets/searchable_dropdown.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/controllers/admission_controller.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/service/document_upload_tile.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/service/image_picker_service.dart';
import 'package:erp_management/core/utils/drawer_main/src/flutter_zoom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NewAdmissionScreen extends StatefulWidget {
  /// Set to true ONLY when this screen is shown as a tab inside a
  /// `RoleScaffold` (which renders a floating BottomBar on top of the tab
  /// body). In that case, the fixed bottom action bar here needs extra
  /// clearance so it isn't hidden underneath the floating bar.
  ///
  /// Leave this false (the default) when this screen is opened standalone
  /// (e.g. via `Get.to`/a route/from Home), where there is no floating
  /// bottom bar and no extra clearance is needed.
  final bool insideBottomBarTab;

  const NewAdmissionScreen({super.key, this.insideBottomBarTab = false});

  @override
  State<NewAdmissionScreen> createState() => _NewAdmissionScreenState();
}

class _NewAdmissionScreenState extends State<NewAdmissionScreen>
    with SingleTickerProviderStateMixin {
  final AdmissionController c = Get.put(AdmissionController());
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
          title: const Text('Student Admission'),
          centerTitle: false,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Navigator.of(context).canPop()
                  ? Icons.arrow_back_rounded
                  : Icons.menu_rounded,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Get.back();
              } else {
                ZoomDrawer.of(context)?.toggle();
              }
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            bottom: widget.insideBottomBarTab
                ? 65 + MediaQuery.of(context).padding.bottom
                : 0,
          ),
          child: Obx(() {
            return Column(
              children: [
                _HorizontalStepIndicator(controller: c, isMobile: isMobile),
                Expanded(
                  child: _buildStepContent(c.currentStep.value, isMobile),
                ),
                _BottomActionButton(controller: c, isMobile: isMobile),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStepContent(int step, bool isMobile) {
    switch (step) {
      case 0:
        return BasicInformationStep(controller: c, isMobile: isMobile);
      case 1:
        return _GuardianDetailsStep(controller: c, isMobile: isMobile);
      case 2:
        return _PreviousSchoolStep(controller: c, isMobile: isMobile);
      case 3:
        return _SRNoAndTransportStep(controller: c, isMobile: isMobile);
      case 4:
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
  final AdmissionController controller;
  final bool isMobile;
  const _HorizontalStepIndicator({
    required this.controller,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final List<Map<String, dynamic>> steps = [
      {'title': 'Basic Info', 'icon': Icons.person_outline},
      {'title': 'Guardian', 'icon': Icons.supervisor_account_outlined},
      {'title': 'Prev School', 'icon': Icons.history_edu_outlined},
      {'title': 'Sr & Transport', 'icon': Icons.directions_bus_outlined},
      {'title': 'Documents', 'icon': Icons.cloud_upload_outlined},
    ];

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: scheme.surface,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(steps.length, (index) {
              final isActive = controller.currentStep.value == index;
              final isCompleted = controller.currentStep.value > index;
              return Row(
                children: [
                  GestureDetector(
                    onTap: () => controller.goToStep(index),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
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
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : steps[index]['icon'],
                            color: (isActive || isCompleted)
                                ? Colors.white
                                : scheme.onSurfaceVariant,
                            size: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[index]['title'],
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isActive
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < steps.length - 1)
                    Container(
                      width: 24,
                      height: 2,
                      margin: const EdgeInsets.only(
                        bottom: 18,
                        left: 4,
                        right: 4,
                      ),
                      color: isCompleted
                          ? Colors.green
                          : scheme.surfaceContainerHighest,
                    ),
                ],
              );
            }),
          ),
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

class BasicInformationStep extends StatelessWidget {
  final AdmissionController controller;
  final bool isMobile;
  const BasicInformationStep({
    super.key,
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
                      value: controller.selectedAcademicYear.value.isEmpty
                          ? null
                          : controller.selectedAcademicYear.value,
                      items: controller.academicYearList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) =>
                          controller.selectedAcademicYear.value = v ?? '',
                    ),
                  ),
                  Obx(
                    () => SearchableDropdown<String>(
                      label: 'GROUP *',
                      hint: 'Select Group',
                      isLoading: controller.isGroupLoading.value,
                      value: controller.selectedGroup.value.isEmpty
                          ? null
                          : controller.selectedGroup.value,
                      items: controller.groupList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) =>
                          controller.selectedGroup.value = v ?? '',
                    ),
                  ),
                ],
              ),
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  Obx(
                    () => SearchableDropdown<String>(
                      label: 'CLASS *',
                      hint: 'Select Class',
                      isLoading: controller.isClassLoading.value,
                      value: controller.selectedClass.value.isEmpty
                          ? null
                          : controller.selectedClass.value,
                      items: controller.classList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) =>
                          controller.selectedClass.value = v ?? '',
                    ),
                  ),
                  _buildTextField(
                    context,
                    'STUDENT NAME *',
                    controller.fullNameCtrl,
                    Icons.person_outline,
                    focusNode: controller.fullNameFocus,
                    nextFocusNode: controller.aadhaarFocus,
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
                      value: controller.selectedGender.value.isEmpty
                          ? null
                          : controller.selectedGender.value,
                      items: controller.genderList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) =>
                          controller.selectedGender.value = v ?? '',
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
                      value: controller.selectedReligion.value.isEmpty
                          ? null
                          : controller.selectedReligion.value,
                      items: controller.religionList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) =>
                          controller.selectedReligion.value = v ?? '',
                    ),
                  ),
                  Obx(
                    () => SearchableDropdown<String>(
                      label: 'CATEGORY',
                      hint: 'Select Category',
                      isLoading: controller.isCategoryLoading.value,
                      value: controller.selectedCategory.value.isEmpty
                          ? null
                          : controller.selectedCategory.value,
                      items: controller.categoryList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) =>
                          controller.selectedCategory.value = v ?? '',
                    ),
                  ),
                ],
              ),
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  Obx(
                    () => SearchableDropdown<String>(
                      label: 'CASTE',
                      hint: 'Select Caste',
                      isLoading: controller.isCasteLoading.value,
                      value: controller.selectedCaste.value.isEmpty
                          ? null
                          : controller.selectedCaste.value,
                      items: controller.casteList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) =>
                          controller.selectedCaste.value = v ?? '',
                    ),
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
                    focusNode: controller.aadhaarFocus,
                    nextFocusNode: controller.penNoFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                      _AadhaarFormatter(),
                    ],
                  ),
                  _buildTextField(
                    context,
                    'PEN NO',
                    controller.penNoCtrl,
                    Icons.assignment_ind_outlined,
                    focusNode: controller.penNoFocus,
                    nextFocusNode: controller.apaarIdFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                      _AadhaarFormatter(),
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
                    keyboardType: TextInputType.number,
                    Icons.fingerprint,
                    focusNode: controller.apaarIdFocus,
                    nextFocusNode: controller.fatherNameFocus,
                    // APAAR ID is a 12-digit number, same cap as Aadhaar/PEN.
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
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
            'PARENTAL INFORMATION',
            Icons.family_restroom_outlined,
            [
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  _buildTextField(
                    context,
                    'FATHER NAME *',
                    controller.fatherNameCtrl,
                    Icons.person_outline,
                    focusNode: controller.fatherNameFocus,
                    nextFocusNode: controller.fatherMobileFocus,
                  ),
                  _buildTextField(
                    context,
                    'FATHER MOBILE *',
                    controller.fatherMobileCtrl,
                    Icons.phone_android,
                    focusNode: controller.fatherMobileFocus,
                    nextFocusNode: controller.fatherOccupationFocus,
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
                    focusNode: controller.fatherOccupationFocus,
                    nextFocusNode: controller.motherNameFocus,
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
                    'MOTHER NAME *',
                    controller.motherNameCtrl,
                    Icons.person_outline,
                    focusNode: controller.motherNameFocus,
                    nextFocusNode: controller.motherMobileFocus,
                  ),
                  _buildTextField(
                    context,
                    'MOTHER MOBILE',
                    controller.motherMobileCtrl,
                    Icons.phone_android,
                    focusNode: controller.motherMobileFocus,
                    nextFocusNode: controller.motherOccupationFocus,
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
                    focusNode: controller.motherOccupationFocus,
                    nextFocusNode: controller.villageFocus,
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
                    'VILLAGE / MOHALLA *',
                    controller.villageCtrl,
                    Icons.home_outlined,
                    focusNode: controller.villageFocus,
                    nextFocusNode: controller.tehsilFocus,
                  ),
                  _buildTextField(
                    context,
                    'TEHSIL *',
                    controller.tehsilCtrl,
                    Icons.location_city_outlined,
                    focusNode: controller.tehsilFocus,
                    nextFocusNode: controller.districtFocus,
                  ),
                ],
              ),
              _ResponsiveRow(
                isMobile: isMobile,
                children: [
                  _buildTextField(
                    context,
                    'DISTRICT *',
                    controller.districtCtrl,
                    Icons.map_outlined,
                    focusNode: controller.districtFocus,
                    nextFocusNode: controller.stateFocus,
                  ),
                  _buildTextField(
                    context,
                    'STATE',
                    controller.stateCtrl,
                    Icons.public,
                    focusNode: controller.stateFocus,
                    nextFocusNode: controller.pinCodeFocus,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _GuardianDetailsStep extends StatelessWidget {
  final AdmissionController controller;
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
                () => RadioGroup<bool>(
                  groupValue: controller.isGuardianSameAsFather.value,
                  onChanged: (v) =>
                      controller.isGuardianSameAsFather.value = v ?? true,
                  child: Row(
                    children: [
                      Radio<bool>(value: true),
                      const Text('YES'),
                      const SizedBox(width: 24),
                      Radio<bool>(value: false),
                      const Text('NO'),
                    ],
                  ),
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
                            focusNode: controller.guardianNameFocus,
                            nextFocusNode: controller.guardianMobileFocus,
                          ),
                          _buildTextField(
                            context,
                            'GUARDIAN MOBILE',
                            controller.guardianMobileCtrl,
                            Icons.phone_android,
                            focusNode: controller.guardianMobileFocus,
                            nextFocusNode: controller.guardianOccupationFocus,
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
                            focusNode: controller.guardianOccupationFocus,
                            nextFocusNode: controller.guardianVillageFocus,
                          ),
                          _buildTextField(
                            context,
                            'VILLAGE / MOHALLA',
                            controller.guardianVillageCtrl,
                            Icons.home_outlined,
                            focusNode: controller.guardianVillageFocus,
                            nextFocusNode: controller.guardianTehsilFocus,
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
                            focusNode: controller.guardianTehsilFocus,
                            nextFocusNode: controller.guardianDistrictFocus,
                          ),
                          _buildTextField(
                            context,
                            'DISTRICT',
                            controller.guardianDistrictCtrl,
                            Icons.map_outlined,
                            focusNode: controller.guardianDistrictFocus,
                            nextFocusNode: controller.guardianStateFocus,
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
                            focusNode: controller.guardianStateFocus,
                            nextFocusNode: controller.guardianPinCodeFocus,
                          ),
                          _buildTextField(
                            context,
                            'PIN CODE',
                            controller.guardianPinCodeCtrl,
                            Icons.pin_drop_outlined,
                            focusNode: controller.guardianPinCodeFocus,
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

class _PreviousSchoolStep extends StatelessWidget {
  final AdmissionController controller;
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
                    focusNode: controller.prevSchoolNameFocus,
                    nextFocusNode: controller.prevClassFocus,
                  ),
                  _buildTextField(
                    context,
                    'PREVIOUS CLASS',
                    controller.prevClassCtrl,
                    Icons.class_outlined,
                    focusNode: controller.prevClassFocus,
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
  final AdmissionController controller;
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
              const SizedBox(height: 16),
              Obx(
                () => Visibility(
                  visible: !controller.generateSrNo.value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildTextField(
                      context,
                      'MANUAL SR NO',
                      controller.srNoCtrl,
                      Icons.tag,
                      keyboardType: TextInputType.number,
                      focusNode: controller.srNoFocus,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
              Obx(
                () => Visibility(
                  visible: controller.availTransport.value,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _ResponsiveRow(
                        isMobile: isMobile,
                        children: [
                          Obx(
                            () => SearchableDropdown<String>(
                              label: 'SELECT VEHICLE',
                              hint: 'Select Vehicle',
                              isLoading: controller.isVehicleLoading.value,
                              value: controller.selectedVehicle.value.isEmpty
                                  ? null
                                  : controller.selectedVehicle.value,
                              items: controller.vehicleList
                                  .map(
                                    (e) => SearchableDropdownItem(
                                      value: e,
                                      label: e,
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  controller.selectedVehicle.value = v ?? '',
                            ),
                          ),
                          Obx(
                            () => SearchableDropdown<String>(
                              label: 'SELECT ROUTE',
                              hint: 'Select Route',
                              isLoading: controller.isRouteLoading.value,
                              value: controller.selectedRoute.value.isEmpty
                                  ? null
                                  : controller.selectedRoute.value,
                              items: controller.routeList
                                  .map(
                                    (e) => SearchableDropdownItem(
                                      value: e,
                                      label: e,
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  controller.selectedRoute.value = v ?? '',
                            ),
                          ),
                        ],
                      ),
                      _ResponsiveRow(
                        isMobile: isMobile,
                        children: [
                          Obx(
                            () => SearchableDropdown<String>(
                              label: 'SELECT PICKUP POINT',
                              hint: 'Select Pickup Point',
                              isLoading: controller.isPickupLoading.value,
                              value:
                                  controller.selectedPickupPoint.value.isEmpty
                                  ? null
                                  : controller.selectedPickupPoint.value,
                              items: controller.pickupPointList
                                  .map(
                                    (e) => SearchableDropdownItem(
                                      value: e,
                                      label: e,
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  controller.selectedPickupPoint.value =
                                      v ?? '',
                            ),
                          ),
                          const SizedBox.shrink(),
                        ],
                      ),
                    ],
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
  final AdmissionController controller;
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
      final requiredDocs = AdmissionController.documents;
      final docNames = AdmissionController.documentNames;
      final docIcons = AdmissionController.documentIcons;

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
                          isRequired: false,
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
  final AdmissionController controller;
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
            height: 50,
            child: Obx(() {
              final isLast =
                  controller.currentStep.value == controller.totalSteps - 1;
              return Row(
                mainAxisSize: MainAxisSize.min,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                    icon: Icon(
                      isLast ? Icons.check_circle_rounded : Icons.arrow_forward,
                    ),
                    label: Text(
                      isLast
                          ? (isMobile ? 'Complete' : 'Complete Admission')
                          : 'SAVE & NEXT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
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
      if ((i + 1) % 4 == 0 && (i + 1) != 12 && (i + 1) < text.length) {
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
  FocusNode? focusNode,
  FocusNode? nextFocusNode,
  TextInputType? keyboardType,
  int maxLines = 1,
  bool readOnly = false,
  VoidCallback? onTap,
  List<TextInputFormatter>? inputFormatters,
}) {
  // Add UpperCaseTextFormatter to all text fields
  final formatters = <TextInputFormatter>[
    UpperCaseTextFormatter(),
    ...?inputFormatters,
  ];

  return TextFormField(
    controller: controller,
    focusNode: focusNode,
    keyboardType: keyboardType,
    maxLines: maxLines,
    readOnly: readOnly,
    onTap: onTap,
    inputFormatters: formatters,
    textInputAction: nextFocusNode != null
        ? TextInputAction.next
        : TextInputAction.done,
    onFieldSubmitted: nextFocusNode != null
        ? (_) => nextFocusNode.requestFocus()
        : null,
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
