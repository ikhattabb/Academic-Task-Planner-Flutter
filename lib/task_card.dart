import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'l10n/app_localizations.dart';
import 'task_model.dart';
import 'app_theme.dart';
import 'extensions.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleDone,
    required this.onDelete,
    required this.onTap,
    this.showCompletedStyle = false,
  });

  final TaskModel task;
  final VoidCallback onToggleDone;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final bool showCompletedStyle;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  bool _checking = false;

  void _handleCheck() async {
    setState(() => _checking = true);
    await Future.delayed(const Duration(milliseconds: 300));
    widget.onToggleDone();
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final task = widget.task;
    final taskColor = Color(task.colorValue);
    final isDark = context.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Slidable(
        key: ValueKey(task.uuid),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.22,
          children: [
            SlidableAction(
              onPressed: (_) => widget.onDelete(),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              borderRadius: BorderRadius.circular(16),
              label: l10n.delete,
            ),
          ],
        ),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.darkCardBorder
                    : AppColors.lightCardBorder,
                width: 1,
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Color Strip ─────────────────────────────────────
                    Container(
                      width: 5,
                      decoration: BoxDecoration(
                        color: widget.showCompletedStyle
                            ? taskColor.withOpacity(0.5)
                            : taskColor,
                      ),
                    ),

                    // ── Content ──────────────────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                        child: Row(
                          children: [
                            // ── Checkbox ─────────────────────────────────
                            _AnimatedCheckbox(
                              value: widget.task.isCompleted || _checking,
                              color: taskColor,
                              onChanged: (_) => _handleCheck(),
                            ),
                            const SizedBox(width: 12),

                            // ── Text ──────────────────────────────────────
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Title
                                  Text(
                                    task.title,
                                    style:
                                        context.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      decoration: widget.showCompletedStyle
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: widget.showCompletedStyle
                                          ? context.colors.onSurfaceVariant
                                          : context.colors.onSurface,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 5),

                                  // Meta row
                                  Row(
                                    children: [
                                      if (task.taskType != null) ...[
                                        _MetaBadge(
                                          label: task.taskType!,
                                          color: taskColor,
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      if (task.deadline != null) ...[
                                        _DeadlineChip(
                                            deadline: task.deadline!,
                                            locale: Localizations.localeOf(
                                                    context)
                                                .languageCode),
                                      ],
                                    ],
                                  ),

                                  // Tags
                                  if (task.tags.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 5,
                                      runSpacing: 4,
                                      children: task.tags
                                          .take(3)
                                          .map((tag) => _SmallTag(
                                              label: tag,
                                              color: taskColor))
                                          .toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // ── Notification badge ────────────────────────
                            if (_hasAnyNotification(task))
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.notifications_active_rounded,
                                  size: 14,
                                  color: context.colors.onSurfaceVariant
                                      .withOpacity(0.5),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasAnyNotification(TaskModel task) =>
      task.notifyAtEvent ||
      task.notifyOneDay ||
      task.notifyThreeDays ||
      task.notifyOneWeek;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedCheckbox extends StatelessWidget {
  const _AnimatedCheckbox({
    required this.value,
    required this.color,
    required this.onChanged,
  });
  final bool value;
  final Color color;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: value ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: value ? color : context.colors.onSurfaceVariant,
            width: 1.5,
          ),
        ),
        child: value
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
            : null,
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _DeadlineChip extends StatelessWidget {
  const _DeadlineChip({required this.deadline, required this.locale});
  final DateTime deadline;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        deadline.isBefore(DateTime.now()) && !deadline.isToday;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 11,
          color: isOverdue
              ? AppColors.error
              : context.colors.onSurfaceVariant,
        ),
        const SizedBox(width: 3),
        Text(
          deadline.toSmartLabel(locale: locale),
          style: context.textTheme.labelSmall?.copyWith(
            color: isOverdue
                ? AppColors.error
                : context.colors.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        '#$label',
        style: context.textTheme.labelSmall?.copyWith(
          color: color.withOpacity(0.8),
          fontSize: 10,
        ),
      ),
    );
  }
}