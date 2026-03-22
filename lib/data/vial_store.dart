import 'package:flutter/material.dart';
import '../models/vial.dart';

class VialStore extends ChangeNotifier {
  static final VialStore instance = VialStore._internal();

  VialStore._internal();

  final List<Vial> _vials = [];

  List<Vial> get vials => _vials;

  void addVial(Vial vial) {
    _vials.add(vial);
    notifyListeners();
  }

  void removeVial(Vial vial) {
    _vials.remove(vial);
    notifyListeners();
  }

  void updateVial(Vial oldVial, Vial newVial) {
    final index = _vials.indexOf(oldVial);
    if (index != -1) {
      _vials[index] = newVial;
      notifyListeners();
    }
  }


}