import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';
import 'package:primamobile/app/pages/login/bloc/login_bloc.dart';
import 'package:primamobile/app/pages/login/view/login_screen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (authenticationContext, authenticationState) {
          if (authenticationState is AuthenticationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authenticationState.error)),
            );
          } else if (authenticationState is AuthenticationAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        child: const LoginScreen(),
      ),
    );
  }
}
