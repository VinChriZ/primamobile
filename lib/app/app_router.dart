// lib/app/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';
import 'package:primamobile/app/pages.dart';
import 'package:primamobile/repository/user_repository.dart';
import 'package:primamobile/repository/transaction_repository.dart';
import 'package:primamobile/repository/transaction_detail_repository.dart';
import 'package:primamobile/utils/globals.dart';

class AppRouter {
  final AuthenticationBloc authenticationBloc;
  final UserRepository userRepository;
  final TransactionRepository transactionRepository;
  final TransactionDetailRepository transactionDetailRepository;

  AppRouter({
    required this.authenticationBloc,
    required this.userRepository,
    required this.transactionRepository,
    required this.transactionDetailRepository,
  });

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
                future: userRepository.fetchAndUpdateUserDetails(),
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
                      case 1: // Admin
                        return const Placeholder(
                          child: Text('Admin Page'),
                        );
                      case 2: // Owner
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider.value(
                              value: authenticationBloc,
                            ),
                            // Add other BLoCs related to Owner here if needed
                          ],
                          child: const OwnerHomePage(),
                        );
                      case 3: // Worker
                        return const Placeholder(
                          child: Text('Worker Page'),
                        );
                      default:
                        return const Scaffold(
                          body: Center(child: Text('Unknown role.')),
                        );
                    }
                  }
                },
              );
            } else {
              return const LoginPage();
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
