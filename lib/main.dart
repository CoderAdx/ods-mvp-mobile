import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/interactions_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/interaction_history_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(primarySwatch: Colors.pink);

    return MaterialApp(
      title: 'ODS MVP',
      theme: baseTheme.copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/usage_history': (context) => const InteractionHistoryScreen(),
        '/goals': (context) => const GoalsScreen(),
        '/interactions': (context) => const InteractionsScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
