import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/error/exceptions.dart';
import '../models/goal_model.dart';
import '../models/progress_entry_model.dart';

abstract class LocalDataSource {
  Future<List<GoalModel>> getAllGoals();
  Future<GoalModel> getGoalById(String id);
  Future<void> saveGoal(GoalModel goal);
  Future<void> deleteGoal(String id);
  Future<void> saveAllGoals(List<GoalModel> goals);
  
  Future<List<ProgressEntryModel>> getProgressEntries(String goalId);
  Future<void> saveProgressEntry(ProgressEntryModel entry);
  
  Future<String> exportData();
  Future<void> importData(String jsonData);
  Future<void> clearAllData();
}

class LocalDataSourceImpl implements LocalDataSource {
  static Box<String>? _goalsBox;
  static Box<String>? _progressBox;
  
  static const String _goalsBoxName = 'goals_data';
  static const String _progressBoxName = 'progress_data';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    if (_goalsBox == null || !_goalsBox!.isOpen) {
      _goalsBox = await Hive.openBox<String>(_goalsBoxName);
    }
    
    if (_progressBox == null || !_progressBox!.isOpen) {
      _progressBox = await Hive.openBox<String>(_progressBoxName);
    }
  }

  @override
  Future<List<GoalModel>> getAllGoals() async {
    try {
      if (_goalsBox == null) await initialize();
      
      final goals = <GoalModel>[];
      
      for (final jsonString in _goalsBox!.values) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          goals.add(GoalModel.fromJson(json));
        } catch (e) {
          print('Error parsing goal: ${e.toString()}');
          continue;
        }
      }
      
      return goals;
    } catch (e) {
      print('Error in getAllGoals: $e');
      throw CacheException(message: 'Failed to load goals: ${e.toString()}', statusCode: 500);
    }
  }

  @override
  Future<GoalModel> getGoalById(String id) async {
    try {
      if (_goalsBox == null) await initialize();
      
      final jsonString = _goalsBox!.get(id);
      if (jsonString == null) {
        throw const CacheException(message: 'Goal not found', statusCode: 404);
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GoalModel.fromJson(json);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> saveGoal(GoalModel goal) async {
    try {
      if (_goalsBox == null) await initialize();
      
      final goalJson = goal.toJson();
      final jsonString = jsonEncode(goalJson);
      await _goalsBox!.put(goal.id, jsonString);
    } catch (e, stackTrace) {
      print('Error saving goal: ${e.toString()}');
      print('Stack trace: $stackTrace');
      throw CacheException(message: 'Failed to save goal: ${e.toString()}', statusCode: 500);
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      if (_goalsBox == null) await initialize();
      
      await _goalsBox!.delete(id);
      
      // Also delete associated progress entries
      if (_progressBox == null) await initialize();
      final keysToDelete = <String>[];
      for (final key in _progressBox!.keys) {
        try {
          final jsonString = _progressBox!.get(key);
          if (jsonString != null) {
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            if (json['goalId'] == id) {
              keysToDelete.add(key as String);
            }
          }
        } catch (e) {
          continue;
        }
      }
      for (final key in keysToDelete) {
        await _progressBox!.delete(key);
      }
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> saveAllGoals(List<GoalModel> goals) async {
    try {
      if (_goalsBox == null) await initialize();
      
      await _goalsBox!.clear();
      for (final goal in goals) {
        await saveGoal(goal);
      }
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<List<ProgressEntryModel>> getProgressEntries(String goalId) async {
    try {
      if (_progressBox == null) await initialize();
      
      final entries = <ProgressEntryModel>[];
      for (final jsonString in _progressBox!.values) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final entry = ProgressEntryModel.fromJson(json);
          if (entry.goalId == goalId) {
            entries.add(entry);
          }
        } catch (e) {
          continue;
        }
      }
      
      return entries;
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> saveProgressEntry(ProgressEntryModel entry) async {
    try {
      if (_progressBox == null) await initialize();
      
      final jsonString = jsonEncode(entry.toJson());
      await _progressBox!.put(entry.id, jsonString);
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<String> exportData() async {
    try {
      final goals = await getAllGoals();
      final goalsJson = goals.map((goal) => goal.toJson()).toList();
      
      final exportData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'goals': goalsJson,
      };

      return jsonEncode(exportData);
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final List<dynamic> goalsJson = data['goals'] as List;
      final goals = goalsJson.map((json) => GoalModel.fromJson(json as Map<String, dynamic>)).toList();
      await saveAllGoals(goals);
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      if (_goalsBox == null || _progressBox == null) await initialize();
      
      await _goalsBox!.clear();
      await _progressBox!.clear();
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }
}
