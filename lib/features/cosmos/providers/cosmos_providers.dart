// lib/features/cosmos/providers/cosmos_providers.dart
//
// Plain Riverpod providers — no code generation needed.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/memory_model.dart';
import '../../../data/repositories/memory_repository.dart';

// ── Repository provider ───────────────────────────────────────────────────
final memoryRepositoryProvider = FutureProvider<MemoryRepository>((ref) async {
  return await MemoryRepository.init();
});

// ── All memories provider ─────────────────────────────────────────────────
final allMemoriesProvider = FutureProvider<List<Memory>>((ref) async {
  final repo = await ref.watch(memoryRepositoryProvider.future);
  return repo.getAllMemories();
});

// ── Visible memories (only for the current month) ─────────────────────────
final visibleMemoriesProvider = Provider.family<List<Memory>, ({int year, int month})>(
  (ref, args) {
    final allAsync = ref.watch(allMemoriesProvider);
    return allAsync.whenData((memories) {
      return memories.where((m) {
        // Only show memories that match the exact year and month
        return m.date.year == args.year && m.date.month == args.month;
      }).toList();
    }).valueOrNull ?? [];
  },
);
