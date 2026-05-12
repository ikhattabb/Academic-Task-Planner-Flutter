import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'app_drawer.dart';
import 'extensions.dart';
import 'progress_provider.dart';
import 'progress_card.dart';
import 'add_progress_screen.dart';
import 'main_screen.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final progressAsync = ref.watch(allProgressProvider);

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
              l10n.progressScreen,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            progressAsync.when(
              data: (list) => Text(
                '${list.length} Trackers',
                style: context.textTheme.bodySmall
                    ?.copyWith(color: context.colors.onSurfaceVariant),
              ),
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProgressScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addProgress),
      ),
      body: progressAsync.when(
        data: (trackers) {
          if (trackers.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book_rounded,
              message: l10n.noProgress,
            );
          }
          return ListView.builder(
            padding:
                const EdgeInsets.only(top: 12, bottom: 100),
            physics: const BouncingScrollPhysics(),
            itemCount: trackers.length,
            itemBuilder: (_, index) {
              final tracker = trackers[index];
              return ProgressCard(
                key: ValueKey(tracker.uuid),
                model: tracker,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddProgressScreen(existing: tracker),
                  ),
                ),
                onDelete: () async {
                  final confirmed = await _confirmDelete(context, l10n);
                  if (confirmed == true) {
                    final repo = await ref
                        .read(progressRepositoryProvider.future);
                    await repo.delete(tracker);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<bool?> _confirmDelete(
      BuildContext context, AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }
}