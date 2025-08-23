
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/ui/widgets/responsive_list_layout.dart';

void main() {
  group('ResponsiveListLayout', () {
    testWidgets('displays children in a list', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ResponsiveListLayout(
            children: List.generate(5, (index) => Text('Item $index')),
          ),
        ),
      ));

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('scrolls when content exceeds viewport', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ResponsiveListLayout(
            children: List.generate(100, (index) => SizedBox(height: 100, child: Text('Item $index'))),
          ),
        ),
      ));

      // Initial state: only first few items are visible
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 99'), findsNothing);

      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();

      // After scrolling, more items should be visible
      expect(find.text('Item 0'), findsNothing);
      expect(find.text('Item 50'), findsOneWidget); // Example, depends on screen size
    });
  });
}
