part of 'account_bloc.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object> get props => [];
}

class AccountLoading extends AccountState {}

class AccountError extends AccountState {
  final String message;
  const AccountError({required this.message});

  @override
  List<Object> get props => [message];
}

class AccountLoaded extends AccountState {
  final List<User> accounts;
  final String selectedStatus; // "All", "Active", "Inactive"
  final String selectedRole; // "All", "Admin", "Owner", "Worker"

  const AccountLoaded({
    required this.accounts,
    this.selectedStatus = 'All',
    this.selectedRole = 'All',
  });

  List<User> get filteredAccounts {
    return accounts.where((account) {
      bool statusMatch;
      if (selectedStatus == 'Active') {
        statusMatch = account.active;
      } else if (selectedStatus == 'Inactive') {
        statusMatch = !account.active;
      } else {
        statusMatch = true;
      }

      bool roleMatch;
      if (selectedRole == 'Admin') {
        roleMatch = account.roleId == 1;
      } else if (selectedRole == 'Owner') {
        roleMatch = account.roleId == 2;
      } else if (selectedRole == 'Worker') {
        roleMatch = account.roleId == 3;
      } else {
        roleMatch = true;
      }
      return statusMatch && roleMatch;
    }).toList();
  }

  AccountLoaded copyWith({
    List<User>? accounts,
    String? selectedStatus,
    String? selectedRole,
  }) {
    return AccountLoaded(
      accounts: accounts ?? this.accounts,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }

  @override
  List<Object> get props => [accounts, selectedStatus, selectedRole];
}
