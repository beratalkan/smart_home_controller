/// Interface defining network connectivity operations for smart home devices.
///
/// Requirement covered:
/// - **Interface**: Defines `Connectable` with connection management methods
///   to be implemented by device classes.
abstract interface class Connectable {
  /// Indicates whether the device is currently connected to the smart hub.
  bool get isConnected;

  /// Connects the device to the smart home network.
  void connect();

  /// Disconnects the device from the smart home network.
  void disconnect();

  /// Toggles the current network connection state.
  void toggleConnection();

  /// Returns a human-readable connection status label.
  String getConnectionStatus();
}

