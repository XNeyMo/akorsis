import '../../core/utils/typedef.dart';
import '../repositories/goal_repository.dart';

class ClearAllData {
  const ClearAllData(this._repository);

  final GoalRepository _repository;

  ResultVoid call() async {
    return _repository.clearAllData();
  }
}
