import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../database/app_repository.dart';
import 'repository_provider.dart';

class HistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  HistoryNotifier(this._repository) : super(_repository.getHistory());

  final AppRepository _repository;

  void _load() {
    state = _repository.getHistory();
  }

  Future<void> addEntry(HistoryEntry entry) async {
    await _repository.saveHistoryEntry(entry);
    _load();
  }

  Future<void> deleteEntry(String id) async {
    await _repository.deleteHistoryEntry(id);
    _load();
  }

  Future<void> clearAll() async {
    await _repository.clearHistory();
    _load();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryEntry>>((ref) {
  return HistoryNotifier(ref.read(repositoryProvider));
});
