import 'connectable.dart';

/// Abstract base class representing a generic smart home device.
///
/// Requirements covered:
/// - **Class & Abstraction**: `abstract class SmartDevice` with abstract methods
///   `getStatus()`, `performAction()`, and `getPropertyText()`.
/// - **Interface**: Implements `Connectable`.
/// - **Constructor**: Provides both a default constructor and a named constructor
///   (`SmartDevice.offline`).
/// - **Keywords (`static`, `this`)**:
///   - `static int totalDevices` tracks the total number of created devices.
///   - `this` is used in initializing formals, constructor redirection, and
///     instance field disambiguation.
abstract class SmartDevice implements Connectable {
  /// Static counter tracking the total number of created [SmartDevice] instances.
  static int totalDevices = 0;

  /// Display name of the smart device (e.g., "Smart Light: Living Room").
  String name;

  @override
  bool isConnected;

  /// Default constructor: increments [totalDevices] upon instantiation.
  SmartDevice(this.name, {this.isConnected = true}) {
    totalDevices++;
  }

  /// Named constructor: creates an initially disconnected device using `this`
  /// constructor redirection (ensuring [totalDevices] increments once).
  SmartDevice.offline(String name) : this(name, isConnected: false);

  /// Updates the device name using `this` to disambiguate field from parameter.
  void rename(String name) {
    this.name = name;
  }

  @override
  void connect() {
    isConnected = true;
  }

  @override
  void disconnect() {
    isConnected = false;
  }

  @override
  void toggleConnection() {
    if (isConnected) {
      disconnect();
    } else {
      connect();
    }
  }

  @override
  String getConnectionStatus() {
    return isConnected ? 'Connected' : 'Offline';
  }

  /// Concrete base summary method that subclasses extend via `super`.
  String getDeviceSummary() {
    return '$name (${getConnectionStatus()})';
  }

  /// Abstract method returning the current device status (e.g., ON, Heating, Playing).
  String getStatus();

  /// Abstract method performing the primary control action of the device.
  void performAction();

  /// Abstract method returning the formatted primary property of the device.
  String getPropertyText();

  /// Abstract getter returning the category name of the device.
  String get deviceCategory;
}

