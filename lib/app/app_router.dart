import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';
import 'package:primamobile/app/pages.dart';

class AppRouterMissingArgumentException implements Exception {
  final String message = "Missing route parameters.";
  @override
  String toString() {
    return "Exception: $message";
  }
}

class AppRouter {
  final AuthenticationBloc authenticationBloc;

  AppRouter({required this.authenticationBloc});

  Route<dynamic> onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authenticationBloc,
            child: const LoginPage(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
