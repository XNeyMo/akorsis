import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/progress_entry.dart';
import '../../domain/usecases/get_goal_by_id.dart';
import '../../domain/usecases/get_progress_entries.dart';
import '../../domain/usecases/update_progress.dart';
import '../../domain/usecases/complete_habit_for_today.dart';
import '../../domain/usecases/complete_milestone.dart';
import '../../domain/usecases/complete_level.dart';
import '../../domain/usecases/delete_goal.dart';

part 'goal_detail_state.dart';

class GoalDetailCubit extends Cubit<GoalDetailState> {
  GoalDetailCubit({
    required GetGoalById getGoalById,
    required GetProgressEntries getProgressEntries,
    required UpdateProgress updateProgress,
    required CompleteHabitForToday completeHabitForToday,
    required CompleteMilestone completeMilestone,
    required CompleteLevel completeLevel,
    required DeleteGoal deleteGoal,
  })  : _getGoalById = getGoalById,
        _getProgressEntries = getProgressEntries,
        _updateProgress = updateProgress,
        _completeHabitForToday = completeHabitForToday,
        _completeMilestone = completeMilestone,
        _completeLevel = completeLevel,
      _deleteGoal = deleteGoal,
        super(const GoalDetailInitial());

  final GetGoalById _getGoalById;
  final GetProgressEntries _getProgressEntries;
  final UpdateProgress _updateProgress;
  final CompleteHabitForToday _completeHabitForToday;
  final CompleteMilestone _completeMilestone;
  final CompleteLevel _completeLevel;
  final DeleteGoal _deleteGoal;

  Future<void> load(String goalId) async {
    emit(const GoalDetailLoading());

    final goalResult = await _getGoalById(goalId);
    final entriesResult = await _getProgressEntries(goalId);

    goalResult.fold(
      (failure) => emit(GoalDetailError(failure.message)),
      (goal) {
        entriesResult.fold(
          (failure) => emit(GoalDetailError(failure.message)),
          (entries) {
            entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            emit(GoalDetailLoaded(goal: goal, entries: entries));
          },
        );
      },
    );
  }

  Future<void> addProgress({
    required String goalId,
    required double amount,
    String? note,
  }) async {
    if (state is! GoalDetailLoaded) return;
    final currentState = state as GoalDetailLoaded;
    emit(currentState.copyWith(isSubmitting: true));

    final result = await _updateProgress(goalId: goalId, delta: amount, note: note);

    result.fold(
      (failure) => emit(GoalDetailError(failure.message)),
      (_) async => load(goalId),
    );
  }

  Future<void> completeHabitToday(String goalId) async {
    if (state is! GoalDetailLoaded) return;
    final currentState = state as GoalDetailLoaded;
    emit(currentState.copyWith(isSubmitting: true));

    final result = await _completeHabitForToday(goalId);

    result.fold(
      (failure) => emit(GoalDetailError(failure.message)),
      (_) async => load(goalId),
    );
  }

  Future<void> completeMilestone({required String goalId, required String milestoneId}) async {
    if (state is! GoalDetailLoaded) return;
    final currentState = state as GoalDetailLoaded;
    emit(currentState.copyWith(isSubmitting: true));

    final result = await _completeMilestone(goalId: goalId, milestoneId: milestoneId);

    result.fold(
      (failure) => emit(GoalDetailError(failure.message)),
      (_) async => load(goalId),
    );
  }

  Future<void> completeLevel({required String goalId, required String levelId}) async {
    if (state is! GoalDetailLoaded) return;
    final currentState = state as GoalDetailLoaded;
    emit(currentState.copyWith(isSubmitting: true));

    final result = await _completeLevel(goalId: goalId, levelId: levelId);

    result.fold(
      (failure) => emit(GoalDetailError(failure.message)),
      (_) async => load(goalId),
    );
  }

  Future<void> deleteGoal(String goalId) async {
    if (state is! GoalDetailLoaded) return;
    final currentState = state as GoalDetailLoaded;
    emit(currentState.copyWith(isSubmitting: true));

    final result = await _deleteGoal(goalId);

    result.fold(
      (failure) => emit(GoalDetailError(failure.message)),
      (_) => emit(const GoalDetailDeleted()),
    );
  }
}
