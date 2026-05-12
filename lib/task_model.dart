// ─────────────────────────────────────────────────────────────────────────────
// Task Model - Plain Dart (no Isar annotations)
// ─────────────────────────────────────────────────────────────────────────────

class TaskModel {
  final String id;
  final String uuid;
  final String title;
  final String? taskType;
  final List<String> tags;
  final int colorValue;
  final DateTime? deadline;
  final bool notifyAtEvent;
  final bool notifyOneDay;
  final bool notifyThreeDays;
  final bool notifyOneWeek;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.uuid,
    required this.title,
    this.taskType,
    required this.tags,
    required this.colorValue,
    this.deadline,
    this.notifyAtEvent = false,
    this.notifyOneDay = false,
    this.notifyThreeDays = false,
    this.notifyOneWeek = false,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'title': title,
    'taskType': taskType,
    'tags': tags,
    'colorValue': colorValue,
    'deadline': deadline?.toIso8601String(),
    'notifyAtEvent': notifyAtEvent,
    'notifyOneDay': notifyOneDay,
    'notifyThreeDays': notifyThreeDays,
    'notifyOneWeek': notifyOneWeek,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  static TaskModel fromJson(Map<dynamic, dynamic> json) => TaskModel(
    id: json['id'] as String,
    uuid: json['uuid'] as String,
    title: json['title'] as String,
    taskType: json['taskType'] as String?,
    tags: List<String>.from(json['tags'] as List? ?? []),
    colorValue: json['colorValue'] as int,
    deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
    notifyAtEvent: json['notifyAtEvent'] as bool? ?? false,
    notifyOneDay: json['notifyOneDay'] as bool? ?? false,
    notifyThreeDays: json['notifyThreeDays'] as bool? ?? false,
    notifyOneWeek: json['notifyOneWeek'] as bool? ?? false,
    isCompleted: json['isCompleted'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
  );

  // ── Copy with ─────────────────────────────────────────────────────────────

  TaskModel copyWith({
    String? id,
    String? uuid,
    String? title,
    String? taskType,
    List<String>? tags,
    int? colorValue,
    DateTime? deadline,
    bool? notifyAtEvent,
    bool? notifyOneDay,
    bool? notifyThreeDays,
    bool? notifyOneWeek,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      taskType: taskType ?? this.taskType,
      tags: tags ?? this.tags,
      colorValue: colorValue ?? this.colorValue,
      deadline: deadline ?? this.deadline,
      notifyAtEvent: notifyAtEvent ?? this.notifyAtEvent,
      notifyOneDay: notifyOneDay ?? this.notifyOneDay,
      notifyThreeDays: notifyThreeDays ?? this.notifyThreeDays,
      notifyOneWeek: notifyOneWeek ?? this.notifyOneWeek,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
