class Profile {
  final int? id;
  final String name;
  final String emoji;
  final String themeFlavor;
  final String themeMode;

  Profile({
    this.id,
    required this.name,
    required this.emoji,
    required this.themeFlavor,
    required this.themeMode,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'emoji': emoji,
      'themeFlavor': themeFlavor,
      'themeMode': themeMode,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as int?,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      themeFlavor: map['themeFlavor'] as String,
      themeMode: map['themeMode'] as String,
    );
  }
}
