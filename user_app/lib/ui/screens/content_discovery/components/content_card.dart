import 'package:flutter/material.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/models/timelapse.dart';

class ContentCard extends StatelessWidget {
  final dynamic item;
  final double width;

  const ContentCard({
    super.key,
    required this.item,
    this.width = 150,
  });

  @override
  Widget build(BuildContext context) {
    String title = '';
    if (item is Reel) {
      title = (item as Reel).title;
    } else if (item is Timelapse) {
      title = (item as Timelapse).title;
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: width,
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
