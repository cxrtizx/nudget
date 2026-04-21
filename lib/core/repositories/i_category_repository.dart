import 'package:nudget/core/models/category.dart';
import 'package:nudget/core/repositories/i_repository.dart';

/// Repository contract for [Category] persistence.
///
/// No extra query methods beyond [IRepository] are required at this stage;
/// the interface exists as a seam for test mocking and future extension.
abstract class ICategoryRepository extends IRepository<Category> {}
