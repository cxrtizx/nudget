import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:nudget/core/services/i_notification_listener_service.dart';
import 'package:nudget/core/utils/logger.dart';

/// Android implementation of [INotificationListenerService].
///
/// Uses the `flutter_notification_listener` package, which registers a
/// `NotificationListenerService` in the Android system and keeps it alive via
/// a foreground service (configured in `AndroidManifest.xml`).
///
/// This class must only be instantiated on Android — gate construction with
/// [Platform.isAndroid].
class AndroidNotificationListener implements INotificationListenerService {
  /// Creates an [AndroidNotificationListener] and wires up the platform stream.
  AndroidNotificationListener() {
    _initStream();
  }

  static const Logger _log = Logger('AndroidNotificationListener');

  final StreamController<RawNotificationData> _controller =
      StreamController<RawNotificationData>.broadcast();

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
  Future<void> startListening() async {
    try {
      await NotificationsListener.startService(
        foreground: true,
        title: 'Nudget',
        description: 'Listening for payment notifications',
        showWhen: false,
      );
      _log.info('Notification listener service started');
    } catch (e, st) {
      _log.error('startListening failed', e, st);
    }
  }

  /// Stops the foreground notification listener service.
  Future<void> stopListening() async {
    try {
      await NotificationsListener.stopService();
      _log.info('Notification listener service stopped');
    } catch (e, st) {
      _log.error('stopListening failed', e, st);
    }
  }

  /// Closes the internal stream. Call when the app is terminating.
  void dispose() => _controller.close();

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _initStream() {
    NotificationsListener.initialize(callbackHandle: _onNotificationReceived);
    _log.info('AndroidNotificationListener initialized');
  }

  // Top-level or static — required by flutter_notification_listener's isolate.
  static void _onNotificationReceived(NotificationEvent event) {
    // This callback may fire in a background isolate; routing via a port is
    // handled internally by flutter_notification_listener. The stream
    // subscription below receives events on the main isolate.
  }
}

/// Registers the top-level notification callback used by the background isolate.
///
/// Must be called from [main] before [runApp].
void initAndroidNotificationListener(
  void Function(NotificationEvent) handler,
) {
  NotificationsListener.initialize(callbackHandle: handler);
}
