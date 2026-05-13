import 'package:get/get.dart';

class StudentPickup {
  final String name;
  final String stop;
  final RxBool pickedUp;
  final bool absent;

  StudentPickup({
    required this.name,
    required this.stop,
    bool initialPicked = false,
    this.absent = false,
  }) : pickedUp = initialPicked.obs;
}

class DriverDashboardController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString driverName = 'Driver Mike'.obs;
  final RxString routeLabel = 'ROUTE ACTIVE: BUS #2'.obs;
  final RxString nextStop = 'Maple Ridge Ave'.obs;
  final RxString etaLabel = 'ETA: 4 mins - 1.2 miles'.obs;
  final RxString drivingTime = '14:22'.obs;
  final RxString routeCompleted = '32.8 km'.obs;

  final RxList<StudentPickup> pickups = <StudentPickup>[
    StudentPickup(
      name: 'Julianne Smith',
      stop: 'Stop: Pine Valley Loop',
      initialPicked: true,
    ),
    StudentPickup(
      name: 'Leo Martinez',
      stop: 'Stop: Maple Ridge Ave',
      initialPicked: true,
    ),
    StudentPickup(
      name: 'Sarah Chen',
      stop: 'ABSENT: Parent Notified',
      absent: true,
    ),
  ].obs;

  int get pickedCount => pickups.where((p) => p.pickedUp.value).length;
  int get totalCount => pickups.length;

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
      errorMessage.value = 'Could not load route data.';
    } finally {
      isLoading.value = false;
    }
  }

  void togglePickup(StudentPickup p) {
    if (p.absent) return;
    p.pickedUp.value = !p.pickedUp.value;
  }

  void triggerEmergency() {
    Get.snackbar('Emergency', 'Dispatch has been notified.');
  }
}
