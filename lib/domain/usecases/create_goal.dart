import '../../core/utils/typedef.dart';
import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

class CreateGoal {
  const CreateGoal(this._repository);

  final GoalRepository _repository;

  ResultVoid call(Goal goal) async {
    return _repository.createGoal(goal);
  }
}
