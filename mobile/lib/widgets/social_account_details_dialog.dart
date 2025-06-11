import 'package:flutter/material.dart';
import 'package:passgod_mobile/models/social_account.dart';
import 'package:flutter/services.dart';

class SocialAccountDetailsDialog extends StatelessWidget {
  final SocialAccount account;

  const SocialAccountDetailsDialog({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getPlatformIcon(account.platform ?? ''),
            color: _getPlatformColor(account.platform ?? ''),
          ),
          const SizedBox(width: 8),
          Text(account.platform ?? 'Unknown Platform'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Username', account.username ?? 'N/A'),
            if (account.link != null && account.link!.isNotEmpty)
              _buildDetailRow('Website', account.link!),
            if (account.notes != null && account.notes!.isNotEmpty)
              _buildDetailRow('Notes', account.notes!),
            _buildDetailRow('Created', account.createdAt?.toString() ?? 'N/A'),
            if (account.updatedAt != null)
              _buildDetailRow('Last Updated', account.updatedAt.toString()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (account.link != null && account.link!.isNotEmpty)
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'whatsapp':
        return Icons.chat;
      case 'instagram':
        return Icons.camera_alt;
      case 'reddit':
        return Icons.reddit;
      case 'discord':
        return Icons.discord;
      case 'facebook':
        return Icons.facebook;
      case 'linkedin':
        return Icons.person;
      default:
        return Icons.public;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'whatsapp':
        return Colors.green;
      case 'instagram':
        return Colors.purple;
      case 'reddit':
        return Colors.deepOrange;
      case 'discord':
        return Colors.indigo;
      case 'facebook':
        return Colors.blue;
      case 'linkedin':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }
} 