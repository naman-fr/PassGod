import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/breach_alert.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:passgod_mobile/widgets/app_drawer.dart';

class BreachMonitorScreen extends StatefulWidget {
  const BreachMonitorScreen({Key? key}) : super(key: key);

  @override
  _BreachMonitorScreenState createState() => _BreachMonitorScreenState();
}

class _BreachMonitorScreenState extends State<BreachMonitorScreen> with SingleTickerProviderStateMixin {
  List<BreachAlert> _alerts = [];
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchBreachAlerts();
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

  Future<void> _fetchBreachAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();
      final token = authProvider.token;
      if (token != null) {
        final fetchedAlerts = await apiService.getBreachAlerts(token);
        setState(() {
          _alerts = fetchedAlerts;
        });
      } else {
        throw Exception('Authentication token not found.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load breach alerts: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkPasswordsForBreach() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();
      final token = authProvider.token;
      if (token != null) {
        await apiService.checkPasswordsForBreach(token);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password breach check initiated.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchBreachAlerts();
      } else {
        throw Exception('Authentication token not found.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initiate password breach check: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkEmailForBreach() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();
      final token = authProvider.token;
      if (token != null) {
        await apiService.checkEmailForBreach(token);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email breach check initiated.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchBreachAlerts();
      } else {
        throw Exception('Authentication token not found.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initiate email breach check: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resolveBreachAlert(String alertId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();
      final token = authProvider.token;
      if (token != null) {
        await apiService.resolveBreachAlert(token, alertId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Breach alert marked as resolved.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchBreachAlerts();
      } else {
        throw Exception('Authentication token not found.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resolve breach alert: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  IconData _getBreachSeverityIcon(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'high':
        return Icons.dangerous;
      case 'medium':
        return Icons.warning;
      case 'low':
        return Icons.info;
      default:
        return Icons.security;
    }
  }

  Color _getBreachSeverityColor(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return Colors.lightGreen;
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
                    'Breach Monitor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _fetchBreachAlerts,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check if your credentials have been leaked and manage alerts.',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _checkPasswordsForBreach,
                          icon: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Icon(Icons.password, color: Colors.white),
                          label: Text(
                            _isLoading ? 'Checking Passwords...' : 'Check My Passwords',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _checkEmailForBreach,
                          icon: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Icon(Icons.email, color: Colors.white),
                          label: Text(
                            _isLoading ? 'Checking Email...' : 'Check My Email',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Breach Alerts',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading && _alerts.isEmpty
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
                                    onPressed: _fetchBreachAlerts,
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
                          : _alerts.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.verified_user,
                                        size: 64,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "No breach alerts found. You're safe!",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: _fetchBreachAlerts,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  itemCount: _alerts.length,
                                  itemBuilder: (context, index) {
                                    final alert = _alerts[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 16.0),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      color: alert.isResolved ? Colors.white70 : Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: _getBreachSeverityColor(alert.severity).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(
                                                    _getBreachSeverityIcon(alert.severity),
                                                    color: _getBreachSeverityColor(alert.severity),
                                                    size: 30,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Platform: ${alert.platform ?? 'N/A'}',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                          color: alert.isResolved ? Colors.grey[700] : Colors.black,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Severity: ${alert.severity ?? 'N/A'}',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: _getBreachSeverityColor(alert.severity),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (!alert.isResolved)
                                                  TextButton(
                                                    onPressed: () => _resolveBreachAlert(alert.id!),
                                                    child: const Text(
                                                      'Resolve',
                                                      style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                                    ),
                                                  )
                                                else
                                                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Description: ${alert.description ?? 'No description provided.'}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: alert.isResolved ? Colors.grey[600] : Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Breach Date: ${alert.breachDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: alert.isResolved ? Colors.grey[600] : Colors.grey[700],
                                              ),
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