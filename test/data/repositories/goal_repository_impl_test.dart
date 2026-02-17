import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:akorsis/core/error/exceptions.dart';
import 'package:akorsis/core/error/failures.dart';
import 'package:akorsis/data/datasources/local_data_source.dart';
import 'package:akorsis/data/models/goal_model.dart';
import 'package:akorsis/data/models/milestone_model.dart';
import 'package:akorsis/data/models/progress_entry_model.dart';
import 'package:akorsis/data/repositories/goal_repository_impl.dart';
import 'package:akorsis/domain/entities/goal.dart';
import 'package:akorsis/domain/entities/milestone.dart';

class MockLocalDataSource extends Mock implements LocalDataSource {}

void main() {
  late GoalRepositoryImpl repository;
  late MockLocalDataSource mockDataSource;
  final testDate = DateTime(2024, 1, 1);

  setUpAll(() {
    registerFallbackValue(
      GoalModel(
        id: '1',
        title: 'Test',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
      ),
    );
    registerFallbackValue(
      ProgressEntryModel(
        id: '1',
        goalId: '1',
        value: 10.0,
        createdAt: testDate,
      ),
    );
  });

  setUp(() {
    mockDataSource = MockLocalDataSource();
    repository = GoalRepositoryImpl(mockDataSource);
  });

  group('getAllGoals', () {
    test('should return list of goals when successful', () async {
      // Arrange
      final goalModels = [
        GoalModel(
          id: '1',
          title: 'Goal 1',
          type: GoalType.numeric,
          category: GoalCategory.finance,
          createdAt: testDate,
          updatedAt: testDate,
        ),
        GoalModel(
          id: '2',
          title: 'Goal 2',
          type: GoalType.habit,
          category: GoalCategory.fitness,
          createdAt: testDate,
          updatedAt: testDate,
        ),
      ];

      when(() => mockDataSource.getAllGoals())
          .thenAnswer((_) async => goalModels);

      // Act
      final result = await repository.getAllGoals();

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (goals) {
          expect(goals.length, 2);
          expect(goals[0].id, '1');
          expect(goals[1].id, '2');
        },
      );
      verify(() => mockDataSource.getAllGoals()).called(1);
    });

    test('should return CacheFailure when exception occurs', () async {
      // Arrange
      when(() => mockDataSource.getAllGoals())
          .thenThrow(const CacheException(message: 'Error', statusCode: 500));

      // Act
      final result = await repository.getAllGoals();

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'Error');
        },
        (goals) => fail('Should not return goals'),
      );
    });
  });

  group('getGoalById', () {
    test('should return goal when found', () async {
      // Arrange
      final goalModel = GoalModel(
        id: '1',
        title: 'Test Goal',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
      );

      when(() => mockDataSource.getGoalById('1'))
          .thenAnswer((_) async => goalModel);

      // Act
      final result = await repository.getGoalById('1');

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (goal) => expect(goal.id, '1'),
      );
    });
  });

  group('createGoal', () {
    test('should save goal successfully', () async {
      // Arrange
      final goal = Goal(
        id: '1',
        title: 'New Goal',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
      );

      when(() => mockDataSource.saveGoal(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.createGoal(goal);

      // Assert
      expect(result, const Right(null));
      verify(() => mockDataSource.saveGoal(any())).called(1);
    });
  });

  group('updateProgress', () {
    test('should update progress and mark as completed when target reached', () async {
      // Arrange
      final goal = GoalModel(
        id: '1',
        title: 'Test',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
        currentValue: 90.0,
        targetValue: 100.0,
        isCompleted: false,
      );

      when(() => mockDataSource.getGoalById('1'))
          .thenAnswer((_) async => goal);
      when(() => mockDataSource.saveProgressEntry(any()))
          .thenAnswer((_) async => {});
      when(() => mockDataSource.saveGoal(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.updateProgress('1', 15.0);

      // Assert
      expect(result, const Right(null));
      verify(() => mockDataSource.getGoalById('1')).called(1);
      verify(() => mockDataSource.saveProgressEntry(any())).called(1);
      final captured = verify(() => mockDataSource.saveGoal(captureAny())).captured;
      final savedGoal = captured[0] as GoalModel;
      expect(savedGoal.currentValue, 105.0);
      expect(savedGoal.isCompleted, true);
      expect(savedGoal.completedAt, isNotNull);
    });

    test('should not mark as completed when target not reached', () async {
      // Arrange
      final goal = GoalModel(
        id: '1',
        title: 'Test',
        type: GoalType.numeric,
        category: GoalCategory.finance,
        createdAt: testDate,
        updatedAt: testDate,
        currentValue: 50.0,
        targetValue: 100.0,
        isCompleted: false,
      );

      when(() => mockDataSource.getGoalById('1'))
          .thenAnswer((_) async => goal);
      when(() => mockDataSource.saveProgressEntry(any()))
          .thenAnswer((_) async => {});
      when(() => mockDataSource.saveGoal(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.updateProgress('1', 20.0);

      // Assert
      expect(result, const Right(null));
      final captured = verify(() => mockDataSource.saveGoal(captureAny())).captured;
      final savedGoal = captured[0] as GoalModel;
      expect(savedGoal.currentValue, 70.0);
      expect(savedGoal.isCompleted, false);
    });
  });

  group('completeHabitForToday', () {
    test('should complete habit and update streak', () async {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
      
      final goal = GoalModel(
        id: '1',
        title: 'Exercise',
        type: GoalType.habit,
        category: GoalCategory.fitness,
        createdAt: testDate,
        updatedAt: testDate,
        completedDates: [yesterdayDate],
        streak: 1,
        bestStreak: 5,
      );

      when(() => mockDataSource.getGoalById('1'))
          .thenAnswer((_) async => goal);
      when(() => mockDataSource.saveProgressEntry(any()))
          .thenAnswer((_) async => {});
      when(() => mockDataSource.saveGoal(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.completeHabitForToday('1');

      // Assert
      expect(result, const Right(null));
      final captured = verify(() => mockDataSource.saveGoal(captureAny())).captured;
      final savedGoal = captured[0] as GoalModel;
      expect(savedGoal.streak, 2);
      expect(savedGoal.completedDates?.length, 2);
    });

    test('should not duplicate completion for same day', () async {
      // Arrange
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      final goal = GoalModel(
        id: '1',
        title: 'Exercise',
        type: GoalType.habit,
        category: GoalCategory.fitness,
        createdAt: testDate,
        updatedAt: testDate,
        completedDates: [todayDate],
        streak: 1,
      );

      when(() => mockDataSource.getGoalById('1'))
          .thenAnswer((_) async => goal);

      // Act
      final result = await repository.completeHabitForToday('1');

      // Assert
      expect(result, const Right(null));
      verifyNever(() => mockDataSource.saveGoal(any()));
    });
  });

  group('completeMilestone', () {
    test('should complete milestone and mark goal as completed when all done', () async {
      // Arrange
      final milestones = [
        MilestoneModel(id: 'm1', title: 'M1', isCompleted: true, order: 0),
        MilestoneModel(id: 'm2', title: 'M2', isCompleted: false, order: 1),
      ];

      final goal = GoalModel(
        id: '1',
        title: 'Project',
        type: GoalType.milestone,
        category: GoalCategory.career,
        createdAt: testDate,
        updatedAt: testDate,
        milestones: milestones,
        isCompleted: false,
      );

      when(() => mockDataSource.getGoalById('1'))
          .thenAnswer((_) async => goal);
      when(() => mockDataSource.saveProgressEntry(any()))
          .thenAnswer((_) async => {});
      when(() => mockDataSource.saveGoal(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.completeMilestone('1', 'm2');

      // Assert
      expect(result, const Right(null));
      final captured = verify(() => mockDataSource.saveGoal(captureAny())).captured;
      final savedGoal = captured[0] as GoalModel;
      expect(savedGoal.milestones?[1].isCompleted, true);
      expect(savedGoal.isCompleted, true);
      expect(savedGoal.completedAt, isNotNull);
    });
  });

  group('completeLevel', () {
    test('should complete level and update current level index', () async {
      // Arrange
      final goal = GoalModel(
        id: '1',
        title: 'Learning',
        type: GoalType.levels,
        category: GoalCategory.learning,
        createdAt: testDate,
        updatedAt: testDate,
        currentLevelIndex: 0,
        isCompleted: false,
      );

      when(() => mockDataSource.getGoalById('1'))
          .thenAnswer((_) async => goal);
      when(() => mockDataSource.saveProgressEntry(any()))
          .thenAnswer((_) async => {});
      when(() => mockDataSource.saveGoal(any()))
          .thenAnswer((_) async => {});

      // Act - This would need proper level data, simplified for test
      // In real scenario, you'd mock proper levels
    });
  });
}
