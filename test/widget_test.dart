import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_home_controller/main.dart';
import 'package:smart_home_controller/models/connectable.dart';
import 'package:smart_home_controller/models/schedulable.dart';
import 'package:smart_home_controller/models/smart_device.dart';
import 'package:smart_home_controller/models/smart_light.dart';
import 'package:smart_home_controller/models/smart_speaker.dart';
import 'package:smart_home_controller/models/thermostat.dart';

void main() {
  setUp(() {
    SmartDevice.totalDevices = 0;
  });

  group('OOP & Dart Language Feature Tests', () {
    test('Static totalDevices increments across default and named constructors', () {
      expect(SmartDevice.totalDevices, 0);

      final light1 = SmartLight('Smart Light: Living Room', brightness: 80);
      final light2 = SmartLight.off('Hallway');
      final thermostat1 = Thermostat('Thermostat: Bedroom', temperature: 23);
      final thermostat2 = Thermostat.ecoMode('Guest Room');
      final speaker1 = SmartSpeaker('Smart Speaker: Office', volume: 30);
      final speaker2 = SmartSpeaker.playing('Kitchen', volume: 55);

      expect(SmartDevice.totalDevices, 6);
      expect(light1, isA<SmartDevice>());
      expect(light2, isA<Connectable>());
      expect(light1, isA<Schedulable>());
      expect(thermostat1, isA<Schedulable>());
      expect(thermostat2.getStatus(), 'Eco Idle');
      expect(speaker1.getStatus(), 'Paused');
      expect(speaker2.getStatus(), 'Playing');
    });

    test('Connectable interface and Schedulable mixin work properly', () {
      final light = SmartLight.dimmed('Bedroom', brightness: 45);
      expect(light.isConnected, isTrue);
      expect(light.getStatus(), 'ON');
      expect(light.hasSchedule, isFalse);

      light.setSchedule('23:00');
      expect(light.hasSchedule, isTrue);
      expect(light.getScheduleInfo(), 'At 23:00');

      light.disconnect();
      expect(light.isConnected, isFalse);
      expect(light.getStatus(), 'Offline');

      light.connect();
      expect(light.getStatus(), 'ON');

      light.clearSchedule();
      expect(light.hasSchedule, isFalse);
    });

    test('Device actions and super summary work properly', () {
      final light = SmartLight('Smart Light: Desk', brightness: 60);
      expect(light.getPropertyText(), 'Brightness: 60%');
      light.performAction();
      expect(light.getStatus(), 'OFF');
      expect(light.getPropertyText(), 'Brightness: 0%');
      light.performAction();
      expect(light.getStatus(), 'ON');
      expect(light.getPropertyText(), 'Brightness: 60%');

      final thermostat = Thermostat('Thermostat: Lounge', temperature: 21);
      expect(thermostat.getStatus(), 'Eco Idle');
      thermostat.increaseTemperature();
      expect(thermostat.temperature, 22);
      expect(thermostat.getStatus(), 'Heating');
      expect(thermostat.getDeviceSummary(), contains('Connected'));

      final speaker = SmartSpeaker.quiet('Study');
      expect(speaker.getStatus(), 'Paused');
      speaker.performAction();
      expect(speaker.getStatus(), 'Playing');
    });
  });

  group('Smart Home Controller UI Tests', () {
    testWidgets('Renders devices, static counter, and responds to interactions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const SmartHomeControllerApp());

      // AppBar title & Bottom static device counter
      expect(find.text('Smart Home Controller'), findsOneWidget);
      expect(find.text('Total Devices: 6'), findsOneWidget);

      // Visible initial device cards
      expect(find.text('Smart Light: Living Room'), findsOneWidget);
      expect(find.text('Brightness: 75%'), findsOneWidget);
      expect(find.text('Smart Light: Kitchen'), findsOneWidget);
      expect(find.text('Thermostat: Bedroom'), findsOneWidget);

      // Toggle the first SmartLight switch OFF
      final firstSwitch = find.byType(Switch).first;
      await tester.tap(firstSwitch);
      await tester.pumpAndSettle();

      expect(find.text('Brightness: 0%'), findsOneWidget);
      expect(find.text('Status: OFF'), findsOneWidget);

      // Scroll down to verify SmartSpeaker instances
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Smart Speaker: Kitchen'), findsOneWidget);
      expect(find.text('Smart Speaker: Office'), findsOneWidget);
    });
  });
}
