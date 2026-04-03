import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DoseLogStore extends ChangeNotifier {
  static final DoseLogStore instance = DoseLogStore._internal();
  DoseLogStore._internal();

  Box<bool>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<bool>('dose_logs');
  }

  String _key(String compound, DateTime date) {
    return "${compound}_${date.year}-${date.month}-${date.day}";
  }

  bool isTaken(String compound, DateTime date) {
    return _box?.get(_key(compound, date)) ?? false;
  }

  void toggleDose(String compound, DateTime date) {
    final key = _key(compound, date);
    final current = _box?.get(key) ?? false;
    _box?.put(key, !current);
    notifyListeners();
  }

  int dosesThisWeek(List<String> compoundKeys) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    int count = 0;

    for (int i = 0; i <= now.weekday - 1; i++) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      for (final key in compoundKeys) {
        if (isTaken(key, day)) count++;
      }
    }

    return count;
  }

  int currentStreak(List<String> compoundKeys) {
    if (compoundKeys.isEmpty) return 0;

    int streak = 0;
    final now = DateTime.now();

    for (int i = 0; i <= 365; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final taken = compoundKeys.any((k) => isTaken(k, day));
      if (taken) {
        streak++;
      } else {
        if (i == 0) continue;
        break;
      }
    }

    return streak;
  }
}