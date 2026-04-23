import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/l10n/app_localizations.dart';
import 'package:nudget/providers/locale_provider.dart';
import 'package:nudget/providers/notification_providers.dart';
import 'package:nudget/providers/theme_provider.dart';
import 'package:nudget/routes.dart';
import 'package:nudget/ui/theme/app_theme.dart';

/// Root application widget.
///
/// Responsibilities beyond routing and theming:
/// - Wires up the three supported locales (EN / ES / GL) and a persisted
///   locale preference via [localeProvider].
/// - Activates [notificationPipelineProvider] for the entire app lifetime.
/// - Requests notification-read permission on first launch (Android only).
class NudgetApp extends ConsumerStatefulWidget {
  /// Creates a [NudgetApp].
  const NudgetApp({super.key});

  @override
  ConsumerState<NudgetApp> createState() => _NudgetAppState();
}

class _NudgetAppState extends ConsumerState<NudgetApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startup());
  }

  @override
  Widget build(BuildContext context) {
    // Keep the notification pipeline alive for the whole app lifetime.
    ref.watch(notificationPipelineProvider);

    // Read the persisted locale; null means "follow the system".
    final locale = ref.watch(localeProvider).whenOrNull(data: (l) => l);
    final themeMode =
        ref.watch(themeModeProvider).whenOrNull(data: (m) => m) ??
            ThemeMode.system;

    return MaterialApp.router(
      title: 'Nudget',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      // ── Localisation wiring ────────────────────────────────────────────
      // localizationsDelegates tells Flutter how to load our translations
      // plus the ones built into Material/Cupertino widgets.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // supportedLocales is the list the OS picks from when choosing the
      // best match for the device language.
      supportedLocales: AppLocalizations.supportedLocales,
      // When locale is null Flutter automatically matches the device OS
      // language to a supported one; when non-null the user override wins.
      locale: locale,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _startup() async {
    if (!Platform.isAndroid) return;

    final listener = ref.read(notificationListenerProvider);
    final hasPermission = await listener.hasPermission();

    if (hasPermission) {
      await listener.startListening();
      return;
    }

    if (!mounted) return;
    // NudgetApp's own context sits above MaterialApp.router, so it has no
    // MaterialLocalizations. Use the router navigator's context instead.
    final navContext = appRouter.routerDelegate.navigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) return;
    final accepted = await showDialog<bool>(
      context: navContext,
      barrierDismissible: false,
      builder: (_) => const _NotificationPermissionDialog(),
    );

    if (accepted ?? false) {
      await listener.requestPermission();
      if (await listener.hasPermission()) {
        await listener.startListening();
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Permission dialog — uses l10n once the widget tree has Localizations
// ---------------------------------------------------------------------------

class _NotificationPermissionDialog extends StatelessWidget {
  const _NotificationPermissionDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      icon: Icon(
        Icons.notifications_active_outlined,
        size: 40,
        color: theme.colorScheme.primary,
      ),
      title: Text(l10n.notificationAccessTitle),
      content: Text(l10n.notificationAccessContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.notNow),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.allow),
        ),
      ],
    );
  }
}
