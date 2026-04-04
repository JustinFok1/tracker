import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'vial_inventory_store.dart';

class DoseLogStore extends ChangeNotifier {
  static final DoseLogStore instance = DoseLogStore._internal();
  DoseLogStore._internal();

  // Local cache populated from Firestore stream — keeps isTaken() synchronous.
  final Map<String, bool> _cache = {};

  late CollectionReference<Map<String, dynamic>> _col;
  StreamSubscription<QuerySnapshot>? _sub;

  Future<void> init(String uid) async {
    await _sub?.cancel();
    _col = FirebaseFirestore.instance.collection('users/$uid/dose_logs');
    _sub = _col.snapshots().listen((snap) {
      _cache.clear();
      for (final doc in snap.docs) {
        _cache[doc.id] = (doc.data()['taken'] as bool?) ?? false;
      }
      notifyListeners();
    });
  }

  String _key(String compound, DateTime date) =>
      '${compound}_${date.year}-${date.month}-${date.day}';

  bool isTaken(String compound, DateTime date) =>
      _cache[_key(compound, date)] ?? false;

  Map<String, bool> get allLogs => Map.unmodifiable(_cache);

  void toggleDose(String compound, DateTime date) {
    final key = _key(compound, date);
    final next = !(_cache[key] ?? false);
    _cache[key] = next; // Optimistic local update
    _col.doc(key).set({'taken': next});
    if (next) {
      VialInventoryStore.instance.incrementUsed(compound);
    } else {
      VialInventoryStore.instance.decrementUsed(compound);
    }
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
      final day =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final taken = compoundKeys.any((k) => isTaken(k, day));
      if (taken) {
        streak++;
      } else {
        if (i == 0) continue; // Don't break if today has no doses yet
        break;
      }
    }
    return streak;
  }

  void refresh() => notifyListeners();

  Future<void> restoreAll(Map<String, bool> logs) async {
    final snap = await _col.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) { batch.delete(doc.reference); }
    for (final entry in logs.entries) {
      batch.set(_col.doc(entry.key), {'taken': entry.value});
    }
    await batch.commit();
  }
}
