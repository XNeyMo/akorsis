import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/complete_habit_for_today.dart';
import '../../domain/usecases/complete_level.dart';
import '../../domain/usecases/complete_milestone.dart';
import '../../domain/usecases/create_goal.dart';
import '../../domain/usecases/delete_goal.dart';
import '../../domain/usecases/export_goals.dart';
import '../../domain/usecases/get_all_goals.dart';
import '../../domain/usecases/import_goals.dart';
import '../../domain/usecases/clear_all_data.dart';
import '../../domain/usecases/update_goal.dart';
import '../../domain/usecases/update_progress.dart';
import 'goal_event.dart';
import 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  GoalBloc({
    required GetAllGoals getAllGoals,
    required CreateGoal createGoal,
    required UpdateGoal updateGoal,
    required DeleteGoal deleteGoal,
    required UpdateProgress updateProgress,
    required CompleteHabitForToday completeHabitForToday,
    required CompleteMilestone completeMilestone,
    required CompleteLevel completeLevel,
    required ExportGoals exportGoals,
    required ImportGoals importGoals,
    required ClearAllData clearAllData,
  })  : _getAllGoals = getAllGoals,
        _createGoal = createGoal,
        _updateGoal = updateGoal,
        _deleteGoal = deleteGoal,
        _updateProgress = updateProgress,
        _completeHabitForToday = completeHabitForToday,
        _completeMilestone = completeMilestone,
        _completeLevel = completeLevel,
        _exportGoals = exportGoals,
        _importGoals = importGoals,
      _clearAllData = clearAllData,
        super(const GoalInitial()) {
    on<LoadGoals>(_onLoadGoals);
    on<CreateGoalEvent>(_onCreateGoal);
    on<UpdateGoalEvent>(_onUpdateGoal);
    on<DeleteGoalEvent>(_onDeleteGoal);
    on<UpdateProgressEvent>(_onUpdateProgress);
    on<CompleteHabitEvent>(_onCompleteHabit);
    on<CompleteMilestoneEvent>(_onCompleteMilestone);
    on<CompleteLevelEvent>(_onCompleteLevel);
    on<ExportGoalsEvent>(_onExportGoals);
    on<ImportGoalsEvent>(_onImportGoals);
    on<ClearAllDataEvent>(_onClearAllData);
  }

  final GetAllGoals _getAllGoals;
  final CreateGoal _createGoal;
  final UpdateGoal _updateGoal;
  final DeleteGoal _deleteGoal;
  final UpdateProgress _updateProgress;
  final CompleteHabitForToday _completeHabitForToday;
  final CompleteMilestone _completeMilestone;
  final CompleteLevel _completeLevel;
  final ExportGoals _exportGoals;
  final ImportGoals _importGoals;
  final ClearAllData _clearAllData;

  Future<void> _onLoadGoals(LoadGoals event, Emitter<GoalState> emit) async {
    emit(const GoalLoading());

    final result = await _getAllGoals();

    result.fold(
      (failure) => emit(GoalError(failure.message)),
      (goals) => emit(GoalsLoaded(goals)),
    );
  }

  Future<void> _onCreateGoal(CreateGoalEvent event, Emitter<GoalState> emit) async {
    emit(const GoalLoading());

    try {
      final result = await _createGoal(event.goal);

      await result.fold(
        (failure) {
          emit(GoalError(failure.message));
        },
        (_) async {
          final goalsResult = await _getAllGoals();
          goalsResult.fold(
            (failure) {
              emit(GoalError(failure.message));
            },
            (goals) {
              emit(GoalsLoaded(goals));
            },
          );
        },
      );
    } catch (e, stackTrace) {
      print('Error in _onCreateGoal: $e');
      print('Stack trace: $stackTrace');
      emit(GoalError('Error creating goal: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateGoal(UpdateGoalEvent event, Emitter<GoalState> emit) async {
    emit(const GoalLoading());

    final result = await _updateGoal(event.goal);

    result.fold(
      (failure) => emit(GoalError(failure.message)),
      (_) async {
        final goalsResult = await _getAllGoals();
        goalsResult.fold(
          (failure) => emit(GoalError(failure.message)),
          (goals) => emit(GoalsLoaded(goals)),
        );
      },
    );
  }

  Future<void> _onDeleteGoal(DeleteGoalEvent event, Emitter<GoalState> emit) async {
    emit(const GoalLoading());

    final result = await _deleteGoal(event.goalId);

    result.fold(
      (failure) => emit(GoalError(failure.message)),
      (_) async {
        final goalsResult = await _getAllGoals();
        goalsResult.fold(
          (failure) => emit(GoalError(failure.message)),
          (goals) => emit(GoalsLoaded(goals)),
        );
      },
    );
  }

  Future<void> _onUpdateProgress(UpdateProgressEvent event, Emitter<GoalState> emit) async {
    emit(const GoalLoading());

    final result = await _updateProgress(goalId: event.goalId, delta: event.delta, note: event.note);

    result.fold(
      (failure) => emit(GoalError(failure.message)),
      (_) async {
        final goalsResult = await _getAllGoals();
        goalsResult.fold(
          (failure) => emit(GoalError(failure.message)),
          (goals) => emit(GoalsLoaded(goals)),
        );
      },
    );
  }

  Future<void> _onCompleteHabit(CompleteHabitEvent event, Emitter<GoalState> emit) async {
    emit(const GoalLoading());

    final result = await _completeHabitForToday(event.goalId);

    result.fold(
      (failure) => emit(GoalError(failure.message)),
      (_) async {
        final goalsResult = await _getAllGoals();
        goalsResult.fold(
          (failure) => emit(GoalError(failure.message)),
          (goals) => emit(GoalsLoaded(goals)),
        );
      },
    );
  }

  Future<void> _onCompleteMilestone(CompleteMilestoneEvent event, Emitter<GoalState> emit) async {
    emit(const GoalLoading());

    final result = await _completeMilestone(goalId: event.goalId, milestoneId: event.milestoneId);

    result.fold(
      (failure) => emit(GoalError(failure.message)),
      (_) async {
        final goalsResult = await _getAllGoals();
        goalsResult.fold(
          (failure) => emit(GoalError(failure.message)),
          (goals) => emit(GoalsLoaded(goals)),
        );
      },
    );
  }

  Future<void> _onCompleteLevel(CompleteLevelEvent event, Emitter<GoalState> emit) async {
    emit(const GoalLoading());

    final result = await _completeLevel(goalId: event.goalId, levelId: event.levelId);

    result.fold(
      (failure) => emit(GoalError(failure.message)),
      (_) async {
        final goalsResult = await _getAllGoals();
        goalsResult.fold(
          (failure) => emit(GoalError(failure.message)),
          (goals) => emit(GoalsLoaded(goals)),
        );
      },
    );
  }

  Future<void> _onExportGoals(ExportGoalsEvent event, Emitter<GoalState> emit) async {
    emit(const GoalLoading());

    final result = await _exportGoals();

    result.fold(
      (failure) => emit(GoalError(failure.message)),
      (jsonData) => emit(GoalExported(jsonData)),
    );
  }

  Future<void> _onImportGoals(ImportGoalsEvent event, Emitter<GoalState> emit) async {
    emit(const GoalLoading());

    final result = await _importGoals(event.jsonData);

    result.fold(
      (failure) => emit(GoalError(failure.message)),
      (_) async {
        final goalsResult = await _getAllGoals();
        goalsResult.fold(
          (failure) => emit(GoalError(failure.message)),
          (goals) => emit(GoalsLoaded(goals)),
        );
      },
    );
  }

  Future<void> _onClearAllData(ClearAllDataEvent event, Emitter<GoalState> emit) async {
    emit(const GoalLoading());

    final result = await _clearAllData();

    result.fold(
      (failure) => emit(GoalError(failure.message)),
      (_) => emit(const GoalsLoaded([])),
    );
  }
}
