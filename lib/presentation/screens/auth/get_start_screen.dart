import 'dart:math';

import 'package:ecommerce_app/presentation/screens/auth/login_screen.dart';
import 'package:ecommerce_app/presentation/screens/auth/sign_up_screen.dart';
import 'package:flutter/material.dart';

class GetStartScreen extends StatelessWidget {
  const GetStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Logo Section
              _buildLogo(),

              const SizedBox(height: 30),

              // Welcome Text Section
              _buildWelcomeText(context),

              const Spacer(flex: 2),

              // Get Started Button
              _buildGetStartedButton(context),

              const SizedBox(height: 30),

              // Already have account link
              _buildLoginLink(context),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Logo Section
  Widget _buildLogo() {
    return Hero(
      tag: 'app_logo',
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey,
              spreadRadius: 1, // how much the shadow spreads
              blurRadius: 10, // how blurry the shadow is
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/app_logo.png',
            width: 150,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, StackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.shopping_bag, size: 80, color: Colors.blue),
              );
            },
          ),
        ),
      ),
    );
  }

  // Welcome Text Section
  Widget _buildWelcomeText(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          'Welcome to E-Shop',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Your one-stop shop for everything!',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Discover amazing products and deals.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Get Started Button
  Widget _buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // Add your navigation logic here
          _handleGetStarted(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Let\'s Get Started',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToLogin(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'I alrady have an account',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 18, color: Colors.blue[700]),
          ],
        ),
      ),
    );
  }

  // Navigation handler
  void _handleGetStarted(BuildContext context) {
    // Example navigation - replace with your actual navigation logic
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  // Navigation to the Login
  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
