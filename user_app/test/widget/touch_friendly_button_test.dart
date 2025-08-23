
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/ui/widgets/touch_friendly_button.dart';

void main() {
  group('TouchFriendlyButton', () {
    testWidgets('button calls onPressed when tapped', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TouchFriendlyButton(
              onPressed: () {
                tapped = true;
              },
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      expect(tapped, true);
    });

    testWidgets('button displays its child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TouchFriendlyButton(
              onPressed: () {},
              child: Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('button has a minimum height of 48.0', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TouchFriendlyButton(
              onPressed: () {},
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(ElevatedButton));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });
  });
}
