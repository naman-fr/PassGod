import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:passgod_mobile/providers/auth_provider.dart'; // Make sure this path is correct

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/breach_monitor_screen.dart';
import 'screens/activity_notification_screen.dart';
import 'screens/settings_screen.dart'; // Import the new screen
import 'screens/vault_screen.dart'; // Import VaultScreen
import 'screens/social_screen.dart'; // Import SocialScreen
import 'screens/register_screen.dart'; // Import RegisterScreen

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => RegisterScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => DashboardScreen(),
        ),
        GoRoute(
          path: '/breach',
          builder: (context, state) => BreachMonitorScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => ActivityNotificationScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => SettingsScreen(),
        ),
        GoRoute(
          path: '/vault',
          builder: (context, state) => VaultScreen(),
        ),
        GoRoute(
          path: '/social',
          builder: (context, state) => SocialScreen(),
        ),
      ],
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final loggedIn = authProvider.isAuthenticated;
        final loggingIn = state.matchedLocation == '/login';

        if (!loggedIn && !loggingIn) {
          return '/login';
        }
        if (loggedIn && loggingIn) {
          return '/dashboard';
        }
        return null;
      },
    );

    return MaterialApp.router(
      title: 'PASSGOD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      routerConfig: _router,
    );
  }
} 