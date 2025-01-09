import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/bloc/owner_home_bloc.dart';
import 'package:primamobile/app/pages.dart';
import 'package:primamobile/repository/product_repository.dart';

class OwnerHomePage extends StatelessWidget {
  const OwnerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the ProductRepository from the context
    final productRepository = context.read<ProductRepository>();

    return BlocProvider(
      create: (context) => OwnerHomeBloc(productRepository: productRepository),
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
