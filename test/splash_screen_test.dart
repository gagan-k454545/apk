import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shuffle_master/features/splash/widgets/premium_3d_splash_logo.dart';
import 'package:shuffle_master/features/splash/splash_screen.dart';

void main() {
  testWidgets('Premium3dSplashAnimation mounts and animates smoothly',
      (WidgetTester tester) async {
    bool cycleCompleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Premium3dSplashAnimation(
            loopDuration: const Duration(milliseconds: 1000),
            fadeInDuration: const Duration(milliseconds: 200),
            onCycleComplete: () {
              cycleCompleted = true;
            },
          ),
        ),
      ),
    );

    // Initial pump
    expect(find.byType(Premium3dSplashAnimation), findsOneWidget);

    // Advance through the initial fade-in
    await tester.pump(const Duration(milliseconds: 200));

    // Advance to the middle phase (3D float, tilt, shimmer & glints)
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(Premium3dSplashAnimation), findsOneWidget);

    // Advance past one full loop cycle
    await tester.pump(const Duration(milliseconds: 500));
    expect(cycleCompleted, isTrue);

    // Continues into the next seamless cycle
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(Premium3dSplashAnimation), findsOneWidget);
  });

  testWidgets('SplashScreen renders with minimal luxury UI and skips on tap',
      (WidgetTester tester) async {
    bool proceeded = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          autoNavigate: false,
          onProceed: () {
            proceeded = true;
          },
        ),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(Premium3dSplashAnimation), findsOneWidget);

    // Tap skips/initiates exit animation
    await tester.tap(find.byType(SplashScreen));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    expect(proceeded, isTrue);
  });
}
