part of 'goal_detail_cubit.dart';

abstract class GoalDetailState extends Equatable {
  const GoalDetailState();

  @override
  List<Object?> get props => [];
}

class GoalDetailInitial extends GoalDetailState {
  const GoalDetailInitial();
}

class GoalDetailLoading extends GoalDetailState {
  const GoalDetailLoading();
}

class GoalDetailLoaded extends GoalDetailState {
  const GoalDetailLoaded({required this.goal, required this.entries, this.isSubmitting = false});

  final Goal goal;
  final List<ProgressEntry> entries;
  final bool isSubmitting;

  GoalDetailLoaded copyWith({Goal? goal, List<ProgressEntry>? entries, bool? isSubmitting}) {
    return GoalDetailLoaded(
      goal: goal ?? this.goal,
      entries: entries ?? this.entries,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [goal, entries, isSubmitting];
}

class GoalDetailError extends GoalDetailState {
  const GoalDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class GoalDetailDeleted extends GoalDetailState {
  const GoalDetailDeleted();
}
