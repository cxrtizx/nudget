import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/core/models/notification_source.dart';
import 'package:nudget/core/utils/l10n_extension.dart';
import 'package:nudget/providers/notification_source_providers.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

Future<void> showCreateEditNotificationSourceSheet(
  BuildContext context, {
  NotificationSource? source,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CreateEditNotificationSourceSheet(source: source),
    );

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class CreateEditNotificationSourceSheet extends ConsumerStatefulWidget {
  const CreateEditNotificationSourceSheet({this.source, super.key});

  final NotificationSource? source;

  @override
  ConsumerState<CreateEditNotificationSourceSheet> createState() =>
      _CreateEditNotificationSourceSheetState();
}

class _CreateEditNotificationSourceSheetState
    extends ConsumerState<CreateEditNotificationSourceSheet> {
  static const _uuid = Uuid();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _appNameController;
  late final TextEditingController _patternController;
  final TextEditingController _testController = TextEditingController();

  late bool _isEnabled;
  bool _isSaving = false;

  // Live-test result
  String? _testAmount;
  String? _testMerchant;
  bool _testNoMatch = false;

  bool get _isEditMode => widget.source != null;

  @override
  void initState() {
    super.initState();
    final s = widget.source;
    _appNameController = TextEditingController(text: s?.appName ?? '');
    _patternController = TextEditingController(text: s?.pattern ?? '');
    _isEnabled = s?.isEnabled ?? true;

    _patternController.addListener(_updateTestResult);
    _testController.addListener(_updateTestResult);
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _patternController.dispose();
    _testController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Pattern helpers
  // ---------------------------------------------------------------------------

  static RegExp? _patternToRegex(String pattern) {
    if (!pattern.contains('{importe}')) return null;
    final tokenRegex = RegExp(r'\{importe\}|\{concepto\}');
    final parts = pattern.split(tokenRegex);
    final tokens =
        tokenRegex.allMatches(pattern).map((m) => m.group(0)!).toList();
    final buffer = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      buffer.write(RegExp.escape(parts[i]));
      if (i < tokens.length) {
        buffer.write(switch (tokens[i]) {
          '{importe}' => r'(?<amount>\d+[,\.]\d{1,2})',
          '{concepto}' => r'(?<merchant>.+?)',
          _ => '',
        });
      }
    }
    return RegExp(buffer.toString(), caseSensitive: false);
  }

  void _updateTestResult() {
    final testText = _testController.text;
    if (testText.isEmpty) {
      setState(() {
        _testAmount = null;
        _testMerchant = null;
        _testNoMatch = false;
      });
      return;
    }

    final regex = _patternToRegex(_patternController.text);
    if (regex == null) {
      setState(() {
        _testAmount = null;
        _testMerchant = null;
        _testNoMatch = false;
      });
      return;
    }

    final match = regex.firstMatch(testText);
    if (match == null) {
      setState(() {
        _testAmount = null;
        _testMerchant = null;
        _testNoMatch = true;
      });
    } else {
      setState(() {
        _testAmount = match.namedGroup('amount');
        _testMerchant = match.namedGroup('merchant');
        _testNoMatch = false;
      });
    }
  }

  void _insertAtCursor(TextEditingController controller, String text) {
    final sel = controller.selection;
    final current = controller.text;
    final start = sel.start < 0 ? current.length : sel.start;
    final end = sel.end < 0 ? current.length : sel.end;
    final newText =
        current.substring(0, start) + text + current.substring(end);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + text.length),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final recentApps = ref.watch(uniqueAppNamesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 1.0,
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
                    _isEditMode
                        ? l10n.editNotificationSource
                        : l10n.newNotificationSource,
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

                      // ── App name ──────────────────────────────────────────
                      _SectionLabel(l10n.appNameLabel),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _appNameController,
                        decoration: InputDecoration(
                          hintText: 'Google Pay, Revolut…',
                          border: const OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? l10n.nameRequired
                                : null,
                      ),

                      if (recentApps.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _SectionLabel(l10n.selectFromRecent),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: recentApps
                              .map(
                                (app) => ActionChip(
                                  label: Text(app),
                                  onPressed: () => _appNameController.text =
                                      app,
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Pattern ───────────────────────────────────────────
                      _SectionLabel(l10n.patternLabel),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _patternController,
                        decoration: InputDecoration(
                          hintText: l10n.patternHint('{importe}', '{concepto}'),
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.nameRequired;
                          }
                          if (!v.contains('{importe}')) {
                            return l10n.patternRequiresAmount('{importe}');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.add, size: 16),
                            label: const Text('{importe}'),
                            onPressed: () =>
                                _insertAtCursor(_patternController, '{importe}'),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.add, size: 16),
                            label: const Text('{concepto}'),
                            onPressed: () =>
                                _insertAtCursor(
                                    _patternController, '{concepto}'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Live test ─────────────────────────────────────────
                      _SectionLabel(l10n.testPatternLabel),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _testController,
                        decoration: InputDecoration(
                          hintText: l10n.testPatternHint,
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),

                      if (_testController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _TestResultWidget(
                          amount: _testAmount,
                          merchant: _testMerchant,
                          noMatch: _testNoMatch,
                        ),
                      ],

                      const SizedBox(height: 16),

                      // ── Enabled toggle ────────────────────────────────────
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.enabledLabel),
                        value: _isEnabled,
                        onChanged: (v) => setState(() => _isEnabled = v),
                      ),

                      const SizedBox(height: 24),

                      // ── Save button ───────────────────────────────────────
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
                              : Text(
                                  _isEditMode
                                      ? l10n.saveChanges
                                      : l10n.create,
                                ),
                        ),
                      ),

                      // ── Delete button (edit only) ─────────────────────────
                      if (_isEditMode) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: TextButton(
                            onPressed: _isSaving ? null : _confirmDelete,
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                            ),
                            child: Text(l10n.delete),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
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

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(notificationSourceListProvider.notifier);

      if (_isEditMode) {
        await notifier.edit(
          widget.source!.copyWith(
            appName: _appNameController.text.trim(),
            pattern: _patternController.text.trim(),
            isEnabled: _isEnabled,
          ),
        );
      } else {
        await notifier.add(
          NotificationSource(
            id: _uuid.v4(),
            appName: _appNameController.text.trim(),
            pattern: _patternController.text.trim(),
            isEnabled: _isEnabled,
            createdAt: DateTime.now().toUtc(),
          ),
        );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToSaveSource(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteExpenseTitle),
        content: Text(l10n.cannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isSaving = true);

    try {
      await ref
          .read(notificationSourceListProvider.notifier)
          .remove(widget.source!.id);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToDeleteSource(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

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

class _TestResultWidget extends StatelessWidget {
  const _TestResultWidget({
    required this.amount,
    required this.merchant,
    required this.noMatch,
  });

  final String? amount;
  final String? merchant;
  final bool noMatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    if (noMatch) {
      return Text(
        l10n.patternNoMatch,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (amount != null)
          Chip(
            label: Text(l10n.patternMatchAmount(amount!)),
            backgroundColor: theme.colorScheme.primaryContainer,
            labelStyle: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        if (merchant != null)
          Chip(
            label: Text(l10n.patternMatchMerchant(merchant!)),
            backgroundColor: theme.colorScheme.secondaryContainer,
            labelStyle: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
      ],
    );
  }
}
