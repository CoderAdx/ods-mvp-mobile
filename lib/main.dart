import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/usage_history_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/interactions_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ODS MVP',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/usage_history': (context) => const UsageHistoryScreen(),
        '/goals': (context) => const GoalsScreen(),
        '/interactions': (context) => const InteractionsScreen(),
      },
    );
  }
}
