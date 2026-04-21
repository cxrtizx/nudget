import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/core/services/classification_service.dart';
import 'package:nudget/providers/repository_providers.dart';

/// Provides the application-wide [ClassificationService] instance.
///
/// The service is created once per [ProviderScope] and disposed automatically
/// when the scope is destroyed, which closes the internal pending-count stream.
final classificationServiceProvider = Provider<ClassificationService>((ref) {
  final service = ClassificationService(
    rulesRepository: ref.watch(classificationRuleRepositoryProvider),
    expenseRepository: ref.watch(expenseRepositoryProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Wraps [ClassificationService.pendingCount] as a Riverpod [StreamProvider].
///
/// Widgets that display the pending badge should watch this provider rather
/// than accessing the service stream directly.
final pendingCountStreamProvider = StreamProvider<int>((ref) {
  return ref.watch(classificationServiceProvider).pendingCount;
});
