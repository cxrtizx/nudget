import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/core/models/category.dart';
import 'package:nudget/core/utils/category_icon_mapper.dart';
import 'package:nudget/providers/category_providers.dart';
import 'package:nudget/ui/widgets/color_picker_grid.dart';
import 'package:nudget/ui/widgets/icon_picker_grid.dart';
import 'package:uuid/uuid.dart';

/// Modal bottom sheet for creating a new category or editing an existing one.
///
/// Pass [initialCategory] to enter edit mode; omit it (or pass `null`) to
/// enter create mode.
class CreateEditCategorySheet extends ConsumerStatefulWidget {
  /// Creates a [CreateEditCategorySheet].
  const CreateEditCategorySheet({this.initialCategory, super.key});

  /// Pre-populated category when editing. `null` means create mode.
  final Category? initialCategory;

  @override
  ConsumerState<CreateEditCategorySheet> createState() =>
      _CreateEditCategorySheetState();
}

class _CreateEditCategorySheetState
    extends ConsumerState<CreateEditCategorySheet> {
  static const Uuid _uuid = Uuid();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _limitController;

  late String _selectedIcon;
  late Color _selectedColor;
  bool _isSaving = false;

  bool get _isEditMode => widget.initialCategory != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCategory;
    _selectedIcon = initial?.icon ?? CategoryIconMapper.allNames.first;
    _selectedColor = initial?.color ?? CategoryColorPalette.colors.first;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _limitController = TextEditingController(
      text: initial?.spendingLimit?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    _isEditMode ? 'Edit category' : 'New category',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _SectionLabel('Name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Groceries',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Name is required'
                                : null,
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel('Spending limit (€, optional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _limitController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 300',
                          prefixText: '€ ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final parsed = double.tryParse(v.trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a positive number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel('Color'),
                      const SizedBox(height: 12),
                      ColorPickerGrid(
                        selectedColor: _selectedColor,
                        onSelected: (c) =>
                            setState(() => _selectedColor = c),
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel('Icon'),
                      const SizedBox(height: 12),
                      IconPickerGrid(
                        selectedIconName: _selectedIcon,
                        accentColor: _selectedColor,
                        onSelected: (name) =>
                            setState(() => _selectedIcon = name),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _isSaving ? null : _submit,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_isEditMode ? 'Save changes' : 'Create'),
                        ),
                      ),
                      const SizedBox(height: 24),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final limitText = _limitController.text.trim();
    final spendingLimit =
        limitText.isNotEmpty ? double.tryParse(limitText) : null;

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(categoryListProvider.notifier);

      if (_isEditMode) {
        final updated = widget.initialCategory!.copyWith(
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          color: _selectedColor,
          spendingLimit: spendingLimit,
        );
        await notifier.edit(updated);
      } else {
        final category = Category(
          id: _uuid.v4(),
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          color: _selectedColor,
          spendingLimit: spendingLimit,
          createdAt: DateTime.now().toUtc(),
        );
        await notifier.add(category);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save category: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
}

/// Convenience function that shows [CreateEditCategorySheet] as a modal sheet.
Future<void> showCreateEditCategorySheet(
  BuildContext context, {
  Category? initialCategory,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          CreateEditCategorySheet(initialCategory: initialCategory),
    );
