import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/gc_request_model.dart';
import '../data/repositories/cn_repository.dart';

class CnController extends GetxController {
  final CnRepository _repository;

  CnController({CnRepository? repository})
      : _repository = repository ?? CnRepository();

  // Form fields
  final remarksController = TextEditingController();
  final loadWeightController = TextEditingController();
  final riskCoverAmountController = TextEditingController();

  // Observable state
  final isSaving = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  // Form data passed from the booking request context
  late String bookingRequestId;
  late String gcTypeId;
  late String customerId;
  late String customerCode;
  late String customerName;
  late String transportServiceTypeId;
  late List<String> transportSubService;
  late String consignorId;
  late String consignorCode;
  late String consignorName;
  late String consignorAddress;
  late String consigneeId;
  late String consigneeName;
  late String consigneeAddress;
  late String consigneeCode;
  late String consigneeEmail;
  late String consigneeMobile;
  late String customerContractId;
  late String servingBranchId;
  late String deliveryBranchId;
  late String vehicleTypeId;
  late String bookingBranchId;
  late String riskCoverId;
  late List<BookingServiceItem> bookingService;
  late List<ShipmentDetail> shipmentDetails;
  late List<InstructionItem> instructions;
  late List<Map<String, dynamic>> bookingJobs;

  // Date/time state
  final gcDate = Rx<DateTime>(DateTime.now());
  final pickupDateTime = Rx<DateTime>(DateTime.now());
  final edd = Rx<DateTime>(DateTime.now().add(const Duration(days: 1)));
  final rdd = Rx<DateTime>(DateTime.now().add(const Duration(days: 2)));
  final needPickup = false.obs;
  final pickupByConsignee = true.obs;
  final loadWeightUom = 'Kilogram (kg)'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
  }

  void _loadArguments() {
    final args = Get.arguments;
    if (args == null || args is! Map<String, dynamic>) return;

    bookingRequestId = args['bookingRequestId'] as String? ?? '';
    gcTypeId = args['gcTypeId'] as String? ?? '';
    customerId = args['customerId'] as String? ?? '';
    customerCode = args['customerCode'] as String? ?? '';
    customerName = args['customerName'] as String? ?? '';
    transportServiceTypeId = args['transportServiceTypeId'] as String? ?? '';
    transportSubService =
        List<String>.from(args['transportSubService'] as List? ?? []);
    consignorId = args['consignorId'] as String? ?? '';
    consignorCode = args['consignorCode'] as String? ?? '';
    consignorName = args['consignorName'] as String? ?? '';
    consignorAddress = args['consignorAddress'] as String? ?? '';
    consigneeId = args['consigneeId'] as String? ?? '';
    consigneeName = args['consigneeName'] as String? ?? '';
    consigneeAddress = args['consigneeAddress'] as String? ?? '';
    consigneeCode = args['consigneeCode'] as String? ?? '';
    consigneeEmail = args['consigneeEmail'] as String? ?? '';
    consigneeMobile = args['consigneeMobile'] as String? ?? '';
    customerContractId = args['customerContractId'] as String? ?? '';
    servingBranchId = args['servingBranchId'] as String? ?? '';
    deliveryBranchId = args['deliveryBranchId'] as String? ?? '';
    vehicleTypeId = args['vehicleTypeId'] as String? ?? '';
    bookingBranchId = args['bookingBranchId'] as String? ?? '';
    riskCoverId = args['riskCoverId'] as String? ?? '';

    final rawServices = args['BookingService'] as List? ?? [];
    bookingService = rawServices
        .map((e) => BookingServiceItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final rawShipments = args['shipmentDetails'] as List? ?? [];
    shipmentDetails = rawShipments
        .map((e) => ShipmentDetail.fromJson(e as Map<String, dynamic>))
        .toList();

    final rawInstructions = args['instructions'] as List? ?? [];
    instructions = rawInstructions
        .map((e) => InstructionItem.fromJson(e as Map<String, dynamic>))
        .toList();

    bookingJobs =
        List<Map<String, dynamic>>.from(args['bookingJobs'] as List? ?? []);

    if (args['loadWeight'] != null) {
      loadWeightController.text = args['loadWeight'].toString();
    }
    if (args['riskCoverAmount'] != null) {
      riskCoverAmountController.text = args['riskCoverAmount'].toString();
    }
    if (args['loadWeightUom'] != null) {
      loadWeightUom.value = args['loadWeightUom'] as String;
    }
    if (args['remarks'] != null) {
      remarksController.text = args['remarks'] as String;
    }
  }

  Future<void> saveCn() async {
    if (isSaving.value) return;

    final loadWeight = double.tryParse(loadWeightController.text.trim());
    final riskCover = double.tryParse(riskCoverAmountController.text.trim());

    if (loadWeight == null || loadWeight <= 0) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid load weight.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (riskCover == null || riskCover < 0) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid risk cover amount.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSaving.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final model = GcRequestModel(
        bookingRequestId: bookingRequestId,
        gcTypeId: gcTypeId,
        gcDate: gcDate.value.toUtc().toIso8601String(),
        loadWeightUom: loadWeightUom.value,
        loadWeight: loadWeight,
        riskCoverAmount: riskCover,
        remarks: remarksController.text.trim(),
        pickupDateTime: pickupDateTime.value.toUtc().toIso8601String(),
        customerCode: customerCode,
        customerName: customerName,
        customerId: customerId,
        transportServiceTypeId: transportServiceTypeId,
        transportSubService: transportSubService,
        consignorId: consignorId,
        consignorCode: consignorCode,
        consignorName: consignorName,
        consignorAddress: consignorAddress,
        consigneeId: consigneeId,
        consigneeName: consigneeName,
        consigneeAddress: consigneeAddress,
        consigneeCode: consigneeCode,
        consigneeEmail: consigneeEmail,
        consigneeMobile: consigneeMobile,
        customerContractId: customerContractId,
        edd: edd.value.toUtc().toIso8601String(),
        needPickup: needPickup.value,
        pickupByConsignee: pickupByConsignee.value,
        servingBranchId: servingBranchId,
        deliveryBranchId: deliveryBranchId,
        vehicleTypeId: vehicleTypeId,
        bookingBranchId: bookingBranchId,
        rdd: rdd.value.toUtc().toIso8601String(),
        riskCoverId: riskCoverId,
        bookingService: bookingService,
        charge: const [],
        articles: const [],
        instructions: instructions,
        shipmentDetails: shipmentDetails,
        invoice: const [],
        bookingJobs: bookingJobs,
      );

      final response = await _repository.addGc(model);
      successMessage.value = 'CN created successfully.';
      Get.snackbar(
        'Success',
        'CN created successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back(result: response);
    } catch (e) {
      errorMessage.value = _friendlyError(e);
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  String _friendlyError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Failed host lookup')) {
      return 'No internet connection. Please check your network.';
    }
    if (msg.contains('401')) return 'Session expired. Please log in again.';
    if (msg.contains('400')) return 'Invalid data. Please check your inputs.';
    return 'Something went wrong. Please try again.';
  }

  @override
  void onClose() {
    remarksController.dispose();
    loadWeightController.dispose();
    riskCoverAmountController.dispose();
    super.onClose();
  }
}
