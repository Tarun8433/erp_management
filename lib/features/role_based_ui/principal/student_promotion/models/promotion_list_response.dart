class PromotionListResponse {
  String? rollNumber;
  String? className;
  String? admissionNo;
  String? branchAddress;
  String? previousSchool;
  String? session;
  String? groupName;
  int? studentTypeId;
  int? studentClassTableId;
  bool? isPromoted;
  String? qrCode;
  bool? isActive;
  String? finishedPhoto;
  String? dateOfPromotion;
  String? promotedClass;
  String? feesRecords;
  List<dynamic>? subjectList;
  String? subjectListJson;
  String? modifyOn;
  String? modifiedBy;
  String? includedFields;
  String? templateName;
  String? classTeacher;
  String? examIncharge;
  String? principal;
  String? backTemplate;
  String? printselection;
  bool? sectionUpdated;
  int? parentUserId;
  bool? isGenerateSRNo;
  int? branchId;
  String? sid;
  String? srno;
  String? schoolName;
  String? firstName;
  String? middleName;
  String? lastName;
  String? emailId;
  int? userId;
  String? dob;
  String? religion;
  String? motherName;
  String? motherMobile;
  String? motherOccupation;
  String? fatherName;
  String? fatherMobile;
  String? fatherOccupation;
  String? photo;
  String? fatherAadharCard;
  String? fatherAadharCardBack;
  String? incomeCertificate;
  String? aadharCard;
  String? motherAadharCard;
  String? motherAadharCardBack;
  String? castCertificate;
  String? nationalityCertificate;
  String? transferCertificate;
  int? groupId;
  int? classId;
  int? sessionId;
  String? address;
  int? postalCode;
  String? gender;
  String? uid;
  String? entryOn;
  int? routeId;
  int? pickUpId;
  int? vehicleId;
  int? transportMonthId;
  String? district;
  String? tehsil;
  String? category;
  String? subCategory;
  String? villageMohalla;
  String? state;
  String? aadharCardBack;
  String? markSheet;
  String? effectiveFrom;
  String? effectiveTo;
  String? aadharNo;
  String? penno;
  String? apaarId;
  String? panNo;
  String? boardRegistrationNo;
  String? studentSign;
  String? gaurdianSign;
  String? subjectIds;
  int? id;
  String? printAt;
  String? status;
  bool? isOption1Available;
  bool? isOption2Available;
  bool? isOption3Available;
  String? option1ThName;
  String? option2ThName;
  String? option3ThName;
  String? optional1;
  String? optional2;
  String? optional3;
  String? portalOrgPhoto;

  PromotionListResponse({
    this.rollNumber,
    this.className,
    this.admissionNo,
    this.branchAddress,
    this.previousSchool,
    this.session,
    this.groupName,
    this.studentTypeId,
    this.studentClassTableId,
    this.isPromoted,
    this.qrCode,
    this.isActive,
    this.finishedPhoto,
    this.dateOfPromotion,
    this.promotedClass,
    this.feesRecords,
    this.subjectList,
    this.subjectListJson,
    this.modifyOn,
    this.modifiedBy,
    this.includedFields,
    this.templateName,
    this.classTeacher,
    this.examIncharge,
    this.principal,
    this.backTemplate,
    this.printselection,
    this.sectionUpdated,
    this.parentUserId,
    this.isGenerateSRNo,
    this.branchId,
    this.sid,
    this.srno,
    this.schoolName,
    this.firstName,
    this.middleName,
    this.lastName,
    this.emailId,
    this.userId,
    this.dob,
    this.religion,
    this.motherName,
    this.motherMobile,
    this.motherOccupation,
    this.fatherName,
    this.fatherMobile,
    this.fatherOccupation,
    this.photo,
    this.fatherAadharCard,
    this.fatherAadharCardBack,
    this.incomeCertificate,
    this.aadharCard,
    this.motherAadharCard,
    this.motherAadharCardBack,
    this.castCertificate,
    this.nationalityCertificate,
    this.transferCertificate,
    this.groupId,
    this.classId,
    this.sessionId,
    this.address,
    this.postalCode,
    this.gender,
    this.uid,
    this.entryOn,
    this.routeId,
    this.pickUpId,
    this.vehicleId,
    this.transportMonthId,
    this.district,
    this.tehsil,
    this.category,
    this.subCategory,
    this.villageMohalla,
    this.state,
    this.aadharCardBack,
    this.markSheet,
    this.effectiveFrom,
    this.effectiveTo,
    this.aadharNo,
    this.penno,
    this.apaarId,
    this.panNo,
    this.boardRegistrationNo,
    this.studentSign,
    this.gaurdianSign,
    this.subjectIds,
    this.id,
    this.printAt,
    this.status,
    this.isOption1Available,
    this.isOption2Available,
    this.isOption3Available,
    this.option1ThName,
    this.option2ThName,
    this.option3ThName,
    this.optional1,
    this.optional2,
    this.optional3,
    this.portalOrgPhoto,
  });

  PromotionListResponse.fromJson(Map<String, dynamic> json) {
    rollNumber = json['rollNumber'];
    className = json['className'];
    admissionNo = json['admissionNo'];
    branchAddress = json['branchAddress'];
    previousSchool = json['previousSchool'];
    session = json['session'];
    groupName = json['groupName'];
    studentTypeId = json['studentTypeId'];
    studentClassTableId = json['studentClassTableId'];
    isPromoted = json['isPromoted'];
    qrCode = json['qrCode'];
    isActive = json['isActive'];
    finishedPhoto = json['finishedPhoto'];
    dateOfPromotion = json['dateOfPromotion'];
    promotedClass = json['promotedClass'];
    feesRecords = json['feesRecords'];
    if (json['subjectList'] != null) {
      subjectList = json['subjectList'];
    }
    subjectListJson = json['subjectListJson'];
    modifyOn = json['modifyOn'];
    modifiedBy = json['modifiedBy'];
    includedFields = json['includedFields'];
    templateName = json['templateName'];
    classTeacher = json['classTeacher'];
    examIncharge = json['examIncharge'];
    principal = json['principal'];
    backTemplate = json['backTemplate'];
    printselection = json['printselection'];
    sectionUpdated = json['sectionUpdated'];
    parentUserId = json['parentUserId'];
    isGenerateSRNo = json['isGenerateSRNo'];
    branchId = json['branchId'];
    sid = json['sid'];
    srno = json['srno'];
    schoolName = json['schoolName'];
    firstName = json['firstName'];
    middleName = json['middleName'];
    lastName = json['lastName'];
    emailId = json['emailId'];
    userId = json['userId'];
    dob = json['dob'];
    religion = json['religion'];
    motherName = json['motherName'];
    motherMobile = json['motherMobile'];
    motherOccupation = json['motherOccupation'];
    fatherName = json['fatherName'];
    fatherMobile = json['fatherMobile'];
    fatherOccupation = json['fatherOccupation'];
    photo = json['photo'];
    fatherAadharCard = json['fatherAadharCard'];
    fatherAadharCardBack = json['fatherAadharCardBack'];
    incomeCertificate = json['incomeCertificate'];
    aadharCard = json['aadharCard'];
    motherAadharCard = json['motherAadharCard'];
    motherAadharCardBack = json['motherAadharCardBack'];
    castCertificate = json['castCertificate'];
    nationalityCertificate = json['nationalityCertificate'];
    transferCertificate = json['transferCertificate'];
    groupId = json['groupId'];
    classId = json['classId'];
    sessionId = json['sessionId'];
    address = json['address'];
    postalCode = json['postalCode'];
    gender = json['gender'];
    uid = json['uid'];
    entryOn = json['entryOn'];
    routeId = json['routeId'];
    pickUpId = json['pickUpId'];
    vehicleId = json['vehicleId'];
    transportMonthId = json['transportMonthId'];
    district = json['district'];
    tehsil = json['tehsil'];
    category = json['category'];
    subCategory = json['subCategory'];
    villageMohalla = json['village_Mohalla'];
    state = json['state'];
    aadharCardBack = json['aadharCardBack'];
    markSheet = json['markSheet'];
    effectiveFrom = json['effectiveFrom'];
    effectiveTo = json['effectiveTo'];
    aadharNo = json['aadharNo'];
    penno = json['penno'];
    apaarId = json['apaarId'];
    panNo = json['panNo'];
    boardRegistrationNo = json['boardRegistrationNo'];
    studentSign = json['studentSign'];
    gaurdianSign = json['gaurdianSign'];
    subjectIds = json['subjectIds'];
    id = json['id'];
    printAt = json['printAt'];
    status = json['status'];
    isOption1Available = json['isOption1Available'];
    isOption2Available = json['isOption2Available'];
    isOption3Available = json['isOption3Available'];
    option1ThName = json['option1ThName'];
    option2ThName = json['option2ThName'];
    option3ThName = json['option3ThName'];
    optional1 = json['optional1'];
    optional2 = json['optional2'];
    optional3 = json['optional3'];
    portalOrgPhoto = json['portalOrgPhoto'];
  }
}
