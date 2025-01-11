import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/bloc/stock_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/stock_screen.dart';
import 'package:primamobile/repository/product_repository.dart';

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StockBloc(
        productRepository: RepositoryProvider.of<ProductRepository>(context),
      )..add(LoadProducts()),
      child: const StockScreen(),
    );
  }
}
