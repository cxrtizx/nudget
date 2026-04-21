import 'package:flutter_test/flutter_test.dart';
import 'package:nudget/core/models/classification_rule.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/repositories/i_classification_rule_repository.dart';
import 'package:nudget/core/repositories/i_expense_repository.dart';
import 'package:nudget/core/services/classification_service.dart';

// ---------------------------------------------------------------------------
// In-memory fakes — no mocking framework required
// ---------------------------------------------------------------------------

class _FakeExpenseRepository implements IExpenseRepository {
  final List<Expense> _store = [];
  int incrementMatchCountCallCount = 0;

  @override
  Future<List<Expense>> findAll() async => List.unmodifiable(_store);

  @override
  Future<Expense?> findById(String id) async =>
      _store.where((e) => e.id == id).firstOrNull;

  @override
  Future<void> save(Expense entity) async => _store.add(entity);

  @override
  Future<void> update(Expense entity) async {
    final idx = _store.indexWhere((e) => e.id == entity.id);
    if (idx != -1) _store[idx] = entity;
  }

  @override
  Future<void> delete(String id) async =>
      _store.removeWhere((e) => e.id == id);

  @override
  Future<List<Expense>> findByDateRange(DateTime from, DateTime to) async =>
      _store.where((e) => !e.date.isBefore(from) && !e.date.isAfter(to)).toList();

  @override
  Future<List<Expense>> findUnclassified() async =>
      _store.where((e) => e.categoryId == null).toList();

  @override
  Future<List<Expense>> findByCategoryId(String categoryId) async =>
      _store.where((e) => e.categoryId == categoryId).toList();
}

class _FakeRuleRepository implements IClassificationRuleRepository {
  _FakeRuleRepository(List<ClassificationRule> initial)
      : _store = List.of(initial);

  final List<ClassificationRule> _store;
  final List<String> incrementedIds = [];

  // Returns rules sorted by matchCount descending — mirrors real repository.
  @override
  Future<List<ClassificationRule>> findAll() async =>
      [..._store]..sort((a, b) => b.matchCount.compareTo(a.matchCount));

  @override
  Future<ClassificationRule?> findById(String id) async =>
      _store.where((r) => r.id == id).firstOrNull;

  @override
  Future<void> save(ClassificationRule entity) async => _store.add(entity);

  @override
  Future<void> update(ClassificationRule entity) async {
    final idx = _store.indexWhere((r) => r.id == entity.id);
    if (idx != -1) _store[idx] = entity;
  }

  @override
  Future<void> delete(String id) async =>
      _store.removeWhere((r) => r.id == id);

