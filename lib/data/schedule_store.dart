import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/schedule.dart';

class ScheduleStore extends ChangeNotifier {
  static final ScheduleStore instance = ScheduleStore._internal();

  ScheduleStore._internal();

  final Box<Schedule> _box = Hive.box<Schedule>('schedules');

  List<Schedule> get schedules => _box.values.toList();

  void addSchedule(Schedule schedule) {
    _box.add(schedule);
    notifyListeners();
  }

  void removeSchedule(Schedule schedule) {
    final key = _box.keys.firstWhere((k) => _box.get(k) == schedule);
    _box.delete(key);
    notifyListeners();
  }

  void updateSchedule(Schedule oldSchedule, Schedule newSchedule) {
    final key = _box.keys.firstWhere((k) => _box.get(k) == oldSchedule);
    _box.put(key, newSchedule);
    notifyListeners();
  }
}