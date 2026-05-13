import 'package:get/get.dart';

class TeacherClassItem {
  final String name;
  final String room;
  final String time;
  final bool isNow;

  const TeacherClassItem({
    required this.name,
    required this.room,
    required this.time,
    this.isNow = false,
  });
}

class TeacherMessageItem {
  final String sender;
  final String preview;
  final String timeAgo;
  final bool isNew;

  const TeacherMessageItem({
    required this.sender,
    required this.preview,
    required this.timeAgo,
    this.isNew = false,
  });
}

class TeacherDashboardController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString teacherName = 'Sarah Mitchell'.obs;
  final RxString grade = 'Grade 10-B - Mathematics'.obs;
  final RxInt attendancePending = 4.obs;
  final RxInt upcomingExams = 2.obs;

  final RxList<TeacherClassItem> todayClasses = <TeacherClassItem>[
    const TeacherClassItem(
      name: 'Advanced Algebra',
      room: 'Room 302',
      time: '09:00 - 10:30 AM',
      isNow: true,
    ),
    const TeacherClassItem(
      name: 'Geometry Basics',
      room: 'Room 105',
      time: '11:00 - 12:00 PM',
    ),
    const TeacherClassItem(
      name: 'Calculus II',
      room: 'Lecture Hall A',
      time: '02:00 - 03:30 PM',
    ),
  ].obs;

  final RxList<TeacherMessageItem> messages = <TeacherMessageItem>[
    const TeacherMessageItem(
      sender: 'Elena Rodriguez (Liam)',
      preview: 'Hello Sarah, I wanted to discuss...',
      timeAgo: '2m ago',
      isNew: true,
    ),
    const TeacherMessageItem(
      sender: 'David Chen (Sophia\'s Dad)',
      preview: 'Thank you for the update on the...',
      timeAgo: '1h ago',
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
      errorMessage.value = 'Could not load overview. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
