import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum AttendanceStatus { present, absent, holiday, weekend }

class DayAttendance {
  final int day;
  final AttendanceStatus status;
  const DayAttendance(this.day, this.status);
}

class ChildAttendance {
  final String name;
  final Map<String, List<DayAttendance>> monthlyData; // key: 'yyyy-MM'

  ChildAttendance({required this.name, required this.monthlyData});

  List<DayAttendance> getMonth(int year, int month) {
    final key = '$year-${month.toString().padLeft(2, '0')}';
    return monthlyData[key] ?? [];
  }

  int presentCount(int year, int month) =>
      getMonth(year, month)
          .where((d) => d.status == AttendanceStatus.present)
          .length;

  int absentCount(int year, int month) =>
      getMonth(year, month)
          .where((d) => d.status == AttendanceStatus.absent)
          .length;

  int workingDays(int year, int month) =>
      getMonth(year, month)
          .where((d) =>
              d.status == AttendanceStatus.present ||
              d.status == AttendanceStatus.absent)
          .length;
}

class ParentAttendanceController extends GetxController {
  final RxInt selectedChildIndex = 0.obs;
  final RxInt selectedYear = 0.obs;
  final RxInt selectedMonth = 0.obs;
  final RxBool isLoading = false.obs;

  final RxList<ChildAttendance> children = <ChildAttendance>[].obs;

  ChildAttendance? get selectedChild =>
      children.isNotEmpty ? children[selectedChildIndex.value] : null;

  List<DayAttendance> get currentMonthDays {
    final child = selectedChild;
    if (child == null) return [];
    return child.getMonth(selectedYear.value, selectedMonth.value);
  }

  String get monthLabel =>
      DateFormat('MMMM yyyy')
          .format(DateTime(selectedYear.value, selectedMonth.value));

  bool get canGoNext {
    final now = DateTime.now();
    return !(selectedYear.value == now.year &&
        selectedMonth.value == now.month);
  }

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedYear.value = now.year;
    selectedMonth.value = now.month;
    _generateMockData();
  }

  void _generateMockData() {
    isLoading.value = true;
    final now = DateTime.now();

    final childNames = ['Child 1', 'Child 2', 'Child 3'];
    final generatedChildren = <ChildAttendance>[];

    for (int ci = 0; ci < childNames.length; ci++) {
      final monthlyData = <String, List<DayAttendance>>{};

      // Generate 12 months of data for current year
      for (int m = 1; m <= 12; m++) {
        final key = '${now.year}-${m.toString().padLeft(2, '0')}';
        final daysInMonth = DateTime(now.year, m + 1, 0).day;
        final days = <DayAttendance>[];

        for (int d = 1; d <= daysInMonth; d++) {
          final date = DateTime(now.year, m, d);
          // Skip future days in current month
          if (date.isAfter(now)) {
            days.add(DayAttendance(d, AttendanceStatus.weekend));
            continue;
          }

          final weekday = date.weekday; // 1=Mon … 7=Sun
          AttendanceStatus status;

          if (weekday == 7) {
            // Sunday — weekend
            status = AttendanceStatus.weekend;
          } else if (weekday == 6) {
            // Saturday — 2nd & 4th = holiday, rest = holiday too (school closed)
            status = AttendanceStatus.holiday;
          } else {
            // Deterministic pseudo-random P/A (~88% present)
            final hash = (ci * 97 + m * 31 + d * 7) % 100;
            status = hash < 88
                ? AttendanceStatus.present
                : AttendanceStatus.absent;
          }
          days.add(DayAttendance(d, status));
        }
        monthlyData[key] = days;
      }

      generatedChildren.add(
          ChildAttendance(name: childNames[ci], monthlyData: monthlyData));
    }

    children.assignAll(generatedChildren);
    isLoading.value = false;
  }

  void selectChild(int index) => selectedChildIndex.value = index;

  void previousMonth() {
    if (selectedMonth.value == 1) {
      selectedMonth.value = 12;
      selectedYear.value--;
    } else {
      selectedMonth.value--;
    }
  }

  void nextMonth() {
    if (!canGoNext) return;
    if (selectedMonth.value == 12) {
      selectedMonth.value = 1;
      selectedYear.value++;
    } else {
      selectedMonth.value++;
    }
  }
}
