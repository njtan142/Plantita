
import 'package:flutter/material.dart';
import 'package:user_app/ui/widgets/responsive_grid_layout.dart';

class TimelapseGallery extends StatelessWidget {
  const TimelapseGallery({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timelapse Gallery'),
      ),
      body: ResponsiveGridLayout(
        children: List.generate(20, (index) {
          return Card(
            child: Center(
              child: Text('Timelapse ${index + 1}'),
            ),
          );
        }),
      ),
    );
  }
}
