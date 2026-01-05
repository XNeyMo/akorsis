import 'package:equatable/equatable.dart';

class Milestone extends Equatable {
  const Milestone({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.completedAt,
    required this.order,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? completedAt;
  final int order;

  Milestone copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? completedAt,
    int? order,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted, completedAt, order];
}
