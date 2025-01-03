import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class DirectoryHelper {
  static Future<String?> get downloadDirectory async {
    Directory? directory;
    String? path;

    try {
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        path = directory?.path;
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
        path = directory.absolute.path;
      } else {
        directory = await getApplicationDocumentsDirectory();
        path = directory.absolute.path;
      }
    } catch (e) {
      path = null;
    }

    return path;
  }

  static Future<bool> get usePublicStorage async {
    late bool canAccessPublicStorage;

    if (Platform.isAndroid) {
      int androidSdkVersion = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      if (androidSdkVersion < 29) {
        canAccessPublicStorage = false;
      } else {
        canAccessPublicStorage = true;
      }
    } else if (Platform.isIOS) {
      canAccessPublicStorage = false;
    } else {
      canAccessPublicStorage = false;
    }

    return canAccessPublicStorage;
  }
}
