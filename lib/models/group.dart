import 'package:uuid/uuid.dart';
import 'name_entry.dart';

const _uuid = Uuid();

class Group {
  Group({
    String? id,
    required this.name,
    List<NameEntry>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        members = members ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String name;
  final List<NameEntry> members;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get memberCount => members.length;

  List<NameEntry> get favorites =>
      members.where((m) => m.isFavorite).toList();

  Group copyWith({
    String? name,
    List<NameEntry>? members,
  }) {
    return Group(
      id: id,
      name: name ?? this.name,
      members: members ?? this.members,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'members': members.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] as String?,
      name: map['name'] as String,
      members: (map['members'] as List<dynamic>?)
              ?.map((m) => NameEntry.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
