import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/report/bloc/report_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/report/view/report_screen.dart';
import 'package:primamobile/repository/transaction_detail_repository.dart';
import 'package:primamobile/repository/transaction_repository.dart';
import 'package:primamobile/repository/product_repository.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportBloc>(
      create: (context) => ReportBloc(
        transactionRepository:
            RepositoryProvider.of<TransactionRepository>(context),
        productRepository: RepositoryProvider.of<ProductRepository>(context),
        transactionDetailRepository:
            RepositoryProvider.of<TransactionDetailRepository>(context),
      )..add(const LoadReportEvent()),
      child: const ReportScreen(),
    );
  }
}
