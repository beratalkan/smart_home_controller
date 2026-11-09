import 'connectable.dart';
import 'smart_device.dart';

/// Concrete smart speaker device subclass.
///
/// Requirements covered:
/// - **Inheritance**: Extends [SmartDevice].
/// - **Interface**: Implements [Connectable].
/// - **Constructor**: Provides both default (`SmartSpeaker`) and named
///   constructors (`SmartSpeaker.playing`, `SmartSpeaker.quiet`).
/// - **Keywords**: Demonstrates `static`, `super`, and `this`.
class SmartSpeaker extends SmartDevice implements Connectable {
  static const int minVolume = 0;
  static const int maxVolume = 100;

  /// Current speaker volume percentage (0 to 100).
  int volume;

  /// Whether audio is currently playing.
  bool isPlaying;

  /// Default constructor using `super` and `this`.
  SmartSpeaker(
    super.name, {
    int volume = 40,
    this.isPlaying = false,
    super.isConnected = true,
  }) : volume = volume.clamp(minVolume, maxVolume);

  /// Named constructor creating a speaker actively playing audio.
  SmartSpeaker.playing(String roomName, {int volume = 40})
    : volume = volume.clamp(minVolume, maxVolume),
      isPlaying = true,
      super('Smart Speaker: $roomName', isConnected: true);

  /// Named constructor creating a paused speaker at low ambient volume (25%).
  SmartSpeaker.quiet(String roomName)
    : volume = 25,
      isPlaying = false,
      super('Smart Speaker: $roomName', isConnected: true);

  /// Updates volume using `this.volume` to disambiguate parameter vs. field.
  void setVolume(int volume) {
    if (!isConnected) return;
    this.volume = volume.clamp(minVolume, maxVolume);
  }

  @override
  void performAction() {
    if (!isConnected) return;
    isPlaying = !isPlaying;
  }

  @override
  String getStatus() {
    if (!isConnected) {
      return 'Offline';
    }
    return isPlaying ? 'Playing' : 'Paused';
  }

  @override
  String getPropertyText() {
    return 'Volume: $volume%';
  }

  @override
  String get deviceCategory => 'Smart Speaker';

  @override
  String getDeviceSummary() {
    return '${super.getDeviceSummary()} | ${getPropertyText()} | Status: ${getStatus()}';
  }
}

