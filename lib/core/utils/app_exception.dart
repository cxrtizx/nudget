/// Thrown when a database read, write, or migration operation fails.
class DatabaseException implements Exception {
  /// Creates a [DatabaseException] with a descriptive [message].
  const DatabaseException(this.message, {this.cause});

  /// Human-readable description of what went wrong.
  final String message;

  /// Underlying error (e.g. the raw [Exception] from sqflite).
  final Object? cause;

  @override
  String toString() => cause != null
      ? 'DatabaseException: $message (caused by: $cause)'
      : 'DatabaseException: $message';
}

/// Thrown by repository [update] and [findById] implementations when no record
/// exists for the requested id.
class NotFoundException implements Exception {
  /// Creates a [NotFoundException] for [entityType] with [id].
  const NotFoundException(this.entityType, this.id);

  /// Name of the entity type (e.g. `'Category'`).
  final String entityType;

  /// The id that could not be located.
  final String id;

  @override
  String toString() => 'NotFoundException: $entityType with id "$id" not found';
}

/// Thrown when an operation is attempted that violates a business rule
/// (e.g. deleting a category that still has associated expenses).
class BusinessRuleException implements Exception {
  /// Creates a [BusinessRuleException] with a descriptive [message].
  const BusinessRuleException(this.message);

  /// Description of the violated rule.
  final String message;

  @override
  String toString() => 'BusinessRuleException: $message';
}
