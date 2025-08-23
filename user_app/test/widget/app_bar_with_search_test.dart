
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/ui/widgets/app_bar_with_search.dart';

void main() {
  group('AppBarWithSearch', () {
    testWidgets('displays title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          appBar: AppBarWithSearch(title: 'Test Title'),
        ),
      ));

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('displays search icon', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          appBar: AppBarWithSearch(title: 'Test Title'),
        ),
      ));

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('tapping search icon opens search delegate', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          appBar: AppBarWithSearch(title: 'Test Title'),
        ),
      ));

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget); // Search bar should appear
      expect(find.text('Search results for:'), findsNothing); // Initial state
    });
  });
}
