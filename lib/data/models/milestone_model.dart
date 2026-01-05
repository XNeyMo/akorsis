import '../../domain/entities/milestone.dart';
import '../../core/utils/typedef.dart';

class MilestoneModel extends Milestone {
  const MilestoneModel({
    required super.id,
    required super.title,
    required super.isCompleted,
    super.completedAt,
    required super.order,
  });

  factory MilestoneModel.fromJson(DataMap json) {
    return MilestoneModel(
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

  factory MilestoneModel.fromEntity(Milestone milestone) {
    return MilestoneModel(
      id: milestone.id,
      title: milestone.title,
      isCompleted: milestone.isCompleted,
      completedAt: milestone.completedAt,
      order: milestone.order,
    );
  }

  @override
  MilestoneModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? completedAt,
    int? order,
  }) {
    return MilestoneModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      order: order ?? this.order,
    );
  }
}
