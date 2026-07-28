import 'package:get/get.dart';

class ExamMark {
  final int maxMarks;
  final int? obtained; // null = not yet declared

  const ExamMark({required this.maxMarks, this.obtained});

  bool get isDeclared => obtained != null;
  bool get isPassing => obtained != null && (obtained! / maxMarks) >= 0.33;
  double get percentage =>
      (obtained != null && maxMarks > 0) ? (obtained! / maxMarks) * 100 : 0;
}

class SubjectResult {
  final String name;
  final List<ExamMark> exams; // indexed 0..3 for EXAM 1..4

  const SubjectResult({required this.name, required this.exams});
}

class ChildResultData {
  final String name;
  final String className;
  final Map<String, List<SubjectResult>> sessionData; // key: session string

  const ChildResultData({
    required this.name,
    required this.className,
    required this.sessionData,
  });
}

class ParentResultController extends GetxController {
  // ── Filters ──────────────────────────────────────────────────────────────────
  final RxInt selectedChildIndex = 0.obs;
  final RxString selectedSession = '2025-26'.obs;
  final RxInt selectedExamFilter = 0.obs; // 0=ALL, 1-4 = specific exam index
  final RxBool isCardView = false.obs;

  void toggleView() => isCardView.value = !isCardView.value;

  static const sessions = ['2025-26', '2024-25', '2023-24'];
  static const examLabels = ['EXAM 1\n(UT-1)', 'EXAM 2\n(UT-2)', 'EXAM 3\n(H.Y.)', 'EXAM 4\n(Annual)'];
  static const examShortLabels = ['EXAM 1', 'EXAM 2', 'EXAM 3', 'EXAM 4'];
  static const examFilterOptions = ['ALL EXAMS', 'UNIT TEST-1', 'UNIT TEST-2', 'HALF YEARLY', 'ANNUAL'];

  // ── Children data ─────────────────────────────────────────────────────────────
  final RxList<ChildResultData> children = <ChildResultData>[].obs;

  ChildResultData? get selectedChild =>
      children.isNotEmpty ? children[selectedChildIndex.value] : null;

  List<SubjectResult> get currentSubjects {
    final child = selectedChild;
    if (child == null) return [];
    return child.sessionData[selectedSession.value] ?? [];
  }

  /// Which exam indices (0-3) are visible based on the filter.
  List<int> get visibleExamIndices {
    if (selectedExamFilter.value == 0) return [0, 1, 2, 3];
    return [selectedExamFilter.value - 1];
  }

  // ── Summary calculations ──────────────────────────────────────────────────────
  int totalMaxMarks(int examIdx) {
    return currentSubjects.fold(
        0, (s, sub) => s + sub.exams[examIdx].maxMarks);
  }

  int? totalObtained(int examIdx) {
    final subs = currentSubjects;
    if (subs.isEmpty) return null;
    if (subs.any((s) => !s.exams[examIdx].isDeclared)) return null;
    return subs.fold<int>(0, (s, sub) => s + (sub.exams[examIdx].obtained ?? 0));
  }

  /// Cumulative across all visible declared exams.
  int get grandTotalMax {
    int total = 0;
    for (final idx in visibleExamIndices) {
      total += totalMaxMarks(idx);
    }
    return total;
  }

  int? get grandTotalObtained {
    int total = 0;
    for (final idx in visibleExamIndices) {
      final t = totalObtained(idx);
      if (t == null) return null;
      total += t;
    }
    return total;
  }

  String get overallResult {
    final tot = grandTotalObtained;
    if (tot == null) return '—';
    final allPass = currentSubjects.every((s) {
      for (final idx in visibleExamIndices) {
        if (!s.exams[idx].isPassing) return false;
      }
      return true;
    });
    return allPass ? 'PASS' : 'FAIL';
  }

  String get overallDivision {
    final tot = grandTotalObtained;
    if (tot == null || grandTotalMax == 0) return '—';
    final pct = (tot / grandTotalMax) * 100;
    if (pct >= 60) return '1st Division';
    if (pct >= 45) return '2nd Division';
    if (pct >= 33) return '3rd Division';
    return 'FAIL';
  }

  // ── Init ──────────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _buildMockData();
  }

  void selectChild(int i) => selectedChildIndex.value = i;

  void _buildMockData() {
    // Max marks per exam type (matching wireframe: 20, 30, 50, 100)
    const mm = [20, 30, 50, 100];

    // Deterministic "realistic" obtained marks given child index + subject index
    int obt(int ci, int si, int examIdx) {
      final maxM = mm[examIdx];
      // hash to get consistent percentage (55-95%)
      final hash = (ci * 97 + si * 31 + examIdx * 13) % 40;
      final pct = 55 + hash; // 55..94%
      return ((maxM * pct) / 100).round();
    }

    final subjects = [
      'Mathematics', 'Hindi', 'English', 'Science',
      'Social Studies', 'Computer', 'Sanskrit', 'Art & Craft',
      'Physical Ed.', 'General Knowledge',
    ];

    List<SubjectResult> buildSession(int ci, bool exam4Declared) {
      return subjects.asMap().entries.map((e) {
        final si = e.key;
        final name = e.value;
        return SubjectResult(
          name: name,
          exams: List.generate(4, (ei) {
            // Exams 1-3 always declared; exam 4 depends on flag
            final declared = ei < 3 || exam4Declared;
            return ExamMark(
              maxMarks: mm[ei],
              obtained: declared ? obt(ci, si, ei) : null,
            );
          }),
        );
      }).toList();
    }

    children.assignAll([
      ChildResultData(
        name: 'Aiden Smith',
        className: 'Class 4 - Section B',
        sessionData: {
          '2025-26': buildSession(0, false),
          '2024-25': buildSession(0, true),
          '2023-24': buildSession(0, true),
        },
      ),
      ChildResultData(
        name: 'Emma Smith',
        className: 'Class 2 - Section A',
        sessionData: {
          '2025-26': buildSession(1, false),
          '2024-25': buildSession(1, true),
          '2023-24': buildSession(1, true),
        },
      ),
      ChildResultData(
        name: 'Liam Smith',
        className: 'Class 6 - Section C',
        sessionData: {
          '2025-26': buildSession(2, false),
          '2024-25': buildSession(2, true),
          '2023-24': buildSession(2, true),
        },
      ),
    ]);
  }
}
