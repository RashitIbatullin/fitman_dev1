import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull

/// A generic popup menu button displayed as a chip, designed for filtering lists.
///
/// This widget is intended to be a stable and reusable component. Its internal
/// logic should not be modified to accommodate specific one-off UI requirements
/// on a particular screen.
///
/// --- INTENDED USAGE ---
///
/// 1.  **As a standard filter button:**
///    - The button's label is determined by the `label` of the `selectedOption` or
///      falls back to `allOptionText` if no option is selected.
///    - To include an "All" option in the dropdown menu, keep `showAllOption: true` (default).
///      The text for this "All" option is configured via `allOptionText`.
///
/// 2.  **As an "Actions" button (with no "All" option in the menu):**
///    - Set `showAllOption: false`.
///    - Set `allOptionText` to the desired button label (e.g., "Действия").
///    - Set `initialValue` to `null`. This makes the button display the `allOptionText`
///      as its label, while the `showAllOption: false` flag prevents that text from
///      appearing as a selectable item in the menu itself.
///
/// --- CUSTOMIZATION ---
///
/// For UI behaviors not covered by this widget's properties (e.g., adding a
/// prefix to the selected label like "Статус: В архиве"), do not modify this
/// widget. Instead, create a custom implementation in the parent screen using
/// a standard `PopupMenuButton` wrapped in a `Chip`, as demonstrated in
/// `buildings_list_screen.dart`.
class FilterOption<T> {
  final String label;
  final T value;
  final bool enabled; // New property
  final Widget? avatar;

  const FilterOption({required this.label, required this.value, this.enabled = true, this.avatar});
}

// Placeholder for the "All" option to distinguish it from a null value
const String _kAllValuePlaceholder = '__ALL__';

class FilterPopupMenuButton<T> extends StatelessWidget {
  final T? initialValue;
  final List<FilterOption<T>> options;
  final ValueChanged<T?> onSelected;
  final String allOptionText;
  final String tooltip;
  final Widget? avatar;
  final bool showAllOption; // New property

  const FilterPopupMenuButton({
    super.key,
    required this.options,
    required this.onSelected,
    this.initialValue,
    this.allOptionText = 'Все',
    this.tooltip = 'Фильтр',
    this.avatar,
    this.showAllOption = true, // Default to true
  });

  @override
  Widget build(BuildContext context) {
    // Determine the current label for the chip
    final selectedOption = options.firstWhereOrNull((option) => option.value == initialValue);
    final String currentLabel = selectedOption?.label ?? allOptionText;

    return PopupMenuButton<dynamic>(
      tooltip: tooltip,
      initialValue: initialValue ?? _kAllValuePlaceholder,
      onSelected: (dynamic value) {
        if (value == _kAllValuePlaceholder) {
          onSelected(null);
        } else {
          onSelected(value as T?); // Cast to T? to handle both nullable and non-nullable T
        }
      },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<dynamic>>[
              // "All" option (conditionally built)
              if (showAllOption)
                PopupMenuItem<dynamic>(
                  value: _kAllValuePlaceholder,
                  child: Text(allOptionText),
                ),
              // Other options
              ...options.map((option) => PopupMenuItem<dynamic>(
                    value: option.value,
                    enabled: option.enabled, // Use the new enabled property
                    child: Row(
                      children: [
                        if (option.avatar != null) ...[
                          option.avatar!,
                          const SizedBox(width: 8),
                        ],
                        Text(option.label),
                      ],
                    ),
                  )),
            ],
      child: Chip(
        key: ValueKey('filter_chip_${initialValue ?? _kAllValuePlaceholder}'),
        label: Text(currentLabel),
        avatar: avatar,
      ),
    );
  }
}
