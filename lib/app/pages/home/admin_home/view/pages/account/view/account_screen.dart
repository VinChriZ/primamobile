import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/admin_home/view/pages/account/bloc/account_bloc.dart';
import 'package:primamobile/app/pages/home/admin_home/view/pages/account/view/add_account_page.dart';
import 'package:primamobile/app/pages/home/admin_home/view/pages/account/view/edit_account_page.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  String _roleName(int roleId) {
    switch (roleId) {
      case 1:
        return "Admin";
      case 2:
        return "Owner";
      case 3:
        return "Worker";
      default:
        return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accounts"),
        centerTitle: true,
      ),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AccountLoaded) {
            if (state.accounts.isEmpty) {
              return const Center(child: Text("No accounts available"));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.accounts.length,
              itemBuilder: (context, index) {
                final account = state.accounts[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  // Light green for active, light red for inactive
                  color: account.active ? Colors.green[100] : Colors.red[100],
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        account.username[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      account.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text("Role: ${_roleName(account.roleId)}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: BlocProvider.of<AccountBloc>(context),
                              child: EditAccountPage(user: account),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          } else if (state is AccountError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: BlocProvider.of<AccountBloc>(context),
                child: const AddAccountPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
