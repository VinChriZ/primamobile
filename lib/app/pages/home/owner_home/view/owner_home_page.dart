import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/bloc/owner_home_bloc.dart';
import 'package:primamobile/app/pages.dart';

class OwnerHomePage extends StatelessWidget {
  const OwnerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OwnerHomeBloc(),
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (authenticationContext, authenticationState) {
          if (authenticationState is AuthenticationUnauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: const OwnerHomeScreen(),
      ),
    );
  }
}
