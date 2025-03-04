import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:primamobile/app/models/users/users.dart';
import 'package:primamobile/repository/user_repository.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final UserRepository userRepository;

  AccountBloc({required this.userRepository}) : super(AccountInitial()) {
    on<FetchAccounts>(_onFetchAccounts);
    on<AddAccount>(_onAddAccount);
    on<UpdateAccount>(_onUpdateAccount);
    on<DeactivateAccount>(_onDeactivateAccount);
  }

  Future<void> _onFetchAccounts(
      FetchAccounts event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final accounts = await userRepository.fetchAllUsers();
      emit(AccountLoaded(accounts));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onAddAccount(
      AddAccount event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      await userRepository.addUser(event.user, event.password);
      final accounts = await userRepository.fetchAllUsers();
      emit(AccountLoaded(accounts));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onUpdateAccount(
      UpdateAccount event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      await userRepository.updateUser(event.userId, event.updatedData);
      final accounts = await userRepository.fetchAllUsers();
      emit(AccountLoaded(accounts));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onDeactivateAccount(
      DeactivateAccount event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      await userRepository.deactivateUser(event.userId);
      final accounts = await userRepository.fetchAllUsers();
      emit(AccountLoaded(accounts));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }
}
