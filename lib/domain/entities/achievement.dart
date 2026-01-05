import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
    required this.isUnlocked,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    DateTime? unlockedAt,
    bool? isUnlocked,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  @override
  List<Object?> get props => [id, title, description, icon, unlockedAt, isUnlocked];
}
