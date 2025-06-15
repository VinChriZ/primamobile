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
      create: (context) {
        // Calculate the default date range for Last 7 Days
        final now = DateTime.now();
        final startDate = now.subtract(const Duration(days: 7));
        // final startDate = DateTime(now.year, now.month - 1, now.day);

        return SalesBloc(
          transactionRepository:
              RepositoryProvider.of<TransactionRepository>(context),
        )..add(FetchSales(
            selectedDateRange: 'Last 7 Days',
            startDate: startDate,
            endDate: now,
          ));
      },
      child: const SalesScreen(),
    );
  }
}
