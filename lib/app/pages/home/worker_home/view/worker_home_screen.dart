import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/worker_home/bloc/worker_home_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/home/view/home_page.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/profile/view/profile_page.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/sales/view/sales/sales_page.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/stock/view/stock_page.dart';

class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkerHomeBloc, WorkerHomeState>(
      builder: (context, state) {
        final selectedIndex =
            state is WorkerHomeNavigationState ? state.selectedIndex : 0;

        final List<Widget> pages = [
          const HomePage(),
          const StockPage(),
          const SalesPage(),
          const ProfilePage()
        ];

        return Scaffold(
          body: pages[selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => context
                .read<WorkerHomeBloc>()
                .add(WorkerHomeNavigationChanged(index)),
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
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
