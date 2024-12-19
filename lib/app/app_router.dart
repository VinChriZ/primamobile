import 'package:flutter/material.dart';
import 'package:primamobile/app/pages/splashscreen/splash_screen.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mynpti_mv/app/bloc/authentication_bloc.dart';
import 'package:primamobile/app/pages.dart';

class AppRouterMissingArgumentException implements Exception {
  final String message = "Missing route parameters.";
  @override
  String toString() {
    return "Exception: $message";
  }
}

class AppRouter {
  static Route<dynamic> onGenerateRoutes(RouteSettings settings) {
    // AuthenticationBloc authenticationBloc = AuthenticationBloc()
    //   ..add(AppStarted());
    switch (settings.name) {
      case '/':
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      // case '/login':
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider.value(
      //       value: authenticationBloc,
      //       child: const LoginPage(),
      //     ),
      //   );
      // case '/home':
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider.value(
      //       value: authenticationBloc,
      //       child: const HomePage(),
      //     ),
      //   );
      // case '/account':
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider.value(
      //       value: authenticationBloc,
      //       child: const AccountPage(),
      //     ),
      //   );
      // case '/profile':
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider.value(
      //       value: authenticationBloc,
      //       child: const ProfilePage(),
      //     ),
      //   );
      // case '/settings':
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider.value(
      //       value: authenticationBloc,
      //       child: const SettingsPage(),
      //     ),
      //   );
      // case '/change_password':
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider.value(
      //       value: authenticationBloc,
      //       child: const ChangePasswordPage(),
      //     ),
      //   );
      // case '/shift':
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider.value(
      //       value: authenticationBloc,
      //       child: const ShiftPage(),
      //     ),
      //   );
      // case '/shift_calendar':
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider.value(
      //       value: authenticationBloc,
      //       child: const ShiftCalendarPage(),
      //     ),
      //   );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
