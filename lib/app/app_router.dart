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
              // Use FutureBuilder to fetch user details
              return FutureBuilder(
                future: UserRepository().fetchAndUpdateUserDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading spinner while fetching user details
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    // Show an error message if fetching fails
                    return const Scaffold(
                      body: Center(child: Text('Error loading user data')),
                    );
                  } else {
                    // Fetch the role ID from the updated UserSession
                    final int roleId = Globals.userSession.user.roleId;

                    // Navigate based on role ID
                    switch (roleId) {
                      case 1:
                        return const Placeholder(
                          child: Text('Admin'),
                        ); // Navigate to Admin page
                      case 2:
                        return const Placeholder(
                          child: Text('Owner'),
                        ); // Navigate to Owner page
                      case 3:
                        return const Placeholder(); // Navigate to Worker page
                      default:
                        return const Placeholder(); // Fallback for unknown role
                    }
                  }
                },
              );
            } else {
              return const LoginPage(); // Redirect if unauthenticated
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
