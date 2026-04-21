import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nudget/core/models/category.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/utils/category_icon_mapper.dart';
import 'package:nudget/providers/category_providers.dart';
import 'package:nudget/providers/expense_providers.dart';

/// Opens a modal bottom sheet for viewing and editing [expense].
///
/// Returns `true` when the expense was deleted so the caller can react.
Future<bool> showExpenseDetailSheet(
  BuildContext context, {
  required Expense expense,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ExpenseDetailSheet(expense: expense),
  );
  return result ?? false;
}

// ---------------------------------------------------------------------------
// Sheet widget
// ---------------------------------------------------------------------------

class _ExpenseDetailSheet extends ConsumerStatefulWidget {
  const _ExpenseDetailSheet({required this.expense});

  final Expense expense;

  @override
  ConsumerState<_ExpenseDetailSheet> createState() =>
      _ExpenseDetailSheetState();
}

class _ExpenseDetailSheetState extends ConsumerState<_ExpenseDetailSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descController;
  late final TextEditingController _amountController;
  String? _selectedCategoryId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _descController =
        TextEditingController(text: widget.expense.description);
    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(2),
    );
    _selectedCategoryId = widget.expense.categoryId;
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoryListProvider);
    final categories =
        categoriesAsync.whenOrNull(data: (c) => c) ?? <Category>[];
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit expense',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),

                      // Description
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Amount
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount (€)',
                          border: OutlineInputBorder(),
                          prefixText: '€ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[.,]?\d{0,2}'),
                          ),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          final parsed =
                              double.tryParse(v.replaceAll(',', '.'));
                          if (parsed == null || parsed < 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category picker
                      _CategoryDropdown(
                        categories: categories,
                        selectedId: _selectedCategoryId,
                        onChanged: (id) =>
                            setState(() => _selectedCategoryId = id),
                      ),
                      const SizedBox(height: 20),

                      // Read-only metadata
                      _MetaRow(
                        label: 'Date',
                        value: DateFormat('d MMM yyyy, HH:mm')
                            .format(widget.expense.date),
                      ),
                      const SizedBox(height: 8),
                      _MetaRow(
                        label: 'Source',
                        value: widget.expense.notificationSource,
                      ),
                      if (widget.expense.rawNotificationText.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _MetaRow(
                          label: 'Original text',
                          value: widget.expense.rawNotificationText,
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                                side: BorderSide(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                              onPressed:
                                  _isSaving ? null : _confirmDelete,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check),
                              label: const Text('Save'),
                              onPressed: _isSaving ? null : _save,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final amount = double.parse(
        _amountController.text.replaceAll(',', '.'),
      );
      final updated = widget.expense.copyWith(
        description: _descController.text.trim(),
        amount: amount,
        categoryId: _selectedCategoryId,
        autoClassified: widget.expense.autoClassified &&
            (_selectedCategoryId == null ||
                _selectedCategoryId == widget.expense.categoryId),
      );
      await ref.read(expenseListProvider.notifier).edit(updated);
      await ref.read(unclassifiedExpensesProvider.notifier).refresh();
      if (mounted) Navigator.of(context).pop(false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style:
                TextButton.styleFrom(foregroundColor: ctx.colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(expenseListProvider.notifier).remove(widget.expense.id);
      await ref.read(unclassifiedExpensesProvider.notifier).refresh();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Private helper widgets
// ---------------------------------------------------------------------------

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.categories,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      // ignore: deprecated_member_use
      value: selectedId,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(child: Text('Uncategorised')),
        ...categories.map(
          (c) => DropdownMenuItem(
            value: c.id,
            child: Row(
              children: [
                Icon(
                  CategoryIconMapper.resolve(c.icon),
                  size: 18,
                  color: c.color,
                ),
                const SizedBox(width: 8),
                Text(c.name),
              ],
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Extension helpers
// ---------------------------------------------------------------------------

extension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
