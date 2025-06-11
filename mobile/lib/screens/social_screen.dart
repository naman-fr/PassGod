import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:passgod_mobile/services/api_service.dart';
import 'package:passgod_mobile/providers/auth_provider.dart';
import 'package:passgod_mobile/models/social_account.dart';
import 'package:passgod_mobile/widgets/app_drawer.dart';
import 'package:passgod_mobile/widgets/social_account_form_dialog.dart';
import 'package:passgod_mobile/widgets/social_account_details_dialog.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({Key? key}) : super(key: key);

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> with SingleTickerProviderStateMixin {
  List<SocialAccount> _socialAccounts = [];
  List<SocialAccount> _filteredSocialAccounts = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchSocialAccounts();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterSocialAccounts(String query) {
    setState(() {
      _filteredSocialAccounts = _socialAccounts.where((account) {
        final platform = account.platform?.toLowerCase() ?? '';
        final username = account.username?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return platform.contains(searchLower) || username.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _fetchSocialAccounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();
      final token = authProvider.token;

      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      final fetchedAccounts = await apiService.getSocialAccounts(token);
      setState(() {
        _socialAccounts = fetchedAccounts;
        _filteredSocialAccounts = fetchedAccounts;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load social accounts: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addSocialAccount() async {
    await showDialog(
      context: context,
      builder: (context) => SocialAccountFormDialog(
        onSave: (accountData) async {
          try {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final apiService = ApiService();
            final token = authProvider.token;

            if (token == null) {
              throw Exception('Authentication token not found.');
            }
            await apiService.createSocialAccount(token, accountData);
            _fetchSocialAccounts();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Social account added successfully!'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add social account: ${e.toString()}'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _editSocialAccount(SocialAccount account) async {
    await showDialog(
      context: context,
      builder: (context) => SocialAccountFormDialog(
        account: account,
        onSave: (accountData) async {
          try {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final apiService = ApiService();
            final token = authProvider.token;

            if (token == null) {
              throw Exception('Authentication token not found.');
            }
            if (account.id == null) {
              throw Exception('Social account ID is null, cannot update.');
            }
            await apiService.updateSocialAccount(token, account.id!, accountData);
            _fetchSocialAccounts();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Social account updated successfully!'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update social account: ${e.toString()}'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteSocialAccount(String accountId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Social Account'),
        content: const Text('Are you sure you want to delete this social account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();
      final token = authProvider.token;

      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      await apiService.deleteSocialAccount(token, accountId);
      _fetchSocialAccounts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Social account deleted successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete social account: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getPlatformIcon(String? platform) {
    switch (platform?.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'twitter':
        return Icons.alternate_email; // Using a generic icon for now, consider a custom icon library
      case 'instagram':
        return Icons.photo_camera; // Using a generic icon for now
      case 'linkedin':
        return Icons.people_alt; // Using a generic icon for now
      case 'github':
        return Icons.integration_instructions_outlined; // Using a generic icon for now
      case 'google':
        return Icons.g_mobiledata; // Using a generic icon for now
      case 'other':
        return Icons.public;
      default:
        return Icons.public; // Default icon for unknown platforms
    }
  }

  Color _getPlatformColor(String? platform) {
    switch (platform?.toLowerCase()) {
      case 'facebook':
        return Colors.blue[700]!;
      case 'twitter':
        return Colors.lightBlue[400]!;
      case 'instagram':
        return Colors.pink[400]!;
      case 'linkedin':
        return Colors.blue[800]!;
      case 'github':
        return Colors.grey[900]!;
      case 'google':
        return Colors.red[700]!;
      case 'other':
        return Colors.grey[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Accounts'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSocialAccount,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSocialAccounts,
              decoration: InputDecoration(
                hintText: 'Search social accounts...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      )
                    : _filteredSocialAccounts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No social accounts added yet.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _addSocialAccount,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Social Account'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredSocialAccounts.length,
                              itemBuilder: (context, index) {
                                final account = _filteredSocialAccounts[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => SocialAccountDetailsDialog(account: account),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(15),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: _getPlatformColor(account.platform).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  _getPlatformIcon(account.platform),
                                                  color: _getPlatformColor(account.platform),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      account.platform ?? 'Unknown Platform',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      account.username ?? 'N/A',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuButton<String>(
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    _editSocialAccount(account);
                                                  } else if (value == 'delete') {
                                                    _deleteSocialAccount(account.id ?? '');
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit, size: 20),
                                                        SizedBox(width: 8),
                                                        Text('Edit'),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                                        SizedBox(width: 8),
                                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (account.link != null && account.link!.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                const Icon(Icons.link, size: 16, color: Colors.grey),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    account.link!,
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSocialAccount,
        icon: const Icon(Icons.add),
        label: const Text('Add Social Account'),
      ),
    );
  }
} 