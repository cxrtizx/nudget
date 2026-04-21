/// Raw notification payload delivered by the platform notification listener.
class RawNotificationData {
  /// Creates a [RawNotificationData].
  const RawNotificationData({
    required this.packageName,
    required this.appName,
    required this.title,
    required this.body,
    required this.timestamp,
  });

  /// Originating app package name (e.g. `'es.lacaixa.mobile.android'`).
  final String packageName;

  /// Human-readable app name resolved from [packageName].
  final String appName;

  /// Notification title text.
  final String title;

  /// Notification body text — the primary input for [NotificationParser].
  final String body;

  /// Time the notification was posted (device local time).
  final DateTime timestamp;

  @override
  String toString() =>
      'RawNotificationData(app: $appName, title: $title, body: $body)';
}

/// Abstract contract for the platform notification listener service.
///
/// The Android implementation uses `flutter_notification_listener` with a
/// foreground service to keep the listener alive when the app is in background.
/// The iOS implementation is a no-op stub — iOS does not allow third-party
/// apps to read system notifications from other apps.
abstract class INotificationListenerService {
  /// Requests the platform permission required to read notifications.
  ///
  /// On Android, redirects the user to the system Notification access settings
  /// screen. On iOS, shows an informational dialog explaining the limitation.
  Future<void> requestPermission();

  /// Returns `true` if the app currently holds notification-read permission.
  ///
  /// Always returns `false` on iOS.
  Future<bool> hasPermission();

  /// Starts the background notification listener service.
  ///
  /// On Android, this launches the foreground service that keeps the listener
  /// alive when the app is in the background. On iOS this is a no-op.
  Future<void> startListening();

  /// Stops the background notification listener service.
  ///
  /// No-op on iOS.
  Future<void> stopListening();

  /// Broadcasts [RawNotificationData] for each notification posted by any app.
  ///
  /// Emits only while the listener service is running and has permission.
  /// On iOS this stream never emits.
  Stream<RawNotificationData> get notificationStream;
}
