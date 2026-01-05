import '../../core/utils/typedef.dart';
import '../repositories/goal_repository.dart';

class CompleteHabitForToday {
  const CompleteHabitForToday(this._repository);

  final GoalRepository _repository;

  ResultVoid call(String goalId) async {
    return _repository.completeHabitForToday(goalId);
  }
}
