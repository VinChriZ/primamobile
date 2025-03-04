import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';
import 'package:primamobile/app/pages/home/admin_home/bloc/admin_home_bloc.dart';
import 'package:primamobile/app/pages/home/admin_home/view/admin_home_screen.dart';
import 'package:primamobile/repository/product_repository.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final productRepository = context.read<ProductRepository>();

    return BlocProvider(
      create: (context) => AdminHomeBloc(productRepository: productRepository),
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (authContext, authState) {
          if (authState is AuthenticationUnauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: const AdminHomeScreen(),
      ),
    );
  }
}
