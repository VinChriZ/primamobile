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

  /// Helper widget to build a row for a given label/value pair.
  Widget _buildAttributeRow(String label, String value) {
    // Extract the base label without the colon
    String baseLabel =
        label.endsWith(':') ? label.substring(0, label.length - 1) : label;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          padding: const EdgeInsets.only(right: 5),
          child: Text(
            baseLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 5), // Space before colon
        const Text(
          ":",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 10), // Space after colon
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AccountBloc, AccountState>(
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
                            itemCount: filteredAccounts.length,
                            itemBuilder: (context, index) {
                              final account = filteredAccounts[index];

                              // Determine border color based on status
                              BorderSide borderSide = BorderSide(
                                color: account.active
                                    ? Colors.green.shade300
                                    : Colors.red.shade300,
                                width: 1.5,
                              );

                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 3,
                                  shadowColor: Colors.black26,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: borderSide,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  Colors.blueAccent,
                                              radius: 20,
                                              child: Text(
                                                account.username[0]
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                account.username,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Divider(
                                          color: account.active
                                              ? Colors.green.shade300
                                              : Colors.red.shade300,
                                          thickness: 1,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildAttributeRow(
                                            "Role", _roleName(account.roleId)),
                                        const SizedBox(height: 6.0),
                                        _buildAttributeRow(
                                            "Status",
                                            account.active
                                                ? "Active"
                                                : "Inactive"),
                                        const SizedBox(height: 12.0),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      BlocProvider.value(
                                                    value: context
                                                        .read<AccountBloc>(),
                                                    child: EditAccountPage(
                                                        user: account),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text('Edit',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
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
