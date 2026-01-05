import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'milestone.dart';
import 'level.dart';

enum GoalType { numeric, habit, milestone, levels }

enum GoalCategory { health, finance, learning, career, personal, fitness, creative, social }

extension GoalCategoryExtension on GoalCategory {
  IconData getIcon() {
    switch (this) {
      case GoalCategory.health:
        return LucideIcons.heart;
      case GoalCategory.finance:
        return LucideIcons.wallet;
      case GoalCategory.learning:
        return LucideIcons.bookOpen;
      case GoalCategory.career:
        return LucideIcons.briefcase;
      case GoalCategory.personal:
        return LucideIcons.star;
      case GoalCategory.fitness:
        return LucideIcons.activity;
      case GoalCategory.creative:
        return LucideIcons.palette;
      case GoalCategory.social:
        return LucideIcons.users;
    }
  }
}

enum GoalColor { teal, purple, blue, orange }

class Goal extends Equatable {
  const Goal({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.targetValue,
    this.currentValue,
    this.unit,
    this.frequency,
    this.streak,
    this.bestStreak,
    this.completedDates,
    this.milestones,
    this.levels,
    this.currentLevelIndex,
    this.deadline,
    this.icon,
    this.color = GoalColor.teal,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final String title;
  final String? description;
  final GoalType type;
  final GoalCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Numeric goals
  final double? targetValue;
  final double? currentValue;
  final String? unit;

  // Habit goals
  final String? frequency; // 'daily' or 'weekly'
  final int? streak;
  final int? bestStreak;
  final List<DateTime>? completedDates;

  // Milestone goals
  final List<Milestone>? milestones;

  // Level goals
  final List<Level>? levels;
  final int? currentLevelIndex;

  // Common
  final DateTime? deadline;
  final String? icon;
  final GoalColor color;
  final bool isCompleted;
  final DateTime? completedAt;

  Goal copyWith({
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
    return Goal(
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

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        category,
        createdAt,
        updatedAt,
        targetValue,
        currentValue,
        unit,
        frequency,
        streak,
        bestStreak,
        completedDates,
        milestones,
        levels,
        currentLevelIndex,
        deadline,
        icon,
        color,
        isCompleted,
        completedAt,
      ];
}
