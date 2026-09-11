import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum CoinSide { heads, tails }

class CoinTossEntry {
  CoinTossEntry({
    String? id,
    required this.isHeads,
    DateTime? tossedAt,
  })  : id = id ?? _uuid.v4(),
        tossedAt = tossedAt ?? DateTime.now();

  final String id;
  final bool isHeads;
  final DateTime tossedAt;

  CoinSide get side => isHeads ? CoinSide.heads : CoinSide.tails;
  String get resultText => isHeads ? 'Heads' : 'Tails';
  String get emoji => '🪙';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isHeads': isHeads,
      'tossedAt': tossedAt.toIso8601String(),
    };
  }

  factory CoinTossEntry.fromMap(Map<String, dynamic> map) {
    return CoinTossEntry(
      id: map['id']?.toString(),
      isHeads: map['isHeads'] as bool? ?? true,
      tossedAt: map['tossedAt'] != null
          ? DateTime.tryParse(map['tossedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinTossEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
