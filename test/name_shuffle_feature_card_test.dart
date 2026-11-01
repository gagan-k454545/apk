import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shuffle_master/features/home/widgets/name_shuffle_feature_card.dart';

void main() {
  group('NameShuffleFeatureCard Widget Tests', () {
    testWidgets('renders cleanly, displays card graphic, and triggers onTap on click',
        (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: NameShuffleFeatureCard(
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

      // 1. Verify Title & Subtitle Badge
      expect(find.text('Name Shuffle'), findsOneWidget);
      expect(find.text('Fair & Instant'), findsOneWidget);

      // 2. Verify Semantics Button role & label
      final semantics = find.bySemanticsLabel(
        'Name Shuffle, Randomize a list of names using pure Fisher-Yates algorithm.',
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
                  child: NameShuffleFeatureCard(
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

      expect(find.text('Name Shuffle'), findsOneWidget);
      expect(find.text('Fair & Instant'), findsOneWidget);

      final semantics = find.bySemanticsLabel(
        'Name Shuffle, Randomize a list of names using pure Fisher-Yates algorithm.',
      );
      expect(semantics, findsOneWidget);

      await tester.tap(semantics);
      await tester.pump();

      expect(tapCount, equals(1));
    });
  });
}
