import '../../core/utils/typedef.dart';
import '../repositories/goal_repository.dart';

class DeleteGoal {
  const DeleteGoal(this._repository);

  final GoalRepository _repository;

  ResultVoid call(String id) async {
    return _repository.deleteGoal(id);
  }
}
