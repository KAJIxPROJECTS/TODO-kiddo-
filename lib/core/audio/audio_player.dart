import 'audio_player_stub.dart'
    if (dart.library.html) 'audio_player_web.dart';

class NotificationSoundPlayer {
  static void playSound(String soundId) {
    playNotificationSound(soundId);
  }
}
