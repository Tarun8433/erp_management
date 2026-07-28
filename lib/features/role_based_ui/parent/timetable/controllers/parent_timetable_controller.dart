import 'package:get/get.dart';

class Period {
  final int number;
  final String startTime;
  final String endTime;
  final String teacher;
  final String subject;
  final String subSubject;
  final bool isBreak;

  const Period({
    required this.number,
    required this.startTime,
    required this.endTime,
    required this.teacher,
    required this.subject,
    this.subSubject = '',
    this.isBreak = false,
  });
}

class ChildTimetable {
  final String name;
  final String className;
  final Map<String, List<Period>> weeklySchedule; // key: 'MON'..'SAT'

  const ChildTimetable({
    required this.name,
    required this.className,
    required this.weeklySchedule,
  });

  List<Period> periodsFor(String day) => weeklySchedule[day] ?? [];
}

class ParentTimetableController extends GetxController {
  final RxInt selectedChildIndex = 0.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // '' means AUTO (derive from selectedDate); otherwise 'MON'..'SAT'
  final RxString manualDay = ''.obs;

  final RxList<ChildTimetable> children = <ChildTimetable>[].obs;

  static const _weekdayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  String get activeDayLabel {
    if (manualDay.value.isNotEmpty) return manualDay.value;
    final wd = selectedDate.value.weekday; // 1=Mon .. 7=Sun
    if (wd <= 6) return _weekdayLabels[wd - 1];
    return 'MON'; // fallback Sunday → show Monday
  }

  bool get isAutoDay => manualDay.value.isEmpty;

  ChildTimetable? get selectedChild =>
      children.isNotEmpty ? children[selectedChildIndex.value] : null;

  List<Period> get currentPeriods =>
      selectedChild?.periodsFor(activeDayLabel) ?? [];

  String get classLabel => selectedChild?.className ?? '—';

  void selectChild(int i) {
    selectedChildIndex.value = i;
  }

  void pickDate(DateTime date) {
    selectedDate.value = date;
    manualDay.value = ''; // revert to AUTO
  }

  void selectDay(String day) {
    // Tapping the already-active manual day resets to AUTO
    if (manualDay.value == day) {
      manualDay.value = '';
    } else {
      manualDay.value = day;
    }
  }

  bool isCurrentPeriod(Period p) {
    if (!isAutoDay) return false;
    final now = DateTime.now();
    final today = DateTime.now();
    if (selectedDate.value.day != today.day ||
        selectedDate.value.month != today.month ||
        selectedDate.value.year != today.year) {
      return false;
    }

    try {
      final start = _parseTime(p.startTime, now);
      final end = _parseTime(p.endTime, now);
      return now.isAfter(start) && now.isBefore(end);
    } catch (_) {
      return false;
    }
  }

  DateTime _parseTime(String t, DateTime ref) {
    final parts = t.split(' ');
    final hm = parts[0].split(':');
    var h = int.parse(hm[0]);
    final m = int.parse(hm[1]);
    final isPm = parts.length > 1 && parts[1] == 'PM';
    if (isPm && h != 12) h += 12;
    if (!isPm && h == 12) h = 0;
    return DateTime(ref.year, ref.month, ref.day, h, m);
  }

  @override
  void onInit() {
    super.onInit();
    _buildMockData();
  }

