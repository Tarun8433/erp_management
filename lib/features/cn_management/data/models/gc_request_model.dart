class BookingServiceItem {
  final String serviceId;
  final String subServiceId;
  final List<String> bookingServiceJob;
  final bool isReadOnly;
  final String? startDate;
  final String? endDate;

  const BookingServiceItem({
    required this.serviceId,
    required this.subServiceId,
    required this.bookingServiceJob,
    required this.isReadOnly,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
    'serviceId': serviceId,
    'subServiceId': subServiceId,
    'bookingServiceJob': bookingServiceJob,
    'isReadOnly': isReadOnly,
    'startDate': startDate,
    'endDate': endDate,
  };

  factory BookingServiceItem.fromJson(Map<String, dynamic> json) =>
      BookingServiceItem(
        serviceId: json['serviceId'] as String,
        subServiceId: json['subServiceId'] as String,
        bookingServiceJob: List<String>.from(json['bookingServiceJob'] as List),
        isReadOnly: json['isReadOnly'] as bool? ?? false,
        startDate: json['startDate'] as String?,
        endDate: json['endDate'] as String?,
      );
}

class ShipmentDetail {
  final String ghuid;
  final String ghuDescription;
  final String ghuSrNo;
  final String ghuName;
  final String ghuCode;
  final int quantity;
  final double weight;
  final double totalWeight;
  final String dimensions;
  final double totalVolume;
  final String materialId;
  final double goodsValue;
  final String hsnCode;
  final bool isHazardous;

  const ShipmentDetail({
    required this.ghuid,
    required this.ghuDescription,
    required this.ghuSrNo,
    required this.ghuName,
    required this.ghuCode,
    required this.quantity,
    required this.weight,
    required this.totalWeight,
    required this.dimensions,
    required this.totalVolume,
    required this.materialId,
    required this.goodsValue,
    required this.hsnCode,
    required this.isHazardous,
  });

  Map<String, dynamic> toJson() => {
    'ghuid': ghuid,
    'ghuDescription': ghuDescription,
    'ghuSrNo': ghuSrNo,
    'ghuName': ghuName,
    'ghuCode': ghuCode,
    'quantity': quantity,
    'weight': weight,
    'totalWeight': totalWeight,
    'dimensions': dimensions,
    'totalVolume': totalVolume,
    'materialId': materialId,
    'goodsValue': goodsValue,
    'hsnCode': hsnCode,
    'isHazardous': isHazardous,
  };

  factory ShipmentDetail.fromJson(Map<String, dynamic> json) => ShipmentDetail(
    ghuid: json['ghuid'] as String,
    ghuDescription: json['ghuDescription'] as String,
    ghuSrNo: json['ghuSrNo'] as String,
    ghuName: json['ghuName'] as String,
    ghuCode: json['ghuCode'] as String,
    quantity: (json['quantity'] as num).toInt(),
    weight: (json['weight'] as num).toDouble(),
    totalWeight: (json['totalWeight'] as num).toDouble(),
    dimensions: json['dimensions'] as String,
    totalVolume: (json['totalVolume'] as num).toDouble(),
    materialId: json['materialId'] as String,
    goodsValue: (json['goodsValue'] as num).toDouble(),
    hsnCode: json['hsnCode'] as String,
    isHazardous: json['isHazardous'] as bool? ?? false,
  );
}

class InstructionItem {
  final String instructionType;
  final String instructionName;
  final String description;
  final bool isAutoPopulated;

  const InstructionItem({
    required this.instructionType,
    required this.instructionName,
    required this.description,
    required this.isAutoPopulated,
  });

  Map<String, dynamic> toJson() => {
    'instructionType': instructionType,
    'instructionName': instructionName,
    'description': description,
    'isAutoPopulated': isAutoPopulated,
  };

  factory InstructionItem.fromJson(Map<String, dynamic> json) =>
      InstructionItem(
        instructionType: json['instructionType'] as String,
        instructionName: json['instructionName'] as String,
        description: json['description'] as String,
        isAutoPopulated: json['isAutoPopulated'] as bool? ?? false,
      );
}

class GcRequestModel {
  final String bookingRequestId;
  final String gcTypeId;
  final String gcDate;
  final String loadWeightUom;
  final double loadWeight;
  final double riskCoverAmount;
  final String remarks;
  final String pickupDateTime;
  final String customerCode;
  final String customerName;
  final String customerId;
  final String transportServiceTypeId;
  final List<String> transportSubService;
  final String consignorId;
  final String consignorCode;
  final String consignorName;
  final String consignorAddress;
  final String consigneeId;
  final String consigneeName;
  final String consigneeAddress;
  final String consigneeCode;
  final String consigneeEmail;
  final String consigneeMobile;
  final String customerContractId;
  final String edd;
  final bool needPickup;
  final bool pickupByConsignee;
  final String servingBranchId;
  final String deliveryBranchId;
  final String vehicleTypeId;
  final String bookingBranchId;
  final String rdd;
  final String riskCoverId;
  final List<BookingServiceItem> bookingService;
  final List<Map<String, dynamic>> charge;
  final List<Map<String, dynamic>> articles;
  final List<InstructionItem> instructions;
  final List<ShipmentDetail> shipmentDetails;
  final List<Map<String, dynamic>> invoice;
  final List<Map<String, dynamic>> bookingJobs;

  const GcRequestModel({
    required this.bookingRequestId,
    required this.gcTypeId,
    required this.gcDate,
    required this.loadWeightUom,
    required this.loadWeight,
    required this.riskCoverAmount,
    required this.remarks,
    required this.pickupDateTime,
    required this.customerCode,
    required this.customerName,
    required this.customerId,
    required this.transportServiceTypeId,
    required this.transportSubService,
    required this.consignorId,
    required this.consignorCode,
    required this.consignorName,
    required this.consignorAddress,
    required this.consigneeId,
    required this.consigneeName,
    required this.consigneeAddress,
    required this.consigneeCode,
    required this.consigneeEmail,
    required this.consigneeMobile,
    required this.customerContractId,
    required this.edd,
    required this.needPickup,
    required this.pickupByConsignee,
    required this.servingBranchId,
    required this.deliveryBranchId,
    required this.vehicleTypeId,
    required this.bookingBranchId,
    required this.rdd,
    required this.riskCoverId,
    required this.bookingService,
    required this.charge,
    required this.articles,
    required this.instructions,
    required this.shipmentDetails,
    required this.invoice,
    required this.bookingJobs,
  });

  Map<String, dynamic> toJson() => {
    'bookingRequestId': bookingRequestId,
    'gcTypeId': gcTypeId,
    'gcDate': gcDate,
    'loadWeightUom': loadWeightUom,
    'loadWeight': loadWeight,
    'riskCoverAmount': riskCoverAmount,
    'remarks': remarks,
    'pickupDateTime': pickupDateTime,
    'customerCode': customerCode,
    'customerName': customerName,
    'customerId': customerId,
    'transportServiceTypeId': transportServiceTypeId,
    'transportSubService': transportSubService,
    'consignorId': consignorId,
    'consignorCode': consignorCode,
    'consignorName': consignorName,
    'consignorAddress': consignorAddress,
    'consigneeId': consigneeId,
    'consigneeName': consigneeName,
    'consigneeAddress': consigneeAddress,
    'consigneeCode': consigneeCode,
    'consigneeEmail': consigneeEmail,
    'consigneeMobile': consigneeMobile,
    'customerContractId': customerContractId,
    'edd': edd,
    'needPickup': needPickup,
    'pickupByConsignee': pickupByConsignee,
    'servingBranchId': servingBranchId,
    'deliveryBranchId': deliveryBranchId,
    'vehicleTypeId': vehicleTypeId,
    'bookingBranchId': bookingBranchId,
    'rdd': rdd,
    'riskCoverId': riskCoverId,
    'BookingService': bookingService.map((s) => s.toJson()).toList(),
    'Charge': charge,
    'articles': articles,
    'instructions': instructions.map((i) => i.toJson()).toList(),
    'shipmentDetails': shipmentDetails.map((s) => s.toJson()).toList(),
    'invoice': invoice,
    'bookingJobs': bookingJobs,
  };
}
