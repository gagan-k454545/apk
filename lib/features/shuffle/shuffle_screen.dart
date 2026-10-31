import 'package:flutter/material.dart';
import 'premium_shuffle_result_screen.dart';

/// Entry widget for the Shuffle Screen route `/shuffle/:groupId`.
/// Delegates directly to the modular [PremiumShuffleResultScreen].
class ShuffleScreen extends StatelessWidget {
  const ShuffleScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return PremiumShuffleResultScreen(groupId: groupId);
  }
}
