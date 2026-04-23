import 'dart:async';

import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:nudget/core/services/i_notification_listener_service.dart';
import 'package:nudget/core/utils/logger.dart';
import 'package:nudget/platform/android/background_notification_handler.dart';

/// Android implementation of [INotificationListenerService].
///
/// Uses the `flutter_notification_listener` package, which registers a
/// `NotificationListenerService` in the Android system and keeps it alive via
/// a foreground service (configured in `AndroidManifest.xml`).
///
/// This class must only be instantiated on Android.
class AndroidNotificationListener implements INotificationListenerService {
  /// Creates an [AndroidNotificationListener] and wires up the platform stream.
  AndroidNotificationListener() {
    _initStream();
  }

  static const Logger _log = Logger('AndroidNotificationListener');

  final StreamController<RawNotificationData> _controller =
      StreamController<RawNotificationData>.broadcast();

  StreamSubscription<dynamic>? _portSubscription;

  @override
  Stream<RawNotificationData> get notificationStream => _controller.stream;

  @override
  Future<bool> hasPermission() async {
    try {
      return await NotificationsListener.hasPermission ?? false;
    } catch (e, st) {
      _log.error('hasPermission check failed', e, st);
      return false;
    }
  }

  @override
  Future<void> requestPermission() async {
    try {
      await NotificationsListener.openPermissionSettings();
    } catch (e, st) {
      _log.error('requestPermission failed', e, st);
    }
  }

  /// Starts the foreground notification listener service.
  @override
  Future<void> startListening() async {
    try {
      await NotificationsListener.startService(
        title: 'Nudget',
        description: 'Listening for payment notifications',
      );
      _log.info('Notification listener service started');
    } catch (e, st) {
      _log.error('startListening failed', e, st);
    }
  }

  /// Stops the foreground notification listener service.
  @override
  Future<void> stopListening() async {
    try {
      await NotificationsListener.stopService();
      _log.info('Notification listener service stopped');
    } catch (e, st) {
      _log.error('stopListening failed', e, st);
    }
  }

  /// Closes the internal stream and port subscription.
  void dispose() {
    _portSubscription?.cancel();
    _controller.close();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _initStream() {
    // Register backgroundNotificationHandler as the unified callback:
    //   • Main isolate alive → callback routes event to this receivePort.
    //   • Main isolate gone  → callback writes directly to SQLite.
    NotificationsListener.initialize(
      callbackHandle: backgroundNotificationHandler,
    );

    // Subscribe to the named receive port so events routed from the callback
    // reach the stream and are processed by notificationPipelineProvider.
    _portSubscription = NotificationsListener.receivePort!.listen(
      (dynamic raw) {
        if (raw is! NotificationEvent) return;
        _controller.add(_toRawData(raw));
      },
      onError: (Object e, StackTrace st) =>
          _log.error('receivePort error', e, st),
    );

    _log.info('AndroidNotificationListener initialized');
  }

  RawNotificationData _toRawData(NotificationEvent event) {
    return RawNotificationData(
      packageName: event.packageName ?? '',
      // Human-readable app name is not resolvable in Dart without a platform
      // channel call; use package name as the matching key for now.
      appName: event.packageName ?? '',
      title: event.title ?? '',
      body: event.text ?? '',
      timestamp: event.createAt ?? DateTime.now(),
    );
  }
}
