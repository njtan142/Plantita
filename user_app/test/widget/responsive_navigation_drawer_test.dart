
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/ui/widgets/responsive_navigation_drawer.dart';

void main() {
  group('ResponsiveNavigationDrawer', () {
    testWidgets('drawer displays menu items', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          drawer: ResponsiveNavigationDrawer(),
        ),
      ));

      // Open the drawer
      await tester.drag(find.byType(Scaffold), const Offset(300.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.text('Menu'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Reels'), findsOneWidget);
      expect(find.text('Timelapse'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('drawer has a DrawerHeader', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          drawer: ResponsiveNavigationDrawer(),
        ),
      ));

      // Open the drawer
      await tester.drag(find.byType(Scaffold), const Offset(300.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.byType(DrawerHeader), findsOneWidget);
    });
  });
}
