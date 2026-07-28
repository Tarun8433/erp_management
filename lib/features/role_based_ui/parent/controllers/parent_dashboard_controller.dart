import 'package:get/get.dart';

class SubjectGrade {
  final String subject;
  final int percent;
  const SubjectGrade(this.subject, this.percent);
}

class TeacherRemark {
  final String teacher;
  final String subjectLabel;
  final String remark;
  final String date;
  const TeacherRemark({
    required this.teacher,
    required this.subjectLabel,
    required this.remark,
    required this.date,
  });
}

class ParentDashboardController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Parent / Child identity
  final RxString parentName = 'Parent'.obs;
  final RxString childName = 'Aiden Smith'.obs;
  final RxString childGrade = 'Grade 4 — Section B'.obs;
  final RxString childAvatarText = 'A'.obs;

  // Attendance
  final RxString attendanceStatus = 'Present'.obs;
  final RxString attendancePercent = '98%'.obs;
  final RxString attendanceCheckIn = 'Checked in at 08:15 AM'.obs;
  final RxInt totalDays = 120.obs;
  final RxInt presentDays = 117.obs;

  // Fees
  final RxString pendingFeeAmount = '₹4,500'.obs;
  final RxString feeDueLabel = 'Due in 3 days'.obs;
  final RxBool hasPendingFee = true.obs;

  // Homework
  final RxString nextHomeworkSubject = 'Mathematics'.obs;
  final RxString nextHomeworkDue = 'Due Tomorrow'.obs;

  // Exam
  final RxString nextExamSubject = 'Science'.obs;
  final RxString nextExamMeta = 'Oct 24 · Period 2'.obs;

  // Result
  final RxString midTermGrade = 'A−'.obs;

  final RxList<SubjectGrade> subjects = <SubjectGrade>[
    const SubjectGrade('Science', 92),
    const SubjectGrade('Literature', 85),
    const SubjectGrade('History', 78),
    const SubjectGrade('Maths', 88),
  ].obs;

  final RxList<TeacherRemark> remarks = <TeacherRemark>[
    const TeacherRemark(
      teacher: 'Ms. Sarah Jenkins',
      subjectLabel: 'SCIENCE TEACHER',
      remark:
          'Aiden showed exceptional curiosity during the lab session. Keep up the great work!',
      date: 'Oct 18',
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOverview();
  }

  Future<void> fetchOverview() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.delayed(const Duration(milliseconds: 250));
    } catch (e) {
      errorMessage.value = 'Could not load child overview.';
    } finally {
      isLoading.value = false;
    }
  }
}
