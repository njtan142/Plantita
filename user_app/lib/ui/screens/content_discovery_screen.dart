
import 'package:flutter/material.dart';
import 'package:user_app/ui/widgets/app_bar_with_search.dart';
import 'package:user_app/ui/widgets/responsive_grid_layout.dart';

class ContentDiscoveryScreen extends StatelessWidget {
  const ContentDiscoveryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWithSearch(title: 'Discover Content'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Trending')),
                ElevatedButton(onPressed: () {}, child: const Text('Categories')),
                ElevatedButton(onPressed: () {}, child: const Text('Recommended')),
              ],
            ),
          ),
          Expanded(
            child: ResponsiveGridLayout(
              children: List.generate(30, (index) {
                return Card(
                  child: Center(
                    child: Text('Content Item ${index + 1}'),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
