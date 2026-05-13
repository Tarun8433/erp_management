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
    final theme = Theme.of(context);
    final selectedSet = Set<T>.from(selectedValues);
    final searchCtrl = TextEditingController();
    final allItems = items;
    var filtered = allItems;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                          Text(
                            'Select $label',
                            style: theme.textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () {
                              onChanged(selectedSet.toList());
                              Navigator.pop(context);
                            },
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ),
                    if (enableSearch)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: TextField(
                          controller: searchCtrl,
                          decoration: InputDecoration(
                            hintText: searchHint,
                            prefixIcon: const Icon(Icons.search, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            isDense: true,
                            suffixIcon: searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      searchCtrl.clear();
                                      setState(() => filtered = allItems);
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (q) {
                            final query = q.trim().toLowerCase();
                            setState(() {
                              filtered = query.isEmpty
                                  ? allItems
                                  : allItems.where((it) {
                                      final child = it.child;
                                      final labelText =
                                          child is Text
                                              ? (child.data ?? '')
                                              : child.toString();
                                      return labelText
                                          .toLowerCase()
                                          .contains(query);
                                    }).toList();
                            });
                          },
                        ),
                      ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isSelected = selectedSet.contains(item.value);
                          
                          return CheckboxListTile(
                            value: isSelected,
                            title: item.child,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  final v = item.value;
                                  if (v != null) selectedSet.add(v);
                                } else {
                                  selectedSet.remove(item.value);
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
          },
        );
      },
    ).then((_) {
      searchCtrl.dispose();
      // Ensure the change is propagated if dismissed without clicking Done (optional)
      // onChanged(selectedSet.toList());
    });
  }
}
