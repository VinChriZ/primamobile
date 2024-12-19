// import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:primamobile/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black, // Status bar color
    statusBarIconBrightness: Brightness.light, // Status bar icon brightness
  ));

  // Lock the device orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const App());

  //Device Preview Run
  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => const App(),
  //   ),
  // );
}
