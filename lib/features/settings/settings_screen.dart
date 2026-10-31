import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/premium_design_tokens.dart';
import '../../core/widgets/premium/pressable_scale.dart';
import '../../database/app_repository.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

/// Settings Screen following Apple Human Interface Guidelines:
/// - Inset Grouped TableView architecture
/// - 44x44 pt touch targets for all interactive rows
/// - Colored icon squircles matching iOS Settings conventions
/// - Indented hairline separators
/// - iOS Cupertino switches with responsive tactile feedback
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final groups = ref.watch(groupsProvider);
    final history = ref.watch(historyProvider);
    final coinTosses = ref.watch(coinTossProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: PremiumDesignTokens.bgApp,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // iOS Large Title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: PremiumDesignTokens.textStrong,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Preferences, algorithm engine, and backups',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: PremiumDesignTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SECTION 1: PREFERENCES
            _buildSectionHeader('PREFERENCES'),
            SliverToBoxAdapter(
              child: _IOSInsetGroup(
                children: [
                  _IOSSettingsRow(
                    icon: Icons.palette_rounded,
                    iconBg: const Color(0xFFFF9500), // iOS Orange
                    title: 'Appearance',
                    subtitle: _themeModeLabel(settings.themeMode),
                    showChevron: true,
                    onTap: () => _showThemeSheet(context, ref, settings),
                  ),
                  _IOSSettingsRow(
                    icon: Icons.volume_up_rounded,
                    iconBg: const Color(0xFF007AFF), // iOS Blue
                    title: 'Sound Effects',
                    subtitle: 'Audio clicks on shuffle & toss',
                    trailing: CupertinoSwitch(
                      value: settings.soundEnabled,
                      activeTrackColor: PremiumDesignTokens.forestDark,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        ref
                            .read(settingsProvider.notifier)
                            .setSoundEnabled(val);
                      },
                    ),
                  ),
                  _IOSSettingsRow(
                    icon: Icons.vibration_rounded,
                    iconBg: const Color(0xFF5856D6), // iOS Purple
                    title: 'Haptic Feedback',
                    subtitle: 'Tactile physical taps on press',
                    trailing: CupertinoSwitch(
                      value: settings.hapticEnabled,
                      activeTrackColor: PremiumDesignTokens.forestDark,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        ref
                            .read(settingsProvider.notifier)
                            .setHapticEnabled(val);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // SECTION 2: SHUFFLE ENGINE & MEMORY
            _buildSectionHeader('ALGORITHM ENGINE'),
            SliverToBoxAdapter(
              child: _IOSInsetGroup(
                children: [
                  _IOSSettingsRow(
                    icon: Icons.verified_user_rounded,
                    iconBg: const Color(0xFF34C759), // iOS Green
                    title: 'Unbiased CSPRNG',
                    subtitle: 'Fisher-Yates Durstenfeld with rejection sampling',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2EEDC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0x1F1B4332),
                          width: 0.5,
                        ),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: PremiumDesignTokens.forestDark,
                        ),
                      ),
                    ),
                  ),
                  _IOSSettingsRow(
                    icon: Icons.refresh_rounded,
                    iconBg: const Color(0xFFFF9500), // iOS Orange
                    title: 'Reset Shuffle Memory',
                    subtitle: 'Clears recent anti-repeat history',
                    showChevron: true,
                    onTap: () => _confirmResetShuffleMemory(context),
                  ),
                ],
              ),
            ),

            // SECTION 3: DATA & BACKUP
            _buildSectionHeader('DATA MANAGEMENT'),
            SliverToBoxAdapter(
              child: _IOSInsetGroup(
                children: [
                  _IOSSettingsRow(
                    icon: Icons.share_rounded,
                    iconBg: const Color(0xFF30B0C7), // iOS Teal
                    title: 'Export Backup',
                    subtitle:
                        '${groups.length} groups · ${history.length} shuffles · ${coinTosses.length} tosses',
                    showChevron: true,
                    onTap: () => _exportData(context, ref),
                  ),
                  _IOSSettingsRow(
                    icon: Icons.download_rounded,
                    iconBg: const Color(0xFF5856D6), // iOS Indigo
                    title: 'Import Backup',
                    subtitle: 'Restore from a JSON file',
                    showChevron: true,
                    onTap: () => _importData(context, ref),
                  ),
                  _IOSSettingsRow(
                    icon: Icons.delete_forever_rounded,
                    iconBg: const Color(0xFFFF3B30), // iOS Red
                    title: 'Clear All Data',
                    subtitle: 'Permanently erase all local storage',
                    isDestructive: true,
                    showChevron: true,
                    onTap: () => _confirmClearAll(context, ref),
                  ),
                ],
              ),
            ),

            // SECTION 4: ABOUT
            _buildSectionHeader('ABOUT'),
            const SliverToBoxAdapter(
              child: _IOSInsetGroup(
                children: [
                  _IOSSettingsRow(
                    icon: Icons.shuffle_rounded,
                    iconBg: PremiumDesignTokens.forestDark,
                    title: 'Shuffle Master',
                    subtitle: 'Version 2.0.0 · Apple HIG Edition',
                  ),
                  _IOSSettingsRow(
                    icon: Icons.code_rounded,
                    iconBg: Color(0xFF8E8E93),
                    title: 'Architecture',
                    subtitle: 'Offline-first · Flutter · Hive · Riverpod',
                  ),
                ],
              ),
            ),

            // Safe bottom margin
            SliverPadding(
              padding: EdgeInsets.only(bottom: 110 + bottomInset),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 20, 6),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: PremiumDesignTokens.textMuted,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.system:
        return 'System Default';
      case ThemeModeOption.light:
        return 'Light (Warm Sand)';
      case ThemeModeOption.dark:
        return 'Dark Mode';
    }
  }

  void _showThemeSheet(
      BuildContext context, WidgetRef ref, AppSettings settings) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: PremiumDesignTokens.cardShadow,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Select Theme',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: PremiumDesignTokens.textStrong,
                ),
              ),
            ),
            const Divider(height: 1),
            ...ThemeModeOption.values.map((mode) {
              final isSelected = settings.themeMode == mode;
              return ListTile(
                title: Text(
                  _themeModeLabel(mode),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? PremiumDesignTokens.forestDark
                        : PremiumDesignTokens.textStrong,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: PremiumDesignTokens.forestDark,
                      )
                    : null,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(settingsProvider.notifier).setThemeMode(mode);
                  Navigator.pop(sheetContext);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _confirmResetShuffleMemory(BuildContext context) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: PremiumDesignTokens.cardShadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Reset Shuffle Memory?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesignTokens.textStrong,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This clears the previous 5 order history and shuffle bag state. Subsequent shuffles will start fresh.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: PremiumDesignTokens.textMuted,
                    ),
                  ),
                  const Divider(height: 24),
                  PressableScale(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      resetShuffleMemory();
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Shuffle memory reset'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      child: const Text(
                        'Reset Memory',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF9500),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            PressableScale(
              onTap: () => Navigator.pop(sheetContext),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: PremiumDesignTokens.cardShadow,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PremiumDesignTokens.forestDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportData(BuildContext context, WidgetRef ref) async {
    await HapticFeedback.selectionClick();
    final data = AppRepository.instance.exportData();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    await Share.share(
      json,
      subject: 'Shuffle Master Backup',
    );
  }

  void _importData(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 12,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x261B4332),
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(sheetContext),
                  child: const SizedBox(
                    width: 60,
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color: PremiumDesignTokens.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Import Backup',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: PremiumDesignTokens.textStrong,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      final data =
                          jsonDecode(controller.text) as Map<String, dynamic>;
                      await AppRepository.instance.importData(data);
                      ref.invalidate(groupsProvider);
                      ref.invalidate(historyProvider);
                      ref.invalidate(coinTossProvider);
                      ref.invalidate(settingsProvider);
                      if (context.mounted) {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Backup restored successfully'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invalid JSON: $e'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFFE53935),
                          ),
                        );
                      }
                    }
                  },
                  child: const SizedBox(
                    width: 60,
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Restore',
                        style: TextStyle(
                          fontSize: 16,
                          color: PremiumDesignTokens.forestDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF1E8DA).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PremiumDesignTokens.innerBorder),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: controller,
                autofocus: true,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  color: PremiumDesignTokens.textStrong,
                ),
                decoration: const InputDecoration(
                  hintText: 'Paste exported JSON here...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: PremiumDesignTokens.cardShadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Clear All Data?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesignTokens.textStrong,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This permanently removes all groups, names, history, coin tosses, and settings. This cannot be undone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: PremiumDesignTokens.textMuted,
                    ),
                  ),
                  const Divider(height: 24),
                  PressableScale(
                    onTap: () async {
                      await AppRepository.instance.clearAll();
                      resetShuffleMemory();
                      ref.invalidate(groupsProvider);
                      ref.invalidate(historyProvider);
                      ref.invalidate(coinTossProvider);
                      ref.invalidate(settingsProvider);
                      if (context.mounted) {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All data cleared'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      child: const Text(
                        'Clear Everything',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF3B30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            PressableScale(
              onTap: () => Navigator.pop(sheetContext),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: PremiumDesignTokens.cardShadow,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PremiumDesignTokens.forestDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An iOS Inset Grouped Container.
class _IOSInsetGroup extends StatelessWidget {
  const _IOSInsetGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: PremiumDesignTokens.cardBorder,
          ),
          boxShadow: PremiumDesignTokens.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// An individual row in an iOS Inset Group.
class _IOSSettingsRow extends StatelessWidget {
  const _IOSSettingsRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showChevron = false,
    this.isDestructive = false,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final bool isDestructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      targetScale: onTap != null ? 0.98 : 1.0,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.transparent,
        child: Row(
          children: [
            // iOS Colored Squircle Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? const Color(0xFFFF3B30)
                          : PremiumDesignTokens.textStrong,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: PremiumDesignTokens.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing element
            if (trailing != null) trailing!,
            if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: PremiumDesignTokens.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
