import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity_notification.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:passgod_mobile/widgets/app_drawer.dart';

class ActivityNotificationScreen extends StatefulWidget {
  const ActivityNotificationScreen({Key? key}) : super(key: key);

  @override
  _ActivityNotificationScreenState createState() => _ActivityNotificationScreenState();
}

class _ActivityNotificationScreenState extends State<ActivityNotificationScreen> with SingleTickerProviderStateMixin {
  List<ActivityNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchActivityNotifications();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchActivityNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();
      final token = authProvider.token;
      if (token != null) {
        final fetchedNotifications = await apiService.getActivityNotifications(token);
        setState(() {
          _notifications = fetchedNotifications;
        });
      } else {
        throw Exception('Authentication token not found.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load notifications: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();
      final token = authProvider.token;
      if (token != null) {
        await apiService.markNotificationAsRead(token, notificationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification marked as read.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchActivityNotifications();
      } else {
        throw Exception('Authentication token not found.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark notification as read: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'breach_alert':
        return Icons.security;
      case 'account_activity':
        return Icons.person;
      case 'login_alert':
        return Icons.login;
      default:
        return Icons.info_outline;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'breach_alert':
        return Colors.redAccent;
      case 'account_activity':
        return Colors.blueAccent;
      case 'login_alert':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  title: const Text(
                    'Activity Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoading && _notifications.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _fetchActivityNotifications,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
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
                          : _notifications.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.notifications_off,
                                        size: 64,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No activity notifications found.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: _fetchActivityNotifications,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Refresh'),
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
                                  padding: const EdgeInsets.all(16.0),
                                  itemCount: _notifications.length,
                                  itemBuilder: (context, index) {
                                    final notification = _notifications[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 16.0),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      color: notification.isRead ? Colors.white70 : Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: _getNotificationColor(notification.type).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                _getNotificationIcon(notification.type),
                                                color: _getNotificationColor(notification.type),
                                                size: 30,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    notification.message ?? 'No message',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: notification.isRead ? Colors.grey[700] : Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Type: ${notification.type ?? 'N/A'}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: notification.isRead ? Colors.grey[600] : Colors.grey[700],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Time: ${notification.createdAt?.toLocal().toString().split(' ')[0]} ${notification.createdAt?.toLocal().toString().split(' ')[1].substring(0, 5)}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: notification.isRead ? Colors.grey[600] : Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (!notification.isRead)
                                              Align(
                                                alignment: Alignment.bottomRight,
                                                child: TextButton(
                                                  onPressed: () => _markNotificationAsRead(notification.id!),
                                                  child: const Text(
                                                    'Mark as Read',
                                                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              )
                                            else
                                              const Align(
                                                alignment: Alignment.bottomRight,
                                                child: Icon(Icons.check_circle, color: Colors.green, size: 24),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 