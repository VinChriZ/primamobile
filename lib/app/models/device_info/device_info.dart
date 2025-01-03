import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:primamobile/utils/globals.dart';

enum DeviceOS { unknown, android, ios }

extension DeviceOSExtension on DeviceOS {
  String toPlatform() => toString().split('.').last.toUpperCase();
}

class DeviceInfo {
  late final String _deviceId;
  final DeviceOS deviceOS;
  final String deviceVersion;
  final String deviceName;
  final bool isPhysical;

  String get deviceId => _deviceId;

  DeviceInfo({
    required String deviceId,
    this.deviceOS = DeviceOS.unknown,
    this.deviceVersion = '-',
    this.deviceName = '-',
    this.isPhysical = false,
  }) {
    _deviceId = deviceId;
  }

  static Future<DeviceInfo> fromPlatform() async {
    DeviceInfo deviceInfo;
    final String deviceId = Globals.preferences.getString('device_id') ??
        DateTime.now().microsecondsSinceEpoch.toString();

    if (!kIsWeb && Platform.isAndroid) {
      AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      final String? deviceIdAlt = await const AndroidId().getId();

      deviceInfo = DeviceInfo(
        deviceId: deviceIdAlt ?? deviceId,
        deviceOS: DeviceOS.android,
        deviceVersion: info.version.release,
        deviceName: '${info.manufacturer}-${info.model}',
        isPhysical: info.isPhysicalDevice,
      );
    } else if (!kIsWeb && Platform.isIOS) {
      IosDeviceInfo info = await DeviceInfoPlugin().iosInfo;

      deviceInfo = DeviceInfo(
        deviceId: deviceId,
        deviceOS: DeviceOS.ios,
        deviceVersion: info.systemVersion,
        deviceName: '${info.systemName}-${info.name}',
        isPhysical: info.isPhysicalDevice,
      );
    } else {
      deviceInfo = DeviceInfo(
        deviceId: deviceId,
      );
    }

    Globals.preferences.setString('device_id', deviceId);

    return deviceInfo;
  }

  @override
  String toString() {
    return '${deviceOS.toPlatform()}-$deviceName';
  }
}
