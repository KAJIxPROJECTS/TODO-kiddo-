import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/services/notification_service.dart';
import '../../../../presentation/providers/notification_settings_provider.dart';
import 'sound_selection_screen.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(notificationSettingsProvider);
    final settingsNotifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notification Settings', style: TextStyle(fontWeight: FontWeight.bold)),
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
        children: [
          SwitchListTile(
            title: const Text('Enable Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Get task deadlines and morning digest'),
            value: settings.enabled,
            activeThumbColor: const Color(0xFFFBBF24),
            onChanged: (val) {
              settingsNotifier.updateSettings(enabled: val);
              if (val) {
                NotificationService().scheduleDailyReminder(hour: settings.hour, minute: settings.minute);
              } else {
                NotificationService().cancelDailyReminder();
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Daily Briefing Time', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Receive tasks digest at ${settings.hour.toString().padLeft(2, '0')}:${settings.minute.toString().padLeft(2, '0')}'),
            trailing: const Icon(Icons.access_time_filled_rounded, color: Color(0xFFFBBF24)),
            enabled: settings.enabled,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: settings.hour, minute: settings.minute),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: const Color(0xFFFBBF24),
                          ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                settingsNotifier.updateSettings(hour: picked.hour, minute: picked.minute);
                if (settings.enabled) {
                  NotificationService().scheduleDailyReminder(hour: picked.hour, minute: picked.minute);
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Task Reminders Priority', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Receive alerts for: ${settings.priorityFilter} priority tasks'),
            enabled: settings.enabled,
            trailing: DropdownButton<String>(
              value: settings.priorityFilter,
              onChanged: settings.enabled
                  ? (val) {
                      if (val != null) {
                        settingsNotifier.updateSettings(priorityFilter: val);
                      }
                    }
                  : null,
              items: <String>['All', 'High'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Sound & Vibration', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Play sound for notifications'),
            value: settings.soundEnabled,
            activeThumbColor: const Color(0xFFFBBF24),
            onChanged: settings.enabled
                ? (val) {
                    settingsNotifier.updateSettings(soundEnabled: val);
                  }
                : null,
          ),
          const Divider(),
          ListTile(
            title: const Text('Notification Sound', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              notificationSounds.firstWhere((s) => s.id == settings.selectedSound, orElse: () => const SoundDefinition('zen_gong', 'Zen Gong', '')).name,
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            enabled: settings.enabled && settings.soundEnabled,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SoundSelectionScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: settings.enabled
                ? () {
                    NotificationService().showTestNotification();
                  }
                : null,
            icon: const Icon(Icons.notifications_active_rounded),
            label: const Text('Send Instant Test Notification'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFBBF24),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
