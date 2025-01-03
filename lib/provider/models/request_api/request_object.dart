import 'package:primamobile/app/models/device_info/device_info.dart';
import 'package:primamobile/provider/models/request_api/request_api.dart';
// import 'package:primamobile/utils/globals.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class RequestObject {
  late final RequestParam requestParam;

  Future<Map<String, dynamic>> toJson() async {
    // Get the device information
    final DeviceInfo deviceInfo = await DeviceInfo.fromPlatform();

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // Correct assignment of version and build number
    final String devicePlatform =
        deviceInfo.deviceOS.toPlatform().toUpperCase();
    final String deviceName =
        '${deviceInfo.deviceName}-${deviceInfo.deviceVersion}';
    final String appVersion = packageInfo.version;
    final String appBuildNumber = packageInfo.buildNumber;
    final String deviceSession = deviceInfo.deviceId;

    return <String, dynamic>{
      'device_platform': devicePlatform,
      'device_name': deviceName,
      'app_version': appVersion,
      'app_buildnumber': appBuildNumber,
      'device_session': deviceSession,
      ...requestParam.toJson(),
    };
  }
}

class RequestObjectGET extends RequestObject {
  RequestObjectGET({RequestParam? requestParam}) {
    this.requestParam = requestParam ?? RequestParam();
  }
}
