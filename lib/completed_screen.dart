import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'app_drawer.dart';
import 'tag_filter_bar.dart';
import 'extensions.dart';
import 'task_provider.dart';
import 'main_screen.dart';
import 'task_card.dart';

class CompletedTasksScreen extends ConsumerWidget {
  const CompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tagsAsync = ref.watch(completedTagsListProvider);
    final selectedTag = ref.watch(completedTagFilterProvider);
    final filteredAsync = ref.watch(filteredCompletedTasksProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.completedScreen,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            // FIX: was Consumer(builder: (_, ref, _) — duplicate wildcard crash
            Consumer(builder: (ctx, consumerRef, child) {
              final tasks = consumerRef.watch(completedTasksProvider);
              return tasks.when(
                data: (list) => Text(
                  '${list.length} ${l10n.completed}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                // FIX: was error: (_, _) — duplicate wildcard
                error: (err, stack) => const SizedBox.shrink(),
              );
            }),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // ── Tag Filter ───────────────────────────────────────────────
          tagsAsync.when(
            data: (tags) => tags.isEmpty
                ? const SizedBox.shrink()
                : TagFilterBar(
                    tags: tags,
                    selectedTag: selectedTag,
                    allLabel: l10n.allTags,
                    onTagSelected: (tag) =>
                        ref.read(completedTagFilterProvider.notifier).state =
                            tag,
                  ),
            loading: () => const SizedBox(height: 44),
            // FIX: was error: (_, _) — duplicate wildcard
            error: (err, stack) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 8),

          // ── Task List ────────────────────────────────────────────────
          Expanded(
            child: filteredAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return EmptyState(
                    icon: Icons.check_circle_outline_rounded,
                    message: l10n.noCompleted,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 32),
                  physics: const BouncingScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (ctx, index) {
                    final task = tasks[index];
                    return TaskCard(
                      key: ValueKey(task.uuid),
                      task: task,
                      showCompletedStyle: true,
                      onToggleDone: () async {
                        final repo =
                            await ref.read(taskRepositoryProvider.future);
                        await repo.markActive(task);
                        if (context.mounted) {
                          context.showSnack(l10n.active);
                        }
                      },
                      onDelete: () async {
                        final repo =
                            await ref.read(taskRepositoryProvider.future);
                        await repo.deleteTask(task);
                        if (context.mounted) {
                          context.showSnack(l10n.taskDeleted);
                        }
                      },
                      onTap: () {},
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, stack) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}