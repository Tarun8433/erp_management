import 'dart:io';
import 'package:erp_management/core/widgets/searchable_dropdown.dart';
import 'package:erp_management/features/role_based_ui/principal/add_student/controllers/add_student_controller.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/service/image_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddStudentScreen extends GetView<AddStudentController> {
  const AddStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final ImagePickerService imagePickerService = ImagePickerService();

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
        body: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormSection(
                theme,
                scheme,
                'STUDENT INFORMATION',
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
                              .map((e) => SearchableDropdownItem(value: e, label: e))
                              .toList(),
                          onChanged: (v) => controller.selectedAcademicYear.value = v ?? '',
                        ),
                      ),
                      Obx(
                        () => SearchableDropdown<String>(
                          label: 'GROUP *',
                          hint: 'Select Group',
                          value: controller.selectedGroup.value.isEmpty
                              ? null
                              : controller.selectedGroup.value,
                          items: controller.groupList
                              .map((e) => SearchableDropdownItem(value: e, label: e))
                              .toList(),
                          onChanged: (v) => controller.selectedGroup.value = v ?? '',
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
                          value: controller.selectedClass.value.isEmpty
                              ? null
                              : controller.selectedClass.value,
                          items: controller.classList
                              .map((e) => SearchableDropdownItem(value: e, label: e))
                              .toList(),
                          onChanged: (v) => controller.selectedClass.value = v ?? '',
                        ),
                      ),
                      _buildTextField(
                        context,
                        'STUDENT FULL NAME *',
                        controller.fullNameCtrl,
                        Icons.person_outline,
                      ),
                    ],
                  ),
                  _ResponsiveRow(
                    isMobile: isMobile,
                    children: [
                      _buildTextField(
                        context,
                        'S.R.NO',
                        controller.srNoCtrl,
                        Icons.numbers_outlined,
                      ),
                      _buildTextField(
                        context,
                        'EMAIL ID (OPTIONAL)',
                        controller.emailCtrl,
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
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
                        Icons.calendar_month_outlined,
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
                              .map((e) => SearchableDropdownItem(value: e, label: e))
                              .toList(),
                          onChanged: (v) => controller.selectedGender.value = v ?? '',
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
                'IDENTITY & DEMOGRAPHICS',
                Icons.badge_outlined,
                [
                  _ResponsiveRow(
                    isMobile: isMobile,
                    children: [
                      _buildTextField(
                        context,
                        'AADHAAR NUMBER',
                        controller.aadhaarCtrl,
                        Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                      ),
                      _buildTextField(
                        context,
                        'PEN NO',
                        controller.penNoCtrl,
                        Icons.assignment_ind_outlined,
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
                        Icons.fingerprint_outlined,
                      ),
                      Obx(
                        () => SearchableDropdown<String>(
                          label: 'RELIGION',
                          hint: 'Select Religion',
                          value: controller.selectedReligion.value.isEmpty
                              ? null
                              : controller.selectedReligion.value,
                          items: controller.religionList
                              .map((e) => SearchableDropdownItem(value: e, label: e))
                              .toList(),
                          onChanged: (v) => controller.selectedReligion.value = v ?? '',
                        ),
                      ),
                    ],
                  ),
                  _ResponsiveRow(
                    isMobile: isMobile,
                    children: [
                      Obx(
                        () => SearchableDropdown<String>(
                          label: 'CATEGORY',
                          hint: 'Select Category',
                          value: controller.selectedCategory.value.isEmpty
                              ? null
                              : controller.selectedCategory.value,
                          items: controller.categoryList
                              .map((e) => SearchableDropdownItem(value: e, label: e))
                              .toList(),
                          onChanged: (v) => controller.selectedCategory.value = v ?? '',
                        ),
                      ),
                      Obx(
                        () => SearchableDropdown<String>(
                          label: 'SUBCATEGORY',
                          hint: 'Select Subcategory',
                          value: controller.selectedSubCategory.value.isEmpty
                              ? null
                              : controller.selectedSubCategory.value,
                          items: controller.subCategoryList
                              .map((e) => SearchableDropdownItem(value: e, label: e))
                              .toList(),
                          onChanged: (v) => controller.selectedSubCategory.value = v ?? '',
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
                'ADDRESS DETAILS',
                Icons.location_on_outlined,
                [
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
                        'VILLAGE / MOHALLA',
                        controller.villageCtrl,
                        Icons.home_outlined,
                      ),
                      _buildPhotoUpload(context, imagePickerService),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFormSection(
                theme,
                scheme,
                'PARENT DETAILS',
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
                        'MOTHER NAME *',
                        controller.motherNameCtrl,
                        Icons.person_outline,
                      ),
                    ],
                  ),
                  _ResponsiveRow(
                    isMobile: isMobile,
                    children: [
                      _buildTextField(
                        context,
                        'MOBILE NUMBER',
                        controller.mobileNoCtrl,
                        Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerRight,
                child: Obx(
                  () => FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 24 : 40,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: controller.isSubmitting.value ? null : () => controller.saveStudent(),
                    icon: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_rounded),
                    label: Text(
                      'SAVE STUDENT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
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
    bool readOnly = false,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
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
      ),
    );
  }

  Widget _buildPhotoUpload(BuildContext context, ImagePickerService service) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STUDENT PHOTO (OPTIONAL)',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            height: 52,
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    service.showImagePickerOptions(
                      context: context,
                      onImageSelected: (file) => controller.setStudentPhoto(file),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                      border: Border(right: BorderSide(color: theme.dividerColor)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Choose File',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.studentPhoto.value != null
                        ? controller.studentPhoto.value!.path.split('/').last
                        : 'No file selected',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (controller.studentPhoto.value != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () => controller.removeStudentPhoto(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final bool isMobile;
  const _ResponsiveRow({required this.children, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 16), child: w)).toList(),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
