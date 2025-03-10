import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';
import 'package:primamobile/app/pages/home/worker_home/bloc/worker_home_bloc.dart';
import 'package:primamobile/app/pages/home/worker_home/view/worker_home_screen.dart';
import 'package:primamobile/repository/product_repository.dart';

class WorkerHomePage extends StatelessWidget {
  const WorkerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final productRepository = context.read<ProductRepository>();

    return BlocProvider(
      create: (context) => WorkerHomeBloc(productRepository: productRepository),
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (authContext, authState) {
          if (authState is AuthenticationUnauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: const WorkerHomeScreen(),
      ),
    );
  }
}
