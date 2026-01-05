import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/utils/typedef.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/progress_entry.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/goal_model.dart';
import '../models/milestone_model.dart';
import '../models/level_model.dart';
import '../models/progress_entry_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  const GoalRepositoryImpl(this._localDataSource);

  final LocalDataSource _localDataSource;
  final _uuid = const Uuid();

  @override
  ResultFuture<List<Goal>> getAllGoals() async {
    try {
      final result = await _localDataSource.getAllGoals();
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<Goal> getGoalById(String id) async {
    try {
      final result = await _localDataSource.getGoalById(id);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> createGoal(Goal goal) async {
    try {
      final goalModel = GoalModel.fromEntity(goal);
      await _localDataSource.saveGoal(goalModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> updateGoal(Goal goal) async {
    try {
      final updatedGoal = GoalModel.fromEntity(goal).copyWith(
        updatedAt: DateTime.now(),
      );
      await _localDataSource.saveGoal(updatedGoal);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> deleteGoal(String id) async {
    try {
      await _localDataSource.deleteGoal(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> updateProgress(String goalId, double delta, {String? note}) async {
    try {
      final goal = await _localDataSource.getGoalById(goalId);
      final current = goal.currentValue ?? 0;
      final newTotal = current + delta;

      final updatedGoal = GoalModel.fromEntity(goal).copyWith(
        currentValue: newTotal,
        updatedAt: DateTime.now(),
      );

      // Save progress entry
      final entry = ProgressEntryModel(
        id: _uuid.v4(),
        goalId: goalId,
        value: delta,
        note: note,
        createdAt: DateTime.now(),
      );
      await _localDataSource.saveProgressEntry(entry);
      
      // Update goal
      await _localDataSource.saveGoal(updatedGoal);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> completeHabitForToday(String goalId) async {
    try {
      final goal = await _localDataSource.getGoalById(goalId);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final completedDates = List<DateTime>.from(goal.completedDates ?? []);
      
      // Check if already completed today
      if (completedDates.any((date) => 
        date.year == today.year && 
        date.month == today.month && 
        date.day == today.day)) {
        return const Right(null);
      }

      completedDates.add(today);
      
      // Calculate streak
      int newStreak = 1;
      final sortedDates = List<DateTime>.from(completedDates)..sort((a, b) => b.compareTo(a));
      
      for (int i = 0; i < sortedDates.length - 1; i++) {
        final diff = sortedDates[i].difference(sortedDates[i + 1]).inDays;
        if (diff == 1) {
          newStreak++;
        } else {
          break;
        }
      }

      final bestStreak = goal.bestStreak ?? 0;
      final updatedGoal = GoalModel.fromEntity(goal).copyWith(
        completedDates: completedDates,
        streak: newStreak,
        bestStreak: newStreak > bestStreak ? newStreak : bestStreak,
        updatedAt: DateTime.now(),
      );

      final entry = ProgressEntryModel(
        id: _uuid.v4(),
        goalId: goalId,
        value: 1,
        note: 'Habit completed',
        createdAt: now,
      );

      await _localDataSource.saveProgressEntry(entry);
      await _localDataSource.saveGoal(updatedGoal);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> completeMilestone(String goalId, String milestoneId) async {
    try {
      final goal = await _localDataSource.getGoalById(goalId);
      final milestones = List<MilestoneModel>.from(
        goal.milestones?.map((m) => MilestoneModel.fromEntity(m)) ?? [],
      );

      final index = milestones.indexWhere((m) => m.id == milestoneId);
      if (index == -1) {
        return const Left(CacheFailure(message: 'Milestone not found', statusCode: 404));
      }

      milestones[index] = milestones[index].copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      final now = DateTime.now();
      final entry = ProgressEntryModel(
        id: _uuid.v4(),
        goalId: goalId,
        value: 1,
        note: 'Milestone "${milestones[index].title}" completed',
        createdAt: now,
      );
      await _localDataSource.saveProgressEntry(entry);

      final allCompleted = milestones.every((m) => m.isCompleted);
      final updatedGoal = GoalModel.fromEntity(goal).copyWith(
        milestones: milestones,
        isCompleted: allCompleted,
        completedAt: allCompleted ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );

      await _localDataSource.saveGoal(updatedGoal);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> completeLevel(String goalId, String levelId) async {
    try {
      final goal = await _localDataSource.getGoalById(goalId);
      final levels = List<LevelModel>.from(
        goal.levels?.map((l) => LevelModel.fromEntity(l)) ?? [],
      );

      final index = levels.indexWhere((l) => l.id == levelId);
      if (index == -1) {
        return const Left(CacheFailure(message: 'Level not found', statusCode: 404));
      }

      levels[index] = levels[index].copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      final now = DateTime.now();
      final entry = ProgressEntryModel(
        id: _uuid.v4(),
        goalId: goalId,
        value: 1,
        note: 'Level "${levels[index].title}" completed',
        createdAt: now,
      );
      await _localDataSource.saveProgressEntry(entry);

      final allCompleted = levels.every((l) => l.isCompleted);
      final updatedGoal = GoalModel.fromEntity(goal).copyWith(
        levels: levels,
        currentLevelIndex: index + 1,
        isCompleted: allCompleted,
        completedAt: allCompleted ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );

      await _localDataSource.saveGoal(updatedGoal);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<String> exportGoals() async {
    try {
      final result = await _localDataSource.exportData();
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> importGoals(String jsonData) async {
    try {
      await _localDataSource.importData(jsonData);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> clearAllData() async {
    try {
      await _localDataSource.clearAllData();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<ProgressEntry>> getProgressEntries(String goalId) async {
    try {
      final result = await _localDataSource.getProgressEntries(goalId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
