import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/transaction/transaction.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/bloc/transaction_detail/transaction_detail_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/transaction_detail/transaction_detail_screen.dart';
import 'package:primamobile/repository/transaction_detail_repository.dart';
import 'package:primamobile/repository/transaction_repository.dart';
import 'package:primamobile/repository/user_repository.dart';

class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionDetailBloc(
        transactionDetailRepository:
            RepositoryProvider.of<TransactionDetailRepository>(context),
        transactionRepository:
            RepositoryProvider.of<TransactionRepository>(context),
        userRepository: RepositoryProvider.of<UserRepository>(context),
      )..add(FetchTransactionDetails(transaction.transactionId)),
      child: TransactionDetailScreen(transaction: transaction),
    );
  }
}
