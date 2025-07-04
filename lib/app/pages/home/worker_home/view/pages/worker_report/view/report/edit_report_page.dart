import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:primamobile/app/models/report/report.dart';
import 'package:primamobile/repository/report_repository.dart';

class EditReportPage extends StatefulWidget {
  final Report report;

  const EditReportPage({super.key, required this.report});

  @override
  _EditReportPageState createState() => _EditReportPageState();
}

class _EditReportPageState extends State<EditReportPage> {
  late DateTime _reportDate;
  late String _selectedType;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  late TextEditingController _noteController;

  late final ReportRepository _reportRepository;

  @override
  void initState() {
    super.initState();
    _reportDate = widget.report.dateCreated;
    _selectedType = widget.report.type;
    _noteController = TextEditingController(text: widget.report.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reportRepository = RepositoryProvider.of<ReportRepository>(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _reportDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _reportDate) {
      setState(() {
        _reportDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    // Build payload with date_created, type and note
    final updateFields = {
      'date_created': _reportDate.toIso8601String(),
      'type': _selectedType,
      'note':
          _noteController.text.trim().isNotEmpty ? _noteController.text : null,
    };

    try {
      final updatedReport = await _reportRepository.editReport(
          widget.report.reportId, updateFields);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report updated successfully.')),
      );
      Navigator.of(context).pop(updatedReport);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update report: $error')),
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
    final formattedDate = DateFormat('yyyy-MM-dd').format(_reportDate);
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Report - $formattedDate"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isSaving
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Report Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(formattedDate,
                                      style: const TextStyle(fontSize: 16)),
                                  Icon(Icons.calendar_today,
                                      color: Theme.of(context).primaryColor),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Report Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            value: _selectedType,
                            items: const [
                              DropdownMenuItem(
                                value: 'restock',
                                child: Text('Restock'),
                              ),
                              DropdownMenuItem(
                                value: 'return',
                                child: Text('Return'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedType = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              labelText: 'Note (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              hintText: 'Add a note for this report',
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
