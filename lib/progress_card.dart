import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'l10n/app_localizations.dart';
import 'app_theme.dart';
import 'extensions.dart';
import 'progress_model.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.model,
    required this.onEdit,
    required this.onDelete,
  });

  final ProgressModel model;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Color(model.colorValue);
    final isDark = context.isDark;
    final pct = model.completionPercent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Slidable(
        key: ValueKey(model.uuid),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.22,
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              borderRadius: BorderRadius.circular(16),
              label: l10n.delete,
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onEdit,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? AppColors.darkCardBorder
                    : AppColors.lightCardBorder,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      // Color dot
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Subject name
                      Expanded(
                        child: Text(
                          model.subjectName,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Percent badge
                      _PercentBadge(
                        percent: model.percentageInt,
                        color: color,
                        isComplete: model.isComplete,
                      ),
                    ],
                  ),
                ),

                // ── Progress Bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LinearPercentIndicator(
                    percent: pct,
                    lineHeight: 8,
                    backgroundColor: color.withOpacity(0.15),
                    progressColor: color,
                    barRadius: const Radius.circular(100),
                    padding: EdgeInsets.zero,
                    animation: true,
                    animationDuration: 800,
                    curve: Curves.easeOutCubic,
                  ),
                ),

                const SizedBox(height: 10),

                // ── Page Info + Bookmark image ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PageRow(model: model, l10n: l10n),
                            const SizedBox(height: 4),
                            Text(
                              model.isComplete
                                  ? '✅ ${l10n.completed}'
                                  : '${(pct * 100).toStringAsFixed(1)}% ${l10n.completionPercent}',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: model.isComplete
                                    ? AppColors.success
                                    : context.colors.onSurfaceVariant,
                                fontWeight: model.isComplete
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bookmark image thumbnail
                      if (model.bookmarkImagePath != null)
                        _BookmarkThumbnail(path: model.bookmarkImagePath!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PercentBadge extends StatelessWidget {
  const _PercentBadge({
    required this.percent,
    required this.color,
    required this.isComplete,
  });
  final int percent;
  final Color color;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isComplete
            ? AppColors.success.withOpacity(0.12)
            : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$percent%',
        style: context.textTheme.labelSmall?.copyWith(
          color: isComplete ? AppColors.success : color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PageRow extends StatelessWidget {
  const _PageRow({required this.model, required this.l10n});
  final ProgressModel model;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: context.textTheme.bodySmall,
        children: [
          TextSpan(
            text: '${l10n.page} ',
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
          TextSpan(
            text: '${model.currentPage}',
            style: TextStyle(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: ' ${l10n.of} ${model.totalPages}',
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _BookmarkThumbnail extends StatelessWidget {
  const _BookmarkThumbnail({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(path),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Container(
          width: 56,
          height: 56,
          color: context.colors.surfaceContainerHighest,
          child: Icon(Icons.broken_image_rounded,
              color: context.colors.onSurfaceVariant),
        ),
      ),
    );
  }
}