import 'package:flutter/material.dart';
import 'package:akshar_final/models/reading_settings.dart';

enum ReaderFont { sans, serif, mono }

class SettingsPanel extends StatelessWidget {
  final ReadingSettings settings;
  final VoidCallback onChanged;

  const SettingsPanel({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),

          // FONT SIZE
          Row(
            children: [
              const Text("Font Size", style: TextStyle(color: Colors.white)),
              Expanded(
                child: Slider(
                  value: settings.fontSize,
                  min: 14,
                  max: 32,
                  onChanged: (v) {
                    settings.fontSize = v;
                    onChanged();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // LINE HEIGHT
          Row(
            children: [
              const Text("Line Height", style: TextStyle(color: Colors.white)),
              Expanded(
                child: Slider(
                  value: settings.lineHeight,
                  min: 1.0,
                  max: 2.5,
                  onChanged: (v) {
                    settings.lineHeight = v;
                    onChanged();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // FONT FAMILY
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Font Style", style: TextStyle(color: Colors.white)),
          ),
          DropdownButton<ReaderFont>(
            value: _mapEnum(settings.fontFamily),
            dropdownColor: const Color(0xFF2A2A2A),
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(
                value: ReaderFont.sans,
                child: Text("Sans Serif"),
              ),
              DropdownMenuItem(value: ReaderFont.serif, child: Text("Serif")),
              DropdownMenuItem(
                value: ReaderFont.mono,
                child: Text("Monospace"),
              ),
            ],
            onChanged: (val) {
              settings.fontFamily = _mapString(val!);
              onChanged();
            },
          ),

          const SizedBox(height: 20),

          // TEXT ALIGNMENT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.format_align_left, color: Colors.white),
                onPressed: () {
                  settings.textAlign = TextAlign.left;
                  onChanged();
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.format_align_center,
                  color: Colors.white,
                ),
                onPressed: () {
                  settings.textAlign = TextAlign.center;
                  onChanged();
                },
              ),
              IconButton(
                icon: const Icon(Icons.format_align_right, color: Colors.white),
                onPressed: () {
                  settings.textAlign = TextAlign.right;
                  onChanged();
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.format_align_justify,
                  color: Colors.white,
                ),
                onPressed: () {
                  settings.textAlign = TextAlign.justify;
                  onChanged();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  ReaderFont _mapEnum(String fam) {
    switch (fam) {
      case 'serif':
        return ReaderFont.serif;
      case 'mono':
        return ReaderFont.mono;
      default:
        return ReaderFont.sans;
    }
  }

  String _mapString(ReaderFont f) {
    switch (f) {
      case ReaderFont.serif:
        return 'serif';
      case ReaderFont.mono:
        return 'mono';
      default:
        return 'sans';
    }
  }
}
