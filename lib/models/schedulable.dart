import 'smart_device.dart';

/// Mixin providing automation scheduling capabilities for suitable smart devices.
///
/// Requirements covered:
/// - **Mixin**: `mixin Schedulable` applied to suitable subclasses
///   (`SmartLight` and `Thermostat`).
/// - **Keywords (`this`)**: Demonstrates `this.scheduledTime` disambiguation.
mixin Schedulable on SmartDevice {
  /// Optional scheduled automation time in `HH:mm` format (e.g., "22:00").
  String? scheduledTime;

  /// Returns `true` when an automation schedule is active on this device.
  bool get hasSchedule => scheduledTime != null;

  /// Sets a daily schedule time for the device.
  void setSchedule(String scheduledTime) {
    this.scheduledTime = scheduledTime;
  }

  /// Removes any active schedule from the device.
  void clearSchedule() {
    scheduledTime = null;
  }

  /// Returns a formatted label describing the current schedule state.
  String getScheduleInfo() {
    if (scheduledTime == null) {
      return 'Schedule';
    }
    return 'At $scheduledTime';
  }
}

