import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert'; // Import for base64Encode

class AddPrivateItemDialog extends StatefulWidget {
  final Function(String type, String data, Map<String, dynamic> metadata) onSave;

  const AddPrivateItemDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  State<AddPrivateItemDialog> createState() => _AddPrivateItemDialogState();
}

class _AddPrivateItemDialogState extends State<AddPrivateItemDialog> {
  String _selectedType = 'note';
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _selectedFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _pickDocument() async {
    // TODO: Implement document picker using file_picker package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document picker not yet implemented.')),
    );
  }

  void _saveItem() async {
    String data = '';
    Map<String, dynamic> metadata = {
      'title': _titleController.text,
    };

    if (_selectedType == 'note') {
      data = _contentController.text;
      metadata['content'] = _contentController.text;
    } else if (_selectedType == 'photo' || _selectedType == 'document') {
      if (_selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a file.')),
        );
        return;
      }
      data = base64Encode(_selectedFile!.readAsBytesSync());
    }

    widget.onSave(_selectedType, data, metadata);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Private Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Item Type'),
              items: const [
                DropdownMenuItem(value: 'note', child: Text('Note')),
                DropdownMenuItem(value: 'photo', child: Text('Photo')),
                DropdownMenuItem(value: 'document', child: Text('Document')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _selectedFile = null; // Clear selected file when type changes
                });
              },
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            if (_selectedType == 'note')
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                ),
                maxLines: 5,
              ),
            if (_selectedType == 'photo') ...[
              const SizedBox(height: 16),
              _selectedFile == null
                  ? ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo),
                      label: const Text('Select Photo'),
                    )
                  : Column(
                      children: [
                        Image.file(
                          _selectedFile!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                        TextButton(
                          onPressed: _pickImage,
                          child: const Text('Change Photo'),
                        ),
                      ],
                    ),
            ],
            if (_selectedType == 'document') ...[
              const SizedBox(height: 16),
              _selectedFile == null
                  ? ElevatedButton.icon(
                      onPressed: _pickDocument,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Select Document'),
                    )
                  : Column(
                      children: [
                        Text(_selectedFile!.path.split('/').last), // Display file name
                        TextButton(
                          onPressed: _pickDocument,
                          child: const Text('Change Document'),
                        ),
                      ],
                    ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveItem,
          child: const Text('Save'),
        ),
      ],
    );
  }
} 