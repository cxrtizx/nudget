import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nudget/core/utils/l10n_extension.dart';
import 'package:nudget/providers/notification_providers.dart';
import 'package:nudget/providers/theme_provider.dart';
import 'package:nudget/providers/user_profile_provider.dart';
import 'package:nudget/routes.dart';
import 'package:nudget/ui/widgets/language_selector_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final userName =
        ref.watch(userNameProvider).whenOrNull(data: (n) => n) ?? '';
    final themeMode =
        ref.watch(themeModeProvider).whenOrNull(data: (m) => m) ??
            ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SettingsSection(
            title: l10n.profileSection,
            children: [
              _ProfileTile(userName: userName),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: l10n.appearanceSection,
            children: [
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(l10n.language),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLanguageSelectorSheet(context),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(l10n.themeLabel),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemePicker(context, themeMode),
              ),
            ],
          ),
          if (Platform.isAndroid) ...[
            const SizedBox(height: 16),
            _SettingsSection(
              title: l10n.notificationsSection,
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(l10n.manageNotificationAccess),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () =>
                      ref.read(notificationListenerProvider).requestPermission(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: l10n.automationSection,
              children: [
                ListTile(
                  leading: const Icon(Icons.tune_outlined),
                  title: Text(l10n.notificationSourcesTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(kRouteNotificationSources),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, ThemeMode current) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (_) => _ThemePickerSheet(current: current),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile tile — avatar + editable name
// ---------------------------------------------------------------------------

class _ProfileTile extends ConsumerWidget {
  const _ProfileTile({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          _initials(userName),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(l10n.editProfileName),
      subtitle: Text(
        userName.isNotEmpty ? userName : '—',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.edit_outlined),
      onTap: () => _editName(context, ref),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: userName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editProfileName),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null) {
      await ref.read(userNameProvider.notifier).setName(result);
    }
  }
}

// ---------------------------------------------------------------------------
// Theme picker bottom sheet
// ---------------------------------------------------------------------------

class _ThemePickerSheet extends ConsumerWidget {
  const _ThemePickerSheet({required this.current});

  final ThemeMode current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final options = [
      (
        label: l10n.themeSystem,
        mode: ThemeMode.system,
        icon: Icons.brightness_auto_outlined
      ),
      (
        label: l10n.themeLight,
        mode: ThemeMode.light,
        icon: Icons.light_mode_outlined
      ),
      (
        label: l10n.themeDark,
        mode: ThemeMode.dark,
        icon: Icons.dark_mode_outlined
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
            child: Text(l10n.themeLabel, style: theme.textTheme.titleMedium),
          ),
        ),
        RadioGroup<ThemeMode>(
          groupValue: current,
          onChanged: (selected) {
            ref.read(themeModeProvider.notifier).setThemeMode(selected!);
            Navigator.of(context).pop();
          },
          child: Column(
            children: options
                .map(
                  (opt) => RadioListTile<ThemeMode>(
                    title: Text(opt.label),
                    secondary: Icon(opt.icon),
                    value: opt.mode,
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

// ---------------------------------------------------------------------------
// Reusable section wrapper
// ---------------------------------------------------------------------------

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}
