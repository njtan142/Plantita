import 'package:flutter/material.dart';
import 'content_card.dart';

class HorizontalContentList extends StatelessWidget {
  final String title;
  final List<dynamic> items;

  const HorizontalContentList({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120, // Reduced height since cards are simpler now
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ContentCard(item: items[index]);
            },
          ),
        ),
      ],
    );
  }
}
