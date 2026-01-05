import '../../domain/entities/goal.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/level.dart';
import '../../core/utils/typedef.dart';
import 'milestone_model.dart';
import 'level_model.dart';

class GoalModel extends Goal {
  const GoalModel({
    required super.id,
    required super.title,
    super.description,
    required super.type,
    required super.category,
    required super.createdAt,
    required super.updatedAt,
    super.targetValue,
    super.currentValue,
    super.unit,
    super.frequency,
    super.streak,
    super.bestStreak,
    super.completedDates,
    super.milestones,
    super.levels,
    super.currentLevelIndex,
    super.deadline,
    super.icon,
    super.color,
    super.isCompleted,
    super.completedAt,
  });

  factory GoalModel.fromJson(DataMap json) {
    return GoalModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: GoalType.values.firstWhere((e) => e.name == json['type']),
      category: GoalCategory.values.firstWhere((e) => e.name == json['category']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      targetValue: json['targetValue'] != null ? (json['targetValue'] as num).toDouble() : null,
      currentValue: json['currentValue'] != null ? (json['currentValue'] as num).toDouble() : null,
      unit: json['unit'] as String?,
      frequency: json['frequency'] as String?,
      streak: json['streak'] as int?,
      bestStreak: json['bestStreak'] as int?,
      completedDates: json['completedDates'] != null
          ? (json['completedDates'] as List).map((e) => DateTime.parse(e as String)).toList()
          : null,
      milestones: json['milestones'] != null
          ? (json['milestones'] as List).map((e) => MilestoneModel.fromJson(e as DataMap)).toList()
          : null,
      levels: json['levels'] != null
          ? (json['levels'] as List).map((e) => LevelModel.fromJson(e as DataMap)).toList()
          : null,
      currentLevelIndex: json['currentLevelIndex'] as int?,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      icon: json['icon'] as String?,
      color: json['color'] != null ? GoalColor.values.firstWhere((e) => e.name == json['color']) : GoalColor.teal,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'frequency': frequency,
      'streak': streak,
      'bestStreak': bestStreak,
      'completedDates': completedDates?.map((e) => e.toIso8601String()).toList(),
      'milestones': milestones?.map((e) => (e as MilestoneModel).toJson()).toList(),
      'levels': levels?.map((e) => (e as LevelModel).toJson()).toList(),
      'currentLevelIndex': currentLevelIndex,
      'deadline': deadline?.toIso8601String(),
      'icon': icon,
      'color': color.name,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory GoalModel.fromEntity(Goal goal) {
    return GoalModel(
      id: goal.id,
      title: goal.title,
      description: goal.description,
      type: goal.type,
      category: goal.category,
      createdAt: goal.createdAt,
      updatedAt: goal.updatedAt,
      targetValue: goal.targetValue,
      currentValue: goal.currentValue,
      unit: goal.unit,
      frequency: goal.frequency,
      streak: goal.streak,
      bestStreak: goal.bestStreak,
      completedDates: goal.completedDates,
      milestones: goal.milestones?.map((m) => MilestoneModel.fromEntity(m)).toList(),
      levels: goal.levels?.map((l) => LevelModel.fromEntity(l)).toList(),
      currentLevelIndex: goal.currentLevelIndex,
      deadline: goal.deadline,
      icon: goal.icon,
      color: goal.color,
      isCompleted: goal.isCompleted,
      completedAt: goal.completedAt,
    );
  }

  @override
  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    GoalCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? targetValue,
    double? currentValue,
    String? unit,
    String? frequency,
    int? streak,
    int? bestStreak,
    List<DateTime>? completedDates,
    List<Milestone>? milestones,
    List<Level>? levels,
    int? currentLevelIndex,
    DateTime? deadline,
    String? icon,
    GoalColor? color,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      frequency: frequency ?? this.frequency,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      completedDates: completedDates ?? this.completedDates,
      milestones: milestones ?? this.milestones,
      levels: levels ?? this.levels,
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      deadline: deadline ?? this.deadline,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
