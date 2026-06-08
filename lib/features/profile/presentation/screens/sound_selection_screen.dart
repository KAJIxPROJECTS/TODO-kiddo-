import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/audio_player.dart';
import '../../../../presentation/providers/notification_settings_provider.dart';

class SoundDefinition {
  final String id;
  final String name;
  final String genre;
  const SoundDefinition(this.id, this.name, this.genre);
}

const List<SoundDefinition> notificationSounds = [
  SoundDefinition('zen_gong', 'Zen Gong', 'Zen / Calming'),
  SoundDefinition('peaceful_bell', 'Peaceful Bell', 'Zen / Calming'),
  SoundDefinition('soft_breeze', 'Soft Breeze', 'Zen / Calming'),
  SoundDefinition('quiet_chime', 'Quiet Chime', 'Zen / Calming'),
  SoundDefinition('morning_dew', 'Morning Dew', 'Zen / Calming'),

  SoundDefinition('tech_ping', 'Tech Ping', 'Modern / Tech'),
  SoundDefinition('digital_rise', 'Digital Rise', 'Modern / Tech'),
  SoundDefinition('cyber_beep', 'Cyber Beep', 'Modern / Tech'),
  SoundDefinition('echo_dot', 'Echo Dot', 'Modern / Tech'),
  SoundDefinition('synth_chord', 'Synth Chord', 'Modern / Tech'),

  SoundDefinition('retro_jump', 'Retro Jump', 'Retro / Arcade'),
  SoundDefinition('laser_shot', 'Laser Shot', 'Retro / Arcade'),
  SoundDefinition('level_up', 'Level Up', 'Retro / Arcade'),
  SoundDefinition('eight_bit_pip', '8-Bit Pip', 'Retro / Arcade'),
  SoundDefinition('arcade_win', 'Arcade Win', 'Retro / Arcade'),

  SoundDefinition('double_ring', 'Double Ring', 'Alert / Urgent'),
  SoundDefinition('pulse_alarm', 'Pulse Alarm', 'Alert / Urgent'),
  SoundDefinition('high_beep', 'High Beep', 'Alert / Urgent'),
  SoundDefinition('urgent_buzz', 'Urgent Buzz', 'Alert / Urgent'),
  SoundDefinition('siren_chirp', 'Siren Chirp', 'Alert / Urgent'),
];

class SoundSelectionScreen extends ConsumerWidget {
  const SoundSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(notificationSettingsProvider);
    final settingsNotifier = ref.read(notificationSettingsProvider.notifier);

    final Map<String, List<SoundDefinition>> groupedSounds = {};
    for (var sound in notificationSounds) {
      groupedSounds.putIfAbsent(sound.genre, () => []).add(sound);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notification Sound', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: groupedSounds.keys.map((genre) {
          final sounds = groupedSounds[genre]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  genre,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFBBF24),
                  ),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: theme.cardTheme.color,
                child: Column(
                  children: sounds.map((sound) {
                    final isSelected = settings.selectedSound == sound.id;
                    return Column(
                      children: [
                        ListTile(
                          title: Text(sound.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFBBF24))
                              : const Icon(Icons.play_arrow_rounded, color: Colors.grey),
                          onTap: () {
                            settingsNotifier.updateSettings(selectedSound: sound.id);
                            NotificationSoundPlayer.playSound(sound.id);
                          },
                        ),
                        if (sound != sounds.last)
                          Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
