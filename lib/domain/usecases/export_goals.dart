import '../../core/utils/typedef.dart';
import '../repositories/goal_repository.dart';

class ExportGoals {
  const ExportGoals(this._repository);

  final GoalRepository _repository;

  ResultFuture<String> call() async {
    return _repository.exportGoals();
  }
}
