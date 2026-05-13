import 'package:get/get.dart';

class AdmissionReportItem {
  final int sNo;
  final String sid;
  final String group;
  final String className;
  final String aadhaarNo;
  final String name;
  final String status;
  final String fatherName;
  final String motherName;
  final String mobileNo;
  final String district;
  final String tehsil;
  final String village;
  final String dob;
  final String studentImage;
  final String finishedImage;
  final String srNo;
  final String religion;
  final String category;
  final String subCategory;
  final String gender;
  final String entryAt;

  AdmissionReportItem({
    required this.sNo,
    required this.sid,
    required this.group,
    required this.className,
    required this.aadhaarNo,
    required this.name,
    required this.status,
    required this.fatherName,
    required this.motherName,
    required this.mobileNo,
    required this.district,
    required this.tehsil,
    required this.village,
    required this.dob,
    required this.studentImage,
    required this.finishedImage,
    required this.srNo,
    required this.religion,
    required this.category,
    required this.subCategory,
    required this.gender,
    required this.entryAt,
  });
}

class AdmissionReportController extends GetxController {
  final RxString viewMode = 'table'.obs; // 'table' or 'card'
  final RxDouble baseFontSize = 12.0.obs;

  // Filters
  final RxString selectedSession = '2026 - 2027'.obs;
  final RxString selectedGroup = 'PLAY GROUP EM'.obs;
  final RxString selectedClass = 'LKG A'.obs;
  final RxString selectedStatus = 'Active'.obs;
  final RxString searchText = ''.obs;

  final List<String> sessions = ['2025 - 2026', '2026 - 2027', '2027 - 2028'];
  final List<String> groups = [
    'PLAY GROUP EM',
    'NURSERY',
    'LKG',
    'UKG',
    '1st',
    '2nd',
  ];
  final List<String> classes = ['LKG A', 'LKG B', 'UKG A', 'UKG B'];
  final List<String> statuses = ['Active', 'Inactive', 'Pending'];

  final RxList<AdmissionReportItem> reportItems = <AdmissionReportItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReport();
  }

  void toggleViewMode() {
    viewMode.value = viewMode.value == 'table' ? 'card' : 'table';
  }

  void updateFontSize(double delta) {
    baseFontSize.value = (baseFontSize.value + delta).clamp(10.0, 20.0);
  }

  void fetchReport() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));

    // Mock Data based on the screenshot
    reportItems.assignAll([
      AdmissionReportItem(
        sNo: 1,
        sid: 'SID001',
        group: 'PLAY GROUP EM',
        className: 'LKG A',
        aadhaarNo: '1234 5678 9012',
        name: 'Test Student',
        status: 'Active',
        fatherName: 'MR. FT',
        motherName: 'MRS. MT',
        mobileNo: '7888902134',
        district: 'dstr',
        tehsil: 'teh',
        village: 'vill',
        dob: '11-04-2017',
        studentImage: 'https://i.pravatar.cc/150?u=1',
        finishedImage: 'https://i.pravatar.cc/150?u=2',
        srNo: '800',
        religion: 'Hindu',
        category: 'General',
        subCategory: 'Thakur',
        gender: 'Male',
        entryAt: '04/26/2026 13:25:56',
      ),
      AdmissionReportItem(
        sNo: 2,
        sid: 'SID002',
        group: 'PLAY GROUP EM',
        className: 'LKG A',
        aadhaarNo: '9876 5432 1098',
        name: 'Aryan Singh',
        status: 'Active',
        fatherName: 'MR. Singh',
        motherName: 'MRS. Singh',
        mobileNo: '9988776655',
        district: 'Lucknow',
        tehsil: 'Lucknow',
        village: 'Hazratganj',
        dob: '15-08-2018',
        studentImage: 'https://i.pravatar.cc/150?u=3',
        finishedImage: 'https://i.pravatar.cc/150?u=4',
        srNo: '801',
        religion: 'Hindu',
        category: 'OBC',
        subCategory: 'Yadav',
        gender: 'Male',
        entryAt: '04/27/2026 10:15:20',
      ),
    ]);

    isLoading.value = false;
  }
}
