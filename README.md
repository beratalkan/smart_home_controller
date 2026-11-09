# Smart Home Controller App

**BIM493 Mobile Programming I — Assignment #2**

## Students / Hazırlayanlar

| Ad Soyad (Name) | TC / Öğrenci No (ID) |
| :--- | :--- |
| **Berat Alkan** | `10616550172` |
| **Kenan Toprak** | `12779293774` |

---

A Flutter application allowing users to view and control smart home devices (**Smart Light**, **Thermostat**, and **Smart Speaker**), built around Dart Object-Oriented Programming principles.

## Implemented OOP Concepts & Dart Features

| Concept | Implementation Details |
| :--- | :--- |
| **Class** | Base class `SmartDevice` (`lib/models/smart_device.dart`) and subclasses `SmartLight` (`lib/models/smart_light.dart`), `Thermostat` (`lib/models/thermostat.dart`), and `SmartSpeaker` (`lib/models/smart_speaker.dart`). |
| **Objects** | Multiple device instances (6 initial devices across all three subclasses, plus dynamic creation via the `+` button in the AppBar). |
| **Constructor** | Uses both **default constructors** (`SmartLight(...)`, `Thermostat(...)`, `SmartSpeaker(...)`) and **named constructors** (`SmartLight.dimmed(...)`, `SmartLight.off(...)`, `Thermostat.ecoMode(...)`, `Thermostat.comfort(...)`, `SmartSpeaker.playing(...)`, `SmartSpeaker.quiet(...)`, `SmartDevice.offline(...)`). |
| **Inheritance** | `SmartLight`, `Thermostat`, and `SmartSpeaker` all `extends SmartDevice`. |
| **Abstraction** | `SmartDevice` is an `abstract class` defining abstract methods `getStatus()`, `performAction()`, `getPropertyText()`, and `deviceCategory`. |
| **Interface** | `abstract interface class Connectable` (`lib/models/connectable.dart`) defining `connect()`, `disconnect()`, `toggleConnection()`, and `getConnectionStatus()`, implemented by the device classes. |
| **Mixin** | `mixin Schedulable on SmartDevice` (`lib/models/schedulable.dart`) providing `setSchedule()`, `clearSchedule()`, and `getScheduleInfo()`, mixed into `SmartLight` and `Thermostat` via `with Schedulable`. |
| **Keywords** | **`static`**: `SmartDevice.totalDevices` counter displayed at the bottom of the screen (`Total Devices: X`) and static min/max bounds.<br>**`super`**: Subclass constructor chaining (`super.name`, `: super(...)`) and base method invocation (`super.getDeviceSummary()`).<br>**`this`**: Initializing formals (`this.name`, `this.isOn`, `this.isPlaying`), constructor redirection (`: this(...)`), and field/parameter disambiguation (`this.brightness`, `this.temperature`, `this.volume`, `this.scheduledTime`). |

## Running the Project

```bash
flutter pub get
flutter run
```
