import '../../core/utils/typedef.dart';
import '../repositories/goal_repository.dart';

class ImportGoals {
  const ImportGoals(this._repository);

  final GoalRepository _repository;

  ResultVoid call(String jsonData) async {
    return _repository.importGoals(jsonData);
  }
}
