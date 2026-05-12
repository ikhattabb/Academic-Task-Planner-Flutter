import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'app_drawer.dart';
import 'tag_filter_bar.dart';
import 'extensions.dart';
import 'task_provider.dart';
import 'task_card.dart';
import 'add_task_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: _buildAppBar(context, l10n, locale),
      body: _MainBody(),
      floatingActionButton: _AddTaskFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  AppBar _buildAppBar(
      BuildContext context, AppLocalizations l10n, String locale) {
    return AppBar(
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
          tooltip: l10n.navigation,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.mainScreen,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          Text(
            _greeting(locale),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        _TaskCountBadge(),
        const SizedBox(width: 8),
      ],
    );
  }

  String _greeting(String locale) {
    final hour = DateTime.now().hour;
    if (locale == 'ar') {
      if (hour < 12) return 'صباح الخير 🌅';
      if (hour < 17) return 'مساء الخير ☀️';
      return 'مساء النور 🌙';
    }
    if (hour < 12) return 'Good morning 🌅';
    if (hour < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────

class _MainBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tagsAsync = ref.watch(activeTagsListProvider);
    final selectedTag = ref.watch(activeTagFilterProvider);
    final filteredAsync = ref.watch(filteredActiveTasksProvider);

    return Column(
      children: [
        const SizedBox(height: 12),

        // ── Tag Filter Bar ─────────────────────────────────────────────
        tagsAsync.when(
          data: (tags) => tags.isEmpty
              ? const SizedBox.shrink()
              : TagFilterBar(
                  tags: tags,
                  selectedTag: selectedTag,
                  allLabel: l10n.allTags,
                  onTagSelected: (tag) =>
                      ref.read(activeTagFilterProvider.notifier).state = tag,
                ),
          loading: () => const SizedBox(height: 44),
          error: (err, stack) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 8),

        // ── Task List ──────────────────────────────────────────────────
        Expanded(
          child: filteredAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return _EmptyState(
                  icon: Icons.task_alt_rounded,
                  message: l10n.noTasks,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 100),
                physics: const BouncingScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskCard(
                    key: ValueKey(task.uuid),
                    task: task,
                    onToggleDone: () async {
                      final repo = await ref
                          .read(taskRepositoryProvider.future);
                      await repo.markComplete(task);
                      if (context.mounted) {
                        context.showSnack(
                          l10n.completed,
                          action: SnackBarAction(
                            label: l10n.undo,
                            onPressed: () async {
                              final r = await ref
                                  .read(taskRepositoryProvider.future);
                              await r.markActive(task);
                            },
                          ),
                        );
                      }
                    },
                    onDelete: () async {
                      final repo = await ref
                          .read(taskRepositoryProvider.future);
                      await repo.deleteTask(task);
                      if (context.mounted) {
                        context.showSnack(l10n.taskDeleted);
                      }
                    },
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTaskScreen(existing: task),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAB
// ─────────────────────────────────────────────────────────────────────────────

class _AddTaskFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a1, a2) => const AddTaskScreen(),
          transitionsBuilder: (_, a1, a2, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: a1, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      icon: const Icon(Icons.add_rounded),
      label: Text(l10n.addTask),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task Count Badge
// ─────────────────────────────────────────────────────────────────────────────

class _TaskCountBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(activeTasksProvider);
    return tasks.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${list.length}',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _EmptyState(icon: icon, message: message);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 44,
              color: context.colors.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}