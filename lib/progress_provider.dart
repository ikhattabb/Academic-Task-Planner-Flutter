import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'progress_model.dart';
import 'hive_service.dart';
import 'task_provider.dart' show hiveServiceProvider;

// ─────────────────────────────────────────────────────────────────────────────
// Progress Repository
// ─────────────────────────────────────────────────────────────────────────────

class ProgressRepository {
  ProgressRepository(this._hive);
  final HiveService _hive;

  Stream<List<ProgressModel>> watchAll() {
    return _hive.watchAllProgress();
  }

  Future<ProgressModel> create({
    required String subjectName,
    required int totalPages,
    required int currentPage,
    required Color color,
    String? bookmarkImagePath,
  }) async {
    return await _hive.createProgress(
      subjectName: subjectName,
      totalPages: totalPages,
      currentPage: currentPage,
      colorValue: color.value,
      bookmarkImagePath: bookmarkImagePath,
    );
  }

  Future<ProgressModel> update(ProgressModel updated) async {
    await _hive.updateProgress(updated);
    return updated;
  }

  Future<void> delete(ProgressModel model) async {
    await _hive.deleteProgress(model.id);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final progressRepositoryProvider =
    FutureProvider<ProgressRepository>((ref) async {
  final hive = await ref.watch(hiveServiceProvider.future);
  return ProgressRepository(hive);
});

final allProgressProvider = StreamProvider<List<ProgressModel>>((ref) async* {
  final repo = await ref.watch(progressRepositoryProvider.future);
  yield* repo.watchAll();
});
