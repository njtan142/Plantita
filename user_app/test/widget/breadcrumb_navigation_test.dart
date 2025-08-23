
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/ui/widgets/breadcrumb_navigation.dart';

void main() {
  group('BreadcrumbNavigation', () {
    testWidgets('displays all items correctly', (WidgetTester tester) async {
      const items = ['Home', 'Category', 'Product'];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BreadcrumbNavigation(items: items),
        ),
      ));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Product'), findsOneWidget);
    });

    testWidgets('calls onItemTapped with correct index when item is tapped', (WidgetTester tester) async {
      const items = ['Home', 'Category', 'Product'];
      int? tappedIndex;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BreadcrumbNavigation(
            items: items,
            onItemTapped: (index) {
              tappedIndex = index;
            },
          ),
        ),
      ));

      await tester.tap(find.text('Category'));
      expect(tappedIndex, 1);
    });

    testWidgets('last item is not underlined and is black', (WidgetTester tester) async {
      const items = ['Home', 'Category', 'Product'];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BreadcrumbNavigation(items: items),
        ),
      ));

      final productText = tester.widget<Text>(find.text('Product'));
      expect(productText.style?.decoration, TextDecoration.none);
      expect(productText.style?.color, Colors.black);
    });

    testWidgets('non-last items are underlined and blue', (WidgetTester tester) async {
      const items = ['Home', 'Category', 'Product'];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BreadcrumbNavigation(items: items),
        ),
      ));

      final homeText = tester.widget<Text>(find.text('Home'));
      expect(homeText.style?.decoration, TextDecoration.underline);
      expect(homeText.style?.color, Colors.blue);

      final categoryText = tester.widget<Text>(find.text('Category'));
      expect(categoryText.style?.decoration, TextDecoration.underline);
      expect(categoryText.style?.color, Colors.blue);
    });
  });
}
