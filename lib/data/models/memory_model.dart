// lib/data/models/memory_model.dart
//
// Memory model stored in Hive as a Map<String, dynamic>.
// Using manual serialization avoids hive_generator code-gen entirely
// while keeping perfect performance.

class Memory {
  final int id;
  final String title;
  final DateTime date;
  final String? description;
  final String? quote;
  final String? imagePath;
  final String? thumbnailPath;
  final String? audioPath;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? weather;
  final List<String> tags;
  final int moodColorValue;
  final double cosmosOffsetX;
  final double cosmosOffsetY;
  final String iconKey;

  const Memory({
    required this.id,
    required this.title,
    required this.date,
    this.description,
    this.quote,
    this.imagePath,
    this.thumbnailPath,
    this.audioPath,
    this.locationName,
    this.latitude,
    this.longitude,
    this.weather,
    this.tags = const [],
    this.moodColorValue = 0xFFD4A843,
    this.cosmosOffsetX = 0,
    this.cosmosOffsetY = 0,
    this.iconKey = 'star',
  });

  // ── Hive serialization ───────────────────────────────────
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'date': date.millisecondsSinceEpoch,
    'description': description,
    'quote': quote,
    'imagePath': imagePath,
    'thumbnailPath': thumbnailPath,
    'audioPath': audioPath,
    'locationName': locationName,
    'latitude': latitude,
    'longitude': longitude,
    'weather': weather,
    'tags': tags,
    'moodColorValue': moodColorValue,
    'cosmosOffsetX': cosmosOffsetX,
    'cosmosOffsetY': cosmosOffsetY,
    'iconKey': iconKey,
  };

  factory Memory.fromMap(Map map) => Memory(
    id: map['id'] as int? ?? 0,
    title: map['title'] as String? ?? '',
    date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int? ?? 0),
    description: map['description'] as String?,
    quote: map['quote'] as String?,
    imagePath: map['imagePath'] as String?,
    thumbnailPath: map['thumbnailPath'] as String?,
    audioPath: map['audioPath'] as String?,
    locationName: map['locationName'] as String?,
    latitude: (map['latitude'] as num?)?.toDouble(),
    longitude: (map['longitude'] as num?)?.toDouble(),
    weather: map['weather'] as String?,
    tags: List<String>.from(map['tags'] as List? ?? []),
    moodColorValue: map['moodColorValue'] as int? ?? 0xFFD4A843,
    cosmosOffsetX: (map['cosmosOffsetX'] as num?)?.toDouble() ?? 0,
    cosmosOffsetY: (map['cosmosOffsetY'] as num?)?.toDouble() ?? 0,
    iconKey: map['iconKey'] as String? ?? 'star',
  );

  Memory copyWith({
    int? id,
    String? title,
    DateTime? date,
    String? description,
    String? quote,
    String? imagePath,
    String? locationName,
    double? latitude,
    double? longitude,
    String? weather,
    List<String>? tags,
    int? moodColorValue,
    String? iconKey,
  }) => Memory(
    id: id ?? this.id,
    title: title ?? this.title,
    date: date ?? this.date,
    description: description ?? this.description,
    quote: quote ?? this.quote,
    imagePath: imagePath ?? this.imagePath,
    thumbnailPath: thumbnailPath,
    audioPath: audioPath,
    locationName: locationName ?? this.locationName,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    weather: weather ?? this.weather,
    tags: tags ?? this.tags,
    moodColorValue: moodColorValue ?? this.moodColorValue,
    cosmosOffsetX: cosmosOffsetX,
    cosmosOffsetY: cosmosOffsetY,
    iconKey: iconKey ?? this.iconKey,
  );
}

/// Icon key constants
class MemoryIcon {
  static const String star    = 'star';
  static const String camera  = 'camera';
  static const String heart   = 'heart';
  static const String music   = 'music';
  static const String plane   = 'plane';
  static const String book    = 'book';
  static const String coffee  = 'coffee';
  static const String sparkle = 'sparkle';
  static const String leaf    = 'leaf';
  
  // Additional icons
  static const String cake    = 'cake';        // birthdays, celebrations
  static const String gift    = 'gift';        // presents, surprises
  static const String home    = 'home';        // home, family
  static const String beach   = 'beach';       // beach, vacation
  static const String mountain = 'mountain';   // hiking, adventure
  static const String food    = 'food';        // dining, meals
  static const String movie   = 'movie';       // cinema, films
  static const String game    = 'game';        // gaming, sports
  static const String pet     = 'pet';         // pets, animals
  static const String car     = 'car';         // road trips, driving
  static const String bike    = 'bike';        // cycling, biking
  static const String run     = 'run';         // running, fitness
  static const String paint   = 'paint';       // art, creativity
  static const String school  = 'school';      // education, learning
  static const String work    = 'work';        // career, achievements
  static const String chat    = 'chat';        // conversations, messages
  static const String laugh   = 'laugh';       // funny moments
  static const String sunset  = 'sunset';      // beautiful views
  static const String rain    = 'rain';        // rainy days
  static const String snow    = 'snow';        // winter, snow
}
