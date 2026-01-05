import '../../core/utils/typedef.dart';
import '../repositories/goal_repository.dart';

class UpdateProgress {
  const UpdateProgress(this._repository);

  final GoalRepository _repository;

  ResultVoid call({required String goalId, required double delta, String? note}) async {
    return _repository.updateProgress(goalId, delta, note: note);
  }
}
