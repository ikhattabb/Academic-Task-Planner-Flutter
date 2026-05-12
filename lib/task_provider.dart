import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_model.dart';
import 'hive_service.dart';
import 'notification_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Task Repository
// ─────────────────────────────────────────────────────────────────────────────

class TaskRepository {
  TaskRepository(this._hive);
  final HiveService _hive;

  // ── Streams ───────────────────────────────────────────────────────────────

  Stream<List<TaskModel>> watchActiveTasks() {
    return _hive.watchActiveTasks();
  }

  Stream<List<TaskModel>> watchCompletedTasks() {
    return _hive.watchCompletedTasks();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<TaskModel> createTask({
    required String title,
    String? taskType,
    required List<String> tags,
    required Color color,
    DateTime? deadline,
    bool notifyAtEvent = false,
    bool notifyOneDay = false,
    bool notifyThreeDays = false,
    bool notifyOneWeek = false,
  }) async {
    final task = await _hive.createTask(
      title: title,
      taskType: taskType,
      tags: tags,
      colorValue: color.value,
      deadline: deadline,
      notifyAtEvent: notifyAtEvent,
      notifyOneDay: notifyOneDay,
      notifyThreeDays: notifyThreeDays,
      notifyOneWeek: notifyOneWeek,
    );

    if (deadline != null) {
      await NotificationService.instance.scheduleTaskNotifications(task);
    }

    return task;
  }

  Future<TaskModel> updateTask(TaskModel updated) async {
    await _hive.updateTask(updated);
    await NotificationService.instance.scheduleTaskNotifications(updated);
    return updated;
  }

  Future<void> markComplete(TaskModel task) async {
    final updated = task.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
    await _hive.updateTask(updated);
    await NotificationService.instance.cancelTaskNotifications(task.uuid);
  }

  Future<void> markActive(TaskModel task) async {
    final updated = task.copyWith(isCompleted: false);
    await _hive.updateTask(updated);
  }

  Future<void> deleteTask(TaskModel task) async {
    await _hive.deleteTask(task.id);
    await NotificationService.instance.cancelTaskNotifications(task.uuid);
  }

  // ── Tag Aggregation ───────────────────────────────────────────────────────

  Future<List<String>> getAllActiveTags() async {
    final tasks = _hive.getActiveTasks();
    final tags = <String>{};
    for (final t in tasks) {
      tags.addAll(t.tags);
    }
    return tags.toList()..sort();
  }

  Future<List<String>> getAllCompletedTags() async {
    final tasks = _hive.getCompletedTasks();
    final tags = <String>{};
    for (final t in tasks) {
      tags.addAll(t.tags);
    }
    return tags.toList()..sort();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final hiveServiceProvider = FutureProvider<HiveService>((ref) async {
  final hive = HiveService.instance;
  if (!hive.isInitialized) {
    await hive.init();
  }
  return hive;
});

final taskRepositoryProvider = FutureProvider<TaskRepository>((ref) async {
  final hive = await ref.watch(hiveServiceProvider.future);
  return TaskRepository(hive);
});

/// Stream of active (non-completed) tasks
final activeTasksProvider = StreamProvider<List<TaskModel>>((ref) async* {
  final repo = await ref.watch(taskRepositoryProvider.future);
  yield* repo.watchActiveTasks();
});

/// Stream of completed tasks
final completedTasksProvider = StreamProvider<List<TaskModel>>((ref) async* {
  final repo = await ref.watch(taskRepositoryProvider.future);
  yield* repo.watchCompletedTasks();
});

/// Currently selected tag filter for active tasks screen
final activeTagFilterProvider = StateProvider<String?>((ref) => null);

/// Currently selected tag filter for completed tasks screen
final completedTagFilterProvider = StateProvider<String?>((ref) => null);

/// Derived: filtered active tasks
final filteredActiveTasksProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  final tasksAsync = ref.watch(activeTasksProvider);
  final filter = ref.watch(activeTagFilterProvider);

  return tasksAsync.whenData((tasks) {
    if (filter == null || filter.isEmpty) return tasks;
    return tasks.where((t) => t.tags.contains(filter)).toList();
  });
});

/// Derived: filtered completed tasks
final filteredCompletedTasksProvider =
    Provider<AsyncValue<List<TaskModel>>>((ref) {
  final tasksAsync = ref.watch(completedTasksProvider);
  final filter = ref.watch(completedTagFilterProvider);

  return tasksAsync.whenData((tasks) {
    if (filter == null || filter.isEmpty) return tasks;
    return tasks.where((t) => t.tags.contains(filter)).toList();
  });
});

/// All unique tags from active tasks (for chip bar)
final activeTagsListProvider = FutureProvider<List<String>>((ref) async {
  // Recompute when tasks change
  ref.watch(activeTasksProvider);
  final repo = await ref.watch(taskRepositoryProvider.future);
  return repo.getAllActiveTags();
});

/// All unique tags from completed tasks (for chip bar)
final completedTagsListProvider = FutureProvider<List<String>>((ref) async {
  ref.watch(completedTasksProvider);
  final repo = await ref.watch(taskRepositoryProvider.future);
  return repo.getAllCompletedTags();
});