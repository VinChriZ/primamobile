import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/app_router.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';
import 'package:primamobile/repository/login_repository.dart';
import 'package:primamobile/repository/user_session_repository.dart';
import 'package:primamobile/repository/user_repository.dart';
import 'package:primamobile/repository/product_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Create instances of repositories
    final loginRepository = LoginRepository();
    final userSessionRepository = UserSessionRepository();
    final userRepository = UserRepository(); // Added UserRepository
    final productRepository = ProductRepository(); // Added ProductRepository

    // Create an instance of AuthenticationBloc with dependencies
    final authenticationBloc = AuthenticationBloc(
      loginRepository: loginRepository,
      userSessionRepository: userSessionRepository,
    )..add(AppStarted());

    // Pass dependencies to AppRouter
    final appRouter = AppRouter(
      authenticationBloc: authenticationBloc,
      userRepository: userRepository,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: loginRepository),
        RepositoryProvider.value(value: userSessionRepository),
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: productRepository),
      ],
      child: BlocProvider.value(
        value: authenticationBloc,
        child: MaterialApp(
          title: 'PrimaMobile',
          theme: ThemeData(
            brightness: Brightness.light,
            fontFamily: 'Montserrat',
          ),
          initialRoute: '/',
          onGenerateRoute: appRouter.onGenerateRoutes,
          debugShowCheckedModeBanner: false,

          // Device Preview
          builder: DevicePreview.appBuilder,
          locale: DevicePreview.locale(context),
        ),
      ),
    );
  }
}
