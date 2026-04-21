import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/core/models/category.dart';
import 'package:nudget/core/repositories/i_category_repository.dart';
import 'package:nudget/providers/repository_providers.dart';

/// Notifier that owns the category list and exposes CRUD mutations.
class CategoryListNotifier extends AsyncNotifier<List<Category>> {
  ICategoryRepository get _repo => ref.read(categoryRepositoryProvider);

  @override
  Future<List<Category>> build() =>
      ref.watch(categoryRepositoryProvider).findAll();

  /// Re-fetches the full category list from the repository.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.findAll);
  }

  /// Persists [category] and refreshes the list.
  Future<void> add(Category category) async {
    await _repo.save(category);
    await refresh();
  }

  /// Updates [category] in the repository and refreshes the list.
  Future<void> edit(Category category) async {
    await _repo.update(category);
    await refresh();
  }

  /// Deletes the category identified by [id] and refreshes the list.
  Future<void> remove(String id) async {
    await _repo.delete(id);
    await refresh();
  }
}

/// Provides the full list of categories, ordered alphabetically.
final categoryListProvider =
    AsyncNotifierProvider<CategoryListNotifier, List<Category>>(
  CategoryListNotifier.new,
);

/// Returns a single [Category] by [id], or `null` if not found.
///
/// Derived from [categoryListProvider] to avoid an extra repository call.
final categoryByIdProvider =
    Provider.family<Category?, String>((ref, id) {
  return ref.watch(categoryListProvider).whenOrNull(
        data: (list) =>
            list.where((c) => c.id == id).firstOrNull,
      );
});
