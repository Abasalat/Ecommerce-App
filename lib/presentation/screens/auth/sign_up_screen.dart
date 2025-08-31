import 'package:ecommerce_app/core/constants/app_colors.dart';
import 'package:ecommerce_app/core/constants/app_constants.dart';
import 'package:ecommerce_app/core/services/auth_service.dart';
import 'package:ecommerce_app/core/routes/routes_name.dart';
import 'package:ecommerce_app/presentation/widgets/custom_button.dart';
import 'package:ecommerce_app/presentation/widgets/custom_text_field.dart';
import 'package:ecommerce_app/presentation/widgets/text_link_widget.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    // Cleaning up the controllers when the widget is disposed
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppConstants.defaultPadding,
                right: AppConstants.defaultPadding,
                bottom: keyboardHeight > 0 ? 20 : 0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    // Dynamic top spacing based on screen size and keyboard visibility
                    SizedBox(
                      height: isKeyboardVisible
                          ? AppConstants.mediumSpacing
                          : screenHeight * 0.05,
                    ),

                    // Sign Up header
                    _buildSignUpHeader(),

                    SizedBox(
                      height: isKeyboardVisible
                          ? AppConstants.largeSpacing
                          : AppConstants.xLargeSpacing,
                    ),

                    // Sign Up Form
                    _buildSignUpForm(),

                    SizedBox(
                      height: isKeyboardVisible
                          ? AppConstants.mediumSpacing
                          : AppConstants.xLargeSpacing,
                    ),

                    // Sign Up Button
                    CustomButton(
                      text: AppConstants.signUpButton,
                      onPressed: _handleSignUp,
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: AppConstants.mediumSpacing),

                    // Navigate to Login Screen
                    TextLinkWidget(
                      text: AppConstants.alreadyHaveAccountSignUp,
                      linkText: AppConstants.loginLink,
                      onPressed: _navigateToLogin,
                    ),

                    SizedBox(
                      height: isKeyboardVisible
                          ? AppConstants.mediumSpacing
                          : AppConstants.xLargeSpacing,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSignUpHeader() {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.signUpTitle,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isKeyboardVisible ? 36 : 48,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Text(
          AppConstants.signUpSubtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        // Full Name Field
        CustomTextField(
          controller: _fullNameController,
          labelText: AppConstants.fullNameLabel,
          keyboardType: TextInputType.name,
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: AppConstants.largeSpacing),

        // Email Field
        CustomTextField(
          controller: _emailController,
          labelText: AppConstants.emailLabel,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: AppConstants.largeSpacing),

        // Password Field
        CustomTextField(
          controller: _passwordController,
          labelText: AppConstants.passwordLabel,
          isPassword: true,
          prefixIcon: Icons.lock_outline,
        ),
        const SizedBox(height: AppConstants.largeSpacing),

        // Confirm Password Field
        CustomTextField(
          controller: _confirmPasswordController,
          labelText: AppConstants.confirmPasswordLabel,
          isPassword: true,
          prefixIcon: Icons.lock_outline,
        ),
      ],
    );
  }

  // Handle Sign Up Logic with Firebase
  Future<void> _handleSignUp() async {
    // Basic validation
    if (_fullNameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return;
    }

    if (_fullNameController.text.trim().length < 2) {
      _showError('Full name must be at least 2 characters long');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _showError('Please enter a valid email address');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Please enter a password');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters long');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Sign up with Firebase
      await _authService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      if (mounted) {
        _showSuccess('Account created successfully! Welcome to E-Shop!');

        // Wait a bit to show success message
        await Future.delayed(const Duration(milliseconds: 1500));

        // Navigate to home screen directly
        // The AuthWrapper will automatically detect the authenticated user
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.homeScreen,
          (route) => false, // Clear all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, RoutesName.loginScreen);
  }

  // Helper method to validate email format
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
