import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/bloc/stock_bloc.dart';
import 'package:primamobile/repository/product_repository.dart';
import 'stock_screen.dart';

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StockBloc(
        productRepository: context.read<ProductRepository>(),
      )..add(LoadProducts()),
      child: const StockScreen(),
    );
  }
}
