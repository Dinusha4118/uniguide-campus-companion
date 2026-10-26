import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_compass/presentation/widgets/brand_logo_widget.dart';
import 'package:campus_compass/presentation/widgets/primary_button.dart';
import 'package:campus_compass/presentation/widgets/circular_gauge_widget.dart';
import 'package:campus_compass/presentation/widgets/status_card.dart';
import 'package:campus_compass/domain/calculations/attendance_calculator.dart';

void main() {
  testWidgets('BrandLogoWidget renders with correct proportions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BrandLogoWidget(size: 80.0),
        ),
      ),
    );

    expect(find.byType(BrandLogoWidget), findsOneWidget);
  });

  testWidgets('PrimaryButton displays label and responds to taps', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Get Started',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('CircularGaugeWidget renders primary and secondary text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CircularGaugeWidget(
            value: 0.75,
            primaryText: '3.42',
            secondaryText: 'Target 3.30',
          ),
        ),
      ),
    );

    expect(find.text('3.42'), findsOneWidget);
    expect(find.text('Target 3.30'), findsOneWidget);
  });

  testWidgets('StatusCard renders title and safe status badge', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusCard(
            status: AttendanceStatus.safe,
            title: 'Computer Networks · 92%',
            subtitle: '11/12 attended · Safe',
            badgeText: '2 safe skips',
          ),
        ),
      ),
    );

    expect(find.text('Computer Networks · 92%'), findsOneWidget);
    expect(find.text('11/12 attended · Safe'), findsOneWidget);
    expect(find.text('2 safe skips'), findsOneWidget);
  });
}
