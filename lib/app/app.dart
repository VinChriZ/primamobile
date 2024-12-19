import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:primamobile/app/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'myNPTI',
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Montserrat',
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
      ),
      initialRoute: '/',
      onGenerateRoute: AppRouter.onGenerateRoutes,
      debugShowCheckedModeBanner: false,

      //Device Preview
      builder: DevicePreview.appBuilder,
      // useInheritedMediaQuery: true, //-
      locale: DevicePreview.locale(context), //-
    );
  }
}
