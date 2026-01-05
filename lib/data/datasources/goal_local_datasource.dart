import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/goal_model.dart';

abstract class GoalLocalDataSource {
  Future<void> saveGoal(GoalModel goal);
  Future<List<GoalModel>> getAllGoals();
  Future<GoalModel?> getGoalById(String id);
  Future<void> updateGoal(GoalModel goal);
  Future<void> deleteGoal(String id);
}

class GoalLocalDataSourceImpl implements GoalLocalDataSource {
  static const String _boxName = 'goals_encrypted';
  static const String _encryptionKeyName = 'encryption_key';
  
  late Box<String> _goalsBox;
  late encrypt_pkg.Encrypter _encrypter;
  late encrypt_pkg.IV _iv;
  
  GoalLocalDataSourceImpl() {
    _initializeEncryption();
  }

  void _initializeEncryption() {
    // Generate or retrieve encryption key
    final keyBox = Hive.box<String>('secure_keys');
    String? storedKey = keyBox.get(_encryptionKeyName);
    
    final encrypt_pkg.Key key;
    if (storedKey == null) {
      // Generate new key
      key = encrypt_pkg.Key.fromSecureRandom(32);
      keyBox.put(_encryptionKeyName, base64Encode(key.bytes));
    } else {
      key = encrypt_pkg.Key(base64Decode(storedKey));
    }
    
    _iv = encrypt_pkg.IV.fromLength(16);
    _encrypter = encrypt_pkg.Encrypter(encrypt_pkg.AES(key));
  }

  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Open secure keys box first
    if (!Hive.isBoxOpen('secure_keys')) {
      await Hive.openBox<String>('secure_keys');
    }
    
    _initializeEncryption();
    
    // Open goals box
    if (!Hive.isBoxOpen(_boxName)) {
      _goalsBox = await Hive.openBox<String>(_boxName);
    } else {
      _goalsBox = Hive.box<String>(_boxName);
    }
  }

  String _encrypt(String data) {
    return _encrypter.encrypt(data, iv: _iv).base64;
  }

  String _decrypt(String encrypted) {
    return _encrypter.decrypt64(encrypted, iv: _iv);
  }

  @override
  Future<void> saveGoal(GoalModel goal) async {
    final jsonString = jsonEncode(goal.toJson());
    final encrypted = _encrypt(jsonString);
    await _goalsBox.put(goal.id, encrypted);
  }

  @override
  Future<List<GoalModel>> getAllGoals() async {
    final encryptedGoals = _goalsBox.values.toList();
    final goals = <GoalModel>[];
    
    for (final encrypted in encryptedGoals) {
      try {
        final decrypted = _decrypt(encrypted);
        final json = jsonDecode(decrypted) as Map<String, dynamic>;
        goals.add(GoalModel.fromJson(json));
      } catch (e) {
        // Skip corrupted data
        continue;
      }
    }
    
    return goals;
  }

  @override
  Future<GoalModel?> getGoalById(String id) async {
    final encrypted = _goalsBox.get(id);
    if (encrypted == null) return null;
    
    try {
      final decrypted = _decrypt(encrypted);
      final json = jsonDecode(decrypted) as Map<String, dynamic>;
      return GoalModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    await saveGoal(goal);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _goalsBox.delete(id);
  }
}
