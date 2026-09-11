import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class NameEntry {
  NameEntry({
    String? id,
    required this.name,
    this.isFavorite = false,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final bool isFavorite;
  final DateTime createdAt;

  NameEntry copyWith({
    String? name,
    bool? isFavorite,
  }) {
    return NameEntry(
      id: id,
      name: name ?? this.name,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NameEntry.fromMap(Map<String, dynamic> map) {
    return NameEntry(
      id: map['id']?.toString(),
      name: map['name']?.toString() ?? '',
      isFavorite: map['isFavorite'] == true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NameEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
