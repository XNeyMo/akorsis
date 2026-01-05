import 'package:equatable/equatable.dart';
import '../../../domain/entities/goal.dart';

abstract class GoalState extends Equatable {
  const GoalState();

  @override
  List<Object?> get props => [];
}

class GoalInitial extends GoalState {
  const GoalInitial();
}

class GoalLoading extends GoalState {
  const GoalLoading();
}

class GoalsLoaded extends GoalState {
  const GoalsLoaded(this.goals);

  final List<Goal> goals;

  @override
  List<Object?> get props => [goals];
}

class GoalOperationSuccess extends GoalState {
  const GoalOperationSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class GoalExported extends GoalState {
  const GoalExported(this.jsonData);

  final String jsonData;

  @override
  List<Object?> get props => [jsonData];
}

class GoalError extends GoalState {
  const GoalError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
