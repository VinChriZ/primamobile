import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/bloc/owner_home_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/home/home_page.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/bloc/stock_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/stock_page.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwnerHomeBloc, OwnerHomeState>(
      builder: (context, state) {
        final selectedIndex =
            state is OwnerHomeNavigationState ? state.selectedIndex : 0;

        final productRepository =
            context.read<OwnerHomeBloc>().productRepository; // Access from bloc

        final List<Widget> pages = [
          const HomePage(),
          BlocProvider(
            create: (_) => StockBloc(productRepository: productRepository)
              ..add(LoadProducts()),
            child: const StockPage(),
          ),
          const Placeholder(),
          const Placeholder(),
          const Placeholder(),
        ];

        return Scaffold(
          body: pages[selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => context
                .read<OwnerHomeBloc>()
                .add(OwnerHomeNavigationChanged(index)),
            selectedItemColor: Colors.blue.shade800,
            unselectedItemColor: Colors.grey,
            selectedIconTheme: const IconThemeData(size: 30),
            unselectedIconTheme: const IconThemeData(size: 25),
            selectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.inventory), label: 'Stock'),
              BottomNavigationBarItem(icon: Icon(Icons.sell), label: 'Sales'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart), label: 'Report'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
