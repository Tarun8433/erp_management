import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erp_management/core/constants/hardcode.dart';
import 'dart:developer';
import '../../../../../core/services/api/api_service.dart';
import '../../../../../core/services/api/endpoints.dart';
import '../../../../../core/widgets/common_dialog.dart';

class SignUpController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Text Controllers
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final dobController = TextEditingController();

  // Dropdown Selections
  final RxnString selectedUserType = RxnString();
  final RxnString selectedDepartment = RxnString();
  final RxnString selectedState = RxnString();
  final RxnString selectedCity = RxnString();
  final RxnString selectedPostalCode = RxnString();
  final RxList<String> selectedVendors = <String>[].obs;
  final RxList<String> selectedCustomers = <String>[].obs;
  final RxnString selectedCompany = RxnString();
  final RxList<String> selectedBranches = <String>[].obs;
  final RxList<String> selectedRoles = <String>[].obs;

  // Dropdown Data Lists
  final RxList<Map<String, String>> userTypes = <Map<String, String>>[].obs;
  final RxList<Map<String, String>> departments = <Map<String, String>>[].obs;
  final RxList<Map<String, String>> states = <Map<String, String>>[].obs;
  final RxList<Map<String, String>> cities = <Map<String, String>>[].obs;
  final RxList<Map<String, String>> postalCodes = <Map<String, String>>[].obs;
  final RxList<Map<String, String>> vendors = <Map<String, String>>[].obs;
  final RxList<Map<String, String>> customers = <Map<String, String>>[].obs;
  final RxList<Map<String, String>> companies = <Map<String, String>>[].obs;
  final RxList<Map<String, String>> branches = <Map<String, String>>[].obs;
  final RxList<Map<String, String>> roles = <Map<String, String>>[].obs;
  final RxList<Map<String, dynamic>> addedRoles = <Map<String, dynamic>>[].obs;

  // Other State
  var isPasswordVisible = false.obs;
  var currentStep = 0.obs;
  final int totalSteps = 3;

  // List State
  var isFormVisible = false.obs;
  final RxList<Map<String, dynamic>> userList = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingUsers = false.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Fetch users initially
    fetchUsers();

    // Initial fetches for dropdowns
    fetchUserTypes();
     fetchStates();
    
    fetchCompanies();

    // Listeners for dependent dropdowns
    ever(selectedState, (_) => fetchCities());
    ever(selectedCity, (_) => fetchPostalCodes());
    ever(selectedCompany, (_) {
      fetchBranches();
      fetchRoles();
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    dobController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // --- Navigation & List Management ---

  void showForm() {
    isFormVisible.value = true;
    currentStep.value = 0;
    // Clear form if needed
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    passwordController.clear();
    dobController.clear();
    selectedUserType.value = null;
    selectedDepartment.value = null;
    selectedState.value = null;
    selectedCity.value = null;
    selectedPostalCode.value = null;
    selectedVendors.clear();
    selectedCustomers.clear();
    selectedCompany.value = null;
    selectedBranches.clear();
    selectedRoles.clear();
    addedRoles.clear();
  }

  void clearForm() {
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    passwordController.clear();
    dobController.clear();

    selectedUserType.value = null;
    selectedDepartment.value = null;
    selectedState.value = null;
    selectedCity.value = null;
    selectedPostalCode.value = null;

    selectedVendors.clear();
    selectedCustomers.clear();
    selectedCompany.value = null;
    selectedBranches.clear();
    selectedRoles.clear();
    addedRoles.clear();

    currentStep.value = 0;
  }

  void hideForm() {
    isFormVisible.value = false;
  }

  Future<void> fetchUsers() async {
    try {
      isLoadingUsers.value = true;

      final body = {
        "page": 1,
        "limit": 25,
        "sortBy": "createdAt",
        "sortOrder": "desc",
        "include": {
          "company": {
            "select": {"nameCode": true},
          },
          "postalCode": {
            "select": {"code": true},
          },
          "state": {
            "select": {"nameCode": true},
          },
          "city": {
            "select": {"name": true},
          },
          "department": {
            "select": {"nameCode": true},
          },
          "userVendor": {
            "select": {
              "vendorId": true,
              "vendor": {
                "select": {"nameCode": true, "id": true},
              },
            },
          },
          "userCustomer": {
            "select": {
              "customerId": true,
              "customer": {
                "select": {"nameCode": true, "id": true},
              },
            },
          },
          "userCompany": {
            "select": {
              "companyId": true,
              "company": {
                "select": {
                  "name": true,
                  "email": true,
                  "legalName": true,
                  "nameCode": true,
                },
              },
              "userBranch": {
                "select": {
                  "id": true,
                  "branchId": true,
                  "branch": {
                    "select": {
                      "id": true,
                      "branchName": true,
                      "branchCode": true,
                      "nameCode": true,
                    },
                  },
                },
              },
              "userRole": {
                "select": {
                  "roleId": true,
                  "role": {
                    "select": {
                      "id": true,
                      "roleName": true,
                      "nameCode": true,
                      "roleComponent": {
                        "select": {
                          "componentId": true,
                          "action": true,
                          "hasAccess": true,
                          "component": {
                            "select": {
                              "id": true,
                              "moduleName": true,
                              "componentName": true,
                              "componentType": true,
                              "description": true,
                              "parentId": true,
                              "routeLink": true,
                              "icon": true,
                              "orderNo": true,
                            },
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      };

      final response = await _apiService.postJson(Endpoints.searchUser(), body);

      if (response != null && response['status'] == 'success') {
        if (response['data'] != null && response['data']['data'] != null) {
          final list = response['data']['data'] as List;
          userList.assignAll(list.cast<Map<String, dynamic>>());
        }
      }
    } catch (e) {
      log("Error fetching users: $e");
    } finally {
      isLoadingUsers.value = false;
    }
  }

  // --- Form Logic ---

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      currentStep.value = step;
    }
  }

  void nextStep() {
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  bool validateStep(int step) {
    switch (step) {
      case 0: // Basic Info
        return selectedUserType.value != null &&
            nameController.text.isNotEmpty &&
            mobileController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            passwordController.text.isNotEmpty;
      case 1: // Address & Work
        return selectedDepartment.value != null &&
            selectedState.value != null &&
            selectedCity.value != null &&
            selectedPostalCode.value != null;
      case 2: // Company
        return addedRoles.isNotEmpty;
      default:
        return false;
    }
  }

  bool validateAll() {
    return validateStep(0) && validateStep(1) && validateStep(2);
  }

  void addRole() {
    if (selectedCompany.value == null ||
        selectedBranches.isEmpty ||
        selectedRoles.isEmpty) {
      showCommonDialog(
        title: 'Error',
        message: 'Please select Company, Branch and Role',
        isError: true,
      );
      return;
    }

    // Get company name
    final companyName =
        companies.firstWhereOrNull(
          (e) => e['id'] == selectedCompany.value,
        )?['name'] ??
        '';

    // Get selected branches
    final selectedBranchList = branches
        .where((e) => selectedBranches.contains(e['id']))
        .map((e) => {'id': e['id'], 'name': e['name']})
        .toList();

    // Get selected roles
    final selectedRoleList = roles
        .where((e) => selectedRoles.contains(e['id']))
        .map((e) => {'id': e['id'], 'name': e['name']})
        .toList();

    addedRoles.add({
      'companyId': selectedCompany.value,
      'companyName': companyName,
      'branches': selectedBranchList,
      'roles': selectedRoleList,
    });

    // Reset selections
    selectedCompany.value = null;
    selectedBranches.clear();
    selectedRoles.clear();
  }

  void removeRole(int index) {
    addedRoles.removeAt(index);
  }

  void onSignUp() {
    for (int i = 0; i < totalSteps; i++) {
      if (!validateStep(i)) {
        currentStep.value = i; // Jump to the invalid step
        showCommonDialog(
          title: 'Missing Fields',
          message: 'Please complete step ${i + 1} before submitting.',
          isError: true,
        );
        return;
      }
    }

    _registerUser();
  }

  Future<void> _registerUser() async {
    try {
      isSubmitting.value = true;

      // Parse DOB to ISO format
      String dobISO = "";
      if (dobController.text.isNotEmpty) {
        try {
          final parts = dobController.text.split('-');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            // Use UTC to ensure 'Z' suffix is added for backend compatibility
            dobISO = DateTime.utc(year, month, day).toIso8601String();
          }
        } catch (e) {
          log("Error parsing DOB: $e");
        }
      }

      final body = {
        "userType": selectedUserType.value?.toUpperCase(),
        "name": nameController.text,
        "mobile": mobileController.text,
        "email": emailController.text,
        "pwdHash": passwordController.text, // Corrected field name
        "dob": dobISO,
        "departmentId": selectedDepartment.value,
        "stateId": selectedState.value,
        "cityId": selectedCity.value,
        "postalCodeId": selectedPostalCode.value,
        "userCompany": addedRoles
            .map(
              (e) => {
                // Corrected field name
                "companyId": e['companyId'],
                "userBranch": (e['branches'] as List)
                    .map((b) => b['id'])
                    .toList(), // Corrected field name
                "userRole": (e['roles'] as List)
                    .map((r) => r['id'])
                    .toList(), // Corrected field name
              },
            )
            .toList(),
      };

      // Add conditional fields based on user type
      if (selectedUserType.value?.toUpperCase() == 'VENDOR') {
        if (selectedVendors.isNotEmpty) {
          body['vendorId'] = selectedVendors.first; // Primary vendor
          body['userVendor'] = selectedVendors;
        }
      } else if (selectedUserType.value?.toUpperCase() == 'CUSTOMER') {
        if (selectedCustomers.isNotEmpty) {
          body['customerId'] = selectedCustomers.first; // Primary customer
          body['userCustomer'] = selectedCustomers;
        }
      }

      final response = await _apiService.postJson(Endpoints.register(), body);

      if (response != null &&
          (response['status'] == 'success' || response['status'] == true)) {
        showCommonDialog(
          title: 'Success',
          message: 'Account created successfully.',
          isError: false,
          onConfirm: () {
            hideForm();
            fetchUsers();
          },
        );
      } else {
        showCommonDialog(
          title: 'Error',
          message: response?['message'] ?? 'Failed to create account',
          isError: true,
        );
      }
    } catch (e) {
      log("Error creating account: $e");
      showCommonDialog(
        title: 'Error',
        message: 'An error occurred: $e',
        isError: true,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> fetchUserTypes() async {
    // Use local enum values instead of API
    userTypes.assignAll(
      UserType.values.map((e) {
        String name = e.name;
        // Capitalize first letter
        name = name[0].toUpperCase() + name.substring(1);
        return {"id": e.name, "name": name};
      }).toList(),
    );
  }

 
  Future<void> fetchStates() async {
    try {
      final uri = Endpoints.searchState();
      final body = {"page": 1, "limit": 100};
      final response = await _apiService.postJson(uri, body);
      if (response != null) {
        if (response['data'] != null) {
          final list = response['data']['data'] as List;
          states.assignAll(
            list
                .map(
                  (e) => {
                    "id": e['id'].toString(),
                    "name": e['name'].toString(),
                  },
                )
                .toList(),
          );
        } else if (response['status'] == 'error') {
          log("Error fetching states: ${response['message']}");
        }
      }
    } catch (e) {
      log("Error fetching states: $e");
    }
  }

  Future<void> fetchCities() async {
    if (selectedState.value == null) return;
    try {
      final uri = Endpoints.searchCity();
      // Updated body structure based on working curl command
      final body = {
        "sortBy": "name",
        "sortOrder": "asc",
        "filters": {
          "stateId": {"equals": selectedState.value},
        },
      };
      final response = await _apiService.postJson(uri, body);
      if (response != null) {
        if (response['data'] != null) {
          final list = response['data']['data'] as List;
          cities.assignAll(
            list
                .map(
                  (e) => {
                    "id": e['id'].toString(),
                    "name": e['name'].toString(),
                  },
                )
                .toList(),
          );
        } else if (response['status'] == 'error') {
          log("Error fetching cities: ${response['message']}");
        }
      }
    } catch (e) {
      log("Error fetching cities: $e");
    }
  }

  Future<void> fetchPostalCodes() async {
    if (selectedCity.value == null) return;
    try {
      final uri = Endpoints.searchPostalCode();
      // Updated body structure based on working curl command
      final body = {
        "include": {
          "area": {
            "orderBy": {"code": "asc"},
          },
        },
        "filters": {
          "cityId": {"equals": selectedCity.value},
        },
      };
      final response = await _apiService.postJson(uri, body);
      if (response != null) {
        if (response['data'] != null) {
          final list = response['data']['data'] as List;
          final List<Map<String, String>> areaList = [];
          for (var item in list) {
            if (item['area'] != null) {
              for (var area in item['area']) {
                areaList.add({
                  "id": area['id'].toString(),
                  "name": "${area['code']} - ${area['name']}",
                });
              }
            }
          }
          postalCodes.assignAll(areaList);
        } else if (response['status'] == 'error') {
          log("Error fetching postal codes: ${response['message']}");
        }
      }
    } catch (e) {
      log("Error fetching postal codes: $e");
    }
  }

 

  

  Future<void> fetchCompanies() async {
    try {
      final uri = Endpoints.searchCompany();
      final body = {"page": 1, "limit": 100};
      final response = await _apiService.postJson(uri, body);
      if (response != null && response['data'] != null) {
        final list = response['data']['data'] as List;
        companies.assignAll(
          list
              .map(
                (e) => {"id": e['id'].toString(), "name": e['name'].toString()},
              )
              .toList(),
        );
      }
    } catch (e) {
      log("Error fetching companies: $e");
    }
  }

  Future<void> fetchBranches() async {
    if (selectedCompany.value == null) return;
    try {
      final uri = Endpoints.searchBranch();
      final body = {
        "sortBy": "nameCode",
        "sortOrder": "asc",
        "filters": {
          "companyId": {"equals": selectedCompany.value},
        },
      };
      final response = await _apiService.postJson(uri, body);
      if (response != null && response['data'] != null) {
        final list = response['data']['data'] as List;
        branches.assignAll(
          list
              .map(
                (e) => {
                  "id": e['id'].toString(),
                  "name":
                      e['nameCode']?.toString() ?? e['branchName'].toString(),
                },
              )
              .toList(),
        );
      }
    } catch (e) {
      log("Error fetching branches: $e");
    }
  }

  Future<void> fetchRoles() async {
    try {
      final uri = Endpoints.searchRole();
      final body = {"page": 1, "limit": 100};
      final response = await _apiService.postJson(uri, body);
      if (response != null && response['data'] != null) {
        final list = response['data']['data'] as List;
        roles.assignAll(
          list
              .map(
                (e) => {
                  "id": e['id'].toString(),
                  "name": e['roleName'].toString(),
                },
              )
              .toList(),
        );
      }
    } catch (e) {
      log("Error fetching roles: $e");
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text =
          "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
    }
  }

  // --- Actions ---

  void onLogin() {
    Get.back();
  }

  void onGoogleSignUp() {
    // Implement Google sign up
  }

  void onAppleSignUp() {
    // Implement Apple sign up
  }
}
