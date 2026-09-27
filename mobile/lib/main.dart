import 'package:flutter/material.dart';
import 'frontend/home_screen.dart';
import 'frontend/add_firearm_screen.dart';
import 'frontend/onboarding_screen.dart';


 void main() {
  runApp(const ArmaVaultApp());
}

class ArmaVaultApp extends StatelessWidget {
  const ArmaVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ArmaVault',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B101D),
        primaryColor: const Color(0xFF3B82F6),
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          surface: Color(0xFF0B101D),
        ),
      ),
      // Starts with the Onboarding Screen by default
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/add_firearm': (context) => const AddFirearmScreen(),
      },
    );
  }
} 