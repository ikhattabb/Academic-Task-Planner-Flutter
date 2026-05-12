import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'app_theme.dart';
import 'theme_provider.dart';
import 'notification_service.dart';
import 'hive_service.dart';
import 'main_screen.dart';
import 'completed_screen.dart';
import 'progress_screen.dart';
import 'app_drawer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry Point
// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive here (works on web, Android, iOS, desktop)
  await HiveService.instance.init();

  // Initialize notifications (non-blocking for UI, skipped on web)
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermission();

  runApp(const ProviderScope(child: StudentPlannerApp()));
}

// ─────────────────────────────────────────────────────────────────────────────
// Root Widget
// ─────────────────────────────────────────────────────────────────────────────

class StudentPlannerApp extends ConsumerWidget {
  const StudentPlannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    return MaterialApp(
      title: 'Student Planner',
      debugShowCheckedModeBanner: false,

      // ── Theme ─────────────────────────────────────────────────────────
      theme: AppTheme.light(isArabic: isArabic),
      darkTheme: AppTheme.dark(isArabic: isArabic),
      themeMode: themeMode,

      // ── Localization ──────────────────────────────────────────────────
      locale: locale,
      // FIX 2: Use AppLocalizations.supportedLocales which now includes 'ar'
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      // ── RTL / LTR ─────────────────────────────────────────────────────
      builder: (context, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },

      // ── Routes (single source of truth — removed duplicate onGenerateRoute) ──
      initialRoute: AppRoutes.main,
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case AppRoutes.main:
            page = const MainScreen();
            break;
          case AppRoutes.completed:
            page = const CompletedTasksScreen();
            break;
          case AppRoutes.progress:
            page = const ProgressScreen();
            break;
          default:
            return null;
        }

        // FIX 3: Removed duplicate `routes:` map. All routing through
        // onGenerateRoute so fade transitions actually apply.
        // Also fixed triple wildcard (_, _, _) → proper named params.
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (ctx, animation, secondaryAnimation) => page,
          transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        );
      },
    );
  }
}