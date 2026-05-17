import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:audioplayers/audioplayers.dart';

/// Service for managing game audio (background music and sound effects)
class AudioService with WidgetsBindingObserver {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  
  bool _isTestEnvironment = false;
  StreamSubscription<void>? _sfxSubscription;

  AudioService._internal() {
    try {
      WidgetsBinding.instance.addObserver(this);
      
      // Configure global audio context for mixable ambient audio across all platforms
      AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.duckOthers,
            },
          ),
        ),
      );
    } catch (_) {
      // Allow pure unit tests to run without binding initialization
      _isTestEnvironment = true;
    }
  }

  AudioPlayer? _bgmPlayerInstance;
  AudioPlayer? _sfxPlayerInstance;

  AudioPlayer get _bgmPlayer {
    _bgmPlayerInstance ??= AudioPlayer();
    return _bgmPlayerInstance!;
  }

  AudioPlayer get _sfxPlayer {
    _sfxPlayerInstance ??= AudioPlayer();
    return _sfxPlayerInstance!;
  }

  bool _isBgmPlaying = false;
  bool _isMuted = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isTestEnvironment) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      if (_isBgmPlaying && !_isMuted) {
        _bgmPlayer.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isBgmPlaying && !_isMuted) {
        _bgmPlayer.resume();
      }
    }
  }

  /// Initialize and start background music
  Future<void> initializeBgm() async {
    if (_isTestEnvironment) return;
    
    // If BGM is already marked as playing, try to resume to bypass browser autoplay blocks on user tap
    if (_isBgmPlaying) {
      try {
        if (!_isMuted) {
          await _bgmPlayer.resume();
        }
      } catch (_) {}
      return;
    }

    try {
      // Set release mode to loop
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);

      // Set volume (0.0 to 1.0)
      await _bgmPlayer.setVolume(_isMuted ? 0.0 : 0.3); // Respect mute status

      // Play background music
      await _bgmPlayer.play(AssetSource('sounds/bgm.mp3'));

      _isBgmPlaying = true;
      print('🎵 Background music started');
    } catch (e) {
      print('❌ Error playing background music: $e');
    }
  }

  /// Stop background music
  Future<void> stopBgm() async {
    if (_isTestEnvironment) return;
    await _bgmPlayer.stop();
    _isBgmPlaying = false;
    print('🔇 Background music stopped');
  }

  /// Pause background music
  Future<void> pauseBgm() async {
    if (_isTestEnvironment) return;
    await _bgmPlayer.pause();
    print('⏸️ Background music paused');
  }

  /// Resume background music
  Future<void> resumeBgm() async {
    if (_isTestEnvironment) return;
    await _bgmPlayer.resume();
    print('▶️ Background music resumed');
  }

  /// Play sound effect with dynamic BGM ducking
  Future<void> playSfx(String fileName) async {
    if (_isTestEnvironment) return;
    if (_isMuted) return;

    try {
      // 1. Duck background music if playing
      if (_isBgmPlaying && !_isMuted) {
        await _bgmPlayer.setVolume(0.08); // 8% volume during SFX
      }

      // 2. Cancel previous completion subscription if active
      await _sfxSubscription?.cancel();

      // 3. Play the sound effect
      await _sfxPlayer.play(AssetSource('sounds/$fileName'));

      // 4. Setup listener to restore BGM volume on completion
      _sfxSubscription = _sfxPlayer.onPlayerComplete.listen((_) async {
        if (_isBgmPlaying && !_isMuted) {
          await _bgmPlayer.setVolume(0.3); // Restore to 30%
        }
        await _sfxSubscription?.cancel();
        _sfxSubscription = null;
      });

      // 5. Safety fallback to ensure BGM volume is restored even if stream fails
      Future.delayed(const Duration(milliseconds: 2500), () async {
        if (_sfxSubscription != null) {
          if (_isBgmPlaying && !_isMuted) {
            await _bgmPlayer.setVolume(0.3);
          }
          await _sfxSubscription?.cancel();
          _sfxSubscription = null;
        }
      });

    } catch (e) {
      print('❌ Error playing sound effect: $e');
    }
  }

  /// Toggle mute for all audio
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    if (_isTestEnvironment) return;

    if (_isMuted) {
      await _bgmPlayer.setVolume(0.0);
    } else {
      await _bgmPlayer.setVolume(0.3);
    }

    print(_isMuted ? '🔇 Audio muted' : '🔊 Audio unmuted');
  }

  /// Set background music volume (0.0 to 1.0)
  Future<void> setBgmVolume(double volume) async {
    if (_isTestEnvironment) return;
    await _bgmPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Dispose audio players
  Future<void> dispose() async {
    if (_isTestEnvironment) return;
    WidgetsBinding.instance.removeObserver(this);
    await _sfxSubscription?.cancel();
    await _bgmPlayerInstance?.dispose();
    await _sfxPlayerInstance?.dispose();
  }

  /// Check if background music is playing
  bool get isBgmPlaying => _isBgmPlaying;

  /// Check if audio is muted
  bool get isMuted => _isMuted;
}

// Made with Bob
