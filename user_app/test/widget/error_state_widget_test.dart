
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/ui/widgets/error_state_widget.dart';

void main() {
  group('ErrorStateWidget', () {
    testWidgets('displays message and error icon', (WidgetTester tester) async {
      const testMessage = 'Test Error Message';
      await tester.pumpWidget(const MaterialApp(
        home: ErrorStateWidget(message: testMessage),
      ));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('displays retry button when onRetry is provided', (WidgetTester tester) async {
      bool retryTapped = false;
      await tester.pumpWidget(MaterialApp(
        home: ErrorStateWidget(
          message: 'Error',
          onRetry: () {
            retryTapped = true;
          },
        ),
      ));

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retryTapped, true);
    });

    testWidgets('does not display retry button when onRetry is null', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ErrorStateWidget(message: 'Error'),
      ));

      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.text('Retry'), findsNothing);
    });
  });
}
