import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_repository.dart';

final repositoryProvider = Provider<AppRepository>((ref) {
  return AppRepository.instance;
});
