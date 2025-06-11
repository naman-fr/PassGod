import 'package:flutter/material.dart';
import 'package:passgod_mobile/models/private_item.dart';
import 'dart:convert'; // For base64Decode

class PrivateItemDetailsDialog extends StatelessWidget {
  final PrivateItem item;
  final Function(String itemId) onDelete;

  const PrivateItemDetailsDialog({Key? key, required this.item, required this.onDelete}) : super(key: key);

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(item.metadata?['title'] ?? 'Untitled'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${item.itemType}'),
            Text('Created: ${_formatDate(item.createdAt)}'),
            Text('Last Updated: ${_formatDate(item.updatedAt)}'),
            const SizedBox(height: 16),
            if (item.itemType == 'note')
              Text(item.metadata?['content'] ?? ''),
            if (item.itemType == 'photo')
              Image.memory(
                base64Decode(item.encryptedData),
                fit: BoxFit.cover,
              ),
            if (item.itemType == 'document')
              ElevatedButton.icon(
                onPressed: () {
                  // Implement document download
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document download not yet implemented.')),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Download Document'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog first
            onDelete(item.id!); // Then trigger delete
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
} 