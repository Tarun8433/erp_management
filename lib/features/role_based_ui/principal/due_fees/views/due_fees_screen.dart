import 'package:erp_management/features/role_based_ui/principal/due_fees/controllers/due_fees_controller.dart';
import 'package:erp_management/features/role_based_ui/principal/due_fees/models/due_fee_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final NumberFormat _money = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

class DueFeesScreen extends StatelessWidget {
  const DueFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DueFeesController c = Get.put(DueFeesController());
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: scheme.surfaceContainerLowest,
        appBar: AppBar(
          title: const Text('Due Fees'),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Get.back(),
          ),
        ),
        body: Column(
          children: [
            _buildFilterBar(context, c),
            Expanded(child: _buildResults(context, c)),
          ],
        ),
      ),
    );
  }

  // ── Filter bar ─────────────────────────────────────────────────────────────
  Widget _buildFilterBar(BuildContext context, DueFeesController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _dropdown(context, 'Session', c.selectedSession, c.sessions),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dropdown(context, 'Group', c.selectedGroup, c.groups),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _dropdown(context, 'Class', c.selectedClass, c.classes),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dropdownFixed(
                  context,
                  'Month',
                  c.selectedMonth,
                  c.monthNames,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: TextField(
                    onChanged: (v) => c.searchBy.value = v,
                    decoration: InputDecoration(
                      labelText: 'Search By',
                      hintText: 'SID, Name, Mobile...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: c.fetchDueFees,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reactive dropdown bound to a live [RxList] (Session/Group/Class).
  Widget _dropdown(
    BuildContext context,
    String label,
    RxString value,
    RxList<String> items,
  ) {
    return Obx(() => _dropdownFixed(context, label, value, items.toList()));
  }

  /// Dropdown over a static list of strings.
  Widget _dropdownFixed(
    BuildContext context,
    String label,
    RxString value,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Obx(
          () => Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: items.contains(value.value) ? value.value : null,
                hint: const Text('Select', style: TextStyle(fontSize: 13)),
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => value.value = v ?? '',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Results ──────────────────────────────────────────────────────────────────
  Widget _buildResults(BuildContext context, DueFeesController c) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (c.error.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(c.error.value, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: c.fetchDueFees,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }
      if (!c.hasSearched.value) {
        return _placeholder(
          context,
          Icons.search_rounded,
          'Select filters and tap search to load due fees.',
        );
      }
      if (c.reports.isEmpty) {
        return _placeholder(
          context,
          Icons.inbox_rounded,
          'No due-fee records found.',
        );
      }

      return Column(
        children: [
          _SummaryBar(controller: c),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: c.reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _DueFeeCard(item: c.reports[index]),
            ),
          ),
        ],
      );
    });
  }

  Widget _placeholder(BuildContext context, IconData icon, String message) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: scheme.primary.withValues(alpha: 0.25)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Summary bar (count + total due) ────────────────────────────────────────────
class _SummaryBar extends StatelessWidget {
  final DueFeesController controller;
  const _SummaryBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.78)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.groups_rounded, color: scheme.onPrimary, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${controller.reports.length} Students',
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Fee due records',
                style: TextStyle(
                  color: scheme.onPrimary.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Due',
                style: TextStyle(
                  color: scheme.onPrimary.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
              Text(
                _money.format(controller.totalDueAmount),
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Fee card ───────────────────────────────────────────────────────────────────
class _DueFeeCard extends StatelessWidget {
  final DueFeeModel item;
  const _DueFeeCard({required this.item});

  String get _initials {
    final parts = item.studentName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar + name + class/sid, amount due highlighted.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.studentName.isEmpty ? '—' : item.studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _chip(scheme, Icons.school_outlined, item.className),
                          if (item.sid.isNotEmpty)
                            _chip(scheme, Icons.badge_outlined, 'SID ${item.sid}'),
                          _chip(
                            scheme,
                            Icons.calendar_month_outlined,
                            item.monthName,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Due',
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      _money.format(item.totalDue),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: item.totalDue > 0
                            ? Colors.red.shade600
                            : Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Divider(height: 22, color: theme.dividerColor),
            // Contact / parents.
            _infoRow(scheme, Icons.man_outlined, 'Father', item.fatherName),
            _infoRow(scheme, Icons.woman_outlined, 'Mother', item.motherName),
            _infoRow(scheme, Icons.phone_outlined, 'Mobile', item.mobileNo),
            _infoRow(
              scheme,
              Icons.location_on_outlined,
              'Address',
              item.address,
            ),
            // Fee breakdown (only when there's something beyond the base amount).
            if (item.penalty > 0 ||
                item.paidAmount > 0 ||
                item.specialDiscount > 0 ||
                item.extraDiscountAmount > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _stat('Amount', item.amount, scheme),
                    if (item.penalty > 0)
                      _stat('Penalty', item.penalty, scheme),
                    if (item.paidAmount > 0)
                      _stat('Paid', item.paidAmount, scheme),
                    if (item.specialDiscount > 0)
                      _stat('Discount', item.specialDiscount, scheme),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(ColorScheme scheme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.primary),
          const SizedBox(width: 4),
          Text(
            label.isEmpty ? '—' : label,
            style: TextStyle(
              fontSize: 11,
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    ColorScheme scheme,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, double value, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
        ),
        Text(
          _money.format(value),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
