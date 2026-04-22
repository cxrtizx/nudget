import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and exposes the user-chosen [Locale].
///
/// `null` means "follow the system locale". [MaterialApp] treats a null
/// locale exactly that way — it defers to the device's OS setting.
///
/// How it works:
/// - On first read, [build] loads the stored language code from prefs.
/// - [setLocale] writes the new code (or removes the key for system
///   default) and updates the state so every widget rebuilds immediately.
class LocaleNotifier extends AsyncNotifier<Locale?> {
  static const _key = 'app_locale';

  @override
  Future<Locale?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    // A stored code like 'es' becomes Locale('es'); missing key → null.
    return code != null ? Locale(code) : null;
  }

  /// Changes the app locale and persists the choice.
  ///
  /// Pass `null` to revert to the system locale.
  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
    // AsyncData(...) updates the state synchronously so the UI reacts
    // before the next async frame.
    state = AsyncData(locale);
  }
}

/// Global provider for the user's locale preference.
///
/// Use [ref.watch(localeProvider)] in [MaterialApp] to make locale reactive:
/// ```dart
/// locale: ref.watch(localeProvider).whenOrNull(data: (l) => l),
/// ```
final localeProvider = AsyncNotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
