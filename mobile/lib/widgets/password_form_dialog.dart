import 'package:flutter/material.dart';
import 'package:passgod_mobile/models/password.dart';

class PasswordFormDialog extends StatefulWidget {
  final Password? password;
  final Function(Map<String, dynamic>) onSave;

  const PasswordFormDialog({Key? key, this.password, required this.onSave}) : super(key: key);

  @override
  State<PasswordFormDialog> createState() => _PasswordFormDialogState();
}

class _PasswordFormDialogState extends State<PasswordFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _websiteUrlController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.password?.title ?? '');
    _usernameController = TextEditingController(text: widget.password?.username ?? '');
    _passwordController = TextEditingController(); // Password is never pre-filled for security
    _websiteUrlController = TextEditingController(text: widget.password?.websiteUrl ?? '');
    _notesController = TextEditingController(text: widget.password?.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _websiteUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final Map<String, dynamic> passwordData = {
        'title': _titleController.text,
        'username': _usernameController.text,
        'website_url': _websiteUrlController.text,
        'notes': _notesController.text,
      };
      if (_passwordController.text.isNotEmpty) {
        passwordData['encrypted_password'] = _passwordController.text;
      }
      widget.onSave(passwordData);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.password == null ? 'Add Password' : 'Edit Password'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username/Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username or email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password (leave blank to keep current)'),
                obscureText: true,
              ),
              TextFormField(
                controller: _websiteUrlController,
                decoration: const InputDecoration(labelText: 'Website URL'),
                keyboardType: TextInputType.url,
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Save'),
        ),
      ],
    );
  }
} 