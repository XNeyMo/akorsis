import 'package:get_it/get_it.dart';

import 'data/datasources/local_data_source.dart';
import 'data/repositories/goal_repository_impl.dart';
import 'domain/repositories/goal_repository.dart';
import 'domain/usecases/complete_habit_for_today.dart';
import 'domain/usecases/complete_level.dart';
import 'domain/usecases/complete_milestone.dart';
import 'domain/usecases/create_goal.dart';
import 'domain/usecases/delete_goal.dart';
import 'domain/usecases/export_goals.dart';
import 'domain/usecases/clear_all_data.dart';
import 'domain/usecases/get_all_goals.dart';
import 'domain/usecases/get_goal_by_id.dart';
import 'domain/usecases/get_progress_entries.dart';
import 'domain/usecases/import_goals.dart';
import 'domain/usecases/update_goal.dart';
import 'domain/usecases/update_progress.dart';
import 'presentation/bloc/goal_bloc.dart';
import 'presentation/cubit/goal_detail_cubit.dart';
import 'presentation/cubit/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(
    () => GoalBloc(
      getAllGoals: sl(),
      createGoal: sl(),
      updateGoal: sl(),
      deleteGoal: sl(),
      updateProgress: sl(),
      completeHabitForToday: sl(),
      completeMilestone: sl(),
      completeLevel: sl(),
      exportGoals: sl(),
      importGoals: sl(),
      clearAllData: sl(),
    ),
  );

  sl.registerFactory(
    () => GoalDetailCubit(
      getGoalById: sl(),
      getProgressEntries: sl(),
      updateProgress: sl(),
      completeHabitForToday: sl(),
      completeMilestone: sl(),
      completeLevel: sl(),
      deleteGoal: sl(),
    ),
  );

  // Cubit
  sl.registerFactory(() => ThemeCubit());

  // Use cases
  sl.registerLazySingleton(() => GetAllGoals(sl()));
  sl.registerLazySingleton(() => CreateGoal(sl()));
  sl.registerLazySingleton(() => UpdateGoal(sl()));
  sl.registerLazySingleton(() => DeleteGoal(sl()));
  sl.registerLazySingleton(() => UpdateProgress(sl()));
  sl.registerLazySingleton(() => CompleteHabitForToday(sl()));
  sl.registerLazySingleton(() => CompleteMilestone(sl()));
  sl.registerLazySingleton(() => CompleteLevel(sl()));
  sl.registerLazySingleton(() => ExportGoals(sl()));
  sl.registerLazySingleton(() => ImportGoals(sl()));
  sl.registerLazySingleton(() => ClearAllData(sl()));
  sl.registerLazySingleton(() => GetGoalById(sl()));
  sl.registerLazySingleton(() => GetProgressEntries(sl()));

  // Repository
  sl.registerLazySingleton<GoalRepository>(
    () => GoalRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(),
  );
}
