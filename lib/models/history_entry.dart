import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class HistoryEntry {
  HistoryEntry({
    String? id,
    required this.groupId,
    required this.groupName,
    required this.result,
    DateTime? shuffledAt,
  })  : id = id ?? _uuid.v4(),
        shuffledAt = shuffledAt ?? DateTime.now();

  final String id;
  final String groupId;
  final String groupName;
  final List<String> result;
  final DateTime shuffledAt;

  int get count => result.length;

  String get firstPlace => result.isNotEmpty ? result.first : '';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'groupName': groupName,
      'result': result,
      'shuffledAt': shuffledAt.toIso8601String(),
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id']?.toString(),
      groupId: map['groupId']?.toString() ?? '',
      groupName: map['groupName']?.toString() ?? '',
      result: (map['result'] as List<dynamic>?)
              ?.map((r) => r.toString())
              .toList() ??
          [],
      shuffledAt: map['shuffledAt'] != null
          ? DateTime.tryParse(map['shuffledAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
