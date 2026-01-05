import '../../core/utils/typedef.dart';
import '../repositories/goal_repository.dart';

class CompleteMilestone {
  const CompleteMilestone(this._repository);

  final GoalRepository _repository;

  ResultVoid call({required String goalId, required String milestoneId}) async {
    return _repository.completeMilestone(goalId, milestoneId);
  }
}
