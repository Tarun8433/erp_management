import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum FeeStatus { paid, due, notGenerated }

enum FeeType { tuition, transport }

class FeeEntry {
  final String monthLabel; // "OLD DUE", "APR-26", etc.
  final String detail;
  final int amount;
  final FeeStatus status;

  FeeEntry({
    required this.monthLabel,
    this.detail = '',
    this.amount = 0,
    this.status = FeeStatus.notGenerated,
  });
}

class ChildFeeData {
  final String name;
  final String className;
  final List<FeeEntry> tuitionEntries;
  final List<FeeEntry> transportEntries;

  ChildFeeData({
    required this.name,
    required this.className,
    required this.tuitionEntries,
    required this.transportEntries,
  });

  int totalFee(FeeType type) => _entries(type)
      .where((e) => e.amount > 0)
      .fold(0, (s, e) => s + e.amount);

  int totalPaid(FeeType type) => _entries(type)
      .where((e) => e.status == FeeStatus.paid)
      .fold(0, (s, e) => s + e.amount);

  int totalDue(FeeType type) => _entries(type)
      .where((e) => e.status == FeeStatus.due)
      .fold(0, (s, e) => s + e.amount);

  List<FeeEntry> _entries(FeeType type) =>
      type == FeeType.tuition ? tuitionEntries : transportEntries;
}

class ParentFeeController extends GetxController {
  final RxInt selectedChildIndex = 0.obs;
  final Rx<FeeType> feeType = FeeType.tuition.obs;
  final RxList<ChildFeeData> children = <ChildFeeData>[].obs;
  final RxSet<int> selectedRows = <int>{}.obs;

  ChildFeeData? get selectedChild =>
      children.isNotEmpty ? children[selectedChildIndex.value] : null;

  List<FeeEntry> get currentEntries {
    final child = selectedChild;
    if (child == null) return [];
    return feeType.value == FeeType.tuition
        ? child.tuitionEntries
        : child.transportEntries;
  }

  int get totalFee => selectedChild?.totalFee(feeType.value) ?? 0;
  int get totalPaid => selectedChild?.totalPaid(feeType.value) ?? 0;
  int get totalDue => selectedChild?.totalDue(feeType.value) ?? 0;

  bool isSelected(int index) => selectedRows.contains(index);

  void toggleRow(int index) {
    final entry = currentEntries[index];
    if (entry.status != FeeStatus.due) return;
    if (selectedRows.contains(index)) {
      selectedRows.remove(index);
    } else {
      selectedRows.add(index);
    }
  }

  void clearSelection() => selectedRows.clear();

  int get selectedTotal => selectedRows
      .where((i) => i < currentEntries.length)
      .fold(0, (s, i) => s + currentEntries[i].amount);

  Color statusColor(FeeStatus status) {
    switch (status) {
      case FeeStatus.paid:
        return const Color(0xFF1B5E20);
      case FeeStatus.due:
        return const Color(0xFFC62828);
      case FeeStatus.notGenerated:
        return Colors.transparent;
    }
  }

  void toggleFeeType() {
    feeType.value =
        feeType.value == FeeType.tuition ? FeeType.transport : FeeType.tuition;
    selectedRows.clear();
  }

  void selectChild(int i) {
    selectedChildIndex.value = i;
    selectedRows.clear();
  }

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    final tuitionMonths = [
      'APR-26', 'MAY-26', 'JUN-26', 'JUL-26', 'AUG-26',
      'SEP-26', 'OCT-26', 'NOV-26', 'DEC-26', 'JAN-27',
      'FEB-27', 'MAR-27',
    ];

    List<FeeEntry> buildTuition(int childIdx) {
      final entries = <FeeEntry>[
        FeeEntry(
          monthLabel: 'OLD DUE',
          detail: 'NEW ADMISSION: ₹500, TUTION FEE: ₹1000',
          amount: 1500,
          status: FeeStatus.paid,
        ),
      ];

      // Per-child: slightly different paid/due split
      final paidCount = [5, 4, 3][childIdx.clamp(0, 2)];
      for (int i = 0; i < tuitionMonths.length; i++) {
        final month = tuitionMonths[i];
        if (i < paidCount) {
          entries.add(FeeEntry(
            monthLabel: month,
            detail: 'TUTION FEE: ₹1000',
            amount: 1000,
            status: FeeStatus.paid,
          ));
        } else if (i < paidCount + 3) {
          entries.add(FeeEntry(
            monthLabel: month,
            detail: 'TUTION FEE: ₹1000',
            amount: 1000,
            status: FeeStatus.due,
          ));
        } else {
          entries.add(FeeEntry(
            monthLabel: month,
            status: FeeStatus.notGenerated,
          ));
        }
      }
      return entries;
    }

    List<FeeEntry> buildTransport(int childIdx) {
      final paidCount = [4, 3, 2][childIdx.clamp(0, 2)];
      final entries = <FeeEntry>[];
      for (int i = 0; i < tuitionMonths.length; i++) {
        final month = tuitionMonths[i];
        if (i < paidCount) {
          entries.add(FeeEntry(
            monthLabel: month,
            detail: 'TRANSPORT FEE: ₹600',
            amount: 600,
            status: FeeStatus.paid,
          ));
        } else if (i < paidCount + 3) {
          entries.add(FeeEntry(
            monthLabel: month,
            detail: 'TRANSPORT FEE: ₹600',
            amount: 600,
            status: FeeStatus.due,
          ));
        } else {
          entries.add(FeeEntry(
            monthLabel: month,
            status: FeeStatus.notGenerated,
          ));
        }
      }
      return entries;
    }

    children.assignAll([
      ChildFeeData(
        name: 'Aiden Smith',
        className: 'Class 4 — Section B',
        tuitionEntries: buildTuition(0),
        transportEntries: buildTransport(0),
      ),
      ChildFeeData(
        name: 'Emma Smith',
        className: 'Class 2 — Section A',
        tuitionEntries: buildTuition(1),
        transportEntries: buildTransport(1),
      ),
      ChildFeeData(
        name: 'Liam Smith',
        className: 'Class 6 — Section C',
        tuitionEntries: buildTuition(2),
        transportEntries: buildTransport(2),
      ),
    ]);
  }
}
