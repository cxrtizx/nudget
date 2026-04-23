import 'package:nudget/core/models/notification_source.dart';
import 'package:nudget/core/repositories/i_repository.dart';

/// Repository contract for [NotificationSource] persistence.
abstract class INotificationSourceRepository
    extends IRepository<NotificationSource> {
  /// Returns all sources where [NotificationSource.isEnabled] is `true`.
  Future<List<NotificationSource>> findEnabled();
}
