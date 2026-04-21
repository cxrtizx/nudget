import 'dart:async';

import 'package:nudget/core/services/i_notification_listener_service.dart';

/// iOS stub implementation of [INotificationListenerService].
///
/// iOS does not allow third-party apps to read system notifications posted by
/// other apps. This stub always reports `hasPermission: false` and never emits
/// on [notificationStream]. The app remains fully functional on iOS via manual
/// expense entry.
class IosNotificationListener implements INotificationListenerService {
  /// Creates an [IosNotificationListener].
  const IosNotificationListener();

  // A stream that never emits — constructed once and reused.
  static final Stream<RawNotificationData> _empty =
      const Stream<RawNotificationData>.empty();

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<void> requestPermission() async {
    // No-op: the UI layer shows an informational message instead of navigating
    // to settings, since no relevant iOS setting exists.
  }

  @override
  Future<void> startListening() async {}

  @override
  Future<void> stopListening() async {}

  @override
  Stream<RawNotificationData> get notificationStream => _empty;
}
