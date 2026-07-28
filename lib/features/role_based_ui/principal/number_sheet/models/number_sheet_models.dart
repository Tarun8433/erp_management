class ExamTypeModel {
  final int id;
  final String name;
  final bool isLooked;

  ExamTypeModel({required this.id, required this.name, this.isLooked = false});

  factory ExamTypeModel.fromJson(Map<String, dynamic> json) => ExamTypeModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        isLooked: json['isLooked'] ?? false,
      );
}

class SubjectModel {
  final int id;
  final String name;

  SubjectModel({required this.id, required this.name});

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
      );
}

class NumberSheetStudent {
  final int id;
  final String rollNumber;
  final String name;
  int? marks;
  bool isSubjectAssigned;

  NumberSheetStudent({
    required this.id,
    required this.rollNumber,
    required this.name,
    this.marks,
    this.isSubjectAssigned = true,
  });
}

class StudentExamNumber {
  final int? studentId;
  final int? subjectId;
  final int? examTypeId;
  final int? obtainedMarks;

  StudentExamNumber.fromJson(Map<String, dynamic> json)
      : studentId = json['studentId'],
        subjectId = json['subjectId'],
        examTypeId = json['examTypeId'],
        obtainedMarks = json['obtainedMarks'];
}

class AssignedSubject {
  final int? studentId;
  final int? subjectId;

  AssignedSubject.fromJson(Map<String, dynamic> json)
      : studentId = json['studentId'],
        subjectId = json['subjectId'];
}
