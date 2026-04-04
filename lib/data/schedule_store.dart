import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/schedule.dart';

class ScheduleStore extends ChangeNotifier {
  static final ScheduleStore instance = ScheduleStore._internal();
  ScheduleStore._internal();

  List<Schedule> _schedules = [];
  List<Schedule> get schedules => List.unmodifiable(_schedules);

  late CollectionReference<Map<String, dynamic>> _col;
  StreamSubscription<QuerySnapshot>? _sub;

  Future<void> init(String uid) async {
    await _sub?.cancel();
    _col = FirebaseFirestore.instance.collection('users/$uid/schedules');
    _sub = _col.snapshots().listen((snap) {
      _schedules = snap.docs.map(_fromDoc).toList();
      notifyListeners();
    });
  }

  Schedule _fromDoc(QueryDocumentSnapshot<Object?> doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Schedule(
      id: d['id'] as String,
      compoundName: d['compoundName'] as String,
      dosage: (d['dosage'] as num).toDouble(),
      unit: d['unit'] as String,
      daysOfWeek: (d['daysOfWeek'] as List).cast<int>(),
      startDate: (d['startDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _toMap(Schedule s) => {
    'id': s.id,
    'compoundName': s.compoundName,
    'dosage': s.dosage,
    'unit': s.unit,
    'daysOfWeek': s.daysOfWeek,
    'startDate': Timestamp.fromDate(s.startDate),
  };

  void addSchedule(Schedule schedule) =>
      _col.doc(schedule.id).set(_toMap(schedule));

  void removeSchedule(Schedule schedule) => _col.doc(schedule.id).delete();

  void updateSchedule(Schedule oldSchedule, Schedule newSchedule) =>
      _col.doc(oldSchedule.id).set(_toMap(newSchedule));

  void refresh() => notifyListeners();

  Future<void> restoreAll(List<Schedule> schedules) async {
    final snap = await _col.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) { batch.delete(doc.reference); }
    for (final s in schedules) { batch.set(_col.doc(s.id), _toMap(s)); }
    await batch.commit();
  }
}
