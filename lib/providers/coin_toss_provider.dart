import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/shuffle/shuffle_engine.dart';
import '../models/models.dart';
import '../database/app_repository.dart';
import 'repository_provider.dart';
import 'settings_provider.dart';

class CoinTossNotifier extends StateNotifier<List<CoinTossEntry>> {
  CoinTossNotifier(this._repository, this._ref)
      : super(_repository.getCoinTossHistory());

  final AppRepository _repository;
  final Ref _ref;

  int get totalTosses => state.length;
  int get headsCount => state.where((e) => e.isHeads).length;
  int get tailsCount => state.where((e) => !e.isHeads).length;

  double get headsPercentage =>
      totalTosses > 0 ? (headsCount / totalTosses) * 100 : 0.0;

  double get tailsPercentage =>
      totalTosses > 0 ? (tailsCount / totalTosses) * 100 : 0.0;

  List<CoinTossEntry> get todaysTosses {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return state.where((e) {
      final date = DateTime(e.tossedAt.year, e.tossedAt.month, e.tossedAt.day);
      return date == today;
    }).toList();
  }

  /// Performs a true 50/50 random toss, persists it, and updates total toss counter.
  Future<CoinTossEntry> tossCoin() async {
    // Requirement 4: True Random Coin Result
    // Every toss: Heads = 50%, Tails = 50% via CSPRNG rejection sampling
    final bool isHeads = randomInt(2) == 0;
    final entry = CoinTossEntry(isHeads: isHeads);

    await _repository.saveCoinTossEntry(entry);
    _ref.read(settingsProvider.notifier).incrementCoinTosses();

    state = [entry, ...state];
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
