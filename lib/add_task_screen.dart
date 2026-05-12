import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'app_constants.dart';
import 'app_theme.dart';
import 'extensions.dart';
import 'task_model.dart';
import 'task_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit Task Screen
// ─────────────────────────────────────────────────────────────────────────────

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key, this.existing});
  final TaskModel? existing;

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _titleCtrl;
  late final TextEditingController _typeCtrl;
  late final TextEditingController _tagInputCtrl;

  // State
  late Color _selectedColor;
  late List<String> _tags;
  DateTime? _deadline;
  late bool _notifyAtEvent;
  late bool _notifyOneDay;
  late bool _notifyThreeDays;
  late bool _notifyOneWeek;

  bool _saving = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _typeCtrl = TextEditingController(text: e?.taskType ?? '');
    _tagInputCtrl = TextEditingController();
    _selectedColor = e != null
        ? Color(e.colorValue)
        : AppConstants.taskColors.first;
    _tags = List.from(e?.tags ?? []);
    _deadline = e?.deadline;
    _notifyAtEvent = e?.notifyAtEvent ?? false;
    _notifyOneDay = e?.notifyOneDay ?? false;
    _notifyThreeDays = e?.notifyThreeDays ?? false;
    _notifyOneWeek = e?.notifyOneWeek ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _typeCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _addTag() {
    final val = _tagInputCtrl.text.trim();
    if (val.isNotEmpty && !_tags.contains(val)) {
      setState(() {
        _tags.add(val);
        _tagInputCtrl.clear();
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline ?? now),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted || time == null) return;

    setState(() {
      _deadline = DateTime(
        date.year, date.month, date.day,
        time.hour, time.minute,
      );
    });
  }

  Future<void> _pickColor() async {
    Color temp = _selectedColor;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.pickColor),
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        content: StatefulBuilder(
          builder: (ctx, setSt) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Quick Presets ────────────────────────────────────
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppConstants.taskColors.map((c) {
                    final isSelected = temp.value == c.value;
                    return GestureDetector(
                      onTap: () => setSt(() => temp = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)]
                              : [],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Divider(),
                // ── Full Picker ──────────────────────────────────────
                ColorPicker(
                  color: temp,
                  onColorChanged: (c) => setSt(() => temp = c),
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  enableShadesSelection: true,
                  pickersEnabled: const {
                    ColorPickerType.primary: true,
                    ColorPickerType.accent: true,
                    ColorPickerType.wheel: true,
                  },
                  showColorCode: true,
                  copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                    copyButton: false,
                    pasteButton: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _selectedColor = temp);
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final repo = await ref.read(taskRepositoryProvider.future);

      if (widget.existing == null) {
        await repo.createTask(
          title: _titleCtrl.text.trim(),
          taskType: _typeCtrl.text.trim().isEmpty ? null : _typeCtrl.text.trim(),
          tags: _tags,
          color: _selectedColor,
          deadline: _deadline,
          notifyAtEvent: _notifyAtEvent,
          notifyOneDay: _notifyOneDay,
          notifyThreeDays: _notifyThreeDays,
          notifyOneWeek: _notifyOneWeek,
        );
      } else {
        final updated = widget.existing!.copyWith(
          title: _titleCtrl.text.trim(),
          taskType: _typeCtrl.text.trim().isEmpty
              ? null
              : _typeCtrl.text.trim(),
          tags: _tags,
          colorValue: _selectedColor.value,
          deadline: _deadline,
          notifyAtEvent: _notifyAtEvent,
          notifyOneDay: _notifyOneDay,
          notifyThreeDays: _notifyThreeDays,
          notifyOneWeek: _notifyOneWeek,
        );
        await repo.updateTask(updated);
      }

      if (mounted) Navigator.pop(context);
    // FIX: was try/finally with no catch — exceptions were swallowed silently
    // causing "Unexpected null value" red screen. Now errors show as snackbar.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving task: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editTask : l10n.addTask),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(l10n.save),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          physics: const BouncingScrollPhysics(),
          children: [
            // ── Title ───────────────────────────────────────────────────
            _SectionLabel(l10n.taskTitle),
            _buildTitleField(l10n),
            Gap(16),

            // ── Task Type ────────────────────────────────────────────────
            _SectionLabel(l10n.taskType),
            _buildTypeField(l10n),
            Gap(16),

            // ── Tags ─────────────────────────────────────────────────────
            _SectionLabel(l10n.tags),
            _buildTagSection(l10n),
            Gap(16),

            // ── Color ─────────────────────────────────────────────────────
            _SectionLabel(l10n.color),
            _buildColorSection(l10n),
            Gap(16),

            // ── Deadline ──────────────────────────────────────────────────
            _SectionLabel(l10n.deadline),
            _buildDeadlineSection(l10n),
            Gap(20),

            // ── Notifications ─────────────────────────────────────────────
            _SectionLabel(l10n.notifications),
            _buildNotificationsSection(l10n),
            Gap(40),
          ],
        ),
      ),
    );
  }

  // ── Field Builders ─────────────────────────────────────────────────────────

  Widget _buildTitleField(AppLocalizations l10n) {
    return TextFormField(
      controller: _titleCtrl,
      decoration: InputDecoration(
        hintText: l10n.taskTitleHint,
        prefixIcon: Icon(Icons.title_rounded,
            color: context.colors.onSurfaceVariant),
      ),
      textCapitalization: TextCapitalization.sentences,
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? l10n.required : null,
      maxLines: 2,
      minLines: 1,
    );
  }

  Widget _buildTypeField(AppLocalizations l10n) {
    return TextFormField(
      controller: _typeCtrl,
      decoration: InputDecoration(
        hintText: l10n.taskTypeHint,
        prefixIcon: Icon(Icons.label_outline_rounded,
            color: context.colors.onSurfaceVariant),
      ),
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildTagSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagInputCtrl,
                decoration: InputDecoration(
                  hintText: l10n.tagHint,
                  prefixIcon: Icon(Icons.tag_rounded,
                      color: context.colors.onSurfaceVariant),
                ),
                textCapitalization: TextCapitalization.words,
                onFieldSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _addTag,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.add_rounded),
              ),
            ),
          ],
        ),

        // Tag chips
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _tags
                .map(
                  (t) => Chip(
                    label: Text('#$t',
                        style: context.textTheme.labelSmall),
                    deleteIcon:
                        const Icon(Icons.close_rounded, size: 14),
                    onDeleted: () =>
                        setState(() => _tags.remove(t)),
                    backgroundColor:
                        _selectedColor.withOpacity(0.1),
                    side: BorderSide(
                        color: _selectedColor.withOpacity(0.3)),
                    labelStyle: TextStyle(color: _selectedColor),
                    deleteIconColor: _selectedColor,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildColorSection(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _pickColor,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.isDark
              ? const Color(0xFF252540)
              : const Color(0xFFF0F1F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.outline),
        ),
        child: Row(
          children: [
            // Color circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _selectedColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.color,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.palette_rounded,
                color: context.colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineSection(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.isDark
              ? const Color(0xFF252540)
              : const Color(0xFFF0F1F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                color: _deadline != null
                    ? AppColors.primary
                    : context.colors.onSurfaceVariant,
                size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: _deadline == null
                  ? Text(
                      l10n.pickDate,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant.withOpacity(0.6),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _deadline!.toSmartLabel(locale: locale),
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _deadline!.toTimeOnly(locale: locale),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
            ),
            if (_deadline != null)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () => setState(() => _deadline = null),
                color: context.colors.onSurfaceVariant,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDark
            ? const Color(0xFF1A1A2E)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outline),
      ),
      child: Column(
        children: [
          _NotifToggle(
            label: l10n.atTimeOfEvent,
            icon: Icons.notifications_rounded,
            value: _notifyAtEvent,
            enabled: _deadline != null,
            onChanged: (v) => setState(() => _notifyAtEvent = v),
            isFirst: true,
          ),
          _NotifToggle(
            label: l10n.oneDayBefore,
            icon: Icons.notifications_outlined,
            value: _notifyOneDay,
            enabled: _deadline != null,
            onChanged: (v) => setState(() => _notifyOneDay = v),
          ),
          _NotifToggle(
            label: l10n.threeDaysBefore,
            icon: Icons.notifications_outlined,
            value: _notifyThreeDays,
            enabled: _deadline != null,
            onChanged: (v) => setState(() => _notifyThreeDays = v),
          ),
          _NotifToggle(
            label: l10n.oneWeekBefore,
            icon: Icons.notifications_outlined,
            value: _notifyOneWeek,
            enabled: _deadline != null,
            onChanged: (v) => setState(() => _notifyOneWeek = v),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: context.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: context.colors.onSurface,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// iOS-style Notification Toggle Row
// ─────────────────────────────────────────────────────────────────────────────

class _NotifToggle extends StatelessWidget {
  const _NotifToggle({
    required this.label,
    required this.icon,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.isFirst = false,
    this.isLast = false,
  });

  final String label;
  final IconData icon;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: enabled && value
                    ? AppColors.primary
                    : context.colors.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: enabled
                        ? context.colors.onSurface
                        : context.colors.onSurfaceVariant.withOpacity(0.5),
                  ),
                ),
              ),
              Switch(
                value: value && enabled,
                onChanged: enabled ? onChanged : null,
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 48,
            endIndent: 0,
            color: context.colors.outline,
          ),
      ],
    );
  }
}