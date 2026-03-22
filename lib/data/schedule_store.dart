import 'package:flutter/material.dart';
import '../models/schedule.dart';

class ScheduleStore extends ChangeNotifier {
  static final ScheduleStore instance = ScheduleStore._internal();

  ScheduleStore._internal();

  final List<Schedule> _schedules = [];

  List<Schedule> get schedules => _schedules;

  void addSchedule(Schedule schedule) {
    _schedules.add(schedule);
    notifyListeners();
  }

  void removeSchedule(Schedule schedule) {
    _schedules.remove(schedule);
    notifyListeners();
  }

  void updateSchedule(Schedule oldSchedule, Schedule newSchedule) {
    final index = _schedules.indexOf(oldSchedule);
    if (index != -1) {
      _schedules[index] = newSchedule;
      notifyListeners();
    }
  }
}