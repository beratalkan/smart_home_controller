import 'connectable.dart';
import 'schedulable.dart';
import 'smart_device.dart';

/// Concrete smart thermostat device subclass.
///
/// Requirements covered:
/// - **Inheritance**: Extends [SmartDevice].
/// - **Mixin**: Uses [Schedulable] (`with Schedulable`).
/// - **Interface**: Implements [Connectable].
/// - **Constructor**: Provides both default (`Thermostat`) and named
///   constructors (`Thermostat.ecoMode`, `Thermostat.comfort`).
/// - **Keywords**: Demonstrates `static`, `super`, and `this`.
class Thermostat extends SmartDevice with Schedulable implements Connectable {
  static const int minTemperature = 16;
  static const int maxTemperature = 30;

  /// Target temperature in degrees Celsius (°C).
  int temperature;

  /// Default constructor using `super`.
  Thermostat(
    super.name, {
    int temperature = 22,
    super.isConnected = true,
    String? initialSchedule,
  }) : temperature = temperature.clamp(minTemperature, maxTemperature) {
    if (initialSchedule != null) {
      setSchedule(initialSchedule);
    }
  }

  /// Named constructor configuring energy-saving Eco mode (20°C).
  Thermostat.ecoMode(String roomName, {String? initialSchedule})
    : temperature = 20,
      super('Thermostat: $roomName', isConnected: true) {
    if (initialSchedule != null) {
      setSchedule(initialSchedule);
    }
  }

  /// Named constructor configuring warm Comfort mode (default 24°C).
  Thermostat.comfort(String roomName, {int temperature = 24})
    : temperature = temperature.clamp(minTemperature, maxTemperature),
      super('Thermostat: $roomName', isConnected: true);

  /// Updates target temperature using `this.temperature` to disambiguate parameter vs. field.
  void setTemperature(int temperature) {
    if (!isConnected) return;
    this.temperature = temperature.clamp(minTemperature, maxTemperature);
  }

  /// Increments temperature by 1°C up to [maxTemperature].
  void increaseTemperature() {
    setTemperature(temperature + 1);
  }

  /// Decrements temperature by 1°C down to [minTemperature].
  void decreaseTemperature() {
    setTemperature(temperature - 1);
  }

  @override
  void performAction() {
    if (!isConnected) return;
    if (temperature >= maxTemperature) {
      setTemperature(minTemperature);
    } else {
      increaseTemperature();
    }
  }

  @override
  String getStatus() {
    if (!isConnected) {
      return 'Offline';
    }
    if (temperature >= 22) {
      return 'Heating';
    } else if (temperature <= 19) {
      return 'Cooling';
    }
    return 'Eco Idle';
  }

  @override
  String getPropertyText() {
    return 'Temperature: $temperature°C';
  }

  @override
  String get deviceCategory => 'Thermostat';

  @override
  String getDeviceSummary() {
    return '${super.getDeviceSummary()} | ${getPropertyText()} | Status: ${getStatus()}';
  }
}

