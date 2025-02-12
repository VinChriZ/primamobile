import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/transaction/transaction.dart';
import 'package:primamobile/repository/transaction_repository.dart';

class SalesEdit extends StatefulWidget {
  final Transaction transaction;

  const SalesEdit({super.key, required this.transaction});

  @override
  _SalesEditState createState() => _SalesEditState();
}

class _SalesEditState extends State<SalesEdit> {
  late DateTime _selectedDate;
  late TextEditingController _noteController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.transaction.dateCreated;
    _noteController =
        TextEditingController(text: widget.transaction.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    // Get the TransactionRepository from the context.
    final transactionRepository =
        RepositoryProvider.of<TransactionRepository>(context);

    // Prepare the update fields. The API may require an ISO string for date.
    final updateFields = {
      'date_created': _selectedDate.toIso8601String(),
      'note': _noteController.text,
    };

    try {
      // Call the repository method to update the transaction.
      final updatedTransaction = await transactionRepository.editTransaction(
          widget.transaction.transactionId, updateFields);

      // Show a success message.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction updated successfully.')),
      );

      // Pop the screen (optionally, you can pass the updated transaction).
      Navigator.of(context).pop(updatedTransaction);
    } catch (error) {
      // On error, display a message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update transaction: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the selected date for display.
    final formattedDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(formattedDate),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isSaving
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Date Created field with a calendar picker.
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date Created',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Note field.
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      // Note is optional; add validation if needed.
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    // Save button.
                    ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
