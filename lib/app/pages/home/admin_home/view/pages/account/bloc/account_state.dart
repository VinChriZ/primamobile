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
    // Start with a copy of accounts to avoid modifying the original list
    List<User> filtered = List<User>.from(accounts);

    // Apply status filter
    if (selectedStatus != 'All') {
      filtered = filtered.where((user) {
        if (selectedStatus == 'Active') return user.active;
        return !user.active;
      }).toList();
    }

    // Apply role filter
    if (selectedRole != 'All') {
      filtered = filtered.where((user) {
        switch (selectedRole) {
          case 'Admin':
            return user.roleId == 1;
          case 'Owner':
            return user.roleId == 2;
          case 'Worker':
            return user.roleId == 3;
          default:
            return true;
        }
      }).toList();
    }

    // Sort by user ID in descending order
    filtered.sort((a, b) => b.userId.compareTo(a.userId));

    return filtered;
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
