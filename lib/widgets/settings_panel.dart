import 'package:akshar_final/models/reading_settings.dart';
import 'package:flutter/material.dart';

class SettingsPanel extends StatelessWidget {
  final ReadingSettings settings;
  final List<Color> backgroundColors;
  final VoidCallback onSettingsChanged;

  const SettingsPanel({
    super.key,
    required this.settings,
    required this.backgroundColors,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 10, spreadRadius: 5),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Font Size', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Slider(
                  value: settings.fontSize,
                  min: 12,
                  max: 32,
                  divisions: 10,
                  label: settings.fontSize.round().toString(),
                  onChanged: (value) {
                    settings.fontSize = value;
                    onSettingsChanged();
                  },
                ),
              ),
              Text(
                '${settings.fontSize.round()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Background Color', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                backgroundColors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      settings.backgroundColor = color;
                      settings.textColor =
                          color == const Color(0xFF2C2C2C)
                              ? Colors.white
                              : const Color(0xFF212121);
                      onSettingsChanged();
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              settings.backgroundColor == color
                                  ? Colors.deepPurple
                                  : Colors.grey[300]!,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
