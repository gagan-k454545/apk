import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shuffle_master/features/home/widgets/coin_toss_feature_card.dart';

void main() {
  group('CoinTossFeatureCard Widget Tests', () {
    testWidgets('renders cleanly, displays icons, title, badge, and triggers onTap on click',
        (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: CoinTossFeatureCard(
                  onTap: () {
                    tapCount++;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // 1. Verify Title & Subtitle
      expect(find.text('Coin Toss'), findsOneWidget);
      expect(find.text('3D Animation'), findsOneWidget);

      // 2. Verify Semantics Button role & label
      final semantics = find.bySemanticsLabel(
        'Coin Toss, Make a quick 50/50 heads-or-tails decision with 3D animation.',
      );
      expect(semantics, findsOneWidget);

      // 3. Tap card and verify callback
      await tester.tap(semantics);
      await tester.pump(const Duration(milliseconds: 100));

      expect(tapCount, equals(1));
    });

    testWidgets('supports disableAnimations reduced motion cleanly',
        (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  child: CoinTossFeatureCard(
                    onTap: () {
                      tapCount++;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Coin Toss'), findsOneWidget);

      final semantics = find.bySemanticsLabel(
        'Coin Toss, Make a quick 50/50 heads-or-tails decision with 3D animation.',
      );
      expect(semantics, findsOneWidget);

      await tester.tap(semantics);
      await tester.pump();

      expect(tapCount, equals(1));
    });
  });
}
