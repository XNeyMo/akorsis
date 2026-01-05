import '../../domain/entities/level.dart';
import '../../core/utils/typedef.dart';

class LevelModel extends Level {
  const LevelModel({
    required super.id,
    required super.title,
    required super.isCompleted,
    super.completedAt,
    required super.order,
  });

  factory LevelModel.fromJson(DataMap json) {
    return LevelModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      order: json['order'] as int,
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'order': order,
    };
  }

  factory LevelModel.fromEntity(Level level) {
    return LevelModel(
      id: level.id,
      title: level.title,
      isCompleted: level.isCompleted,
      completedAt: level.completedAt,
      order: level.order,
    );
  }

  @override
  LevelModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? completedAt,
    int? order,
  }) {
    return LevelModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      order: order ?? this.order,
    );
  }
}
