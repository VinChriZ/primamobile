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
            final filteredAccounts = state.filteredAccounts;
            return Column(
              children: [
                // Filters Row with updated styling
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 12.0),
                  child: Row(
                    children: [
                      // Status Dropdown
                      SizedBox(
                        width: 180,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          value: state.selectedStatus,
                          items: const [
                            DropdownMenuItem(
                                value: 'All', child: Text('All Status')),
                            DropdownMenuItem(
                                value: 'Active', child: Text('Active')),
                            DropdownMenuItem(
                                value: 'Inactive', child: Text('Inactive')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              context.read<AccountBloc>().add(
                                    FilterAccounts(
                                      selectedStatus: value,
                                      selectedRole: state.selectedRole,
                                    ),
                                  );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      // Role Dropdown
                      SizedBox(
                        width: 180,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            border: OutlineInputBorder(),
                          ),
                          value: state.selectedRole,
                          items: const [
                            DropdownMenuItem(
                                value: 'All', child: Text('All Roles')),
                            DropdownMenuItem(
                                value: 'Admin', child: Text('Admin')),
                            DropdownMenuItem(
                                value: 'Owner', child: Text('Owner')),
                            DropdownMenuItem(
                                value: 'Worker', child: Text('Worker')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              context.read<AccountBloc>().add(
                                    FilterAccounts(
                                      selectedStatus: state.selectedStatus,
                                      selectedRole: value,
                                    ),
                                  );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Accounts List
                Expanded(
                  child: filteredAccounts.isEmpty
                      ? const Center(child: Text("No accounts available"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredAccounts.length,
                          itemBuilder: (context, index) {
                            final account = filteredAccounts[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              color: account.active
                                  ? Colors.green[100]
                                  : Colors.red[100],
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
                                      fontSize: 16),
                                ),
                                subtitle:
                                    Text("Role: ${_roleName(account.roleId)}"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<AccountBloc>(),
                                          child: EditAccountPage(user: account),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
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
                value: context.read<AccountBloc>(),
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
