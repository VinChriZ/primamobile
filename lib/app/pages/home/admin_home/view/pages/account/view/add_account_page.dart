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
  String _username = '';
  String _password = '';
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
      _username = _usernameController.text;
      _checkUsername(_username);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use context.read<AccountBloc>() to access the bloc.
    final accountBloc = context.read<AccountBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text("Add Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  errorText: _usernameError,
                ),
                onSaved: (value) {
                  _username = value ?? '';
                },
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (value) {
                  _password = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                value: _roleId,
                decoration: const InputDecoration(labelText: 'Role'),
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
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text("Add Account"),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    // Create a temporary User object.
                    // Note: The password is passed separately since the backend hashes it.
                    final newUser = User(
                      userId: 0, // Dummy id; backend will assign the proper ID
                      username: _username,
                      passwordHash: '', // Will be set by the backend
                      roleId: _roleId,
                      active: true,
                    );
                    accountBloc.add(AddAccount(newUser, _password));
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
