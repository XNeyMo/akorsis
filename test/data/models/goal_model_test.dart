import 'package:flutter_test/flutter_test.dart';
import 'package:akorsis/data/models/goal_model.dart';
import 'package:akorsis/data/models/milestone_model.dart';
import 'package:akorsis/data/models/level_model.dart';
import 'package:akorsis/domain/entities/goal.dart';
import 'package:akorsis/domain/entities/milestone.dart';
import 'package:akorsis/domain/entities/level.dart';

void main() {
  final testDate = DateTime(2024, 1, 1);

  group('GoalModel', () {
    test('should create model from entity', () {
      // Arrange
      final entity = Goal(
        id: '1',
        title: 'Test Goal',
        description: 'Description',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
        targetValue: 1000,
        currentValue: 500,
        unit: 'USD',
        color: GoalColor.teal,
      );

      // Act
      final model = GoalModel.fromEntity(entity);

      // Assert
      expect(model.id, entity.id);
      expect(model.title, entity.title);
      expect(model.description, entity.description);
      expect(model.type, entity.type);
      expect(model.category, entity.category);
      expect(model.targetValue, entity.targetValue);
      expect(model.currentValue, entity.currentValue);
      expect(model.unit, entity.unit);
      expect(model.color, entity.color);
    });

    test('should convert to JSON and back', () {
      // Arrange
      final model = GoalModel(
        id: '1',
        title: 'Test Goal',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
        targetValue: 1000,
        currentValue: 500,
        unit: 'USD',
      );

      // Act
      final json = model.toJson();
      final fromJson = GoalModel.fromJson(json);

      // Assert
      expect(fromJson.id, model.id);
      expect(fromJson.title, model.title);
      expect(fromJson.type, model.type);
      expect(fromJson.targetValue, model.targetValue);
      expect(fromJson.currentValue, model.currentValue);
    });

    test('should handle numeric goal type in JSON', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Save Money',
        'type': 'numeric',
        'category': 'finance',
        'createdAt': testDate.toIso8601String(),
        'updatedAt': testDate.toIso8601String(),
        'targetValue': 1000.0,
        'currentValue': 500.0,
        'unit': 'USD',
        'color': 'teal',
        'isCompleted': false,
      };

      // Act
      final model = GoalModel.fromJson(json);

      // Assert
      expect(model.type, GoalType.numeric);
      expect(model.targetValue, 1000.0);
      expect(model.currentValue, 500.0);
      expect(model.unit, 'USD');
    });

    test('should handle habit goal type in JSON', () {
      // Arrange
      final json = {
        'id': '2',
        'title': 'Exercise Daily',
        'type': 'habit',
        'category': 'fitness',
        'createdAt': testDate.toIso8601String(),
        'updatedAt': testDate.toIso8601String(),
        'frequency': 'daily',
        'streak': 5,
        'bestStreak': 10,
        'completedDates': [testDate.toIso8601String()],
        'color': 'purple',
        'isCompleted': false,
      };

      // Act
      final model = GoalModel.fromJson(json);

      // Assert
      expect(model.type, GoalType.habit);
      expect(model.frequency, 'daily');
      expect(model.streak, 5);
      expect(model.bestStreak, 10);
      expect(model.completedDates?.length, 1);
    });

    test('should handle milestone goal type in JSON', () {
      // Arrange
      final json = {
        'id': '3',
        'title': 'Complete Project',
        'type': 'milestone',
        'category': 'career',
        'createdAt': testDate.toIso8601String(),
        'updatedAt': testDate.toIso8601String(),
        'milestones': [
          {
            'id': 'm1',
            'title': 'Phase 1',
            'isCompleted': true,
            'completedAt': testDate.toIso8601String(),
            'order': 0,
          }
        ],
        'color': 'blue',
        'isCompleted': false,
      };

      // Act
      final model = GoalModel.fromJson(json);

      // Assert
      expect(model.type, GoalType.milestone);
      expect(model.milestones?.length, 1);
      expect(model.milestones?[0].title, 'Phase 1');
      expect(model.milestones?[0].isCompleted, true);
    });

    test('should handle levels goal type in JSON', () {
      // Arrange
      final json = {
        'id': '4',
        'title': 'Learn Programming',
        'type': 'levels',
        'category': 'learning',
        'createdAt': testDate.toIso8601String(),
        'updatedAt': testDate.toIso8601String(),
        'levels': [
          {
            'id': 'l1',
            'title': 'Beginner',
            'isCompleted': true,
            'completedAt': testDate.toIso8601String(),
            'order': 0,
          }
        ],
        'currentLevelIndex': 1,
        'color': 'orange',
        'isCompleted': false,
      };

      // Act
      final model = GoalModel.fromJson(json);

      // Assert
      expect(model.type, GoalType.levels);
      expect(model.levels?.length, 1);
      expect(model.currentLevelIndex, 1);
    });

    test('copyWith should update only specified fields', () {
      // Arrange
      final model = GoalModel(
        id: '1',
        title: 'Original',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
        currentValue: 100,
        isCompleted: false,
      );

      // Act
      final updated = model.copyWith(
        title: 'Updated',
        currentValue: 200,
        isCompleted: true,
      );

      // Assert
      expect(updated.id, '1');
      expect(updated.title, 'Updated');
      expect(updated.currentValue, 200);
      expect(updated.isCompleted, true);
      expect(updated.type, GoalType.numeric);
    });

    test('should handle all goal categories', () {
      final categories = [
        GoalCategory.health,
        GoalCategory.finance,
        GoalCategory.learning,
        GoalCategory.career,
        GoalCategory.personal,
        GoalCategory.fitness,
        GoalCategory.creative,
        GoalCategory.social,
      ];

      for (final category in categories) {
        final model = GoalModel(
          id: '1',
          title: 'Test',
          type: GoalType.numeric,
          category: category,
          createdAt: testDate,
          updatedAt: testDate,
        );

        final json = model.toJson();
        final fromJson = GoalModel.fromJson(json);

        expect(fromJson.category, category);
      }
    });

    test('should handle all goal colors', () {
      final colors = [
        GoalColor.teal,
        GoalColor.purple,
        GoalColor.blue,
        GoalColor.orange,
      ];

      for (final color in colors) {
        final model = GoalModel(
          id: '1',
          title: 'Test',
          type: GoalType.numeric,
          category: GoalCategory.finance,
          createdAt: testDate,
          updatedAt: testDate,
          color: color,
        );

        final json = model.toJson();
        final fromJson = GoalModel.fromJson(json);

        expect(fromJson.color, color);
      }
    });
  });

  group('MilestoneModel', () {
    test('should create from entity', () {
      // Arrange
      final entity = Milestone(
        id: 'm1',
        title: 'Complete Phase 1',
        isCompleted: true,
        completedAt: testDate,
        order: 0,
      );

      // Act
      final model = MilestoneModel.fromEntity(entity);

      // Assert
      expect(model.id, entity.id);
      expect(model.title, entity.title);
      expect(model.isCompleted, entity.isCompleted);
      expect(model.completedAt, entity.completedAt);
      expect(model.order, entity.order);
    });

    test('should convert to JSON and back', () {
      // Arrange
      final model = MilestoneModel(
        id: 'm1',
        title: 'Test Milestone',
        isCompleted: true,
        completedAt: testDate,
        order: 0,
      );

      // Act
      final json = model.toJson();
      final fromJson = MilestoneModel.fromJson(json);

      // Assert
      expect(fromJson.id, model.id);
      expect(fromJson.title, model.title);
      expect(fromJson.isCompleted, model.isCompleted);
      expect(fromJson.order, model.order);
    });

    test('copyWith should work correctly', () {
      // Arrange
      final model = MilestoneModel(
        id: 'm1',
        title: 'Original',
        isCompleted: false,
        order: 0,
      );

      // Act
      final updated = model.copyWith(
        title: 'Updated',
        isCompleted: true,
        completedAt: testDate,
      );

      // Assert
      expect(updated.id, 'm1');
      expect(updated.title, 'Updated');
      expect(updated.isCompleted, true);
      expect(updated.completedAt, testDate);
    });
  });

  group('LevelModel', () {
    test('should create from entity', () {
      // Arrange
      final entity = Level(
        id: 'l1',
        title: 'Beginner',
        isCompleted: true,
        completedAt: testDate,
        order: 0,
      );

      // Act
      final model = LevelModel.fromEntity(entity);

      // Assert
      expect(model.id, entity.id);
      expect(model.title, entity.title);
      expect(model.isCompleted, entity.isCompleted);
      expect(model.completedAt, entity.completedAt);
      expect(model.order, entity.order);
    });

    test('should convert to JSON and back', () {
      // Arrange
      final model = LevelModel(
        id: 'l1',
        title: 'Expert',
        isCompleted: false,
        order: 2,
      );

      // Act
      final json = model.toJson();
      final fromJson = LevelModel.fromJson(json);

      // Assert
      expect(fromJson.id, model.id);
      expect(fromJson.title, model.title);
      expect(fromJson.isCompleted, model.isCompleted);
      expect(fromJson.order, model.order);
    });

    test('copyWith should work correctly', () {
      // Arrange
      final model = LevelModel(
        id: 'l1',
        title: 'Intermediate',
        isCompleted: false,
        order: 1,
      );

      // Act
      final updated = model.copyWith(
        isCompleted: true,
        completedAt: testDate,
      );

      // Assert
      expect(updated.id, 'l1');
      expect(updated.title, 'Intermediate');
      expect(updated.isCompleted, true);
      expect(updated.completedAt, testDate);
    });
  });
}
