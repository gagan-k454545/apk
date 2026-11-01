import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shuffle_master/features/home/widgets/hero_decision_card.dart';

void main() {
  testWidgets(
      'HeroDecisionCard renders banner, basket, sparkles with zero dummy names and triggers onGetStarted',
      (WidgetTester tester) async {
    int tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: HeroDecisionCard(
                onGetStarted: () {
                  tapCount++;
                },
              ),
            ),
          ),
        ),
      ),
    );

    // Initial pump for repeating animation
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Images are present (background and 3D basket)
    expect(find.byType(Image), findsWidgets);

    // Verify ZERO dummy names are present
    expect(find.text('Gagan'), findsNothing);
    expect(find.text('Bala'), findsNothing);
    expect(find.text('Anshu'), findsNothing);
    expect(find.text('Rakshan'), findsNothing);
    expect(find.text('vinayaka'), findsNothing);

    // Verify Semantics for Get Started button is present
    expect(find.bySemanticsLabel('Get Started'), findsOneWidget);

    // Tap the Get Started button
    await tester.tap(find.bySemanticsLabel('Get Started'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tapCount, equals(1));
  });

  testWidgets('HeroDecisionCard triggers onGetStarted from card tap',
      (WidgetTester tester) async {
    int tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: HeroDecisionCard(
                onGetStarted: () {
                  tapCount++;
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    // Tap the top left of the card
    await tester.tapAt(
      tester.getTopLeft(find.byType(HeroDecisionCard)) + const Offset(30, 30),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(tapCount, equals(1));
  });
}
