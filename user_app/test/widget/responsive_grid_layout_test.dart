
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/ui/widgets/responsive_grid_layout.dart';

void main() {
  group('ResponsiveGridLayout', () {
    testWidgets('displays children in a grid', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ResponsiveGridLayout(
            children: List.generate(6, (index) => Text('Item $index')),
          ),
        ),
      ));

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 5'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('uses correct crossAxisCount', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ResponsiveGridLayout(
            crossAxisCount: 3,
            children: List.generate(6, (index) => Text('Item $index')),
          ),
        ),
      ));

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final SliverGridDelegateWithFixedCrossAxisCount delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 3);
    });

    testWidgets('uses correct childAspectRatio', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ResponsiveGridLayout(
            childAspectRatio: 0.5,
            children: List.generate(2, (index) => Text('Item $index')),
          ),
        ),
      ));

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final SliverGridDelegateWithFixedCrossAxisCount delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.childAspectRatio, 0.5);
    });
  });
}
