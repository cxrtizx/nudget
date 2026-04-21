import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/providers/notification_providers.dart';
import 'package:nudget/routes.dart';
import 'package:nudget/ui/theme/app_theme.dart';

/// Root application widget.
///
/// Responsibilities beyond routing and theming:
/// - Activates [notificationPipelineProvider] so the stream subscription is
///   kept alive for the entire app lifetime.
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
    // Defer startup work until after the first frame so context is valid.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startup());
  }

  @override
  Widget build(BuildContext context) {
    // Watching the pipeline provider here ensures the subscription is created
    // immediately and stays alive as long as NudgetApp is in the tree.
    ref.watch(notificationPipelineProvider);

    return MaterialApp.router(
      title: 'Nudget',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
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

    // No permission yet — show a dialog and, if accepted, open system settings.
    if (!mounted) return;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _NotificationPermissionDialog(),
    );

    if (accepted ?? false) {
      await listener.requestPermission();
      // Re-check after the user returns from system settings.
      if (await listener.hasPermission()) {
        await listener.startListening();
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Permission dialog
// ---------------------------------------------------------------------------

class _NotificationPermissionDialog extends StatelessWidget {
  const _NotificationPermissionDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      icon: Icon(
        Icons.notifications_active_outlined,
        size: 40,
        color: theme.colorScheme.primary,
      ),
      title: const Text('Notification access'),
      content: const Text(
        'Nudget reads your payment notifications to log expenses '
        'automatically. Grant "Notification access" in the next screen '
        'to enable this feature.\n\n'
        'You can still add expenses manually without this permission.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Allow'),
        ),
      ],
    );
  }
}
