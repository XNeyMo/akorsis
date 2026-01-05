import '../../core/utils/typedef.dart';
import '../repositories/goal_repository.dart';

class CompleteLevel {
  const CompleteLevel(this._repository);

  final GoalRepository _repository;

  ResultVoid call({required String goalId, required String levelId}) async {
    return _repository.completeLevel(goalId, levelId);
  }
}
