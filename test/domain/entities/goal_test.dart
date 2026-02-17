import 'package:flutter_test/flutter_test.dart';
import 'package:akorsis/domain/entities/goal.dart';
import 'package:akorsis/domain/entities/milestone.dart';
import 'package:akorsis/domain/entities/level.dart';

void main() {
  group('Goal Entity', () {
    final testDate = DateTime(2024, 1, 1);
    
    test('should create a numeric goal with correct properties', () {
      final goal = Goal(
        id: '1',
        title: 'Save Money',
        description: 'Save for vacation',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
        targetValue: 10000,
        currentValue: 5000,
        unit: 'USD',
      );

      expect(goal.id, '1');
      expect(goal.title, 'Save Money');
      expect(goal.type, GoalType.numeric);
      expect(goal.targetValue, 10000);
      expect(goal.currentValue, 5000);
      expect(goal.unit, 'USD');
    });

    test('should create a habit goal with correct properties', () {
      final goal = Goal(
        id: '2',
        title: 'Daily Exercise',
        type: GoalType.habit,
        category: GoalCategory.fitness,
        createdAt: testDate,
        updatedAt: testDate,
        frequency: 'daily',
        streak: 5,
        bestStreak: 10,
        completedDates: [testDate],
      );

      expect(goal.type, GoalType.habit);
      expect(goal.frequency, 'daily');
      expect(goal.streak, 5);
      expect(goal.bestStreak, 10);
      expect(goal.completedDates?.length, 1);
    });

    test('should create a milestone goal with correct properties', () {
      final milestones = [
        Milestone(
          id: 'm1',
          title: 'Milestone 1',
          isCompleted: true,
          completedAt: testDate,
          order: 0,
        ),
        Milestone(
          id: 'm2',
          title: 'Milestone 2',
          isCompleted: false,
          order: 1,
        ),
      ];

      final goal = Goal(
        id: '3',
        title: 'Complete Project',
        type: GoalType.milestone,
        category: GoalCategory.career,
        createdAt: testDate,
        updatedAt: testDate,
        milestones: milestones,
      );

      expect(goal.type, GoalType.milestone);
      expect(goal.milestones?.length, 2);
      expect(goal.milestones?[0].isCompleted, true);
      expect(goal.milestones?[1].isCompleted, false);
    });

    test('should create a levels goal with correct properties', () {
      final levels = [
        Level(
          id: 'l1',
          title: 'Beginner',
          isCompleted: true,
          completedAt: testDate,
          order: 0,
        ),
        Level(
          id: 'l2',
          title: 'Intermediate',
          isCompleted: false,
          order: 1,
        ),
      ];

      final goal = Goal(
        id: '4',
        title: 'Learn Programming',
        type: GoalType.levels,
        category: GoalCategory.learning,
        createdAt: testDate,
        updatedAt: testDate,
        levels: levels,
        currentLevelIndex: 1,
      );

      expect(goal.type, GoalType.levels);
      expect(goal.levels?.length, 2);
      expect(goal.currentLevelIndex, 1);
    });

    test('copyWith should update only specified properties', () {
      final goal = Goal(
        id: '1',
        title: 'Original',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
        currentValue: 100,
      );

      final updated = goal.copyWith(
        title: 'Updated',
        currentValue: 200,
      );

      expect(updated.id, '1');
      expect(updated.title, 'Updated');
      expect(updated.currentValue, 200);
      expect(updated.type, GoalType.numeric);
    });

    test('should maintain immutability with Equatable', () {
      final goal1 = Goal(
        id: '1',
        title: 'Test',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final goal2 = Goal(
        id: '1',
        title: 'Test',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(goal1, equals(goal2));
      expect(goal1.hashCode, equals(goal2.hashCode));
    });

    test('should handle different goal colors', () {
      final tealGoal = Goal(
        id: '1',
        title: 'Test',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
        color: GoalColor.teal,
      );

      final purpleGoal = tealGoal.copyWith(color: GoalColor.purple);

      expect(tealGoal.color, GoalColor.teal);
      expect(purpleGoal.color, GoalColor.purple);
    });

    test('should handle completion status', () {
      final goal = Goal(
        id: '1',
        title: 'Test',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
        isCompleted: false,
      );

      final completed = goal.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      expect(goal.isCompleted, false);
      expect(goal.completedAt, isNull);
      expect(completed.isCompleted, true);
      expect(completed.completedAt, isNotNull);
    });
  });

  group('Milestone Entity', () {
    test('should create milestone with correct properties', () {
      final milestone = Milestone(
        id: 'm1',
        title: 'Complete phase 1',
        isCompleted: false,
        order: 0,
      );

      expect(milestone.id, 'm1');
      expect(milestone.title, 'Complete phase 1');
      expect(milestone.isCompleted, false);
      expect(milestone.order, 0);
    });

    test('copyWith should work correctly', () {
      final milestone = Milestone(
        id: 'm1',
        title: 'Original',
        isCompleted: false,
        order: 0,
      );

      final completed = milestone.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      expect(completed.isCompleted, true);
      expect(completed.completedAt, isNotNull);
    });
  });

  group('Level Entity', () {
    test('should create level with correct properties', () {
      final level = Level(
        id: 'l1',
        title: 'Beginner',
        isCompleted: false,
        order: 0,
      );

      expect(level.id, 'l1');
      expect(level.title, 'Beginner');
      expect(level.isCompleted, false);
      expect(level.order, 0);
    });

    test('copyWith should work correctly', () {
      final level = Level(
        id: 'l1',
        title: 'Beginner',
        isCompleted: false,
        order: 0,
      );

      final completed = level.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      expect(completed.isCompleted, true);
      expect(completed.completedAt, isNotNull);
    });
  });
}
