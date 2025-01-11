import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/profile/bloc/profile_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/profile/view/profile_screen.dart';
import 'package:primamobile/repository/user_repository.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileBloc(
            userRepository: RepositoryProvider.of<UserRepository>(context),
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
          )..add(LoadProfile()),
        ),
      ],
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationUnauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: const ProfileScreen(),
      ),
    );
  }
}
