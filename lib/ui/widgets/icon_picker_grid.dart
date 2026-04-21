import 'package:flutter/material.dart';
import 'package:nudget/core/utils/category_icon_mapper.dart';

/// A scrollable grid of selectable Material icons drawn from
/// [CategoryIconMapper.catalogue].
///
/// The currently selected icon is highlighted with the category's [accentColor].
class IconPickerGrid extends StatelessWidget {
  /// Creates an [IconPickerGrid].
  const IconPickerGrid({
    required this.selectedIconName,
    required this.accentColor,
    required this.onSelected,
    super.key,
  });

  /// The icon name that is currently selected (highlighted).
  final String selectedIconName;

  /// Highlight color, typically the currently chosen category color.
  final Color accentColor;

  /// Called with the new icon name when the user taps a tile.
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final names = CategoryIconMapper.allNames;
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: names.length,
      itemBuilder: (context, index) {
        final name = names[index];
        final isSelected = name == selectedIconName;

        return Semantics(
          label: name.replaceAll('_', ' '),
          selected: isSelected,
          button: true,
          child: InkWell(
            onTap: () => onSelected(name),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withOpacity(0.2)
                    : colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(color: accentColor, width: 2)
                    : null,
              ),
              child: Icon(
                CategoryIconMapper.resolve(name),
                color: isSelected ? accentColor : colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}
