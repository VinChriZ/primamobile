import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:primamobile/utils/extensions.dart';

class StoragePermissionHelper {
  static Future<Permission> get _permission async {
    Permission platformPermission = Permission.unknown;

    if (Platform.isAndroid) {
      final androidSdkVersion =
          (await DeviceInfoPlugin().androidInfo).version.sdkInt;

      if (androidSdkVersion > 32) {
        platformPermission = Permission.photos;
      } else if (androidSdkVersion >= 29) {
        platformPermission = Permission.manageExternalStorage;
      } else {
        platformPermission = Permission.storage;
      }
    } else if (Platform.isIOS) {
      platformPermission = Permission.photos;
    }

    return platformPermission;
  }

  static Future<PermissionStatus> get status async {
    PermissionStatus status = PermissionStatus.denied;

    if (Platform.isAndroid || Platform.isIOS) {
      status = await (await _permission).status;
    }

    return status;
  }

  static Future<bool> get isGranted async =>
      await (await _permission).isGranted;
  static Future<bool> get isDenied async => await (await _permission).isDenied;
  static Future<bool> get isPermanentlyDenied async =>
      await (await _permission).isPermanentlyDenied;

  static Future<bool> request(
      {PermissionStatus targetStatus = PermissionStatus.granted}) async {
    if (!(await status).isEqual(targetStatus)) {
      await (await _permission).request();
    }

    return (await status).isEqual(targetStatus);
  }
}

class LocationPermissionHelper {
  static Future<PermissionStatus> get status async =>
      await Permission.location.status;
  static Future<bool> get isGranted async =>
      await Permission.location.isGranted;
  static Future<bool> get isDenied async => await Permission.location.isDenied;
  static Future<bool> get isPermanentlyDenied async =>
      await Permission.location.isPermanentlyDenied;
  static Future<bool> get isWhenInUse async =>
      await Permission.locationWhenInUse.isGranted;
  static Future<bool> get isAlways async =>
      await Permission.locationAlways.isGranted;

  static Future<bool> request(
      {PermissionStatus targetStatus = PermissionStatus.granted}) async {
    if (!(await status).isEqual(targetStatus)) {
      if (await isPermanentlyDenied) {
        openAppSettings();
      } else {
        await Permission.location.request();
      }
    }

    return (await status).isEqual(targetStatus);
  }

  static Future<bool> requestAlways() async {
    if (!await Permission.locationAlways.isGranted) {
      if (await isPermanentlyDenied) {
        openAppSettings();
      } else {
        await Permission.locationAlways.request();
      }
    }

    return await isAlways;
  }

  static Future<bool> requestWhenInUse() async {
    if (!await Permission.locationWhenInUse.isGranted) {
      await Permission.locationWhenInUse.request();
    }

    return await isWhenInUse;
  }
}

class NotificationPermissionHelper {
  static Future<PermissionStatus> get status async =>
      await Permission.notification.status;

  static Future<bool> get isGranted async =>
      await Permission.notification.isGranted;
  static Future<bool> get isDenied async =>
      await Permission.notification.isDenied;
  static Future<bool> get isPermanentlyDenied async =>
      await Permission.notification.isPermanentlyDenied;

  static Future<bool> request(
      {PermissionStatus targetStatus = PermissionStatus.granted}) async {
    if (!(await status).isEqual(targetStatus)) {
      await Permission.notification.request();
    }

    return (await status).isEqual(targetStatus);
  }
}

class CameraPermissionHelper {
  static Future<PermissionStatus> get status async =>
      await Permission.camera.status;

  static Future<bool> get isGranted async => await Permission.camera.isGranted;
  static Future<bool> get isDenied async => await Permission.camera.isDenied;
  static Future<bool> get isPermanentlyDenied async =>
      await Permission.camera.isPermanentlyDenied;

  static Future<bool> request(
      {PermissionStatus targetStatus = PermissionStatus.granted}) async {
    if (!(await status).isEqual(targetStatus)) {
      await Permission.camera.request();
    }

    return (await status).isEqual(targetStatus);
  }
}

class BluetoothPermissionHelper {
  static Future<List<Permission>> _getBluetoothPermissions() async {
    List<Permission> permissions = [];

    if (Platform.isAndroid) {
      // For Android 12+ (API 31+), we need BLUETOOTH_CONNECT and BLUETOOTH_SCAN
      permissions.add(Permission.bluetoothConnect);
      permissions.add(Permission.bluetoothScan);
      // Location is often needed for Bluetooth discovery
      permissions.add(Permission.location);
    } else if (Platform.isIOS) {
      permissions.add(Permission.bluetooth);
    }

    return permissions;
  }

  static Future<Map<Permission, PermissionStatus>> getStatus() async {
    final permissions = await _getBluetoothPermissions();
    Map<Permission, PermissionStatus> statuses = {};

    for (var permission in permissions) {
      statuses[permission] = await permission.status;
    }

    return statuses;
  }

  static Future<bool> get isGranted async {
    final statuses = await getStatus();
    return !statuses.values
        .any((status) => status.isDenied || status.isPermanentlyDenied);
  }

  static Future<bool> get isDenied async {
    final statuses = await getStatus();
    return statuses.values.any((status) => status.isDenied);
  }

  static Future<bool> get isPermanentlyDenied async {
    final statuses = await getStatus();
    return statuses.values.any((status) => status.isPermanentlyDenied);
  }

  static Future<bool> request() async {
    final permissions = await _getBluetoothPermissions();

    // Request all needed permissions
    for (var permission in permissions) {
      await permission.request();
    }

    // Check if all permissions are granted
    return await isGranted;
  }
}
