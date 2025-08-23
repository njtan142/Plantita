
import 'package:flutter/material.dart';

class BreadcrumbNavigation extends StatelessWidget {
  final List<String> items;
  final ValueChanged<int>? onItemTapped;

  const BreadcrumbNavigation({
    Key? key,
    required this.items,
    this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        children: List.generate(items.length, (index) {
          return GestureDetector(
            onTap: onItemTapped != null ? () => onItemTapped!(index) : null,
            child: Text(
              items[index],
              style: TextStyle(
                fontSize: 14,
                color: index == items.length - 1 ? Colors.black : Colors.blue,
                decoration: index == items.length - 1 ? TextDecoration.none : TextDecoration.underline,
              ),
            ),
          );
        }),
      ),
    );
  }
}
