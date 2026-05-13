import 'package:get/get.dart';

class PrincipalDashboardController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString principalName = 'Principal Wilson'.obs;
  final RxInt totalStudents = 1284.obs;
  final RxInt newStudentsThisMonth = 12.obs;
  final RxInt teachersPresent = 94.obs;
  final RxString attendancePercent = '98.2%'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOverview();
  }

  Future<void> fetchOverview() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // TODO: wire to ApiService when /admin/overview endpoint exists.
      await Future.delayed(const Duration(milliseconds: 250));
    } catch (e) {
      errorMessage.value = 'Could not load overview. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
