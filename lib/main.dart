import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:primamobile/app/app.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black, // Status bar color
    statusBarIconBrightness: Brightness.light, // Status bar icon brightness
  ));

  // Lock the device orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const App());
}
