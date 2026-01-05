import '../../core/utils/typedef.dart';
import '../entities/goal.dart';
import '../entities/progress_entry.dart';

abstract class GoalRepository {
  ResultFuture<List<Goal>> getAllGoals();
  ResultFuture<Goal> getGoalById(String id);
  ResultFuture<void> createGoal(Goal goal);
  ResultFuture<void> updateGoal(Goal goal);
  ResultFuture<void> deleteGoal(String id);
  
  // Progress tracking
  ResultFuture<void> updateProgress(String goalId, double delta, {String? note});
  ResultFuture<void> completeHabitForToday(String goalId);
  ResultFuture<void> completeMilestone(String goalId, String milestoneId);
  ResultFuture<void> completeLevel(String goalId, String levelId);
  
  // Data management
  ResultFuture<String> exportGoals();
  ResultFuture<void> importGoals(String jsonData);
  ResultFuture<void> clearAllData();
  
  // Progress entries
  ResultFuture<List<ProgressEntry>> getProgressEntries(String goalId);
}
