import 'package:flutter/material.dart';
import 'package:nudget/core/utils/category_icon_mapper.dart';

/// A wrap of selectable color swatches drawn from [CategoryColorPalette].
///
/// The selected color shows a checkmark overlay so color is never the only
/// differentiator (accessibility requirement).
class ColorPickerGrid extends StatelessWidget {
  /// Creates a [ColorPickerGrid].
  const ColorPickerGrid({
    required this.selectedColor,
    required this.onSelected,
    super.key,
  });

  /// The currently selected [Color].
  final Color selectedColor;

  /// Called with the chosen [Color] when the user taps a swatch.
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: CategoryColorPalette.colors.map((color) {
        final isSelected = color.toARGB32() == selectedColor.toARGB32();
        return Semantics(
          label: '0x${color.toARGB32().toRadixString(16).padLeft(8, '0')}',
          selected: isSelected,
          button: true,
          child: GestureDetector(
            onTap: () => onSelected(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 3,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
