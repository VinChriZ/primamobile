import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/home/bloc/home_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/home/view/home_screen.dart';
import 'package:primamobile/repository/user_session_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        userSessionRepository:
            RepositoryProvider.of<UserSessionRepository>(context),
      )..add(HomeStarted()),
      child: const HomeScreen(),
    );
  }
}
