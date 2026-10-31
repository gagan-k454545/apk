import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum CoinSide { heads, tails, noResult }

class CoinTossEntry {
  CoinTossEntry({
    String? id,
    required this.isHeads,
    CoinSide? outcome,
    DateTime? tossedAt,
  })  : id = id ?? _uuid.v4(),
        outcome = outcome ?? (isHeads ? CoinSide.heads : CoinSide.tails),
        tossedAt = tossedAt ?? DateTime.now();

  final String id;
  final bool isHeads;
  final CoinSide outcome;
  final DateTime tossedAt;

  CoinSide get side => outcome;
  bool get isTails => outcome == CoinSide.tails;
  bool get isNoResult => outcome == CoinSide.noResult;

  String get resultText {
    switch (outcome) {
      case CoinSide.heads:
        return 'Heads';
      case CoinSide.tails:
        return 'Tails';
      case CoinSide.noResult:
        return 'No Result';
    }
  }

  String get emoji {
    switch (outcome) {
      case CoinSide.heads:
        return '👑';
      case CoinSide.tails:
        return '⭐';
      case CoinSide.noResult:
        return '🪙';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isHeads': isHeads,
      'outcome': outcome.name,
      'tossedAt': tossedAt.toIso8601String(),
    };
  }

  factory CoinTossEntry.fromMap(Map<String, dynamic> map) {
    final outcomeName = map['outcome'] as String?;
    final isHeads = map['isHeads'] as bool? ?? true;
    CoinSide outcome;
    if (outcomeName != null) {
      outcome = CoinSide.values.firstWhere(
        (e) => e.name == outcomeName,
        orElse: () => isHeads ? CoinSide.heads : CoinSide.tails,
      );
    } else {
      outcome = isHeads ? CoinSide.heads : CoinSide.tails;
    }

    return CoinTossEntry(
      id: map['id']?.toString(),
      isHeads: outcome == CoinSide.heads,
      outcome: outcome,
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
