import 'dart:js_interop';

@JS('eval')
external void jsEval(JSString code);

@JS('playWebNotificationSound')
external void jsPlayWebNotificationSound(JSString soundId);

void playNotificationSound(String soundId) {
  try {
    jsEval("""
      if (!window.playWebNotificationSound) {
        window.playWebNotificationSound = function(soundId) {
          try {
            var AudioContextClass = window.AudioContext || window.webkitAudioContext;
            var ctx = new AudioContextClass();
            
            function playTone(freq, duration, type, attack, decay, startOffset) {
              attack = attack || 0.01;
              decay = decay || 0.1;
              startOffset = startOffset || 0;
              
              var osc = ctx.createOscillator();
              var gain = ctx.createGain();
              
              osc.type = type;
              osc.frequency.value = freq;
              
              gain.gain.setValueAtTime(0.01, ctx.currentTime + startOffset);
              gain.gain.linearRampToValueAtTime(0.5, ctx.currentTime + startOffset + attack);
              gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + startOffset + duration - 0.01);
              
              osc.connect(gain);
              gain.connect(ctx.destination);
              
              osc.start(ctx.currentTime + startOffset);
              osc.stop(ctx.currentTime + startOffset + duration);
            }

            if (soundId === 'zen_gong') {
              playTone(150, 1.5, 'sine', 0.1);
            } else if (soundId === 'peaceful_bell') {
              playTone(880, 1.2, 'sine', 0.05);
            } else if (soundId === 'soft_breeze') {
              playTone(440, 0.8, 'sine', 0.3);
            } else if (soundId === 'quiet_chime') {
              playTone(1200, 0.5, 'sine', 0.02);
            } else if (soundId === 'morning_dew') {
              playTone(523, 0.3, 'sine', 0.05, 0.1, 0.0);
              playTone(659, 0.5, 'sine', 0.05, 0.1, 0.25);
            } else if (soundId === 'tech_ping') {
              playTone(1000, 0.2, 'sine', 0.005);
            } else if (soundId === 'digital_rise') {
              var osc = ctx.createOscillator();
              var gain = ctx.createGain();
              osc.type = 'sine';
              osc.frequency.setValueAtTime(400, ctx.currentTime);
              osc.frequency.exponentialRampToValueAtTime(1200, ctx.currentTime + 0.25);
              gain.gain.setValueAtTime(0.01, ctx.currentTime);
              gain.gain.linearRampToValueAtTime(0.5, ctx.currentTime + 0.05);
              gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.25);
              osc.connect(gain);
              gain.connect(ctx.destination);
              osc.start(0);
              osc.stop(ctx.currentTime + 0.25);
            } else if (soundId === 'cyber_beep') {
              playTone(600, 0.15, 'square', 0.01);
            } else if (soundId === 'echo_dot') {
              playTone(800, 0.1, 'sine', 0.01, 0.1, 0.0);
              playTone(800, 0.1, 'sine', 0.01, 0.1, 0.15);
            } else if (soundId === 'synth_chord') {
              playTone(300, 0.6, 'sine', 0.05);
              playTone(450, 0.6, 'sine', 0.05);
              playTone(600, 0.6, 'sine', 0.05);
            } else if (soundId === 'retro_jump') {
              var osc = ctx.createOscillator();
              var gain = ctx.createGain();
              osc.type = 'triangle';
              osc.frequency.setValueAtTime(200, ctx.currentTime);
              osc.frequency.linearRampToValueAtTime(800, ctx.currentTime + 0.2);
              gain.gain.setValueAtTime(0.01, ctx.currentTime);
              gain.gain.linearRampToValueAtTime(0.4, ctx.currentTime + 0.02);
              gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.2);
              osc.connect(gain);
              gain.connect(ctx.destination);
              osc.start(0);
              osc.stop(ctx.currentTime + 0.2);
            } else if (soundId === 'laser_shot') {
              var osc = ctx.createOscillator();
              var gain = ctx.createGain();
              osc.type = 'sawtooth';
              osc.frequency.setValueAtTime(2000, ctx.currentTime);
              osc.frequency.exponentialRampToValueAtTime(200, ctx.currentTime + 0.3);
              gain.gain.setValueAtTime(0.01, ctx.currentTime);
              gain.gain.linearRampToValueAtTime(0.3, ctx.currentTime + 0.01);
              gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.3);
              osc.connect(gain);
              gain.connect(ctx.destination);
              osc.start(0);
              osc.stop(ctx.currentTime + 0.3);
            } else if (soundId === 'level_up') {
              playTone(262, 0.1, 'square', 0.01, 0.1, 0.0);
              playTone(330, 0.1, 'square', 0.01, 0.1, 0.1);
              playTone(392, 0.1, 'square', 0.01, 0.1, 0.2);
              playTone(523, 0.3, 'square', 0.01, 0.1, 0.3);
            } else if (soundId === 'eight_bit_pip') {
              playTone(1500, 0.08, 'triangle');
            } else if (soundId === 'arcade_win') {
              playTone(523, 0.08, 'square', 0.01, 0.1, 0.0);
              playTone(659, 0.08, 'square', 0.01, 0.1, 0.08);
              playTone(784, 0.08, 'square', 0.01, 0.1, 0.16);
              playTone(1047, 0.2, 'square', 0.01, 0.1, 0.24);
            } else if (soundId === 'double_ring') {
              playTone(1000, 0.1, 'sine', 0.01, 0.1, 0.0);
              playTone(1000, 0.1, 'sine', 0.01, 0.1, 0.15);
            } else if (soundId === 'pulse_alarm') {
              playTone(500, 0.15, 'sawtooth', 0.01, 0.1, 0.0);
              playTone(500, 0.15, 'sawtooth', 0.01, 0.1, 0.2);
              playTone(500, 0.15, 'sawtooth', 0.01, 0.1, 0.4);
            } else if (soundId === 'high_beep') {
              playTone(2000, 0.4, 'sine');
            } else if (soundId === 'urgent_buzz') {
              playTone(100, 0.3, 'sawtooth');
            } else if (soundId === 'siren_chirp') {
              var osc = ctx.createOscillator();
              var gain = ctx.createGain();
              osc.type = 'sine';
              osc.frequency.setValueAtTime(800, ctx.currentTime);
              osc.frequency.linearRampToValueAtTime(1200, ctx.currentTime + 0.15);
              osc.frequency.linearRampToValueAtTime(800, ctx.currentTime + 0.3);
              gain.gain.setValueAtTime(0.01, ctx.currentTime);
              gain.gain.linearRampToValueAtTime(0.4, ctx.currentTime + 0.05);
              gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.3);
              osc.connect(gain);
              gain.connect(ctx.destination);
              osc.start(0);
              osc.stop(ctx.currentTime + 0.3);
            }
          } catch(e) {}
        };
      }
    """.toJS);
    jsPlayWebNotificationSound(soundId.toJS);
  } catch (_) {}
}
