import 'package:flutter/material.dart';

/// Maps category icon name strings (stored in SQLite) to Flutter [IconData].
///
/// The 30 icons below form the selectable set shown in the icon picker. The
/// fallback icon ([Icons.help_outline]) is returned for any unknown name so
/// legacy data never crashes the UI.
abstract class CategoryIconMapper {
  CategoryIconMapper._();

  /// Full icon catalogue available in the icon picker, keyed by name.
  static const Map<String, IconData> catalogue = {
    'shopping_cart': Icons.shopping_cart,
    'directions_car': Icons.directions_car,
    'sports_esports': Icons.sports_esports,
    'local_hospital': Icons.local_hospital,
    'home': Icons.home,
    'restaurant': Icons.restaurant,
    'flight': Icons.flight,
    'hotel': Icons.hotel,
    'school': Icons.school,
    'work': Icons.work,
    'fitness_center': Icons.fitness_center,
    'local_cafe': Icons.local_cafe,
    'phone_android': Icons.phone_android,
    'computer': Icons.computer,
    'headphones': Icons.headphones,
    'movie': Icons.movie,
    'music_note': Icons.music_note,
    'pets': Icons.pets,
    'child_care': Icons.child_care,
    'credit_card': Icons.credit_card,
    'local_gas_station': Icons.local_gas_station,
    'local_pharmacy': Icons.local_pharmacy,
    'local_library': Icons.local_library,
    'spa': Icons.spa,
    'sports': Icons.sports,
    'beach_access': Icons.beach_access,
    'shopping_bag': Icons.shopping_bag,
    'wb_sunny': Icons.wb_sunny,
    'favorite': Icons.favorite,
    'star': Icons.star,
  };

  /// Resolves [name] to its [IconData], falling back to [Icons.help_outline].
  static IconData resolve(String name) =>
      catalogue[name] ?? Icons.help_outline;

  /// Ordered list of all icon names for display in the picker grid.
  static List<String> get allNames => catalogue.keys.toList();
}

/// The 16-color palette offered in the category color picker.
abstract class CategoryColorPalette {
  CategoryColorPalette._();

  /// Ordered list of available category colors.
  static const List<Color> colors = [
    Color(0xFFF44336), // Red
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF03A9F4), // Light Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFC107), // Amber
    Color(0xFFFF9800), // Orange
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
  ];
}
