// import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:primamobile/app/app.dart';
import 'package:primamobile/utils/globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black, // Status bar color
    statusBarIconBrightness: Brightness.light, // Status bar icon brightness
  ));

  // Lock the device orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize global settings
  await Globals.init();

  runApp(const App());

  //Device Preview Run
  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => const App(),
  //   ),
  // );
}
