part of 'transaction_detail_bloc.dart';

abstract class TransactionDetailEvent extends Equatable {
  const TransactionDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchTransactionDetails extends TransactionDetailEvent {
  final int transactionId;

  const FetchTransactionDetails(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}

class AddTransactionDetail extends TransactionDetailEvent {
  final int transactionId;
  final Map<String, dynamic> fields;

  const AddTransactionDetail(this.transactionId, this.fields);

  @override
  List<Object> get props => [transactionId, fields];
}

class UpdateTransactionDetail extends TransactionDetailEvent {
  final int transactionId;
  final int detailId;
  final Map<String, dynamic> fields;

  const UpdateTransactionDetail(this.transactionId, this.detailId, this.fields);

  @override
  List<Object> get props => [transactionId, detailId, fields];
}

class DeleteTransactionDetail extends TransactionDetailEvent {
  final int transactionId;
  final int detailId;

  const DeleteTransactionDetail(this.transactionId, this.detailId);

  @override
  List<Object> get props => [transactionId, detailId];
}
