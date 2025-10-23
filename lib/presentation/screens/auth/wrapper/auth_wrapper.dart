import 'package:ecommerce_app/presentation/navigation/main_navigation.dart';
import 'package:ecommerce_app/presentation/screens/auth/get_start_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, show Main Navigation (with bottom nav)
        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigation(); // CHANGED: Go to MainNavigation instead of HomeScreen
        }

        // If user is not logged in, show Get Started Screen
        return const GetStartScreen();
      },
    );
  }
}
