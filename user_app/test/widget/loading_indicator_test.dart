
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/ui/widgets/loading_indicator.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('displays CircularProgressIndicator', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoadingIndicator()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('is centered', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoadingIndicator()));

      final centerFinder = find.byType(Center);
      expect(centerFinder, findsOneWidget);

      final centerWidget = tester.widget<Center>(centerFinder);
      expect(centerWidget.child, isA<CircularProgressIndicator>());
    });
  });
}
