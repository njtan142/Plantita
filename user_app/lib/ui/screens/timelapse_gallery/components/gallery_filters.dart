import 'package:flutter/material.dart';

class GalleryFilters extends StatelessWidget {
  final String selectedPlantType;
  final String selectedDuration;
  final List<String> plantTypes;
  final List<String> durations;
  final Function(String?) onPlantTypeChanged;
  final Function(String?) onDurationChanged;
  final int selectedCount;
  final VoidCallback onCompare;

  const GalleryFilters({
    super.key,
    required this.selectedPlantType,
    required this.selectedDuration,
    required this.plantTypes,
    required this.durations,
    required this.onPlantTypeChanged,
    required this.onDurationChanged,
    required this.selectedCount,
    required this.onCompare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String>(
          value: selectedPlantType,
          onChanged: onPlantTypeChanged,
          items: plantTypes.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: selectedDuration,
          onChanged: onDurationChanged,
          items: durations.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(width: 10),
        if (selectedCount == 2)
          IconButton(
            icon: const Icon(Icons.compare),
            onPressed: onCompare,
            tooltip: 'Compare Selected',
          ),
        const SizedBox(width: 10),
      ],
    );
  }
}
