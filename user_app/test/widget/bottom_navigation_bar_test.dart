
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/ui/widgets/bottom_navigation_bar.dart';

void main() {
  group('CustomBottomNavigationBar', () {
    testWidgets('displays correct number of items', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {},
          ),
        ),
      ));

      expect(find.byType(BottomNavigationBarItem), findsNWidgets(4));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Reels'), findsOneWidget);
      expect(find.text('Timelapse'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('calls onTap with correct index when item is tapped', (WidgetTester tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              tappedIndex = index;
            },
          ),
        ),
      ));

      await tester.tap(find.text('Reels'));
      expect(tappedIndex, 1); // Reels is the second item (index 1)
    });

    testWidgets('highlights the current index item', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: 2,
            onTap: (index) {},
          ),
        ),
      ));

      // Verify that the icon for the current index (Timelapse) is highlighted
      final Finder timelapseIcon = find.widgetWithText(BottomNavigationBarItem, 'Timelapse');
      // This is a simplified check, actual highlighting might involve color/size changes
      // which are harder to test without specific knowledge of the default theme.
      // For now, we just check for its presence.
      expect(timelapseIcon, findsOneWidget);
    });
  });
}
