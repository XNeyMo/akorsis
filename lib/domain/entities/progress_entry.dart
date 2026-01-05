import 'package:equatable/equatable.dart';

class ProgressEntry extends Equatable {
  const ProgressEntry({
    required this.id,
    required this.goalId,
    required this.value,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String goalId;
  final double value;
  final String? note;
  final DateTime createdAt;

  ProgressEntry copyWith({
    String? id,
    String? goalId,
    double? value,
    String? note,
    DateTime? createdAt,
  }) {
    return ProgressEntry(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      value: value ?? this.value,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, goalId, value, note, createdAt];
}
