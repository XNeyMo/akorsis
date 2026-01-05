import 'package:equatable/equatable.dart';
import '../../../domain/entities/goal.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

class LoadGoals extends GoalEvent {
  const LoadGoals();
}

class CreateGoalEvent extends GoalEvent {
  const CreateGoalEvent(this.goal);

  final Goal goal;

  @override
  List<Object?> get props => [goal];
}

class UpdateGoalEvent extends GoalEvent {
  const UpdateGoalEvent(this.goal);

  final Goal goal;

  @override
  List<Object?> get props => [goal];
}

class DeleteGoalEvent extends GoalEvent {
  const DeleteGoalEvent(this.goalId);

  final String goalId;

  @override
  List<Object?> get props => [goalId];
}

class UpdateProgressEvent extends GoalEvent {
  const UpdateProgressEvent({required this.goalId, required this.delta, this.note});

  final String goalId;
  final double delta;
  final String? note;

  @override
  List<Object?> get props => [goalId, delta, note];
}

class CompleteHabitEvent extends GoalEvent {
  const CompleteHabitEvent(this.goalId);

  final String goalId;

  @override
  List<Object?> get props => [goalId];
}

class CompleteMilestoneEvent extends GoalEvent {
  const CompleteMilestoneEvent({required this.goalId, required this.milestoneId});

  final String goalId;
  final String milestoneId;

  @override
  List<Object?> get props => [goalId, milestoneId];
}

class CompleteLevelEvent extends GoalEvent {
  const CompleteLevelEvent({required this.goalId, required this.levelId});

  final String goalId;
  final String levelId;

  @override
  List<Object?> get props => [goalId, levelId];
}

class ExportGoalsEvent extends GoalEvent {
  const ExportGoalsEvent();
}

class ImportGoalsEvent extends GoalEvent {
  const ImportGoalsEvent(this.jsonData);

  final String jsonData;

  @override
  List<Object?> get props => [jsonData];
}

class ClearAllDataEvent extends GoalEvent {
  const ClearAllDataEvent();
}
