import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:akorsis/core/error/failures.dart';
import 'package:akorsis/domain/entities/goal.dart';
import 'package:akorsis/domain/repositories/goal_repository.dart';
import 'package:akorsis/domain/usecases/create_goal.dart';
import 'package:akorsis/domain/usecases/update_goal.dart';
import 'package:akorsis/domain/usecases/delete_goal.dart';
import 'package:akorsis/domain/usecases/get_all_goals.dart';
import 'package:akorsis/domain/usecases/get_goal_by_id.dart';
import 'package:akorsis/domain/usecases/update_progress.dart';
import 'package:akorsis/domain/usecases/complete_habit_for_today.dart';
import 'package:akorsis/domain/usecases/complete_milestone.dart';
import 'package:akorsis/domain/usecases/complete_level.dart';

class MockGoalRepository extends Mock implements GoalRepository {}

void main() {
  late MockGoalRepository mockRepository;
  final testDate = DateTime(2024, 1, 1);

  setUp(() {
    mockRepository = MockGoalRepository();
  });

  group('CreateGoal', () {
    late CreateGoal usecase;

    setUp(() {
      usecase = CreateGoal(mockRepository);
    });

    test('should create a goal successfully', () async {
      // Arrange
      final goal = Goal(
        id: '1',
        title: 'Test Goal',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
      );

      when(() => mockRepository.createGoal(goal))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(goal);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.createGoal(goal)).called(1);
    });
  });

  group('UpdateGoal', () {
    late UpdateGoal usecase;

    setUp(() {
      usecase = UpdateGoal(mockRepository);
    });

    test('should update a goal successfully', () async {
      // Arrange
      final goal = Goal(
        id: '1',
        title: 'Updated Goal',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: DateTime.now(),
      );

      when(() => mockRepository.updateGoal(goal))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(goal);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.updateGoal(goal)).called(1);
    });
  });

  group('DeleteGoal', () {
    late DeleteGoal usecase;

    setUp(() {
      usecase = DeleteGoal(mockRepository);
    });

    test('should delete a goal successfully', () async {
      // Arrange
      const goalId = '1';

      when(() => mockRepository.deleteGoal(goalId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(goalId);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.deleteGoal(goalId)).called(1);
    });
  });

  group('GetAllGoals', () {
    late GetAllGoals usecase;

    setUp(() {
      usecase = GetAllGoals(mockRepository);
    });

    test('should get all goals successfully', () async {
      // Arrange
      final goals = [
        Goal(
          id: '1',
          title: 'Goal 1',
          type: GoalType.numeric,
          category: GoalCategory.finance,
          createdAt: testDate,
          updatedAt: testDate,
        ),
        Goal(
          id: '2',
          title: 'Goal 2',
          type: GoalType.habit,
          category: GoalCategory.fitness,
          createdAt: testDate,
          updatedAt: testDate,
        ),
      ];

      when(() => mockRepository.getAllGoals())
          .thenAnswer((_) async => Right(goals));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(goals));
      verify(() => mockRepository.getAllGoals()).called(1);
    });

    test('should return empty list when no goals exist', () async {
      // Arrange
      when(() => mockRepository.getAllGoals())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await usecase();

      // Assert
      expect(result, isA<Right<Failure, List<Goal>>>());
    });
  });

  group('GetGoalById', () {
    late GetGoalById usecase;

    setUp(() {
      usecase = GetGoalById(mockRepository);
    });

    test('should get a goal by id successfully', () async {
      // Arrange
      final goal = Goal(
        id: '1',
        title: 'Test Goal',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
      );

      when(() => mockRepository.getGoalById('1'))
          .thenAnswer((_) async => Right(goal));

      // Act
      final result = await usecase('1');

      // Assert
      expect(result, Right(goal));
      verify(() => mockRepository.getGoalById('1')).called(1);
    });
  });

  group('UpdateProgress', () {
    late UpdateProgress usecase;

    setUp(() {
      usecase = UpdateProgress(mockRepository);
    });

    test('should update progress successfully', () async {
      // Arrange
      const goalId = '1';
      const delta = 10.0;
      const note = 'Progress update';

      when(() => mockRepository.updateProgress(goalId, delta, note: note))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(goalId: goalId, delta: delta, note: note);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.updateProgress(goalId, delta, note: note)).called(1);
    });

    test('should update progress without note', () async {
      // Arrange
      const goalId = '1';
      const delta = 5.0;

      when(() => mockRepository.updateProgress(goalId, delta, note: null))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(goalId: goalId, delta: delta);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.updateProgress(goalId, delta, note: null)).called(1);
    });
  });

  group('CompleteHabitForToday', () {
    late CompleteHabitForToday usecase;

    setUp(() {
      usecase = CompleteHabitForToday(mockRepository);
    });

    test('should complete habit for today successfully', () async {
      // Arrange
      const goalId = '1';

      when(() => mockRepository.completeHabitForToday(goalId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(goalId);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.completeHabitForToday(goalId)).called(1);
    });
  });

  group('CompleteMilestone', () {
    late CompleteMilestone usecase;

    setUp(() {
      usecase = CompleteMilestone(mockRepository);
    });

    test('should complete milestone successfully', () async {
      // Arrange
      const goalId = '1';
      const milestoneId = 'm1';

      when(() => mockRepository.completeMilestone(goalId, milestoneId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(goalId: goalId, milestoneId: milestoneId);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.completeMilestone(goalId, milestoneId)).called(1);
    });
  });

  group('CompleteLevel', () {
    late CompleteLevel usecase;

    setUp(() {
      usecase = CompleteLevel(mockRepository);
    });

    test('should complete level successfully', () async {
      // Arrange
      const goalId = '1';
      const levelId = 'l1';

      when(() => mockRepository.completeLevel(goalId, levelId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(goalId: goalId, levelId: levelId);

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.completeLevel(goalId, levelId)).called(1);
    });
  });
}
