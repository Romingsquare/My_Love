// lib/data/seed/seed_memories.dart
// Loads memories from JSON file with support for images.

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/memory_model.dart';

Future<List<Memory>> buildSeedMemories() async {
  try {
    // Load JSON file from assets
    final String jsonString = await rootBundle.loadString('assets/data/memories.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    
    final rand = Random(42); // deterministic cosmos layout
    int nextId = 1;
    
    // Convert JSON to Memory objects
    final memories = <Memory>[];
    for (var jsonItem in jsonList) {
      try {
        final map = jsonItem as Map<String, dynamic>;
        
        memories.add(Memory(
          id: nextId++,
          title: map['title'] as String,
          date: DateTime.parse(map['date'] as String),
          description: map['description'] as String?,
          quote: map['quote'] as String?,
          imagePath: map['imagePath'] as String?,
          locationName: map['locationName'] as String?,
          tags: List<String>.from(map['tags'] ?? []),
          moodColorValue: int.parse(map['moodColor'] as String),
          iconKey: map['iconKey'] as String? ?? 'star',
          cosmosOffsetX: (rand.nextDouble() - 0.5) * 0.55,
          cosmosOffsetY: (rand.nextDouble() - 0.5) * 0.38,
        ));
      } catch (e) {
        // Skip invalid memory and continue
        debugPrint('Error parsing memory: $e');
        continue;
      }
    }
    
    return memories;
  } catch (e) {
    // Return empty list if JSON fails to load
    debugPrint('Error loading memories from JSON: $e');
    return [];
  }
}
