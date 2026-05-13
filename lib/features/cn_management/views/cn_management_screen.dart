import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/cn_controller.dart';

class CnManagementScreen extends GetView<CnController> {
  const CnManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CN Management'),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isSaving.value ? null : controller.saveCn,
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('GC Details'),
            const SizedBox(height: 12),
            _dateField(
              context,
              label: 'GC Date',
              value: controller.gcDate,
            ),
            const SizedBox(height: 12),
            _dateField(
              context,
              label: 'Pickup Date & Time',
              value: controller.pickupDateTime,
              withTime: true,
            ),
            const SizedBox(height: 12),
            _dateField(
              context,
              label: 'Estimated Delivery Date (EDD)',
              value: controller.edd,
            ),
            const SizedBox(height: 12),
            _dateField(
              context,
              label: 'Required Delivery Date (RDD)',
              value: controller.rdd,
            ),
            const SizedBox(height: 16),
            _sectionHeader('Load Details'),
            const SizedBox(height: 12),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.loadWeightUom.value,
                decoration: const InputDecoration(
                  labelText: 'Weight UOM',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Kilogram (kg)',
                    child: Text('Kilogram (kg)'),
                  ),
                  DropdownMenuItem(
                    value: 'Metric Ton (MT)',
                    child: Text('Metric Ton (MT)'),
                  ),
                  DropdownMenuItem(
                    value: 'Pound (lb)',
                    child: Text('Pound (lb)'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) controller.loadWeightUom.value = v;
                },
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller.loadWeightController,
              decoration: const InputDecoration(
                labelText: 'Load Weight',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller.riskCoverAmountController,
              decoration: const InputDecoration(
                labelText: 'Risk Cover Amount',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller.remarksController,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _sectionHeader('Pickup Options'),
            const SizedBox(height: 8),
            Obx(
              () => SwitchListTile(
                title: const Text('Need Pickup'),
                value: controller.needPickup.value,
                onChanged: (v) => controller.needPickup.value = v,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Obx(
              () => SwitchListTile(
                title: const Text('Pickup by Consignee'),
                value: controller.pickupByConsignee.value,
                onChanged: (v) => controller.pickupByConsignee.value = v,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isSaving.value ? null : controller.saveCn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save CN'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      );

  Widget _dateField(
    BuildContext context, {
    required String label,
    required Rx<DateTime> value,
    bool withTime = false,
  }) {
    return Obx(() {
      final formatted = withTime
          ? DateFormat('dd/MM/yyyy HH:mm').format(value.value)
          : DateFormat('dd/MM/yyyy').format(value.value);
      return GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value.value,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (picked == null) return;
          if (withTime) {
            if (!context.mounted) return;
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(value.value),
            );
            if (time != null) {
              value.value = DateTime(
                picked.year,
                picked.month,
                picked.day,
                time.hour,
                time.minute,
              );
            }
          } else {
            value.value = picked;
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
            ),
            controller: TextEditingController(text: formatted),
          ),
        ),
      );
    });
  }
}
