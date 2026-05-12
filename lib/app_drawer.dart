import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'theme_provider.dart';
import 'app_theme.dart';
import 'extensions.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route Name Constants
// ─────────────────────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();
  static const String main = '/';
  static const String completed = '/completed';
  static const String progress = '/progress';
}

// ─────────────────────────────────────────────────────────────────────────────
// App Drawer
// ─────────────────────────────────────────────────────────────────────────────

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final isAr = locale.languageCode == 'ar';
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

    return Drawer(
      width: 280,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            _DrawerHeader(isDark: isDark),

            const SizedBox(height: 8),

            // ── Navigation Section ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                l10n.navigation,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            _NavItem(
              icon: Icons.task_alt_rounded,
              label: l10n.mainScreen,
              route: AppRoutes.main,
              isSelected: currentRoute == AppRoutes.main,
            ),
            _NavItem(
              icon: Icons.check_circle_outline_rounded,
              label: l10n.completedScreen,
              route: AppRoutes.completed,
              isSelected: currentRoute == AppRoutes.completed,
            ),
            _NavItem(
              icon: Icons.menu_book_rounded,
              label: l10n.progressScreen,
              route: AppRoutes.progress,
              isSelected: currentRoute == AppRoutes.progress,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(height: 1),
            ),

            // ── Settings Section ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                l10n.settings,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Dark / Light Toggle
            _SettingsTile(
              icon: isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              label: isDark ? l10n.lightMode : l10n.darkMode,
              trailing: Switch(
                value: isDark,
                onChanged: (_) =>
                    ref.read(themeProvider.notifier).toggle(),
              ),
            ),

            // Language Toggle
            _SettingsTile(
              icon: Icons.language_rounded,
              label: isAr ? l10n.english : l10n.arabic,
              trailing: _LanguageBadge(isArabic: isAr),
              onTap: () =>
                  ref.read(localeProvider.notifier).toggle(),
            ),

            const Spacer(),

            // ── Footer ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Student Planner v1.0',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Student Planner',
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Stay focused. Stay ahead.',
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isSelected,
  });

  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected
            ? AppColors.primary.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pop(context);
            if (!isSelected) {
              Navigator.pushReplacementNamed(context, route);
            }
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.primary
                      : context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : context.colors.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, size: 20),
        title: Text(label, style: context.textTheme.bodyMedium),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        minLeadingWidth: 20,
      ),
    );
  }
}

class _LanguageBadge extends StatelessWidget {
  const _LanguageBadge({required this.isArabic});
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        isArabic ? 'EN' : 'عر',
        style: context.textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}