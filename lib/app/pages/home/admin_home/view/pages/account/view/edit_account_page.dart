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

  @override
  Widget build(BuildContext context) {
    // Use context.read<AccountBloc>() to access the bloc.
    final accountBloc = context.read<AccountBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _username,
                decoration: const InputDecoration(labelText: 'Username'),
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
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'New Password (leave blank to keep current)'),
                obscureText: true,
                onSaved: (value) {
                  _password = value ?? '';
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
                    _roleId = value ?? _roleId;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Active'),
                value: _active,
                onChanged: (value) {
                  setState(() {
                    _active = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text("Update Account"),
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

                    accountBloc
                        .add(UpdateAccount(widget.user.userId, updatedData));
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
