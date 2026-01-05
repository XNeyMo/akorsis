import '../../core/utils/typedef.dart';
import '../entities/progress_entry.dart';
import '../repositories/goal_repository.dart';

class GetProgressEntries {
  const GetProgressEntries(this._repository);

  final GoalRepository _repository;

  ResultFuture<List<ProgressEntry>> call(String goalId) async {
    return _repository.getProgressEntries(goalId);
  }
}
