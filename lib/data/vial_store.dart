import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/vial.dart';

class VialStore extends ChangeNotifier {
  static final VialStore instance = VialStore._internal();
  VialStore._internal();

  List<Vial> _vials = [];
  List<Vial> get vials => List.unmodifiable(_vials);

  late CollectionReference<Map<String, dynamic>> _col;
  StreamSubscription<QuerySnapshot>? _sub;

  Future<void> init(String uid) async {
    await _sub?.cancel();
    _col = FirebaseFirestore.instance.collection('users/$uid/vials');
    _sub = _col.snapshots().listen((snap) {
      _vials = snap.docs.map(_fromDoc).toList();
      notifyListeners();
    });
  }

  Vial _fromDoc(QueryDocumentSnapshot<Object?> doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Vial(
      compoundName: d['compoundName'] as String,
      dosage: (d['dosage'] as num).toDouble(),
      unit: d['unit'] as String,
      totalDoses: d['totalDoses'] as int?,
    );
  }

  Map<String, dynamic> _toMap(Vial v) => {
    'compoundName': v.compoundName,
    'dosage': v.dosage,
    'unit': v.unit,
    if (v.totalDoses != null) 'totalDoses': v.totalDoses,
  };

  // Use compound+dosage+unit as the stable document ID
  static String docId(Vial v) =>
      '${v.compoundName}_${v.dosage}_${v.unit}'
          .replaceAll('/', '_')
          .replaceAll(' ', '_');

  void addVial(Vial vial) => _col.doc(docId(vial)).set(_toMap(vial));

  void removeVial(Vial vial) => _col.doc(docId(vial)).delete();

  void updateVial(Vial oldVial, Vial newVial) {
    if (docId(oldVial) != docId(newVial)) {
      _col.doc(docId(oldVial)).delete();
    }
    _col.doc(docId(newVial)).set(_toMap(newVial));
  }

  Future<void> restoreAll(List<Vial> vials) async {
    final snap = await _col.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) { batch.delete(doc.reference); }
    for (final v in vials) { batch.set(_col.doc(docId(v)), _toMap(v)); }
    await batch.commit();
  }
}
