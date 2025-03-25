import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/models/users/users.dart';
import 'package:primamobile/app/pages/home/admin_home/view/pages/account/bloc/account_bloc.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({super.key});

  @override
  _AddAccountPageState createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _roleId = 3; // Default to Worker
  String? _usernameError;

  // Checks if the username already exists using the current AccountBloc state.
  void _checkUsername(String value) {
    final currentState = context.read<AccountBloc>().state;
    if (currentState is AccountLoaded) {
      final exists = currentState.accounts.any(
        (acc) => acc.username.toLowerCase() == value.toLowerCase(),
      );
      setState(() {
        _usernameError = exists ? "Username already exists" : null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Listen for changes to the username field.
    _usernameController.addListener(() {
      _checkUsername(_usernameController.text);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      appBar: AppBar(title: const Text("Add Account")),
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
                      controller: _usernameController,
                      decoration: _buildInputDecoration(
                        'Username',
                        errorText: _usernameError,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        if (_usernameError != null) {
                          return _usernameError;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: _buildInputDecoration('Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
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
                          _roleId = value ?? 3;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    // Add account button
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
                            // Create a temporary User object.
                            // Note: The password is passed separately since the backend hashes it.
                            final newUser = User(
                              userId:
                                  0, // Dummy id; backend will assign the proper ID
                              username: _usernameController.text,
                              passwordHash: '', // Will be set by the backend
                              roleId: _roleId,
                              active: true,
                            );
                            accountBloc.add(
                                AddAccount(newUser, _passwordController.text));
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          "Add Account",
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
