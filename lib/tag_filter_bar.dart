import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'extensions.dart';

class TagFilterBar extends StatelessWidget {
  const TagFilterBar({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
    required this.allLabel,
  });

  final List<String> tags;
  final String? selectedTag;
  final ValueChanged<String?> onTagSelected;
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    final chips = ['', ...tags]; // '' = All

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tag = chips[index];
          final isAll = tag.isEmpty;
          final isSelected =
              isAll ? selectedTag == null : selectedTag == tag;

          return _TagChip(
            label: isAll ? allLabel : tag,
            isSelected: isSelected,
            onTap: () => onTagSelected(isAll ? null : tag),
          );
        },
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (context.isDark
                  ? const Color(0xFF252540)
                  : const Color(0xFFF0F1F8)),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : context.colors.outline,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? Colors.white
                : context.colors.onSurface,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}