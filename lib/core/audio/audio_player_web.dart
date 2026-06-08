import 'dart:html' as html;

void playNotificationSound(String soundId) {
  try {
    final ctx = html.AudioContext();
    
    void playTone({
      required double freq,
      required double duration,
      required String type,
      double attack = 0.01,
      double decay = 0.1,
      double startOffset = 0.0,
    }) {
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      
      osc.type = type;
      osc.frequency.value = freq;
      
      gain.gain.setValueAtTime(0.01, ctx.currentTime + startOffset);
      gain.gain.linearRampToValueAtTime(0.5, ctx.currentTime + startOffset + attack);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + startOffset + duration - 0.01);
      
      osc.connectNode(gain);
      gain.connectNode(ctx.destination);
      
      osc.start(ctx.currentTime + startOffset);
      osc.stop(ctx.currentTime + startOffset + duration);
    }

    if (soundId == 'zen_gong') {
      playTone(freq: 150, duration: 1.5, type: 'sine', attack: 0.1);
    } else if (soundId == 'peaceful_bell') {
      playTone(freq: 880, duration: 1.2, type: 'sine', attack: 0.05);
    } else if (soundId == 'soft_breeze') {
      playTone(freq: 440, duration: 0.8, type: 'sine', attack: 0.3);
    } else if (soundId == 'quiet_chime') {
      playTone(freq: 1200, duration: 0.5, type: 'sine', attack: 0.02);
    } else if (soundId == 'morning_dew') {
      playTone(freq: 523, duration: 0.3, type: 'sine', attack: 0.05, startOffset: 0.0);
      playTone(freq: 659, duration: 0.5, type: 'sine', attack: 0.05, startOffset: 0.25);
    } else if (soundId == 'tech_ping') {
      playTone(freq: 1000, duration: 0.2, type: 'sine', attack: 0.005);
    } else if (soundId == 'digital_rise') {
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(400, ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(1200, ctx.currentTime + 0.25);
      gain.gain.setValueAtTime(0.01, ctx.currentTime);
      gain.gain.linearRampToValueAtTime(0.5, ctx.currentTime + 0.05);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.25);
      osc.connectNode(gain);
      gain.connectNode(ctx.destination);
      osc.start(0);
      osc.stop(ctx.currentTime + 0.25);
    } else if (soundId == 'cyber_beep') {
      playTone(freq: 600, duration: 0.15, type: 'square', attack: 0.01);
    } else if (soundId == 'echo_dot') {
      playTone(freq: 800, duration: 0.1, type: 'sine', startOffset: 0.0);
      playTone(freq: 800, duration: 0.1, type: 'sine', startOffset: 0.15);
    } else if (soundId == 'synth_chord') {
      playTone(freq: 300, duration: 0.6, type: 'sine', attack: 0.05);
      playTone(freq: 450, duration: 0.6, type: 'sine', attack: 0.05);
      playTone(freq: 600, duration: 0.6, type: 'sine', attack: 0.05);
    } else if (soundId == 'retro_jump') {
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(200, ctx.currentTime);
      osc.frequency.linearRampToValueAtTime(800, ctx.currentTime + 0.2);
      gain.gain.setValueAtTime(0.01, ctx.currentTime);
      gain.gain.linearRampToValueAtTime(0.4, ctx.currentTime + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.2);
      osc.connectNode(gain);
      gain.connectNode(ctx.destination);
      osc.start(0);
      osc.stop(ctx.currentTime + 0.2);
    } else if (soundId == 'laser_shot') {
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(2000, ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(200, ctx.currentTime + 0.3);
      gain.gain.setValueAtTime(0.01, ctx.currentTime);
      gain.gain.linearRampToValueAtTime(0.3, ctx.currentTime + 0.01);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.3);
      osc.connectNode(gain);
      gain.connectNode(ctx.destination);
      osc.start(0);
      osc.stop(ctx.currentTime + 0.3);
    } else if (soundId == 'level_up') {
      playTone(freq: 262, duration: 0.1, type: 'square', startOffset: 0.0);
      playTone(freq: 330, duration: 0.1, type: 'square', startOffset: 0.1);
      playTone(freq: 392, duration: 0.1, type: 'square', startOffset: 0.2);
      playTone(freq: 523, duration: 0.3, type: 'square', startOffset: 0.3);
    } else if (soundId == 'eight_bit_pip') {
      playTone(freq: 1500, duration: 0.08, type: 'triangle');
    } else if (soundId == 'arcade_win') {
      playTone(freq: 523, duration: 0.08, type: 'square', startOffset: 0.0);
      playTone(freq: 659, duration: 0.08, type: 'square', startOffset: 0.08);
      playTone(freq: 784, duration: 0.08, type: 'square', startOffset: 0.16);
      playTone(freq: 1047, duration: 0.2, type: 'square', startOffset: 0.24);
    } else if (soundId == 'double_ring') {
      playTone(freq: 1000, duration: 0.1, type: 'sine', startOffset: 0.0);
      playTone(freq: 1000, duration: 0.1, type: 'sine', startOffset: 0.15);
    } else if (soundId == 'pulse_alarm') {
      playTone(freq: 500, duration: 0.15, type: 'sawtooth', startOffset: 0.0);
      playTone(freq: 500, duration: 0.15, type: 'sawtooth', startOffset: 0.2);
      playTone(freq: 500, duration: 0.15, type: 'sawtooth', startOffset: 0.4);
    } else if (soundId == 'high_beep') {
      playTone(freq: 2000, duration: 0.4, type: 'sine');
    } else if (soundId == 'urgent_buzz') {
      playTone(freq: 100, duration: 0.3, type: 'sawtooth');
    } else if (soundId == 'siren_chirp') {
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(800, ctx.currentTime);
      osc.frequency.linearRampToValueAtTime(1200, ctx.currentTime + 0.15);
      osc.frequency.linearRampToValueAtTime(800, ctx.currentTime + 0.3);
      gain.gain.setValueAtTime(0.01, ctx.currentTime);
      gain.gain.linearRampToValueAtTime(0.4, ctx.currentTime + 0.05);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.3);
      osc.connectNode(gain);
      gain.connectNode(ctx.destination);
      osc.start(0);
      osc.stop(ctx.currentTime + 0.3);
    }
  } catch (_) {}
}
