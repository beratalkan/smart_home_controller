import 'connectable.dart';
import 'schedulable.dart';
import 'smart_device.dart';

/// Concrete smart light device subclass.
///
/// Requirements covered:
/// - **Inheritance**: Extends [SmartDevice].
/// - **Mixin**: Uses [Schedulable] (`with Schedulable`).
/// - **Interface**: Implements [Connectable].
/// - **Constructor**: Provides both default (`SmartLight`) and named
///   constructors (`SmartLight.dimmed`, `SmartLight.off`).
/// - **Keywords**: Demonstrates `static`, `super`, and `this`.
class SmartLight extends SmartDevice with Schedulable implements Connectable {
  static const int minBrightness = 0;
  static const int maxBrightness = 100;

  /// Current brightness percentage (0 to 100).
  int brightness;

  /// Whether the light is currently switched ON.
  bool isOn;

  /// Remembers last non-zero brightness so toggling back ON restores it.
  int _savedBrightness;

  /// Default constructor using `super` and `this`.
  SmartLight(
    super.name, {
    int brightness = 75,
    this.isOn = true,
    super.isConnected = true,
    String? initialSchedule,
  }) : brightness = isOn ? brightness.clamp(minBrightness, maxBrightness) : 0,
       _savedBrightness = brightness.clamp(1, maxBrightness) {
    if (initialSchedule != null) {
      setSchedule(initialSchedule);
    }
  }

  /// Named constructor creating an ON light with a dimmed brightness preset.
  SmartLight.dimmed(
    String roomName, {
    int brightness = 50,
    String? initialSchedule,
  }) : brightness = brightness.clamp(1, maxBrightness),
       isOn = true,
       _savedBrightness = brightness.clamp(1, maxBrightness),
       super('Smart Light: $roomName', isConnected: true) {
    if (initialSchedule != null) {
      setSchedule(initialSchedule);
    }
  }

  /// Named constructor creating a smart light initially turned OFF (0% brightness).
  SmartLight.off(String roomName)
    : brightness = 0,
      isOn = false,
      _savedBrightness = 75,
      super('Smart Light: $roomName', isConnected: true);

  /// Updates brightness using `this.brightness` to disambiguate parameter vs. field.
  void setBrightness(int brightness) {
    if (!isConnected) return;
    this.brightness = brightness.clamp(minBrightness, maxBrightness);
    if (this.brightness == 0) {
      isOn = false;
    } else {
      isOn = true;
      _savedBrightness = this.brightness;
    }
  }

  /// Sets power state explicitly while preserving saved brightness level.
  void setPower(bool isOn) {
    if (!isConnected) return;
    this.isOn = isOn;
    if (this.isOn) {
      brightness = _savedBrightness;
    } else {
      if (brightness > 0) {
        _savedBrightness = brightness;
      }
      brightness = 0;
    }
  }

  @override
  void performAction() {
    setPower(!isOn);
  }

  @override
  String getStatus() {
    if (!isConnected) {
      return 'Offline';
    }
    return isOn ? 'ON' : 'OFF';
  }

  @override
  String getPropertyText() {
    final displayedBrightness = isOn ? brightness : 0;
    return 'Brightness: $displayedBrightness%';
  }

  @override
  String get deviceCategory => 'Smart Light';

  @override
  String getDeviceSummary() {
    return '${super.getDeviceSummary()} | ${getPropertyText()} | Status: ${getStatus()}';
  }
}

