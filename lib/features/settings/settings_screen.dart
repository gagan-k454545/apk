import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../database/app_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final groups = ref.watch(groupsProvider);
    final history = ref.watch(historyProvider);
    final coinTosses = ref.watch(coinTossProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Settings'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Customize your experience',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ).animate().fadeIn(delay: 100.ms),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Card(
                child: Column(
                  children: [
                    _buildThemeTile(context, ref, settings),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: Icon(
                        Icons.volume_up_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Sound Effects'),
                      subtitle: const Text('Subtle sound on shuffle & flip'),
                      value: settings.soundEnabled,
                      onChanged: (val) {
                        ref
                            .read(settingsProvider.notifier)
                            .setSoundEnabled(val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: Icon(
                        Icons.vibration_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Haptic Feedback'),
                      subtitle: const Text('Vibrate during interactions'),
                      value: settings.hapticEnabled,
                      onChanged: (val) {
                        ref
                            .read(settingsProvider.notifier)
                            .setHapticEnabled(val);
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Data & Backup',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.file_download_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Export Data'),
                      subtitle: Text(
                        '${groups.length} groups, ${history.length} shuffles, ${coinTosses.length} coin tosses',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _exportData(context, ref),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.file_upload_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Import Data'),
                      subtitle: const Text('Restore from a backup'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _importData(context, ref),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.delete_sweep_outlined,
                        color: theme.colorScheme.error,
                      ),
                      title: Text(
                        'Clear All Data',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      subtitle: const Text('Remove everything'),
                      onTap: () => _confirmClearAll(context, ref),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'About',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Shuffle Master'),
                      subtitle: const Text('Version 2.0.0 Premium Edition'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.code_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Built with Flutter'),
                      subtitle: const Text('Material 3 · Riverpod · Hive'),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  Widget _buildThemeTile(
      BuildContext context, WidgetRef ref, AppSettings settings) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        Icons.palette_outlined,
        color: theme.colorScheme.primary,
      ),
      title: const Text('Theme'),
      subtitle: Text(_themeModeLabel(settings.themeMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context, ref, settings),
    );
  }

  String _themeModeLabel(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.system:
        return 'System Default';
      case ThemeModeOption.light:
        return 'Light';
      case ThemeModeOption.dark:
        return 'Dark';
    }
  }

  void _showThemeDialog(
      BuildContext context, WidgetRef ref, AppSettings settings) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          title: const Text('Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeModeOption.values.map((mode) {
              final isSelected = settings.themeMode == mode;
              return ListTile(
                title: Text(_themeModeLabel(mode)),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                      )
                    : Icon(
                        Icons.circle_outlined,
                        color: theme.colorScheme.outline,
                      ),
                onTap: () {
                  ref.read(settingsProvider.notifier).setThemeMode(mode);
                  Navigator.of(dialogContext).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _exportData(BuildContext context, WidgetRef ref) async {
    final data = AppRepository.instance.exportData();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    await Share.share(
      json,
      subject: 'Shuffle Master Backup',
    );
  }

  void _importData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'To import data, paste your backup JSON in the next dialog. This will replace all current data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showImportDialog(context, ref);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paste Backup'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Paste JSON data here...',
              alignLabelWithHint: true,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final data = jsonDecode(controller.text) as Map<String, dynamic>;
                await AppRepository.instance.importData(data);
                ref.invalidate(groupsProvider);
                ref.invalidate(historyProvider);
                ref.invalidate(coinTossProvider);
                ref.invalidate(settingsProvider);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data imported successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Import failed: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all groups, names, shuffle history, coin toss history, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await AppRepository.instance.clearAll();
              ref.invalidate(groupsProvider);
              ref.invalidate(historyProvider);
              ref.invalidate(coinTossProvider);
              ref.invalidate(settingsProvider);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }
}
