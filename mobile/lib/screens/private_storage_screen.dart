import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passgod_mobile/services/private_storage_service.dart';
import 'package:passgod_mobile/providers/auth_provider.dart';
import 'package:passgod_mobile/widgets/pattern_lock.dart';
import 'package:passgod_mobile/widgets/pin_lock.dart';
import 'package:passgod_mobile/models/private_item.dart';
import 'package:passgod_mobile/widgets/app_drawer.dart';
import 'package:passgod_mobile/widgets/add_private_item_dialog.dart';
import 'package:passgod_mobile/widgets/private_item_details_dialog.dart';

class PrivateStorageScreen extends StatefulWidget {
  const PrivateStorageScreen({Key? key}) : super(key: key);

  @override
  State<PrivateStorageScreen> createState() => _PrivateStorageScreenState();
}

class _PrivateStorageScreenState extends State<PrivateStorageScreen> {
  bool _isLocked = true;
  bool _isLoading = true;
  String? _errorMessage;
  List<PrivateItem> _privateItems = [];
  List<PrivateItem> _filteredPrivateItems = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedItemType = 'all';
  final PrivateStorageService _storageService = PrivateStorageService();
  bool _isInitialized = false;
  String? _selectedSetupLockType;

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
    _searchController.addListener(() {
      _filterItems(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkLockStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await _storageService.getStatus(authProvider.token!);
      setState(() {
        _isInitialized = response['is_initialized'] ?? false;
        _isLocked = response['is_locked'] ?? true;
        _isLoading = false;
      });
      if (_isInitialized && !_isLocked) {
        _loadPrivateItems();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to check lock status: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPrivateItems() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final items = await _storageService.getItems(
        authProvider.token!,
        itemType: _selectedItemType == 'all' ? null : _selectedItemType,
      );
      setState(() {
        _privateItems = items;
        _filterItems(_searchController.text);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load private items: ${e.toString()}';
      });
    }
  }

  Future<void> _unlockWithPattern(String pattern) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await _storageService.unlock(authProvider.token!, pattern: pattern);
      setState(() {
        _isLocked = false;
      });
      _loadPrivateItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unlock: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _unlockWithPin(String pin) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await _storageService.unlock(authProvider.token!, pin: pin);
      setState(() {
        _isLocked = false;
      });
      _loadPrivateItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unlock: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _setupWithPattern(String pattern) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await _storageService.setup(authProvider.token!, pattern: pattern);
      setState(() {
        _isInitialized = true;
        _isLocked = false;
      });
      _loadPrivateItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Private storage setup successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to setup private storage: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _setupWithPin(String pin) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await _storageService.setup(authProvider.token!, pin: pin);
      setState(() {
        _isInitialized = true;
        _isLocked = false;
      });
      _loadPrivateItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Private storage setup successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to setup private storage: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterItems(String query) {
    setState(() {
      _filteredPrivateItems = _privateItems.where((item) {
        final title = item.metadata?['title']?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return title.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _addPrivateItem() async {
    await showDialog(
      context: context,
      builder: (context) => AddPrivateItemDialog(
        onSave: (type, data, metadata) async {
          try {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await _storageService.createItem(authProvider.token!, type, data, metadata);
            _loadPrivateItems();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item added successfully!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add item: ${e.toString()}')),
            );
          }
        },
      ),
    );
  }

  Future<void> _deletePrivateItem(String itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Private Item'),
        content: const Text('Are you sure you want to delete this item? This action cannot be undone.'),
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

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await _storageService.deleteItem(authProvider.token!, itemId);
      _loadPrivateItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Setup Private Storage')),
        body: Center(
          child: _selectedSetupLockType == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Choose a security method for your private storage:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedSetupLockType = 'pin';
                        });
                      },
                      icon: const Icon(Icons.dialpad),
                      label: const Text('Setup PIN Lock'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedSetupLockType = 'pattern';
                        });
                      },
                      icon: const Icon(Icons.pattern),
                      label: const Text('Setup Pattern Lock'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                )
              : _selectedSetupLockType == 'pin'
                  ? PinLock(onComplete: _setupWithPin, isSetupMode: true)
                  : PatternLock(onComplete: _setupWithPattern, isSetupMode: true),
        ),
      );
    } else if (_isLocked) {
      return Scaffold(
        appBar: AppBar(title: const Text('Unlock Private Storage')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter your PIN or Pattern to unlock private storage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedSetupLockType = 'pin';
                  });
                },
                icon: const Icon(Icons.dialpad),
                label: const Text('Unlock with PIN'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedSetupLockType = 'pattern';
                  });
                },
                icon: const Icon(Icons.pattern),
                label: const Text('Unlock with Pattern'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              if (_selectedSetupLockType != null) ...[
                const SizedBox(height: 30),
                _selectedSetupLockType == 'pin'
                    ? PinLock(onComplete: _unlockWithPin, isSetupMode: false)
                    : PatternLock(onComplete: _unlockWithPattern, isSetupMode: false),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Private Storage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_open),
            onPressed: () {
              setState(() {
                _isLocked = true;
              });
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterItems,
              decoration: InputDecoration(
                hintText: 'Search private items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: _selectedItemType,
              items: const [
                DropdownMenuItem(
                  value: 'all',
                  child: Text('All Items'),
                ),
                DropdownMenuItem(
                  value: 'photo',
                  child: Text('Photos'),
                ),
                DropdownMenuItem(
                  value: 'document',
                  child: Text('Documents'),
                ),
                DropdownMenuItem(
                  value: 'note',
                  child: Text('Notes'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedItemType = value!;
                });
                _loadPrivateItems();
              },
            ),
          ),
          Expanded(
            child: _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : _filteredPrivateItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.folder_open,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No private items yet.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _addPrivateItem,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Private Item'),
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
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredPrivateItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredPrivateItems[index];
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
                                  builder: (context) => PrivateItemDetailsDialog(
                                    item: item,
                                    onDelete: _deletePrivateItem,
                                  ),
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
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            _getItemTypeIcon(item.itemType),
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.metadata?['title'] ?? 'Untitled',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatDate(item.createdAt),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'delete') {
                                              _deletePrivateItem(item.id ?? '');
                                            }
                                          },
                                          itemBuilder: (context) => [
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
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPrivateItem,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  IconData _getItemTypeIcon(String type) {
    switch (type) {
      case 'photo':
        return Icons.photo;
      case 'document':
        return Icons.description;
      case 'note':
        return Icons.note;
      default:
        return Icons.folder;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}