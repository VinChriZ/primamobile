import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/bloc/sales/sales_bloc.dart';
import 'package:primamobile/repository/transaction_repository.dart';
import 'sales_screen.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SalesBloc(
        transactionRepository:
            RepositoryProvider.of<TransactionRepository>(context),
      )..add(FetchSales()),
      child: const SalesScreen(),
    );
  }
}
