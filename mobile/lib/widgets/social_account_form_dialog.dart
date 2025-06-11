import 'package:flutter/material.dart';
import 'package:passgod_mobile/models/social_account.dart';

class SocialAccountFormDialog extends StatefulWidget {
  final SocialAccount? account;
  final Function(Map<String, dynamic>) onSave;

  const SocialAccountFormDialog({Key? key, this.account, required this.onSave}) : super(key: key);

  @override
  State<SocialAccountFormDialog> createState() => _SocialAccountFormDialogState();
}

class _SocialAccountFormDialogState extends State<SocialAccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _platformController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _linkController;
  late TextEditingController _notesController;
  String? _selectedPlatform;
  bool _isOtherPlatform = false;

  final List<String> _supportedPlatforms = [
    'whatsapp',
    'instagram',
    'reddit',
    'discord',
    'facebook',
    'linkedin',
    'other'
  ];

  @override
  void initState() {
    super.initState();
    _platformController = TextEditingController(text: widget.account?.platform ?? '');
    _usernameController = TextEditingController(text: widget.account?.username ?? '');
    _passwordController = TextEditingController();
    _linkController = TextEditingController(text: widget.account?.link ?? '');
    _notesController = TextEditingController(text: widget.account?.notes ?? '');
    
    // Set initial platform selection
    if (widget.account?.platform != null) {
      if (_supportedPlatforms.contains(widget.account!.platform!.toLowerCase())) {
        _selectedPlatform = widget.account!.platform!.toLowerCase();
      } else {
        _selectedPlatform = 'other';
        _isOtherPlatform = true;
      }
    }
  }

  @override
  void dispose() {
    _platformController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _linkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final Map<String, dynamic> accountData = {
        'platform': _isOtherPlatform ? _platformController.text : _selectedPlatform,
        'username': _usernameController.text,
        'link': _linkController.text,
        'notes': _notesController.text,
      };
      if (_passwordController.text.isNotEmpty) {
        accountData['password'] = _passwordController.text;
      }
      widget.onSave(accountData);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.account == null ? 'Add Social Account' : 'Edit Social Account'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedPlatform,
                decoration: const InputDecoration(
                  labelText: 'Platform',
                  border: OutlineInputBorder(),
                ),
                items: _supportedPlatforms.map((platform) {
                  return DropdownMenuItem(
                    value: platform,
                    child: Text(platform.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPlatform = value;
                    _isOtherPlatform = value == 'other';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a platform';
                  }
                  return null;
                },
              ),
              if (_isOtherPlatform) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _platformController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Platform Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a platform name';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 10),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username/Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username or email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password (leave blank to keep current)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Website URL',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
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