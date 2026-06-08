import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationSettingsState {
  final bool enabled;
  final int hour;
  final int minute;
  final String priorityFilter;
  final bool soundEnabled;
  final String selectedSound;

  NotificationSettingsState({
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.priorityFilter,
    required this.soundEnabled,
    required this.selectedSound,
  });
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  static const String _boxName = 'profile_box';
  static const String _enabledKey = 'notif_enabled';
  static const String _hourKey = 'notif_hour';
  static const String _minuteKey = 'notif_minute';
  static const String _filterKey = 'notif_filter';
  static const String _soundKey = 'notif_sound';
  static const String _soundFileKey = 'notif_sound_file';

  NotificationSettingsNotifier()
      : super(NotificationSettingsState(
          enabled: _getBool(_enabledKey, true),
          hour: _getInt(_hourKey, 9),
          minute: _getInt(_minuteKey, 0),
          priorityFilter: _getString(_filterKey, 'All'),
          soundEnabled: _getBool(_soundKey, true),
          selectedSound: _getString(_soundFileKey, 'zen_gong'),
        ));

  static bool _getBool(String key, bool defaultValue) {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        return Hive.box(_boxName).get(key, defaultValue: defaultValue) as bool;
      }
    } catch (_) {}
    return defaultValue;
  }

  static int _getInt(String key, int defaultValue) {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        return Hive.box(_boxName).get(key, defaultValue: defaultValue) as int;
      }
    } catch (_) {}
    return defaultValue;
  }

  static String _getString(String key, String defaultValue) {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        return Hive.box(_boxName).get(key, defaultValue: defaultValue) as String;
      }
    } catch (_) {}
    return defaultValue;
  }

  void updateSettings({
    bool? enabled,
    int? hour,
    int? minute,
    String? priorityFilter,
    bool? soundEnabled,
    String? selectedSound,
  }) {
    final newState = NotificationSettingsState(
      enabled: enabled ?? state.enabled,
      hour: hour ?? state.hour,
      minute: minute ?? state.minute,
      priorityFilter: priorityFilter ?? state.priorityFilter,
      soundEnabled: soundEnabled ?? state.soundEnabled,
      selectedSound: selectedSound ?? state.selectedSound,
    );

    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box(_boxName);
        if (enabled != null) box.put(_enabledKey, enabled);
        if (hour != null) box.put(_hourKey, hour);
        if (minute != null) box.put(_minuteKey, minute);
        if (priorityFilter != null) box.put(_filterKey, priorityFilter);
        if (soundEnabled != null) box.put(_soundKey, soundEnabled);
        if (selectedSound != null) box.put(_soundFileKey, selectedSound);
      }
    } catch (_) {}

    state = newState;
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>((ref) {
  return NotificationSettingsNotifier();
});
