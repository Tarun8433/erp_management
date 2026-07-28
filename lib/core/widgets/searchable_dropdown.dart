import 'package:flutter/material.dart';

class SearchableDropdownItem<T> {
  final T value;
  final String label;
  const SearchableDropdownItem({required this.value, required this.label});
}

class SearchableDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final bool isLoading;
  final List<SearchableDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isLoading = false,
    this.enabled = true,
  });

  String get _selectedLabel {
    if (value == null) return '';
    try {
      return items.firstWhere((i) => i.value == value).label;
    } catch (_) {
      return '';
    }
  }

  Future<void> _open(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchSheet<T>(items: items, hint: hint),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = _selectedLabel;

    return InkWell(
      onTap: (!enabled || isLoading) ? null : () => _open(context),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          enabled: enabled,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          suffixIcon: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Icon(
                  enabled ? Icons.arrow_drop_down : Icons.lock_outline,
                  size: enabled ? 24 : 18,
                ),
        ),
        child: Text(
          selected.isEmpty ? hint : selected,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: !enabled
                ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
                : (selected.isEmpty
                    ? scheme.onSurfaceVariant
                    : scheme.onSurface),
          ),
        ),
      ),
    );
  }
}

class _SearchSheet<T> extends StatefulWidget {
  final List<SearchableDropdownItem<T>> items;
  final String hint;
  const _SearchSheet({required this.items, required this.hint});

  @override
  State<_SearchSheet<T>> createState() => _SearchSheetState<T>();
}

class _SearchSheetState<T> extends State<_SearchSheet<T>> {
  final _ctrl = TextEditingController();
  List<SearchableDropdownItem<T>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _ctrl.addListener(_filter);
  }

  void _filter() {
    final q = _ctrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items
              .where((i) => i.label.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mq = MediaQuery.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        // Give the ListTiles a Material ancestor *inside* the coloured
        // container so their ink splashes/background paint above it (otherwise
        // the DecoratedBox hides them and Flutter throws an assertion).
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _ctrl,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  isDense: true,
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => _ctrl.clear(),
                        )
                      : null,
                ),
              ),
            ),
            if (_filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No results',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  padding: EdgeInsets.only(
                    bottom: mq.viewInsets.bottom + 16,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final item = _filtered[i];
                    return ListTile(
                      title: Text(item.label),
                      onTap: () => Navigator.of(ctx).pop(item.value),
                    );
                  },
                ),
              ),
          ],
          ),
        ),
      ),
    );
  }
}
