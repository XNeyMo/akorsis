import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:akorsis/core/error/failures.dart';
import 'package:akorsis/domain/entities/goal.dart';
import 'package:akorsis/domain/usecases/get_all_goals.dart';
import 'package:akorsis/domain/usecases/create_goal.dart';
import 'package:akorsis/domain/usecases/update_goal.dart';
import 'package:akorsis/domain/usecases/delete_goal.dart';
import 'package:akorsis/domain/usecases/update_progress.dart';
import 'package:akorsis/domain/usecases/complete_habit_for_today.dart';
import 'package:akorsis/domain/usecases/complete_milestone.dart';
import 'package:akorsis/domain/usecases/complete_level.dart';
import 'package:akorsis/domain/usecases/export_goals.dart';
import 'package:akorsis/domain/usecases/import_goals.dart';
import 'package:akorsis/domain/usecases/clear_all_data.dart';
import 'package:akorsis/presentation/bloc/goal_bloc.dart';
import 'package:akorsis/presentation/bloc/goal_event.dart';
import 'package:akorsis/presentation/bloc/goal_state.dart';

class MockGetAllGoals extends Mock implements GetAllGoals {}
class MockCreateGoal extends Mock implements CreateGoal {}
class MockUpdateGoal extends Mock implements UpdateGoal {}
class MockDeleteGoal extends Mock implements DeleteGoal {}
class MockUpdateProgress extends Mock implements UpdateProgress {}
class MockCompleteHabitForToday extends Mock implements CompleteHabitForToday {}
class MockCompleteMilestone extends Mock implements CompleteMilestone {}
class MockCompleteLevel extends Mock implements CompleteLevel {}
class MockExportGoals extends Mock implements ExportGoals {}
class MockImportGoals extends Mock implements ImportGoals {}
class MockClearAllData extends Mock implements ClearAllData {}

