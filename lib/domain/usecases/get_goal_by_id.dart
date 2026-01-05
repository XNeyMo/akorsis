import '../../core/utils/typedef.dart';
import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

class GetGoalById {
  const GetGoalById(this._repository);

  final GoalRepository _repository;

  ResultFuture<Goal> call(String id) async {
    return _repository.getGoalById(id);
  }
}
