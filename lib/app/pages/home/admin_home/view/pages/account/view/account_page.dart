import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/admin_home/view/pages/account/bloc/account_bloc.dart';
import 'package:primamobile/repository/user_repository.dart';
import 'account_screen.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountBloc(
        userRepository: RepositoryProvider.of<UserRepository>(context),
      )..add(FetchAccounts()),
      child: const AccountScreen(),
    );
  }
}
