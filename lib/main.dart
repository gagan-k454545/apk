import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'database/app_repository.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FlutterError.presentError(
      FlutterErrorDetails(exception: error, stack: stack),
    );
    return true;
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  try {
    await AppRepository.instance.init();
  } catch (e, stack) {
    debugPrint('Database initialization error: $e\n$stack');
  }

  runApp(
    const ProviderScope(
      child: ShuffleMasterApp(),
    ),
  );
}

class ShuffleMasterApp extends ConsumerWidget {
  const ShuffleMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settingsNotifier = ref.watch(settingsProvider.notifier);

    return MaterialApp.router(
      title: 'Shuffle Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: settingsNotifier.flutterThemeMode,
      routerConfig: router,
    );
  }
}
