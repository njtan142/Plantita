
import 'package:flutter/material.dart';

class ResponsiveListLayout extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveListLayout({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }
}