  @override
  Future<void> incrementMatchCount(String ruleId) async {
    incrementedIds.add(ruleId);
    final idx = _store.indexWhere((r) => r.id == ruleId);
    if (idx != -1) {
      _store[idx] = _store[idx].copyWith(matchCount: _store[idx].matchCount + 1);
    }
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ClassificationRule _rule({
  required String id,
  required String pattern,
  required String categoryId,
  int matchCount = 0,
}) =>
    ClassificationRule(
      id: id,
      pattern: pattern,
      categoryId: categoryId,
      createdAt: DateTime(2024),
      matchCount: matchCount,
    );

Expense _expense({
  String id = 'exp-1',
  String description = 'Mercadona',
}) =>
    Expense(
      id: id,
      amount: 30.0,
      description: description,
      date: DateTime(2024, 6, 1),
      notificationSource: 'es.lacaixa.mobile.android',
      autoClassified: false,
      rawNotificationText: 'Pago de 30,00€ en $description',
      createdAt: DateTime(2024, 6, 1),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeExpenseRepository expenseRepo;
  late _FakeRuleRepository ruleRepo;
  late ClassificationService service;

  setUp(() {
    expenseRepo = _FakeExpenseRepository();
    ruleRepo = _FakeRuleRepository([]);
    service = ClassificationService(
      rulesRepository: ruleRepo,
      expenseRepository: expenseRepo,
    );
  });

  tearDown(() => service.dispose());

  group('ClassificationService.classify', () {
    test('exact match — assigns correct categoryId and sets autoClassified', () async {
      ruleRepo._store.add(_rule(
        id: 'r1',
        pattern: 'Mercadona',
        categoryId: 'cat-groceries',
      ));

      final result = await service.classify(_expense());

      expect(result.categoryId, 'cat-groceries');
      expect(result.autoClassified, isTrue);
    });

    test('partial match — pattern matches substring of description', () async {
      ruleRepo._store.add(_rule(
        id: 'r1',
        pattern: 'merca',
        categoryId: 'cat-groceries',
      ));

      final result = await service.classify(_expense(description: 'Mercadona'));
      expect(result.categoryId, 'cat-groceries');
    });

    test('case-insensitive match', () async {
      ruleRepo._store.add(_rule(
        id: 'r1',
        pattern: 'MERCADONA',
        categoryId: 'cat-groceries',
      ));

      final result = await service.classify(_expense(description: 'mercadona'));
      expect(result.categoryId, 'cat-groceries');
    });

    test('no match — expense saved as unclassified', () async {
      ruleRepo._store.add(_rule(
        id: 'r1',
        pattern: 'Repsol',
        categoryId: 'cat-transport',
      ));

      final result = await service.classify(_expense(description: 'Amazon'));
      expect(result.categoryId, isNull);
      expect(result.autoClassified, isFalse);
    });

    test('no rules — expense saved as unclassified', () async {
      final result = await service.classify(_expense());
      expect(result.categoryId, isNull);
      expect(result.autoClassified, isFalse);
    });

    test('matching rule has its matchCount incremented', () async {
      ruleRepo._store.add(_rule(id: 'r1', pattern: 'Mercadona', categoryId: 'cat-1'));

      await service.classify(_expense());

      expect(ruleRepo.incrementedIds, contains('r1'));
    });

    test('non-matching rules do not have matchCount incremented', () async {
      ruleRepo._store.add(_rule(id: 'r1', pattern: 'Repsol', categoryId: 'cat-1'));

      await service.classify(_expense(description: 'Amazon'));

      expect(ruleRepo.incrementedIds, isEmpty);
    });

    test('priority order — higher matchCount rule is tested first', () async {
      // r-low matches but r-high (higher matchCount) should win.
      ruleRepo._store.addAll([
        _rule(id: 'r-low', pattern: 'Mercadona', categoryId: 'cat-low', matchCount: 1),
        _rule(id: 'r-high', pattern: 'Merca', categoryId: 'cat-high', matchCount: 50),
      ]);

      final result = await service.classify(_expense(description: 'Mercadona'));

      // r-high has higher matchCount → tested first → wins
      expect(result.categoryId, 'cat-high');
    });

    test('first matching rule wins when multiple rules match', () async {
      ruleRepo._store.addAll([
        _rule(id: 'r1', pattern: 'Amazon', categoryId: 'cat-A', matchCount: 10),
        _rule(id: 'r2', pattern: 'amazon', categoryId: 'cat-B', matchCount: 5),
      ]);

      final result = await service.classify(_expense(description: 'Amazon'));
      expect(result.categoryId, 'cat-A');
    });

    test('expense is persisted to the repository', () async {
      ruleRepo._store.add(_rule(id: 'r1', pattern: 'Mercadona', categoryId: 'cat-1'));
      final expense = _expense();

      await service.classify(expense);

      expect(await expenseRepo.findById(expense.id), isNotNull);
    });
  });

  group('ClassificationService.testRule', () {
    test('returns true when pattern matches text', () {
      expect(service.testRule('mercadona', 'Mercadona'), isTrue);
    });

    test('returns false when pattern does not match', () {
      expect(service.testRule('repsol', 'Mercadona'), isFalse);
    });

    test('returns false for invalid regex without throwing', () {
      expect(service.testRule('[invalid', 'text'), isFalse);
    });
  });

  group('ClassificationService.createRuleFromDescription', () {
    test('saves a new rule to the repository', () async {
      await service.createRuleFromDescription(
        description: 'Mercadona',
        categoryId: 'cat-1',
      );
      final rules = await ruleRepo.findAll();
      expect(rules, hasLength(1));
    });

    test('applies rule retroactively when applyToExisting is true', () async {
      // Save two unclassified expenses first.
      await expenseRepo.save(_expense(id: 'e1', description: 'Mercadona'));
      await expenseRepo.save(_expense(id: 'e2', description: 'Carrefour'));

      await service.createRuleFromDescription(
        description: 'Mercadona',
        categoryId: 'cat-groceries',
        applyToExisting: true,
      );

      final e1 = await expenseRepo.findById('e1');
      final e2 = await expenseRepo.findById('e2');
      expect(e1!.categoryId, 'cat-groceries');
      expect(e2!.categoryId, isNull); // didn't match
    });
  });

  group('ClassificationService.pendingCount stream', () {
    test('emits 0 when there are no unclassified expenses', () async {
      await expectLater(service.pendingCount, emits(0));
    });

    test('emits updated count after classifying an expense', () async {
      ruleRepo._store.add(_rule(id: 'r1', pattern: 'Mercadona', categoryId: 'cat-1'));

      // First unclassified save (no match for 'Amazon').
      await service.classify(_expense(id: 'e1', description: 'Amazon'));

      // Confirm stream emitted 1.
      await expectLater(service.pendingCount, emits(1));
    });
  });
}
