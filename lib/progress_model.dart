// ─────────────────────────────────────────────────────────────────────────────
// Progress Model - Plain Dart (no Isar annotations)
// ─────────────────────────────────────────────────────────────────────────────

class ProgressModel {
  final String id;
  final String uuid;
  final String subjectName;
  final int totalPages;
  final int currentPage;
  final String? bookmarkImagePath;
  final int colorValue;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProgressModel({
    required this.id,
    required this.uuid,
    required this.subjectName,
    required this.totalPages,
    required this.currentPage,
    this.bookmarkImagePath,
    required this.colorValue,
    required this.createdAt,
    this.updatedAt,
  });

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'subjectName': subjectName,
    'totalPages': totalPages,
    'currentPage': currentPage,
    'bookmarkImagePath': bookmarkImagePath,
    'colorValue': colorValue,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  static ProgressModel fromJson(Map<dynamic, dynamic> json) => ProgressModel(
    id: json['id'] as String,
    uuid: json['uuid'] as String,
    subjectName: json['subjectName'] as String,
    totalPages: json['totalPages'] as int,
    currentPage: json['currentPage'] as int,
    bookmarkImagePath: json['bookmarkImagePath'] as String?,
    colorValue: json['colorValue'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
  );

  // ── Computed properties ───────────────────────────────────────────────────

  double get completionPercent {
    if (totalPages <= 0) return 0.0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }

  int get percentageInt => (completionPercent * 100).round();

  bool get isComplete => currentPage >= totalPages;

  // ── Copy with ─────────────────────────────────────────────────────────────

  ProgressModel copyWith({
    String? id,
    String? uuid,
    String? subjectName,
    int? totalPages,
    int? currentPage,
    String? bookmarkImagePath,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearImage = false,
  }) {
    return ProgressModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      subjectName: subjectName ?? this.subjectName,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      bookmarkImagePath: clearImage ? null : (bookmarkImagePath ?? this.bookmarkImagePath),
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
