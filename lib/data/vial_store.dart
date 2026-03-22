import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/vial.dart';

class VialStore extends ChangeNotifier {
  static final VialStore instance = VialStore._internal();

  VialStore._internal();

  final Box<Vial> _box = Hive.box<Vial>('vials');

  List<Vial> get vials => _box.values.toList();

  void addVial(Vial vial) {
    _box.add(vial);
    notifyListeners();
  }

  void removeVial(Vial vial) {
    final key = _box.keys.firstWhere((k) => _box.get(k) == vial);
    _box.delete(key);
    notifyListeners();
  }

  void updateVial(Vial oldVial, Vial newVial) {
    final key = _box.keys.firstWhere((k) => _box.get(k) == oldVial);
    _box.put(key, newVial);
    notifyListeners();
  }
}