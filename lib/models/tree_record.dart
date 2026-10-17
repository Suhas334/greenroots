class TreeRecord {
  final String id, name, species, location, notes;
  final DateTime planted;
  final double height;
  final bool needsCare;
  const TreeRecord(
      {required this.id,
      required this.name,
      required this.species,
      required this.location,
      required this.notes,
      required this.planted,
      required this.height,
      required this.needsCare});
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'species': species,
        'location': location,
        'notes': notes,
        'planted': planted.toIso8601String(),
        'height': height,
        'needsCare': needsCare
      };
  factory TreeRecord.fromJson(Map<String, dynamic> j) => TreeRecord(
      id: j['id'] as String,
      name: j['name'] as String,
      species: j['species'] as String? ?? '',
      location: j['location'] as String? ?? '',
      notes: j['notes'] as String? ?? '',
      planted: DateTime.parse(j['planted'] as String),
      height: (j['height'] as num?)?.toDouble() ?? 0,
      needsCare: j['needsCare'] as bool? ?? false);
  TreeRecord copyWith({bool? needsCare}) => TreeRecord(
      id: id,
      name: name,
      species: species,
      location: location,
      notes: notes,
      planted: planted,
      height: height,
      needsCare: needsCare ?? this.needsCare);
}
