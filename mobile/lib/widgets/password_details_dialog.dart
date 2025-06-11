import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passgod_mobile/models/password.dart';

class PasswordDetailsDialog extends StatelessWidget {
  final Password password;

  const PasswordDetailsDialog({Key? key, required this.password}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              password.title ?? 'Unknown Title',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              context,
              'Username',
              password.username ?? 'N/A',
              Icons.person,
            ),
            if (password.websiteUrl != null && password.websiteUrl!.isNotEmpty)
              _buildDetailRow(
                context,
                'Website',
                password.websiteUrl!,
                Icons.link,
              ),
            if (password.notes != null && password.notes!.isNotEmpty)
              _buildDetailRow(
                context,
                'Notes',
                password.notes!,
                Icons.note,
              ),
            _buildDetailRow(
              context,
              'Created',
              password.createdAt?.toString() ?? 'N/A',
              Icons.calendar_today,
            ),
            if (password.updatedAt != null)
              _buildDetailRow(
                context,
                'Last Updated',
                password.updatedAt.toString(),
                Icons.update,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (password.websiteUrl != null && password.websiteUrl!.isNotEmpty)
          TextButton(
            onPressed: () {
              // TODO: Implement URL launcher
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('URL launcher coming soon!')),
              );
            },
            child: const Text('Open Website'),
          ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied to clipboard'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                value,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 