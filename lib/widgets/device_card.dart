import 'package:flutter/material.dart';

import '../models/schedulable.dart';
import '../models/smart_device.dart';
import '../models/smart_light.dart';
import '../models/smart_speaker.dart';
import '../models/thermostat.dart';

/// Polymorphic card widget displaying information and controls for any [SmartDevice].
class DeviceCard extends StatelessWidget {
  final SmartDevice device;
  final VoidCallback onChanged;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final visual = _resolveVisualStyle(device);
    final isConnected = device.isConnected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFCBD5E1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Device Icon Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: visual.iconBackground,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    visual.icon,
                    color: visual.iconColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 13),

                // Device Name, Relevant Property, and Current Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: isConnected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        device.getPropertyText(),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: visual.statusDotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Status: ${device.getStatus()}',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: visual.statusTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Primary Device-Specific Action Control
                _buildPrimaryControl(context),
              ],
            ),

            // Optional slider for continuous brightness or volume adjustment
            if (isConnected && (device is SmartLight || device is SmartSpeaker))
              _buildSliderRow(),

            const SizedBox(height: 8),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),

            // Footer pills demonstrating Connectable interface & Schedulable mixin
            Row(
              children: [
                _ActionPill(
                  icon: isConnected
                      ? Icons.wifi_rounded
                      : Icons.wifi_off_rounded,
                  label: device.getConnectionStatus(),
                  activeColor: const Color(0xFF16A34A),
                  isActive: isConnected,
                  onTap: () {
                    device.toggleConnection();
                    onChanged();
                  },
                ),
                if (device is Schedulable) ...[
                  const SizedBox(width: 8),
                  _buildSchedulePill(context, device as Schedulable),
                ],
                const Spacer(),
                Text(
                  device.deviceCategory,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the primary device-specific control (Switch, -/+ Temp, Play/Pause).
  Widget _buildPrimaryControl(BuildContext context) {
    final isConnected = device.isConnected;

    if (device is SmartLight) {
      final light = device as SmartLight;
      return Switch.adaptive(
        value: isConnected && light.isOn,
        activeTrackColor: const Color(0xFF2563EB),
        activeThumbColor: Colors.white,
        onChanged: isConnected
            ? (value) {
                light.setPower(value);
                onChanged();
              }
            : null,
      );
    }

    if (device is Thermostat) {
      final thermostat = device as Thermostat;
      final canDecrease =
          isConnected && thermostat.temperature > Thermostat.minTemperature;
      final canIncrease =
          isConnected && thermostat.temperature < Thermostat.maxTemperature;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleStepButton(
            icon: Icons.remove_rounded,
            tooltip: 'Decrease temperature',
            onPressed: canDecrease
                ? () {
                    thermostat.decreaseTemperature();
                    onChanged();
                  }
                : null,
          ),
          const SizedBox(width: 8),
          _CircleStepButton(
            icon: Icons.add_rounded,
            tooltip: 'Increase temperature',
            onPressed: canIncrease
                ? () {
                    thermostat.increaseTemperature();
                    onChanged();
                  }
                : null,
          ),
        ],
      );
    }

    if (device is SmartSpeaker) {
      final speaker = device as SmartSpeaker;
      return Material(
        color: isConnected
            ? const Color(0xFF2563EB)
            : const Color(0xFFCBD5E1),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isConnected
              ? () {
                  speaker.performAction();
                  onChanged();
                }
              : null,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              speaker.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: isConnected
          ? () {
              device.performAction();
              onChanged();
            }
          : null,
      icon: const Icon(Icons.power_settings_new_rounded),
    );
  }

  /// Compact slider row for adjusting SmartLight brightness or SmartSpeaker volume.
  Widget _buildSliderRow() {
    if (device is SmartLight) {
      final light = device as SmartLight;
      final value = (light.isOn ? light.brightness : 0).toDouble();
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            const Icon(
              Icons.brightness_low_rounded,
              size: 16,
              color: Color(0xFF94A3B8),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3.5,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                  activeTrackColor: const Color(0xFFF59E0B),
                  inactiveTrackColor: const Color(0xFFE2E8F0),
                  thumbColor: const Color(0xFFF59E0B),
                ),
                child: Slider(
                  value: value,
                  min: SmartLight.minBrightness.toDouble(),
                  max: SmartLight.maxBrightness.toDouble(),
                  onChanged: (newValue) {
                    light.setBrightness(newValue.round());
                    onChanged();
                  },
                ),
              ),
            ),
            const Icon(
              Icons.brightness_high_rounded,
              size: 16,
              color: Color(0xFFF59E0B),
            ),
          ],
        ),
      );
    }

    if (device is SmartSpeaker) {
      final speaker = device as SmartSpeaker;
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            const Icon(
              Icons.volume_down_rounded,
              size: 17,
              color: Color(0xFF94A3B8),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3.5,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                  activeTrackColor: const Color(0xFF2563EB),
                  inactiveTrackColor: const Color(0xFFE2E8F0),
                  thumbColor: const Color(0xFF2563EB),
                ),
                child: Slider(
                  value: speaker.volume.toDouble(),
                  min: SmartSpeaker.minVolume.toDouble(),
                  max: SmartSpeaker.maxVolume.toDouble(),
                  onChanged: (newValue) {
                    speaker.setVolume(newValue.round());
                    onChanged();
                  },
                ),
              ),
            ),
            const Icon(
              Icons.volume_up_rounded,
              size: 17,
              color: Color(0xFF2563EB),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Interactive schedule pill demonstrating the [Schedulable] mixin.
  Widget _buildSchedulePill(BuildContext context, Schedulable schedulable) {
    return _ActionPill(
      icon: Icons.schedule_rounded,
      label: schedulable.getScheduleInfo(),
      activeColor: const Color(0xFF2563EB),
      isActive: schedulable.hasSchedule,
      onTap: () => _handleScheduleTap(context, schedulable),
    );
  }

  Future<void> _handleScheduleTap(
    BuildContext context,
    Schedulable schedulable,
  ) async {
    if (schedulable.hasSchedule) {
      final action = await showModalBottomSheet<String>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${device.name} (${schedulable.getScheduleInfo()})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.edit_calendar_rounded,
                    color: Color(0xFF2563EB),
                  ),
                  title: const Text('Change Scheduled Time'),
                  onTap: () => Navigator.pop(sheetContext, 'edit'),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFDC2626),
                  ),
                  title: const Text('Clear Schedule'),
                  onTap: () => Navigator.pop(sheetContext, 'clear'),
                ),
              ],
            ),
          ),
        ),
      );

      if (action == 'clear') {
        schedulable.clearSchedule();
        onChanged();
        return;
      }
      if (action != 'edit' || !context.mounted) return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 22, minute: 0),
    );

    if (picked != null) {
      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      schedulable.setSchedule('$hh:$mm');
      onChanged();
    }
  }

  _DeviceVisualStyle _resolveVisualStyle(SmartDevice device) {
    if (!device.isConnected) {
      return const _DeviceVisualStyle(
        icon: Icons.cloud_off_rounded,
        iconColor: Color(0xFF94A3B8),
        iconBackground: Color(0xFFF1F5F9),
        statusDotColor: Color(0xFFEF4444),
        statusTextColor: Color(0xFFDC2626),
      );
    }

    if (device is SmartLight) {
      if (device.isOn) {
        return const _DeviceVisualStyle(
          icon: Icons.lightbulb_rounded,
          iconColor: Color(0xFFF59E0B),
          iconBackground: Color(0xFFFEF3C7),
          statusDotColor: Color(0xFF16A34A),
          statusTextColor: Color(0xFF15803D),
        );
      }
      return const _DeviceVisualStyle(
        icon: Icons.lightbulb_outline_rounded,
        iconColor: Color(0xFF64748B),
        iconBackground: Color(0xFFF1F5F9),
        statusDotColor: Color(0xFF94A3B8),
        statusTextColor: Color(0xFF64748B),
      );
    }

    if (device is Thermostat) {
      final status = device.getStatus();
      if (status == 'Heating') {
        return const _DeviceVisualStyle(
          icon: Icons.thermostat_rounded,
          iconColor: Color(0xFFEA580C),
          iconBackground: Color(0xFFFFEDD5),
          statusDotColor: Color(0xFF16A34A),
          statusTextColor: Color(0xFF475569),
        );
      } else if (status == 'Cooling') {
        return const _DeviceVisualStyle(
          icon: Icons.ac_unit_rounded,
          iconColor: Color(0xFF0284C7),
          iconBackground: Color(0xFFE0F2FE),
          statusDotColor: Color(0xFF0284C7),
          statusTextColor: Color(0xFF0369A1),
        );
      }
      return const _DeviceVisualStyle(
        icon: Icons.thermostat_auto_rounded,
        iconColor: Color(0xFF059669),
        iconBackground: Color(0xFFD1FAE5),
        statusDotColor: Color(0xFF10B981),
        statusTextColor: Color(0xFF047857),
      );
    }

    if (device is SmartSpeaker) {
      if (device.isPlaying) {
        return const _DeviceVisualStyle(
          icon: Icons.speaker_rounded,
          iconColor: Color(0xFF2563EB),
          iconBackground: Color(0xFFDBEAFE),
          statusDotColor: Color(0xFF16A34A),
          statusTextColor: Color(0xFF15803D),
        );
      }
      return const _DeviceVisualStyle(
        icon: Icons.speaker_outlined,
        iconColor: Color(0xFF64748B),
        iconBackground: Color(0xFFF1F5F9),
        statusDotColor: Color(0xFF94A3B8),
        statusTextColor: Color(0xFF64748B),
      );
    }

    return const _DeviceVisualStyle(
      icon: Icons.devices_other_rounded,
      iconColor: Color(0xFF475569),
      iconBackground: Color(0xFFF1F5F9),
      statusDotColor: Color(0xFF64748B),
      statusTextColor: Color(0xFF475569),
    );
  }
}

class _DeviceVisualStyle {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color statusDotColor;
  final Color statusTextColor;

  const _DeviceVisualStyle({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.statusDotColor,
    required this.statusTextColor,
  });
}

class _CircleStepButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _CircleStepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(
          side: BorderSide(
            color: enabled
                ? const Color(0xFF94A3B8)
                : const Color(0xFFE2E8F0),
            width: 1.3,
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              icon,
              size: 18,
              color: enabled
                  ? const Color(0xFF334155)
                  : const Color(0xFFCBD5E1),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color activeColor;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isActive ? activeColor : const Color(0xFF64748B);
    final bg = isActive
        ? activeColor.withValues(alpha: 0.10)
        : const Color(0xFFF1F5F9);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13.5, color: fg),
              const SizedBox(width: 4.5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