void main() {
  late GoalBloc bloc;
  late MockGetAllGoals mockGetAllGoals;
  late MockCreateGoal mockCreateGoal;
  late MockUpdateGoal mockUpdateGoal;
  late MockDeleteGoal mockDeleteGoal;
  late MockUpdateProgress mockUpdateProgress;
  late MockCompleteHabitForToday mockCompleteHabitForToday;
  late MockCompleteMilestone mockCompleteMilestone;
  late MockCompleteLevel mockCompleteLevel;
  late MockExportGoals mockExportGoals;
  late MockImportGoals mockImportGoals;
  late MockClearAllData mockClearAllData;

  final testDate = DateTime(2024, 1, 1);
  final testGoal = Goal(
    id: '1',
    title: 'Test Goal',
    type: GoalType.numeric,
    category: GoalCategory.finance,
    createdAt: testDate,
    updatedAt: testDate,
  );

  setUpAll(() {
    registerFallbackValue(testGoal);
    registerFallbackValue(const LoadGoals());
  });

  setUp(() {
    mockGetAllGoals = MockGetAllGoals();
    mockCreateGoal = MockCreateGoal();
    mockUpdateGoal = MockUpdateGoal();
    mockDeleteGoal = MockDeleteGoal();
    mockUpdateProgress = MockUpdateProgress();
    mockCompleteHabitForToday = MockCompleteHabitForToday();
    mockCompleteMilestone = MockCompleteMilestone();
    mockCompleteLevel = MockCompleteLevel();
    mockExportGoals = MockExportGoals();
    mockImportGoals = MockImportGoals();
    mockClearAllData = MockClearAllData();

    bloc = GoalBloc(
      getAllGoals: mockGetAllGoals,
      createGoal: mockCreateGoal,
      updateGoal: mockUpdateGoal,
      deleteGoal: mockDeleteGoal,
      updateProgress: mockUpdateProgress,
      completeHabitForToday: mockCompleteHabitForToday,
      completeMilestone: mockCompleteMilestone,
      completeLevel: mockCompleteLevel,
      exportGoals: mockExportGoals,
      importGoals: mockImportGoals,
      clearAllData: mockClearAllData,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('GoalBloc', () {
    test('initial state should be GoalInitial', () {
      expect(bloc.state, const GoalInitial());
    });

    group('LoadGoals', () {
      blocTest<GoalBloc, GoalState>(
        'emits [GoalLoading, GoalsLoaded] when LoadGoals succeeds',
        build: () {
          when(() => mockGetAllGoals()).thenAnswer(
            (_) async => Right([testGoal]),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadGoals()),
        expect: () => [
          const GoalLoading(),
          GoalsLoaded([testGoal]),
        ],
        verify: (_) {
          verify(() => mockGetAllGoals()).called(1);
        },
      );

      blocTest<GoalBloc, GoalState>(
        'emits [GoalLoading, GoalError] when LoadGoals fails',
        build: () {
          when(() => mockGetAllGoals()).thenAnswer(
            (_) async => const Left(CacheFailure(message: 'Error', statusCode: 500)),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadGoals()),
        expect: () => [
          const GoalLoading(),
          const GoalError('Error'),
        ],
      );

      blocTest<GoalBloc, GoalState>(
        'emits [GoalLoading, GoalsLoaded] with empty list when no goals',
        build: () {
          when(() => mockGetAllGoals()).thenAnswer(
            (_) async => const Right([]),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadGoals()),
        expect: () => [
          const GoalLoading(),
          const GoalsLoaded([]),
        ],
      );
    });

    group('CreateGoalEvent', () {
      blocTest<GoalBloc, GoalState>(
        'emits [GoalLoading, GoalsLoaded] when CreateGoalEvent succeeds',
        build: () {
          when(() => mockCreateGoal(any())).thenAnswer(
            (_) async => const Right(null),
          );
          when(() => mockGetAllGoals()).thenAnswer(
            (_) async => Right([testGoal]),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(CreateGoalEvent(testGoal)),
        expect: () => [
          const GoalLoading(),
          GoalsLoaded([testGoal]),
        ],
        verify: (_) {
          verify(() => mockCreateGoal(any())).called(1);
          verify(() => mockGetAllGoals()).called(1);
        },
      );

      blocTest<GoalBloc, GoalState>(
        'emits [GoalLoading, GoalError] when CreateGoalEvent fails',
        build: () {
          when(() => mockCreateGoal(any())).thenAnswer(
            (_) async => const Left(CacheFailure(message: 'Create failed', statusCode: 500)),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(CreateGoalEvent(testGoal)),
        expect: () => [
          const GoalLoading(),
          const GoalError('Create failed'),
        ],
      );
    });

    group('UpdateGoalEvent', () {
      blocTest<GoalBloc, GoalState>(
        'emits [GoalLoading, GoalsLoaded] when UpdateGoalEvent succeeds',
        build: () {
          when(() => mockUpdateGoal(any())).thenAnswer(
            (_) async => const Right(null),
          );
          when(() => mockGetAllGoals()).thenAnswer(
            (_) async => Right([testGoal]),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateGoalEvent(testGoal)),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          const GoalLoading(),
          GoalsLoaded([testGoal]),
        ],
      );
    });

    group('DeleteGoalEvent', () {
      blocTest<GoalBloc, GoalState>(
        'emits [GoalLoading, GoalsLoaded] when DeleteGoalEvent succeeds',
        build: () {
          when(() => mockDeleteGoal(any())).thenAnswer(
            (_) async => const Right(null),
          );
          when(() => mockGetAllGoals()).thenAnswer(
            (_) async => const Right([]),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteGoalEvent('1')),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          const GoalLoading(),
          const GoalsLoaded([]),
        ],
        verify: (_) {
          verify(() => mockDeleteGoal('1')).called(1);
        },
      );
    });

    group('UpdateProgressEvent', () {
      blocTest<GoalBloc, GoalState>(
        'emits [GoalLoading, GoalsLoaded] when UpdateProgressEvent succeeds',
        build: () {
          when(() => mockUpdateProgress(
                goalId: any(named: 'goalId'),
                delta: any(named: 'delta'),
                note: any(named: 'note'),
              )).thenAnswer(
            (_) async => const Right(null),
          );
          when(() => mockGetAllGoals()).thenAnswer(
            (_) async => Right([testGoal]),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const UpdateProgressEvent(
          goalId: '1',
          delta: 10.0,
          note: 'Progress',
        )),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          const GoalLoading(),
          GoalsLoaded([testGoal]),
        ],
      );
    });

    group('CompleteHabitEvent', () {
      blocTest<GoalBloc, GoalState>(
        'emits [GoalLoading, GoalsLoaded] when CompleteHabitEvent succeeds',
        build: () {
          when(() => mockCompleteHabitForToday(any())).thenAnswer(
            (_) async => const Right(null),
          );
          when(() => mockGetAllGoals()).thenAnswer(
            (_) async => Right([testGoal]),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CompleteHabitEvent('1')),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          const GoalLoading(),
          GoalsLoaded([testGoal]),
        ],
      );
    });

    group('CompleteMilestoneEvent', () {
      blocTest<GoalBloc, GoalState>(
        'emits [GoalLoading, GoalsLoaded] when CompleteMilestoneEvent succeeds',
        build: () {
          when(() => mockCompleteMilestone(
                goalId: any(named: 'goalId'),
                milestoneId: any(named: 'milestoneId'),
              )).thenAnswer(
            (_) async => const Right(null),
          );
          when(() => mockGetAllGoals()).thenAnswer(
            (_) async => Right([testGoal]),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CompleteMilestoneEvent(
          goalId: '1',
          milestoneId: 'm1',
        )),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          const GoalLoading(),
          GoalsLoaded([testGoal]),
        ],
      );
    });

    group('CompleteLevelEvent', () {
      blocTest<GoalBloc, GoalState>(
        'emits [GoalLoading, GoalsLoaded] when CompleteLevelEvent succeeds',
        build: () {
          when(() => mockCompleteLevel(
                goalId: any(named: 'goalId'),
                levelId: any(named: 'levelId'),
              )).thenAnswer(
            (_) async => const Right(null),
          );
          when(() => mockGetAllGoals()).thenAnswer(
            (_) async => Right([testGoal]),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CompleteLevelEvent(
          goalId: '1',
          levelId: 'l1',
        )),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          const GoalLoading(),
          GoalsLoaded([testGoal]),
        ],
      );
    });

    group('ExportGoalsEvent', () {
      blocTest<GoalBloc, GoalState>(
        'emits [GoalLoading, GoalExported] when ExportGoalsEvent succeeds',
        build: () {
          when(() => mockExportGoals()).thenAnswer(
            (_) async => const Right('{"goals": []}'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const ExportGoalsEvent()),
        expect: () => [
          const GoalLoading(),
          const GoalExported('{"goals": []}'),
        ],
      );
    });

    group('ImportGoalsEvent', () {
      blocTest<GoalBloc, GoalState>(
        'emits [GoalLoading, GoalsLoaded] when ImportGoalsEvent succeeds',
        build: () {
          when(() => mockImportGoals(any())).thenAnswer(
            (_) async => const Right(null),
          );
          when(() => mockGetAllGoals()).thenAnswer(
            (_) async => Right([testGoal]),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const ImportGoalsEvent('{"goals": []}')),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          const GoalLoading(),
          GoalsLoaded([testGoal]),
        ],
      );
    });

    group('ClearAllDataEvent', () {
      blocTest<GoalBloc, GoalState>(
        'emits [GoalLoading, GoalsLoaded] with empty list when ClearAllDataEvent succeeds',
        build: () {
          when(() => mockClearAllData()).thenAnswer(
            (_) async => const Right(null),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const ClearAllDataEvent()),
        expect: () => [
          const GoalLoading(),
          const GoalsLoaded([]),
        ],
      );
    });
  });
}
