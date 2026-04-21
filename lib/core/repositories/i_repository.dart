/// Generic base repository contract for CRUD operations.
///
/// All concrete repository interfaces extend this to ensure a consistent
/// surface area across entity types. Implementations live in `lib/data/local/`.
abstract class IRepository<T> {
  /// Returns all persisted entities of type [T].
  Future<List<T>> findAll();

  /// Returns the entity with the given [id], or `null` if not found.
  Future<T?> findById(String id);

  /// Inserts [entity] into the store.
  ///
  /// Throws [DatabaseException] on conflict or I/O failure.
  Future<void> save(T entity);

  /// Updates the persisted record matching [entity]'s id.
  ///
  /// Throws [NotFoundException] if no record exists for that id.
  Future<void> update(T entity);

  /// Deletes the record identified by [id].
  ///
  /// No-op if the record does not exist.
  Future<void> delete(String id);
}
