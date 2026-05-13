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

  final RxString childName = "Aiden's Progress".obs;
  final RxString childGrade = 'Grade 4 - Section B'.obs;
  final RxString attendanceStatus = 'Present'.obs;
  final RxString attendancePercent = '98%'.obs;
  final RxString attendanceCheckIn = 'Checked in at 08:15 AM'.obs;
  final RxString feeAmount = r'$450.00'.obs;
  final RxString feeDueLabel = 'Due in 3 days'.obs;
  final RxString nextExamSubject = 'Mathematics'.obs;
  final RxString nextExamMeta = 'Oct 24 - Period 2 - 5 Topics covered'.obs;
  final RxString midTermGrade = 'A-'.obs;

  final RxList<SubjectGrade> subjects = <SubjectGrade>[
    const SubjectGrade('Science', 92),
    const SubjectGrade('Literature', 85),
    const SubjectGrade('History', 78),
  ].obs;

  final RxList<TeacherRemark> remarks = <TeacherRemark>[
    const TeacherRemark(
      teacher: 'Ms. Sarah Jenkins',
      subjectLabel: 'SCIENCE TEACHER',
      remark:
          'Aiden showed exceptional curiosity during today\'s lab session. His understanding of photosynthesis is impressive. Keep up the great work!',
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
