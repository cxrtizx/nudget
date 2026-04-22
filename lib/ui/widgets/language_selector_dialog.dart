import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/core/utils/l10n_extension.dart';
import 'package:nudget/providers/locale_provider.dart';

/// Opens a bottom sheet that lets the user pick a language.
///
/// The four options are:
/// - System default (null locale — follows the device OS)
/// - English
/// - Spanish
/// - Galician
///
/// The chosen value is persisted via [localeProvider] and applied immediately
/// without restarting the app, because [MaterialApp.locale] is reactive.
Future<void> showLanguageSelectorSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    // useSafeArea keeps the sheet above the home indicator on iOS.
    useSafeArea: true,
    builder: (context) => const _LanguageSelectorSheet(),
  );
}

class _LanguageSelectorSheet extends ConsumerWidget {
  const _LanguageSelectorSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // whenOrNull(data: ...) returns null while still loading, which is fine —
    // null also means "system default", so the UI renders correctly.
    final current = ref.watch(localeProvider).whenOrNull(data: (l) => l);
    final l10n = context.l10n;
    final theme = Theme.of(context);

    // Each entry is a (label, Locale?) pair.
    // null locale = "follow system"; non-null = forced override.
    final options = [
      (label: l10n.languageSystem, locale: null as Locale?),
      (label: l10n.languageEnglish, locale: const Locale('en')),
      (label: l10n.languageSpanish, locale: const Locale('es')),
      (label: l10n.languageGalician, locale: const Locale('gl')),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.language,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),
        // RadioGroup manages the selected value for all RadioListTile children.
        // Tapping any option saves the preference and closes the sheet.
        RadioGroup<Locale?>(
          groupValue: current,
          onChanged: (selected) {
            // setLocale persists the choice and updates the provider state,
            // which propagates back to MaterialApp.locale immediately.
            ref.read(localeProvider.notifier).setLocale(selected);
            Navigator.of(context).pop();
          },
          child: Column(
            children: options
                .map(
                  (opt) => RadioListTile<Locale?>(
                    title: Text(opt.label),
                    value: opt.locale,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
