import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Global singleton that manages background music (looping) and
/// a round-robin pool of SFX players so rapid taps never interrupt each other.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // --- Background music ---
  AudioPlayer? _bgmPlayer;
  bool _bgmReady = false;
  bool _bgmMuted = false;

  // --- SFX pool ---
  static const int _poolSize = 5;
  final List<AudioPlayer> _sfxPool = [];
  int _sfxIndex = 0;
  bool _sfxReady = false;

  /// Call once at app startup (await it before runApp).
  Future<void> init() async {
    if (!_bgmReady) {
      _bgmPlayer = AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer!.setVolume(0.45);
      _bgmReady = true;
    }

    if (!_sfxReady) {
      for (int i = 0; i < _poolSize; i++) {
        final p = AudioPlayer();
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setVolume(1.0);
        _sfxPool.add(p);
      }
      _sfxReady = true;
    }
  }

  // --------------- Background music ---------------

  Future<void> playBgm() async {
    if (!_bgmReady) await init();
    if (_bgmMuted) return; // Don't play if muted
    try {
      if (_bgmPlayer!.state == PlayerState.playing) return;
      await _bgmPlayer!.play(AssetSource('sounds/background_music.mp3'));
    } catch (e) {
      debugPrint('[Audio] BGM play error: $e');
    }
  }

  Future<void> pauseBgm() async {
    try {
      await _bgmPlayer?.pause();
    } catch (_) {}
  }

  Future<void> resumeBgm() async {
    try {
      if (_bgmPlayer?.state == PlayerState.paused) {
        await _bgmPlayer!.resume();
      } else {
        await playBgm();
      }
    } catch (_) {}
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer?.stop();
    } catch (_) {}
  }

  /// Mute/unmute background music
  Future<void> setMuteBgm(bool muted) async {
    _bgmMuted = muted;
    if (muted) {
      await pauseBgm();
    } else {
      await resumeBgm();
    }
  }

  /// Check if BGM is muted
  bool isBgmMuted() => _bgmMuted;

  // --------------- SFX ---------------

  /// [filename] is the bare filename, e.g. 'button_click.mp3'
  Future<void> playSfx(String filename) async {
    if (!_sfxReady) await init();
    try {
      final player = _sfxPool[_sfxIndex % _poolSize];
      _sfxIndex++;
      // Stop any previous sound on this slot then play immediately
      await player.stop();
      await player.play(AssetSource('sounds/$filename'));
    } catch (e) {
      debugPrint('[Audio] SFX error ($filename): $e');
    }
  }
}
