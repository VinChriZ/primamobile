import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/users/users.dart';
import 'package:primamobile/app/pages/home/admin_home/view/pages/account/bloc/account_bloc.dart';

class EditAccountPage extends StatefulWidget {
  final User user;
  const EditAccountPage({super.key, required this.user});

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late String _username;
  String _password = '';
  late int _roleId;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _username = widget.user.username;
    _roleId = widget.user.roleId;
    _active = widget.user.active;
  }

  /// Returns an InputDecoration with optional error text.
  InputDecoration _buildInputDecoration(String label, {String? errorText}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide:
            BorderSide(color: errorText != null ? Colors.red : Colors.grey),
      ),
      errorText: errorText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use context.read<AccountBloc>() to access the bloc.
    final accountBloc = context.read<AccountBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Account")),
      body: GestureDetector(
        onTap: () =>
            FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Username field
                    TextFormField(
                      initialValue: _username,
                      decoration: _buildInputDecoration('Username'),
                      onSaved: (value) {
                        _username = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password field
                    TextFormField(
                      decoration: _buildInputDecoration(
                          'New Password (leave blank to keep current)'),
                      obscureText: true,
                      onSaved: (value) {
                        _password = value ?? '';
                      },
                    ),
                    const SizedBox(height: 20),
                    // Role dropdown
                    DropdownButtonFormField<int>(
                      value: _roleId,
                      decoration: _buildInputDecoration('Role'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Admin')),
                        DropdownMenuItem(value: 2, child: Text('Owner')),
                        DropdownMenuItem(value: 3, child: Text('Worker')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _roleId = value ?? _roleId;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    // Active status
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: SwitchListTile(
                        title: const Text('Active'),
                        value: _active,
                        onChanged: (value) {
                          setState(() {
                            _active = value;
                          });
                        },
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Update button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();

                            // Build the updatedData map.
                            final Map<String, dynamic> updatedData = {
                              'username': _username,
                              'role_id': _roleId,
                              'active': _active,
                            };

                            // Only add password if provided.
                            if (_password.isNotEmpty) {
                              updatedData['password'] = _password;
                            }

                            accountBloc.add(
                                UpdateAccount(widget.user.userId, updatedData));
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          "Update Account",
                          style: TextStyle(fontSize: 18),
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