  void _buildMockData() {
    // ── Shared period time slots ─────────────────────────────────────
    List<String> starts = [
      '07:50 AM', '08:35 AM', '09:20 AM', '10:05 AM',
      '10:35 AM', '11:20 AM', '12:05 PM', '12:50 PM', '01:35 PM',
    ];
    List<String> ends = [
      '08:35 AM', '09:20 AM', '10:05 AM', '10:35 AM',
      '11:20 AM', '12:05 PM', '12:50 PM', '01:35 PM', '02:20 PM',
    ];
    // Period 4 is break (10:05–10:35)

    // ── Helper to build one day's schedule ──────────────────────────
    List<Period> buildDay(List<List<String>> data) {
      // data: [[teacher, subject, subSubject], ...]  — 8 entries (skip break slot)
      final periods = <Period>[];
      int dataIdx = 0;
      for (int i = 0; i < 9; i++) {
        final isBreak = i == 3; // 4th slot is break
        if (isBreak) {
          periods.add(Period(
            number: i + 1,
            startTime: starts[i],
            endTime: ends[i],
            teacher: '',
            subject: 'BREAK',
            subSubject: '',
            isBreak: true,
          ));
        } else {
          final d = data[dataIdx++];
          periods.add(Period(
            number: i + 1,
            startTime: starts[i],
            endTime: ends[i],
            teacher: d[0],
            subject: d[1],
            subSubject: d.length > 2 ? d[2] : '',
          ));
        }
      }
      return periods;
    }

    // ── Child 1: Class 4-B ───────────────────────────────────────────
    final child1Schedule = {
      'MON': buildDay([
        ['Mr. Sharma', 'Mathematics', 'Fractions'],
        ['Ms. Gupta', 'Hindi', 'Poetry'],
        ['Mr. Verma', 'Science', 'Plants & Life'],
        // break
        ['Ms. Singh', 'English', 'Grammar'],
        ['Mr. Yadav', 'Social Studies', 'Indian History'],
        ['Ms. Rao', 'Computer', 'MS Paint'],
        ['Mr. Jain', 'Art & Craft', 'Drawing'],
        ['Ms. Pandey', 'Physical Ed.', 'Athletics'],
      ]),
      'TUE': buildDay([
        ['Ms. Gupta', 'Hindi', 'Grammar'],
        ['Mr. Sharma', 'Mathematics', 'Decimals'],
        ['Ms. Singh', 'English', 'Reading'],
        // break
        ['Mr. Verma', 'Science', 'Animals'],
        ['Ms. Rao', 'Computer', 'Typing'],
        ['Mr. Yadav', 'Social Studies', 'Geography'],
        ['Ms. Pandey', 'Physical Ed.', 'Yoga'],
        ['Mr. Jain', 'Music', 'Vocals'],
      ]),
      'WED': buildDay([
        ['Mr. Verma', 'Science', 'Water Cycle'],
        ['Ms. Singh', 'English', 'Writing'],
        ['Mr. Sharma', 'Mathematics', 'Geometry'],
        // break
        ['Ms. Gupta', 'Hindi', 'Story'],
        ['Mr. Jain', 'Art & Craft', 'Painting'],
        ['Mr. Yadav', 'Social Studies', 'Civics'],
        ['Ms. Rao', 'Computer', 'Internet'],
        ['Ms. Pandey', 'Physical Ed.', 'Games'],
      ]),
      'THU': buildDay([
        ['Ms. Singh', 'English', 'Literature'],
        ['Mr. Verma', 'Science', 'Matter'],
        ['Ms. Gupta', 'Hindi', 'Comprehension'],
        // break
        ['Mr. Sharma', 'Mathematics', 'Division'],
        ['Ms. Pandey', 'Physical Ed.', 'Sports'],
        ['Mr. Yadav', 'Social Studies', 'Maps'],
        ['Ms. Rao', 'Computer', 'Programming'],
        ['Mr. Jain', 'Music', 'Instruments'],
      ]),
      'FRI': buildDay([
        ['Mr. Yadav', 'Social Studies', 'Culture'],
        ['Mr. Sharma', 'Mathematics', 'Revision'],
        ['Ms. Gupta', 'Hindi', 'Debate'],
        // break
        ['Ms. Singh', 'English', 'Vocabulary'],
        ['Mr. Verma', 'Science', 'Experiment'],
        ['Mr. Jain', 'Art & Craft', 'Craft'],
        ['Ms. Rao', 'Computer', 'MS Word'],
        ['Ms. Pandey', 'Physical Ed.', 'March Past'],
      ]),
      'SAT': buildDay([
        ['Mr. Sharma', 'Mathematics', 'Test'],
        ['Ms. Singh', 'English', 'Dictation'],
        ['Mr. Verma', 'Science', 'Quiz'],
        // break
        ['Ms. Gupta', 'Hindi', 'Test'],
        ['Mr. Yadav', 'Social Studies', 'Test'],
        ['Ms. Rao', 'Computer', 'Practical'],
        ['Mr. Jain', 'General Knowledge', 'Current Affairs'],
        ['Ms. Pandey', 'Assembly', 'Prayers'],
      ]),
    };

    // ── Child 2: Class 2-A ───────────────────────────────────────────
    final child2Schedule = {
      'MON': buildDay([
        ['Ms. Nair', 'English', 'Alphabet'],
        ['Mr. Dubey', 'Mathematics', 'Numbers'],
        ['Ms. Mishra', 'Hindi', 'Vowels'],
        // break
        ['Mr. Sinha', 'EVS', 'My Family'],
        ['Ms. Nair', 'Drawing', 'Nature'],
        ['Mr. Dubey', 'Mathematics', 'Addition'],
        ['Ms. Mishra', 'Hindi', 'Stories'],
        ['Mr. Sinha', 'Physical Ed.', 'Games'],
      ]),
      'TUE': buildDay([
        ['Mr. Dubey', 'Mathematics', 'Subtraction'],
        ['Ms. Nair', 'English', 'Words'],
        ['Mr. Sinha', 'EVS', 'Animals'],
        // break
        ['Ms. Mishra', 'Hindi', 'Poems'],
        ['Mr. Dubey', 'Mathematics', 'Shapes'],
        ['Ms. Nair', 'English', 'Sentences'],
        ['Mr. Sinha', 'Drawing', 'Colours'],
        ['Ms. Mishra', 'Physical Ed.', 'Yoga'],
      ]),
      'WED': buildDay([
        ['Ms. Mishra', 'Hindi', 'Reading'],
        ['Mr. Sinha', 'EVS', 'Plants'],
        ['Ms. Nair', 'English', 'Rhymes'],
        // break
        ['Mr. Dubey', 'Mathematics', 'Tables'],
        ['Ms. Nair', 'English', 'Writing'],
        ['Ms. Mishra', 'Hindi', 'Grammar'],
        ['Mr. Sinha', 'Drawing', 'Sketch'],
        ['Mr. Dubey', 'Mathematics', 'Puzzles'],
      ]),
      'THU': buildDay([
        ['Mr. Sinha', 'EVS', 'Our Body'],
        ['Ms. Nair', 'English', 'Story'],
        ['Mr. Dubey', 'Mathematics', 'Patterns'],
        // break
        ['Ms. Mishra', 'Hindi', 'Writing'],
        ['Mr. Sinha', 'Music', 'Songs'],
        ['Ms. Nair', 'English', 'Phonics'],
        ['Mr. Dubey', 'Mathematics', 'Revision'],
        ['Ms. Mishra', 'Physical Ed.', 'Sports'],
      ]),
      'FRI': buildDay([
        ['Ms. Nair', 'English', 'Test'],
        ['Mr. Dubey', 'Mathematics', 'Test'],
        ['Ms. Mishra', 'Hindi', 'Test'],
        // break
        ['Mr. Sinha', 'EVS', 'Test'],
        ['Ms. Nair', 'Drawing', 'Free Drawing'],
        ['Mr. Dubey', 'Mathematics', 'Mental Maths'],
        ['Ms. Mishra', 'Hindi', 'Reading'],
        ['Mr. Sinha', 'Physical Ed.', 'Dance'],
      ]),
      'SAT': buildDay([
        ['Mr. Dubey', 'Mathematics', 'Activity'],
        ['Ms. Nair', 'English', 'Activity'],
        ['Ms. Mishra', 'Hindi', 'Activity'],
        // break
        ['Mr. Sinha', 'EVS', 'Activity'],
        ['Ms. Nair', 'General Knowledge', 'GK Quiz'],
        ['Mr. Dubey', 'Moral Science', 'Values'],
        ['Ms. Mishra', 'Hindi', 'Recitation'],
        ['Mr. Sinha', 'Assembly', 'Prayers'],
      ]),
    };

    // ── Child 3: Class 6-C ───────────────────────────────────────────
    final child3Schedule = {
      'MON': buildDay([
        ['Mr. Khan', 'Mathematics', 'Algebra'],
        ['Ms. Tiwari', 'Science', 'Physics'],
        ['Mr. Saxena', 'English', 'Grammar'],
        // break
        ['Ms. Bajpai', 'Hindi', 'Prose'],
        ['Mr. Mehta', 'Social Science', 'History'],
        ['Ms. Tiwari', 'Science', 'Chemistry'],
        ['Mr. Khan', 'Mathematics', 'Geometry'],
        ['Ms. Bajpai', 'Sanskrit', 'Shloka'],
      ]),
      'TUE': buildDay([
        ['Ms. Tiwari', 'Science', 'Biology'],
        ['Mr. Saxena', 'English', 'Literature'],
        ['Mr. Khan', 'Mathematics', 'Statistics'],
        // break
        ['Ms. Bajpai', 'Hindi', 'Poetry'],
        ['Mr. Mehta', 'Social Science', 'Geography'],
        ['Mr. Saxena', 'English', 'Writing'],
        ['Ms. Tiwari', 'Science', 'Lab'],
        ['Mr. Khan', 'Mathematics', 'Practice'],
      ]),
      'WED': buildDay([
        ['Mr. Mehta', 'Social Science', 'Civics'],
        ['Ms. Bajpai', 'Hindi', 'Grammar'],
        ['Ms. Tiwari', 'Science', 'Physics'],
        // break
        ['Mr. Khan', 'Mathematics', 'Trigonometry'],
        ['Mr. Saxena', 'English', 'Comprehension'],
        ['Ms. Bajpai', 'Sanskrit', 'Grammar'],
        ['Mr. Mehta', 'Social Science', 'Economics'],
        ['Ms. Tiwari', 'Computer', 'Programming'],
      ]),
      'THU': buildDay([
        ['Mr. Saxena', 'English', 'Debate'],
        ['Mr. Khan', 'Mathematics', 'Revision'],
        ['Ms. Bajpai', 'Hindi', 'Essay'],
        // break
        ['Ms. Tiwari', 'Science', 'Chemistry'],
        ['Mr. Mehta', 'Social Science', 'Maps'],
        ['Mr. Khan', 'Mathematics', 'Word Problems'],
        ['Mr. Saxena', 'English', 'Vocabulary'],
        ['Ms. Bajpai', 'Physical Ed.', 'Sports'],
      ]),
      'FRI': buildDay([
        ['Ms. Tiwari', 'Science', 'Experiment'],
        ['Ms. Bajpai', 'Hindi', 'Comprehension'],
        ['Mr. Khan', 'Mathematics', 'Test'],
        // break
        ['Mr. Saxena', 'English', 'Test'],
        ['Ms. Tiwari', 'Science', 'Test'],
        ['Mr. Mehta', 'Social Science', 'Test'],
        ['Ms. Bajpai', 'Hindi', 'Test'],
        ['Mr. Khan', 'Computer', 'MS Excel'],
      ]),
      'SAT': buildDay([
        ['Mr. Khan', 'Mathematics', 'Olympiad'],
        ['Ms. Tiwari', 'Science', 'Quiz'],
        ['Mr. Saxena', 'English', 'Spelling'],
        // break
        ['Ms. Bajpai', 'Hindi', 'Dictation'],
        ['Mr. Mehta', 'Social Science', 'Revision'],
        ['Ms. Tiwari', 'Computer', 'Practical'],
        ['Mr. Saxena', 'Moral Science', 'Values'],
        ['Ms. Bajpai', 'Assembly', 'Prayers'],
      ]),
    };

    children.assignAll([
      ChildTimetable(
          name: 'Aiden Smith',
          className: 'Class 4 - Section B',
          weeklySchedule: child1Schedule),
      ChildTimetable(
          name: 'Emma Smith',
          className: 'Class 2 - Section A',
          weeklySchedule: child2Schedule),
      ChildTimetable(
          name: 'Liam Smith',
          className: 'Class 6 - Section C',
          weeklySchedule: child3Schedule),
    ]);
  }
}
