import '../../domain/entities/progress_entry.dart';
import '../../core/utils/typedef.dart';

class ProgressEntryModel extends ProgressEntry {
  const ProgressEntryModel({
    required super.id,
    required super.goalId,
    required super.value,
    super.note,
    required super.createdAt,
  });

  factory ProgressEntryModel.fromJson(DataMap json) {
    return ProgressEntryModel(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      value: (json['value'] as num).toDouble(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'value': value,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProgressEntryModel.fromEntity(ProgressEntry entry) {
    return ProgressEntryModel(
      id: entry.id,
      goalId: entry.goalId,
      value: entry.value,
      note: entry.note,
      createdAt: entry.createdAt,
    );
  }
}
