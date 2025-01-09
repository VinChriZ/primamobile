import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';
import 'package:primamobile/app/pages.dart';
import 'package:primamobile/repository/user_repository.dart';
import 'package:primamobile/utils/globals.dart';

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

      case '/home':
        return MaterialPageRoute(
          builder: (_) {
            final authState = authenticationBloc.state;

            if (authState is AuthenticationAuthenticated) {
              return FutureBuilder(
                future: UserRepository().fetchAndUpdateUserDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return const Scaffold(
                      body: Center(child: Text('Error loading user data')),
                    );
                  } else {
                    final int roleId = Globals.userSession.user.roleId;
                    switch (roleId) {
                      case 1:
                        return const Placeholder(
                            child: Text('Admin')); // Admin Page
                      case 2:
                        return BlocProvider.value(
                          value: authenticationBloc, // Pass AuthenticationBloc
                          child: const OwnerHomePage(),
                        ); // Navigate to Owner Page
                      case 3:
                        return const Placeholder(); // Worker Page
                      default:
                        return const Placeholder(); // Fallback for unknown role
                    }
                  }
                },
              );
            } else {
              return const LoginPage(); // Redirect to Login if unauthenticated
            }
          },
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
