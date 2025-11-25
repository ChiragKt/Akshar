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
    final isDark = settings.backgroundColor.computeLuminance() < 0.5;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222222) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // ---------------- FONT SIZE ----------------
          Row(
            children: [
              Text(
                'Font Size',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
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
              Text(
                '${settings.fontSize.round()}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),

          // ---------------- LINE HEIGHT ----------------
          Row(
            children: [
              Text(
                'Line Height',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
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
              Text(
                settings.lineHeight.toStringAsFixed(1),
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ---------------- FONT FAMILY + ALIGNMENT ----------------
          Row(
            children: [
              Text(
                'Font',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(width: 12),
              DropdownButton<ReaderFont>(
                value: _fontToEnum(settings.fontFamily),
                dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                items: const [
                  DropdownMenuItem(
                    value: ReaderFont.sans,
                    child: Text('Sans Serif'),
                  ),
                  DropdownMenuItem(
                    value: ReaderFont.serif,
                    child: Text('Serif'),
                  ),
                  DropdownMenuItem(
                    value: ReaderFont.mono,
                    child: Text('Monospace'),
                  ),
                ],
                onChanged: (v) {
                  settings.fontFamily = _fontToString(v!);
                  onChanged();
                },
              ),

              const Spacer(),

              // ---------------- ALIGNMENT BUTTONS ----------------
              _alignBtn(
                icon: Icons.format_align_left,
                active: settings.textAlign == TextAlign.left,
                onTap: () {
                  settings.textAlign = TextAlign.left;
                  onChanged();
                },
              ),
              _alignBtn(
                icon: Icons.format_align_center,
                active: settings.textAlign == TextAlign.center,
                onTap: () {
                  settings.textAlign = TextAlign.center;
                  onChanged();
                },
              ),
              _alignBtn(
                icon: Icons.format_align_right,
                active: settings.textAlign == TextAlign.right,
                onTap: () {
                  settings.textAlign = TextAlign.right;
                  onChanged();
                },
              ),
              _alignBtn(
                icon: Icons.format_align_justify,
                active: settings.textAlign == TextAlign.justify,
                onTap: () {
                  settings.textAlign = TextAlign.justify;
                  onChanged();
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ---------------- BACKGROUND THEME SWATCHES ----------------
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Background',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                ReadingSettings.themes.map((c) {
                  final selected =
                      c.toARGB32() == settings.backgroundColor.toARGB32();

                  final stroke =
                      c.computeLuminance() < 0.5
                          ? Colors.white
                          : Colors.black54;

                  return GestureDetector(
                    onTap: () {
                      settings.backgroundColor = c;
                      settings.textColor =
                          c.computeLuminance() < 0.5
                              ? Colors.white
                              : Colors.black87;
                      onChanged();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              selected
                                  ? Colors.deepPurpleAccent
                                  : stroke.withValues(alpha: 0.5),
                          width: selected ? 3 : 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  // ======================================================================
  // HELPERS
  // ======================================================================

  ReaderFont _fontToEnum(String s) {
    switch (s) {
      case 'serif':
        return ReaderFont.serif;
      case 'mono':
        return ReaderFont.mono;
      default:
        return ReaderFont.sans;
    }
  }

  String _fontToString(ReaderFont f) {
    switch (f) {
      case ReaderFont.serif:
        return 'serif';
      case ReaderFont.mono:
        return 'mono';
      default:
        return 'sans';
    }
  }

  Widget _alignBtn({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        size: 26,
        color: active ? Colors.deepPurpleAccent : Colors.grey,
      ),
      onPressed: onTap,
    );
  }
}
