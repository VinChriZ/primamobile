import 'package:primamobile/app/models/models.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:primamobile/repository/user_session_repository.dart';

class Globals {
  static late SharedPreferences preferences;
  static late PackageInfo packageInfo;
  static late DeviceInfo deviceInfo;
  static late UserSession userSession;

  static Future<void> init() async {
    try {
      preferences = await SharedPreferences.getInstance();
      packageInfo = await PackageInfo.fromPlatform();
      deviceInfo = await DeviceInfo.fromPlatform();
      userSession = await UserSessionRepository().getUserSession();
      print('Initialized UserSession IsLogin: ${userSession.isLogin}');
    } catch (e) {
      print('Error initializing Globals: $e');
      userSession = UserSession(); // Fallback to default session
    }
  }
}
