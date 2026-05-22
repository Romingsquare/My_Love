# Chronos Archive - Memory App

A beautiful gift app for your girlfriend with pre-loaded memories and photos.

## How to Add Memories

### 1. Edit JSON File
Open `assets/data/memories.json` and add your memories:

```json
{
  "title": "Our First Date",
  "date": "2024-02-14",
  "description": "The day everything changed...",
  "quote": "You smiled, and I knew.",
  "imagePath": "assets/images/memories/first_date.jpg",
  "locationName": "Café Luna",
  "tags": ["#Love", "#Special"],
  "moodColor": "0xFFEF476F",
  "iconKey": "heart"
}
```

### 2. Add Photos
- Place images in `assets/images/memories/`
- Reference them in JSON: `"imagePath": "assets/images/memories/photo.jpg"`

### 3. Increment Version (Important!)
Open `lib/data/repositories/memory_repository.dart` and change:
```dart
const _currentVersion = 2; // Change to 3, 4, 5... each time you update JSON
```

### 4. Rebuild App
```bash
flutter run
```

**Note:** Incrementing the version forces the app to reload from JSON. Without this, it will use cached data.

## Available Icons
heart, star, camera, music, plane, book, coffee, sparkle, leaf

## Color Examples
- Red/Pink: `0xFFEF476F`
- Blue: `0xFF3B82F6`
- Purple: `0xFF8B5CF6`
- Gold: `0xFFD4A843`
- Yellow: `0xFFFFD166`
- Green: `0xFF06D6A0`

## Features
- ✅ JSON-based memory management
- ✅ Asset image support
- ✅ Rotary wheel with tick sound
- ✅ Beautiful cosmos visualization
- ✅ Memory detail view with photos
