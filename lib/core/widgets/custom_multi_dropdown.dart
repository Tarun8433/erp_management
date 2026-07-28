import 'package:flutter/material.dart';

class CustomMultiDropdown<T> extends StatelessWidget {
  final String label;
  final List<T> selectedValues;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<List<T>> onChanged;
  final String? hint;
  final bool isRequired;
  final bool enableSearch;
  final String searchHint;

  const CustomMultiDropdown({
    super.key,
    required this.label,
    required this.selectedValues,
    required this.items,
    required this.onChanged,
    this.hint,
    this.isRequired = false,
    this.enableSearch = false,
    this.searchHint = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate display widget
    Widget displayWidget;
    if (selectedValues.isEmpty) {
      displayWidget = Text(
        hint ?? 'Select $label',
        style: theme.inputDecorationTheme.hintStyle,
      );
    } else {
      final selectedItems = items.where((item) => selectedValues.contains(item.value)).toList();
      
      if (selectedItems.isEmpty) {
         // Fallback if selected items are not in the list (e.g. pagination or filtered out)
         displayWidget = Text('${selectedValues.length} selected', style: theme.textTheme.bodyMedium);
      } else {
        displayWidget = Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: selectedItems.map((e) {
            String text = e.value.toString();
            if (e.child is Text) {
              text = (e.child as Text).data ?? e.value.toString();
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                text,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showMultiSelectBottomSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
              color: theme.inputDecorationTheme.fillColor,
            ),
            constraints: const BoxConstraints(minHeight: 56),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: displayWidget,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMultiSelectBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MultiSelectSheet<T>(
        label: label,
        items: items,
        initialSelected: selectedValues,
        enableSearch: enableSearch,
        searchHint: searchHint,
        onDone: onChanged,
      ),
    );
  }
}

/// Stateful body for the multi-select bottom sheet. Owning the search
/// controller here (and disposing it in [dispose]) avoids the
/// "used after being disposed" crash that arises when a controller created
/// alongside `showModalBottomSheet` is disposed while the sheet is still
/// animating out.
class _MultiSelectSheet<T> extends StatefulWidget {
  final String label;
  final List<DropdownMenuItem<T>> items;
  final List<T> initialSelected;
  final bool enableSearch;
  final String searchHint;
  final ValueChanged<List<T>> onDone;

  const _MultiSelectSheet({
    super.key,
    required this.label,
    required this.items,
    required this.initialSelected,
    required this.enableSearch,
    required this.searchHint,
    required this.onDone,
  });

  @override
  State<_MultiSelectSheet<T>> createState() => _MultiSelectSheetState<T>();
}

class _MultiSelectSheetState<T> extends State<_MultiSelectSheet<T>> {
  late final Set<T> _selected = Set<T>.from(widget.initialSelected);
  final TextEditingController _searchCtrl = TextEditingController();
  late List<DropdownMenuItem<T>> _filtered = widget.items;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    final query = q.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.items
          : widget.items.where((it) {
              final child = it.child;
              final labelText =
                  child is Text ? (child.data ?? '') : child.toString();
              return labelText.toLowerCase().contains(query);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select ${widget.label}',
                      style: theme.textTheme.titleLarge),
                  TextButton(
                    onPressed: () {
                      widget.onDone(_selected.toList());
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            if (widget.enableSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _onSearch,
                ),
              ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final item = _filtered[index];
                  final isSelected = _selected.contains(item.value);
                  return CheckboxListTile(
                    value: isSelected,
                    title: item.child,
                    onChanged: (bool? value) {
                      setState(() {
                        final v = item.value;
                        if (value == true) {
                          if (v != null) _selected.add(v);
                        } else {
                          _selected.remove(item.value);
                        }
                      });
                    },
                    activeColor: theme.colorScheme.primary,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
