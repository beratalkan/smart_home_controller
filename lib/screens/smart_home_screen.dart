import 'package:flutter/material.dart';

import '../models/smart_device.dart';
import '../models/smart_light.dart';
import '../models/smart_speaker.dart';
import '../models/thermostat.dart';
import '../widgets/device_card.dart';

/// Main controller screen displaying smart home device cards and static counter.
class SmartHomeScreen extends StatefulWidget {
  const SmartHomeScreen({super.key});

  @override
  State<SmartHomeScreen> createState() => _SmartHomeScreenState();
}

class _SmartHomeScreenState extends State<SmartHomeScreen> {
  late final List<SmartDevice> _devices;

  @override
  void initState() {
    super.initState();
    // Create multiple device instances using BOTH default and named constructors
    // across all three SmartDevice subclasses:
    _devices = [
      // 1. SmartLight - Default constructor
      SmartLight(
        'Smart Light: Living Room',
        brightness: 75,
        isOn: true,
        initialSchedule: '22:30',
      ),
      // 2. SmartLight - Named constructor
      SmartLight.dimmed('Kitchen', brightness: 50),
      // 3. Thermostat - Default constructor
      Thermostat(
        'Thermostat: Bedroom',
        temperature: 24,
        initialSchedule: '07:00',
      ),
      // 4. Thermostat - Named constructor
      Thermostat.ecoMode('Guest Room'),
      // 5. SmartSpeaker - Named constructor
      SmartSpeaker.playing('Kitchen', volume: 40),
      // 6. SmartSpeaker - Default constructor
      SmartSpeaker(
        'Smart Speaker: Office',
        volume: 25,
        isPlaying: false,
      ),
    ];
  }

  int get _connectedCount => _devices.where((d) => d.isConnected).length;

  void _openAddDeviceSheet() {
    String selectedType = 'SmartLight';
    bool useNamedConstructor = false;
    final roomController = TextEditingController(text: 'Balcony');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_home_rounded,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Add New Smart Device',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Device Subclass',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'SmartLight',
                        label: Text('Light'),
                        icon: Icon(Icons.lightbulb_outline_rounded, size: 18),
                      ),
                      ButtonSegment(
                        value: 'Thermostat',
                        label: Text('Thermostat'),
                        icon: Icon(Icons.thermostat_rounded, size: 18),
                      ),
                      ButtonSegment(
                        value: 'SmartSpeaker',
                        label: Text('Speaker'),
                        icon: Icon(Icons.speaker_outlined, size: 18),
                      ),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (selection) {
                      setSheetState(() {
                        selectedType = selection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: roomController,
                    decoration: InputDecoration(
                      labelText: 'Room / Location Name',
                      hintText: 'e.g., Balcony, Hallway, Garage',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Use Named Constructor Preset',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _constructorPreviewLabel(
                        selectedType,
                        useNamedConstructor,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    value: useNamedConstructor,
                    onChanged: (value) {
                      setSheetState(() {
                        useNamedConstructor = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final room = roomController.text.trim().isEmpty
                            ? 'Room ${SmartDevice.totalDevices + 1}'
                            : roomController.text.trim();

                        final SmartDevice created = _instantiateDevice(
                          selectedType: selectedType,
                          room: room,
                          useNamedConstructor: useNamedConstructor,
                        );

                        setState(() {
                          _devices.add(created);
                        });
                        Navigator.pop(sheetContext);
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'Create Device Instance',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _constructorPreviewLabel(String type, bool useNamed) {
    if (!useNamed) {
      return 'Calls default constructor: $type(...)';
    }
    switch (type) {
      case 'SmartLight':
        return 'Calls named constructor: SmartLight.off(...)';
      case 'Thermostat':
        return 'Calls named constructor: Thermostat.comfort(...)';
      default:
        return 'Calls named constructor: SmartSpeaker.quiet(...)';
    }
  }

  SmartDevice _instantiateDevice({
    required String selectedType,
    required String room,
    required bool useNamedConstructor,
  }) {
    switch (selectedType) {
      case 'SmartLight':
        return useNamedConstructor
            ? SmartLight.off(room)
            : SmartLight('Smart Light: $room', brightness: 80, isOn: true);
      case 'Thermostat':
        return useNamedConstructor
            ? Thermostat.comfort(room, temperature: 24)
            : Thermostat('Thermostat: $room', temperature: 22);
      default:
        return useNamedConstructor
            ? SmartSpeaker.quiet(room)
            : SmartSpeaker(
                'Smart Speaker: $room',
                volume: 50,
                isPlaying: false,
              );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E5BB8),
        foregroundColor: Colors.white,
        title: const Text(
          'Smart Home Controller',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Device',
            onPressed: _openAddDeviceSheet,
            icon: const Icon(Icons.add_circle_outline_rounded, size: 25),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        itemCount: _devices.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final device = _devices[index];
          return DeviceCard(
            device: device,
            onChanged: () => setState(() {}),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bottom Text requirement:
                // Displays the total number of created devices directly from
                // the static variable SmartDevice.totalDevices.
                Text(
                  'Total Devices: ${SmartDevice.totalDevices}',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.hub_rounded,
                        size: 14,
                        color: Color(0xFF1D4ED8),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Online: $_connectedCount/${_devices.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

