import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/shuffle/coin_toss_engine.dart';
import '../database/app_repository.dart';
import '../models/models.dart';
import 'repository_provider.dart';
import 'settings_provider.dart';

class CoinTossNotifier extends StateNotifier<List<CoinTossEntry>> {
  CoinTossNotifier(this._repository, this._ref)
      : super(_repository.getCoinTossHistory());

  final AppRepository _repository;
  final Ref _ref;

  int get totalTosses => state.length;
  int get headsCount =>
      state.where((e) => e.outcome == CoinSide.heads).length;
  int get tailsCount =>
      state.where((e) => e.outcome == CoinSide.tails).length;
  int get noResultCount =>
      state.where((e) => e.outcome == CoinSide.noResult).length;

  double get headsPercentage =>
      totalTosses > 0 ? (headsCount / totalTosses) * 100 : 0.0;

  double get tailsPercentage =>
      totalTosses > 0 ? (tailsCount / totalTosses) * 100 : 0.0;

  double get noResultPercentage =>
      totalTosses > 0 ? (noResultCount / totalTosses) * 100 : 0.0;

  List<CoinTossEntry> get todaysTosses {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return state.where((e) {
      final date = DateTime(e.tossedAt.year, e.tossedAt.month, e.tossedAt.day);
      return date == today;
    }).toList();
  }

  /// Appends a decided toss entry after the landing animation finishes.
  /// Prevents duplicates if already recorded.
  Future<void> saveTossResult(CoinTossEntry entry) async {
    if (state.any((e) => e.id == entry.id)) return;

    await _repository.saveCoinTossEntry(entry);
    _ref.read(settingsProvider.notifier).incrementCoinTosses();

    state = [entry, ...state];
  }

  /// Performs a true random toss, persists it, and updates total toss counter.
  Future<CoinTossEntry> tossCoin() async {
    final CoinFace face = CoinTossEngine.tossCoin();
    CoinSide side;
    switch (face) {
      case CoinFace.heads:
        side = CoinSide.heads;
        break;
      case CoinFace.tails:
        side = CoinSide.tails;
        break;
      case CoinFace.noResult:
        side = CoinSide.noResult;
        break;
    }

    final entry = CoinTossEntry(
      isHeads: side == CoinSide.heads,
      outcome: side,
    );

    await saveTossResult(entry);
    return entry;
  }

  Future<void> deleteEntry(String id) async {
    await _repository.deleteCoinTossEntry(id);
    state = state.where((e) => e.id != id).toList();
  }

  Future<void> clearHistory() async {
    await _repository.clearCoinTossHistory();
    state = [];
  }
}

final coinTossProvider =
    StateNotifierProvider<CoinTossNotifier, List<CoinTossEntry>>((ref) {
  return CoinTossNotifier(ref.read(repositoryProvider), ref);
});
