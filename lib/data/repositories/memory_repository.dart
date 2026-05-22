// lib/data/repositories/memory_repository.dart
//
// SharedPreferences-backed memory repository.
// Stores memories as a JSON list — zero code-generation required.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memory_model.dart';
import '../seed/seed_memories.dart';

const _storageKey = 'chronos_memories';
const _versionKey = 'chronos_version';
const _currentVersion = 2; // Increment this when you update JSON

class MemoryRepository {
  final SharedPreferences _prefs;
  MemoryRepository._(this._prefs);

  static Future<MemoryRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = MemoryRepository._(prefs);

    // Check version - reload from JSON if version changed or first run
    final savedVersion = prefs.getInt(_versionKey) ?? 0;
    final needsReload = savedVersion != _currentVersion || repo._getRawList().isEmpty;

    if (needsReload) {
      // Clear old data
      await prefs.remove(_storageKey);
      
      // Load from JSON
      final seedMemories = await buildSeedMemories();
      for (final m in seedMemories) {
        await repo.save(m);
      }
      
      // Save current version
      await prefs.setInt(_versionKey, _currentVersion);
    }

    return repo;
  }

  // ── Internal helpers ──────────────────────────────────────
  List<Map<String, dynamic>> _getRawList() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> _saveRawList(List<Map<String, dynamic>> list) async {
    await _prefs.setString(_storageKey, jsonEncode(list));
  }

  // ── Read ─────────────────────────────────────────────────
  List<Memory> getAllMemories() {
    final list = _getRawList().map(Memory.fromMap).toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<Memory> getMemoriesNear(int year, int month, {int windowMonths = 3}) {
    return getAllMemories().where((m) {
      final diff = (m.date.year - year) * 12 + (m.date.month - month);
      return diff.abs() <= windowMonths;
    }).toList();
  }

  Memory? getById(int id) {
    final found = _getRawList().where((m) => m['id'] == id);
    return found.isEmpty ? null : Memory.fromMap(found.first);
  }

  int get count => _getRawList().length;

  List<int> getAvailableYears() {
    final years = getAllMemories().map((m) => m.date.year).toSet().toList();
    years.sort();
    return years;
  }

  // ── Write ─────────────────────────────────────────────────
  Future<void> save(Memory memory) async {
    final list = _getRawList();
    final idx = list.indexWhere((m) => m['id'] == memory.id);
    if (idx >= 0) {
      list[idx] = memory.toMap();
    } else {
      list.add(memory.toMap());
    }
    await _saveRawList(list);
  }

  Future<void> delete(int id) async {
    final list = _getRawList();
    list.removeWhere((m) => m['id'] == id);
    await _saveRawList(list);
  }

  Future<int> nextId() async {
    final list = _getRawList();
    if (list.isEmpty) return 1;
    final maxId = list.map((m) => m['id'] as int? ?? 0).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }
}
