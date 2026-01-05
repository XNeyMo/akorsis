import '../../core/utils/typedef.dart';
import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

class GetAllGoals {
  const GetAllGoals(this._repository);

  final GoalRepository _repository;

  ResultFuture<List<Goal>> call() async {
    return _repository.getAllGoals();
  }
}
