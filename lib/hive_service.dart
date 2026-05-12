import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'task_model.dart';
import 'progress_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hive Service - Replaces Isar
// ─────────────────────────────────────────────────────────────────────────────

class HiveService {
  HiveService._();
  static final HiveService instance = HiveService._();

  late Box<Map> _tasksBox;
  late Box<Map> _progressBox;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    if (!kIsWeb) {
      await Hive.initFlutter();
    } else {
      await Hive.openBox('flutter_browser_context');
    }

    _tasksBox = await Hive.openBox<Map>('tasks');
    _progressBox = await Hive.openBox<Map>('progress');
    _initialized = true;
  }

  Future<void> close() async {
    await _tasksBox.close();
    await _progressBox.close();
    _initialized = false;
  }

  // ── Task Operations ───────────────────────────────────────────────────────

  Stream<List<TaskModel>> watchActiveTasks() {
    return _tasksBox.watch().map((_) => getActiveTasks());
  }

  Stream<List<TaskModel>> watchCompletedTasks() {
    return _tasksBox.watch().map((_) => getCompletedTasks());
  }

  List<TaskModel> getActiveTasks() {
    return _tasksBox.values
        .map((json) => TaskModel.fromJson(json))
        .where((t) => !t.isCompleted)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<TaskModel> getCompletedTasks() {
    return _tasksBox.values
        .map((json) => TaskModel.fromJson(json))
        .where((t) => t.isCompleted)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<TaskModel> createTask({
    required String title,
    String? taskType,
    required List<String> tags,
    required int colorValue,
    DateTime? deadline,
    bool notifyAtEvent = false,
    bool notifyOneDay = false,
    bool notifyThreeDays = false,
    bool notifyOneWeek = false,
  }) async {
    final id = const Uuid().v4();
    final task = TaskModel(
      id: id,
      uuid: id,
      title: title,
      taskType: taskType,
      tags: tags,
      colorValue: colorValue,
      deadline: deadline,
      notifyAtEvent: notifyAtEvent,
      notifyOneDay: notifyOneDay,
      notifyThreeDays: notifyThreeDays,
      notifyOneWeek: notifyOneWeek,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    await _tasksBox.put(id, task.toJson());
    return task;
  }

  Future<void> updateTask(TaskModel task) async {
    await _tasksBox.put(task.id, task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
  }

  TaskModel? getTask(String taskId) {
    final json = _tasksBox.get(taskId);
    return json != null ? TaskModel.fromJson(json) : null;
  }

  // ── Progress Operations ───────────────────────────────────────────────────

  Stream<List<ProgressModel>> watchAllProgress() {
    return _progressBox.watch().map((_) => getAllProgress());
  }

  List<ProgressModel> getAllProgress() {
    return _progressBox.values
        .map((json) => ProgressModel.fromJson(json))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<ProgressModel> createProgress({
    required String subjectName,
    required int totalPages,
    required int currentPage,
    required int colorValue,
    String? bookmarkImagePath,
  }) async {
    final id = const Uuid().v4();
    final model = ProgressModel(
      id: id,
      uuid: id,
      subjectName: subjectName,
      totalPages: totalPages,
      currentPage: currentPage,
      bookmarkImagePath: bookmarkImagePath,
      colorValue: colorValue,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _progressBox.put(id, model.toJson());
    return model;
  }

  Future<void> updateProgress(ProgressModel model) async {
    final updated = model.copyWith(updatedAt: DateTime.now());
    await _progressBox.put(model.id, updated.toJson());
  }

  Future<void> deleteProgress(String modelId) async {
    await _progressBox.delete(modelId);
  }

  ProgressModel? getProgress(String modelId) {
    final json = _progressBox.get(modelId);
    return json != null ? ProgressModel.fromJson(json) : null;
  }
}
