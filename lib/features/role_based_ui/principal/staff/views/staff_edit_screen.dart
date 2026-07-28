import 'package:erp_management/core/constants/app_colors.dart';
import 'package:erp_management/core/models/category_model.dart';
import 'package:erp_management/core/widgets/custom_multi_dropdown.dart';
import 'package:erp_management/core/widgets/searchable_dropdown.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/service/document_upload_tile.dart';
import 'package:erp_management/features/role_based_ui/principal/admission/service/image_picker_service.dart';
import 'package:erp_management/features/role_based_ui/principal/staff/controllers/staff_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class StaffEditScreen extends StatelessWidget {
  const StaffEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StaffFormController c = Get.put(StaffFormController());
    final ImagePickerService picker = ImagePickerService();
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: scheme.surfaceContainerLowest,
        appBar: AppBar(
          title: Obx(
            () => Text(c.isEditMode.value ? 'Edit Staff' : 'Add Staff'),
          ),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Get.back(),
          ),
        ),
        body: Obx(() {
          if (c.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            controller: c.scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(context, 'BASIC DETAILS', Icons.person_outline, [
                  _field(
                    context,
                    'Name',
                    c.nameCtrl,
                    Icons.person_outline,
                    fieldKey: c.nameFieldKey,
                    required: true,
                  ),
                  // Married female → Husband Name field; everyone else →
                  // Father Name field. Both map to the API's FatherName.
                  Obx(
                    () => c.usesHusbandName
                        ? _field(
                            context,
                            'Husband Name',
                            c.husbandNameCtrl,
                            Icons.person_outline,
                          )
                        : _field(
                            context,
                            'Father Name',
                            c.fatherNameCtrl,
                            Icons.person_outline,
                          ),
                  ),
                  _field(
                    context,
                    'Mobile No',
                    c.mobileCtrl,
                    Icons.phone_android,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    fieldKey: c.mobileFieldKey,
                    required: true,
                  ),
                  _field(
                    context,
                    'Email',
                    c.emailCtrl,
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    fieldKey: c.emailFieldKey,
                    required: true,
                  ),
                  _field(
                    context,
                    'Qualification',
                    c.qualificationCtrl,
                    Icons.school_outlined,
                  ),
                  _field(
                    context,
                    'Date of Birth',
                    c.dobCtrl,
                    Icons.calendar_today,
                    readOnly: true,
                    onTap: () => c.pickDob(context),
                  ),
                ]),
                const SizedBox(height: 20),
                _section(context, 'PROFESSIONAL', Icons.work_outline, [
                  Obx(
                    () => SearchableDropdown<CategoryModel>(
                      key: c.designationFieldKey,
                      label: 'DESIGNATION *',
                      hint: 'Select Designation',
                      isLoading: c.isDesignationLoading.value,
                      value: c.selectedDesignation.value,
                      items: c.designationList
                          .map(
                            (d) => SearchableDropdownItem(
                              value: d,
                              label: d.name ?? '',
                            ),
                          )
                          .toList(),
                      onChanged: (v) => c.selectedDesignation.value = v,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => SearchableDropdown<CategoryModel>(
                      key: c.roleFieldKey,
                      label: 'ROLE *',
                      hint: 'Select Role',
                      isLoading: c.isRoleLoading.value,
                      value: c.selectedRole.value,
                      items: c.roleList
                          .map(
                            (r) => SearchableDropdownItem(
                              value: r,
                              label: r.name ?? '',
                            ),
                          )
                          .toList(),
                      onChanged: (v) => c.selectedRole.value = v,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => CustomMultiDropdown<CategoryModel>(
                      label: 'GROUP',
                      hint: c.isGroupLoading.value
                          ? 'Loading…'
                          : 'Select Group(s)',
                      enableSearch: true,
                      searchHint: 'Search group…',
                      selectedValues: c.selectedGroups.toList(),
                      items: c.groupList
                          .map(
                            (g) => DropdownMenuItem(
                              value: g,
                              child: Text(g.name ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => c.selectedGroups.assignAll(v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => CustomMultiDropdown<CategoryModel>(
                      label: 'CLASS',
                      hint: c.selectedGroups.isEmpty
                          ? 'Select group first'
                          : c.isClassLoading.value
                          ? 'Loading…'
                          : 'Select Class(es)',
                      enableSearch: true,
                      searchHint: 'Search class…',
                      selectedValues: c.selectedClasses.toList(),
                      items: c.classList
                          .map(
                            (cl) => DropdownMenuItem(
                              value: cl,
                              child: Text(cl.name ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => c.selectedClasses.assignAll(v),
                    ),
                  ),
                  // Class-teacher-of picker: only for teacher designations, and
                  // only lists the classes the user has already selected.
                  Obx(() {
                    if (!c.showClassTeacherOf || c.selectedClasses.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SearchableDropdown<CategoryModel>(
                        label: 'CLASS TEACHER OF',
                        hint: 'Select Class',
                        value: c.selectedClassTeacherOf.value,
                        items: c.selectedClasses
                            .map(
                              (cl) => SearchableDropdownItem(
                                value: cl,
                                label: cl.name ?? '',
                              ),
                            )
                            .toList(),
                        onChanged: (v) => c.selectedClassTeacherOf.value = v,
                      ),
                    );
                  }),
                ]),
                const SizedBox(height: 20),
                _section(context, 'PERSONAL', Icons.info_outline, [
                  Obx(
                    () => SearchableDropdown<String>(
                      key: c.genderFieldKey,
                      label: 'GENDER *',
                      hint: 'Select Gender',
                      value: c.gender.value.isEmpty ? null : c.gender.value,
                      items: c.genderList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) => c.gender.value = v ?? '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => SearchableDropdown<String>(
                      key: c.maritalFieldKey,
                      label: 'MARITAL STATUS *',
                      hint: 'Select',
                      value: c.maritalStatus.value.isEmpty
                          ? null
                          : c.maritalStatus.value,
                      items: c.maritalStatusList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) => c.maritalStatus.value = v ?? '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => SearchableDropdown<String>(
                      label: 'RELIGION',
                      hint: 'Select Religion',
                      value: c.religion.value.isEmpty ? null : c.religion.value,
                      items: c.religionList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) => c.religion.value = v ?? '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => SearchableDropdown<String>(
                      label: 'CATEGORY',
                      hint: 'Select Category',
                      value: c.caste.value.isEmpty ? null : c.caste.value,
                      items: c.casteList
                          .map(
                            (e) => SearchableDropdownItem(value: e, label: e),
                          )
                          .toList(),
                      onChanged: (v) => c.caste.value = v ?? '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    context,
                    'Sub Category',
                    c.subCasteCtrl,
                    Icons.category_outlined,
                  ),
                ]),
                const SizedBox(height: 20),
                _section(context, 'ADDRESS', Icons.location_on_outlined, [
                  _field(
                    context,
                    'Village / Mohalla',
                    c.villageCtrl,
                    Icons.home_outlined,
                  ),
                  _field(
                    context,
                    'Tehsil',
                    c.tehsilCtrl,
                    Icons.location_city_outlined,
                  ),
                  _field(
                    context,
                    'District',
                    c.districtCtrl,
                    Icons.map_outlined,
                  ),
                  _field(context, 'State', c.stateCtrl, Icons.public_outlined),
                ]),
                const SizedBox(height: 20),
                _buildDocuments(context, c, picker),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Obx(
                    () => FilledButton.icon(
                      onPressed: c.isSaving.value ? null : c.saveStaff,
                      icon: c.isSaving.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_rounded),
                      label: Text(
                        c.isSaving.value ? 'Saving...' : 'Save Staff',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDocuments(
    BuildContext context,
    StaffFormController c,
    ImagePickerService picker,
  ) {
    return Obx(
      () => _section(
        context,
        'DOCUMENTS',
        Icons.cloud_upload_outlined,
        StaffFormController.documentKeys.map((key) {
          return DocumentUploadTile(
            docKey: key,
            label: StaffFormController.documentNames[key]!,
            icon: StaffFormController.documentIcons[key]!,
            uploadedFile: c.uploadedFiles[key],
            isRequired: false,
            isUploading: false,
            uploadProgress: 0,
            onUpload: () => picker.showImagePickerOptions(
              context: context,
              onImageSelected: (file) => c.setUploadedFile(key, file),
            ),
            onRemove: () => c.removeUploadedFile(key),
          );
        }).toList(),
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _field(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    Key? fieldKey,
    bool required = false,
  }) {
    return Padding(
      key: fieldKey,
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          label: required
              ? Text.rich(
                  TextSpan(
                    text: label,
                    children: const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                )
              : null,
          labelText: required ? null : label,
          isDense: true,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
