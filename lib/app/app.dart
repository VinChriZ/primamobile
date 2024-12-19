import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/app_router.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Create an instance of AuthenticationBloc
    final authenticationBloc = AuthenticationBloc()..add(AppStarted());

    // Pass the AuthenticationBloc to AppRouter
    final appRouter = AppRouter(authenticationBloc: authenticationBloc);

    return BlocProvider.value(
      value: authenticationBloc,
      child: MaterialApp(
        title: 'myNPTI',
        theme: ThemeData(
          brightness: Brightness.light,
          fontFamily: 'Montserrat',
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
        ),
        initialRoute: '/',
        onGenerateRoute: appRouter.onGenerateRoutes, // Use the instance
        debugShowCheckedModeBanner: false,

        // Device Preview
        builder: DevicePreview.appBuilder,
        locale: DevicePreview.locale(context),
      ),
    );
  }
}
