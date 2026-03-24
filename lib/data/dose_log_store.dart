import 'package:flutter/material.dart';

class DoseLogStore extends ChangeNotifier {
  static final DoseLogStore instance = DoseLogStore._internal();
  DoseLogStore._internal();

  final Set<String> _takenDoses = {};

  String _key(String compound, DateTime date) {
    return "${compound}_${date.year}-${date.month}-${date.day}";
  }

  bool isTaken(String compound, DateTime date) {
    return _takenDoses.contains(_key(compound, date));
  }

  void toggleDose(String compound, DateTime date) {
    final key = _key(compound, date);

    if (_takenDoses.contains(key)) {
      _takenDoses.remove(key);
    } else {
      _takenDoses.add(key);
    }

    notifyListeners();
  }
}