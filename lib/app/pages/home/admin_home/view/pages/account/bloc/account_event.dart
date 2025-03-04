part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class FetchAccounts extends AccountEvent {}

class AddAccount extends AccountEvent {
  final User user;
  final String password;
  const AddAccount(this.user, this.password);

  @override
  List<Object> get props => [user, password];
}

class UpdateAccount extends AccountEvent {
  final int userId;
  final Map<String, dynamic> updatedData;
  const UpdateAccount(this.userId, this.updatedData);

  @override
  List<Object> get props => [userId, updatedData];
}

class DeactivateAccount extends AccountEvent {
  final int userId;
  const DeactivateAccount(this.userId);

  @override
  List<Object> get props => [userId];
}

class FilterAccounts extends AccountEvent {
  final String selectedStatus; // "All", "Active", "Inactive"
  final String selectedRole; // "All", "Admin", "Owner", "Worker"
  const FilterAccounts(
      {required this.selectedStatus, required this.selectedRole});

  @override
  List<Object> get props => [selectedStatus, selectedRole];
}
