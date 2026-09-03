import 'package:flutter/material.dart';
import '../../systems/save_manager.dart';

class SettingsDialog extends StatefulWidget {
  final VoidCallback onSettingsChanged;

  const SettingsDialog({super.key, required this.onSettingsChanged});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _sound = true;
  bool _vibration = true;

  @override
  void initState() {
    super.initState();
    _sound = SaveManager.isSoundEnabled();
    _vibration = SaveManager.isVibrationEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white24),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 20, spreadRadius: 4),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚙️', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 6),
              const Text(
                'SETTINGS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Sound Toggle
              SwitchListTile(
                title: const Text('Sound Effects', style: TextStyle(color: Colors.white, fontSize: 14)),
                secondary: const Text('🔊', style: TextStyle(fontSize: 20)),
                activeColor: Colors.pinkAccent,
                value: _sound,
                onChanged: (val) async {
                  setState(() => _sound = val);
                  await SaveManager.setSoundEnabled(val);
                  widget.onSettingsChanged();
                },
              ),

              // Vibration Toggle
              SwitchListTile(
                title: const Text('Haptic Vibration', style: TextStyle(color: Colors.white, fontSize: 14)),
                secondary: const Text('📳', style: TextStyle(fontSize: 20)),
                activeColor: Colors.pinkAccent,
                value: _vibration,
                onChanged: (val) async {
                  setState(() => _vibration = val);
                  await SaveManager.setVibrationEnabled(val);
                  widget.onSettingsChanged();
                },
              ),

              const Divider(color: Colors.white24, height: 24),

              // Privacy & Policies notice
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  'Privacy Note: Kiss & Run requires 0 invasive permissions. All saves are stored 100% locally on your device.',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Reset Progress Button
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                label: const Text(
                  'RESET ALL PROGRESS',
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1E293B),
                      title: const Text('Reset All Data?', style: TextStyle(color: Colors.white)),
                      content: const Text(
                        'This will reset your coins, unlocks, and high scores.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('CANCEL'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                          onPressed: () async {
                            final nav = Navigator.of(context);
                            final ctxNav = Navigator.of(ctx);
                            await SaveManager.resetAll();
                            ctxNav.pop();
                            nav.pop();
                            widget.onSettingsChanged();
                          },
                          child: const Text('RESET', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white12,
                  minimumSize: const Size(double.infinity, 38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
