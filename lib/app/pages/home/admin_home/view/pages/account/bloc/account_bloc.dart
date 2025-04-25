import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/app/models/users/users.dart';
import 'package:primamobile/repository/user_repository.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final UserRepository userRepository;

  AccountBloc({required this.userRepository}) : super(AccountLoading()) {
    on<FetchAccounts>(_onFetchAccounts);
    on<AddAccount>(_onAddAccount);
    on<UpdateAccount>(_onUpdateAccount);
    on<DeactivateAccount>(_onDeactivateAccount);
    on<FilterAccounts>(_onFilterAccounts);
  }

  Future<void> _onFetchAccounts(
      FetchAccounts event, Emitter<AccountState> emit) async {
    try {
      final accounts = await userRepository.fetchAllUsers();
      emit(AccountLoaded(accounts: accounts));
    } catch (e) {
      if (e.toString().contains("401")) {
        emit(const AccountError(
            message: "Login expired, please restart the app and login again"));
      } else {
        emit(AccountError(message: e.toString()));
      }
    }
  }

  Future<void> _onAddAccount(
      AddAccount event, Emitter<AccountState> emit) async {
    try {
      await userRepository.addUser(event.user, event.password);
      final accounts = await userRepository.fetchAllUsers();
      if (state is AccountLoaded) {
        final currentState = state as AccountLoaded;
        emit(currentState.copyWith(accounts: accounts));
      } else {
        emit(AccountLoaded(accounts: accounts));
      }
    } catch (e) {
      if (e.toString().contains("401")) {
        emit(const AccountError(
            message: "Login expired, please restart the app and login again"));
      } else {
        emit(AccountError(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdateAccount(
      UpdateAccount event, Emitter<AccountState> emit) async {
    try {
      await userRepository.updateUser(event.userId, event.updatedData);
      final accounts = await userRepository.fetchAllUsers();
      if (state is AccountLoaded) {
        final currentState = state as AccountLoaded;
        emit(currentState.copyWith(accounts: accounts));
      } else {
        emit(AccountLoaded(accounts: accounts));
      }
    } catch (e) {
      if (e.toString().contains("401")) {
        emit(const AccountError(
            message: "Login expired, please restart the app and login again"));
      } else {
        emit(const AccountError(message: "Failed to load account data"));
      }
    }
  }

  Future<void> _onDeactivateAccount(
      DeactivateAccount event, Emitter<AccountState> emit) async {
    try {
      await userRepository.deactivateUser(event.userId);
      final accounts = await userRepository.fetchAllUsers();
      if (state is AccountLoaded) {
        final currentState = state as AccountLoaded;
        emit(currentState.copyWith(accounts: accounts));
      } else {
        emit(AccountLoaded(accounts: accounts));
      }
    } catch (e) {
      if (e.toString().contains("401")) {
        emit(const AccountError(
            message: "Login expired, please restart the app and login again"));
      } else {
        emit(AccountError(message: e.toString()));
      }
    }
  }

  Future<void> _onFilterAccounts(
      FilterAccounts event, Emitter<AccountState> emit) async {
    if (state is AccountLoaded) {
      final currentState = state as AccountLoaded;
      emit(currentState.copyWith(
        selectedStatus: event.selectedStatus,
        selectedRole: event.selectedRole,
      ));
    }
  }
}
