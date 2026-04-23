import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/core/models/notification_source.dart';
import 'package:nudget/core/repositories/i_notification_source_repository.dart';
import 'package:nudget/providers/expense_providers.dart';
import 'package:nudget/providers/repository_providers.dart';

/// Notifier that owns the notification source list and exposes mutations.
class NotificationSourceListNotifier
    extends AsyncNotifier<List<NotificationSource>> {
  INotificationSourceRepository get _repo =>
      ref.read(notificationSourceRepositoryProvider);

  @override
  Future<List<NotificationSource>> build() =>
      ref.watch(notificationSourceRepositoryProvider).findAll();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.findAll);
  }

  Future<void> add(NotificationSource source) async {
    await _repo.save(source);
    await refresh();
  }

  Future<void> edit(NotificationSource source) async {
    await _repo.update(source);
    await refresh();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await refresh();
  }

  /// Toggles [NotificationSource.isEnabled] without opening the edit sheet.
  Future<void> toggle(NotificationSource source) =>
      edit(source.copyWith(isEnabled: !source.isEnabled));
}

/// Provides the full list of configured notification sources.
final notificationSourceListProvider = AsyncNotifierProvider<
    NotificationSourceListNotifier, List<NotificationSource>>(
  NotificationSourceListNotifier.new,
);

/// Derives unique app names from existing expenses (excluding `'manual'`).
///
/// Used in the app-picker chips inside [CreateEditNotificationSourceSheet]
/// so the user can tap a known source instead of typing it manually.
final uniqueAppNamesProvider = Provider<List<String>>((ref) {
  final expenses =
      ref.watch(expenseListProvider).whenOrNull(data: (list) => list) ?? [];
  return expenses
      .map((e) => e.notificationSource)
      .where((s) => s != 'manual' && s.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
});
