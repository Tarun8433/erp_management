class StudentListResponseMain {
  int? statusCode;
  String? responseText;
  List<StudentListResponse>? students;

  StudentListResponseMain({this.statusCode, this.responseText, this.students});

  StudentListResponseMain.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    responseText = json['responseText'];
    if (json['result'] != null) {
      students = <StudentListResponse>[];
      json['result'].forEach((v) {
        students!.add(StudentListResponse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['responseText'] = responseText;
    if (students != null) {
      data['result'] = students!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StudentListResponse {
  String? rollNumber;
  String? className;
  String? session;
  String? groupName;
  String? studentNo;
  bool? isActive;
  String? finishedPhoto;
  String? feesRecords;
  int? parentUserId;
  String? sid;
  String? srno;
  int? marks;
  String? firstName;
  String? middleName;
  String? lastName;
  String? emailId;
  int? userId;
  String? dob;
  String? aadharNo;
  String? penno;
  String? apaarId;
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
  String? aadharCardBack;
  String? markSheet;
  int? id;

  StudentListResponse({
    this.rollNumber,
    this.className,
    this.session,
    this.groupName,
    this.isActive,
    this.finishedPhoto,
    this.feesRecords,
    this.parentUserId,
    this.sid,
    this.aadharNo,
    this.penno,
    this.apaarId,
    this.srno,
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
    this.aadharCardBack,
    this.markSheet,
    this.id,
  });

  StudentListResponse.fromJson(Map<String, dynamic> json) {
    rollNumber = json['rollNumber'];
    className = json['className'];
    session = json['session'];
    groupName = json['groupName'];
    isActive = json['isActive'];
    finishedPhoto = json['finishedPhoto'];
    feesRecords = json['feesRecords'];
    parentUserId = json['parentUserId'];
    sid = json['sid'];
    aadharNo = json['aadharNo'];
    penno = json['penno'];
    apaarId = json['ApaarId'] ?? json['apaarId'];
    srno = json['srno'];
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
    entryOn = json['entryOn'];
    routeId = json['routeId'];
    pickUpId = json['pickUpId'];
    vehicleId = json['vehicleId'];
    transportMonthId = json['transportMonthId'];
    district = json['district'];
    tehsil = json['tehsil'];
    category = json['category'];
    subCategory = json['subCategory'];
    villageMohalla = json['village_Mohalla'] ?? json['villageMohalla'];
    aadharCardBack = json['aadharCardBack'];
    markSheet = json['markSheet'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rollNumber'] = rollNumber;
    data['aadharNo'] = aadharNo;
    data['penno'] = penno;
    data['ApaarId'] = apaarId;
    data['className'] = className;
    data['session'] = session;
    data['groupName'] = groupName;
    data['isActive'] = isActive;
    data['finishedPhoto'] = finishedPhoto;
    data['feesRecords'] = feesRecords;
    data['parentUserId'] = parentUserId;
    data['sid'] = sid;
    data['srno'] = srno;
    data['firstName'] = firstName;
    data['middleName'] = middleName;
    data['lastName'] = lastName;
    data['emailId'] = emailId;
    data['userId'] = userId;
    data['dob'] = dob;
    data['religion'] = religion;
    data['motherName'] = motherName;
    data['motherMobile'] = motherMobile;
    data['motherOccupation'] = motherOccupation;
    data['fatherName'] = fatherName;
    data['fatherMobile'] = fatherMobile;
    data['fatherOccupation'] = fatherOccupation;
    data['photo'] = photo;
    data['fatherAadharCard'] = fatherAadharCard;
    data['fatherAadharCardBack'] = fatherAadharCardBack;
    data['incomeCertificate'] = incomeCertificate;
    data['aadharCard'] = aadharCard;
    data['motherAadharCard'] = motherAadharCard;
    data['motherAadharCardBack'] = motherAadharCardBack;
    data['castCertificate'] = castCertificate;
    data['nationalityCertificate'] = nationalityCertificate;
    data['transferCertificate'] = transferCertificate;
    data['groupId'] = groupId;
    data['classId'] = classId;
    data['sessionId'] = sessionId;
    data['address'] = address;
    data['postalCode'] = postalCode;
    data['gender'] = gender;
    data['entryOn'] = entryOn;
    data['routeId'] = routeId;
    data['pickUpId'] = pickUpId;
    data['vehicleId'] = vehicleId;
    data['transportMonthId'] = transportMonthId;
    data['district'] = district;
    data['tehsil'] = tehsil;
    data['category'] = category;
    data['subCategory'] = subCategory;
    data['village_Mohalla'] = villageMohalla;
    data['aadharCardBack'] = aadharCardBack;
    data['markSheet'] = markSheet;
    data['id'] = id;
    return data;
  }
}
