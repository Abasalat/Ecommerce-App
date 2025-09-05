import 'package:ecommerce_app/core/constants/app_colors.dart';
import 'package:ecommerce_app/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/routes_name.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/text_link_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Login Header
              _buildLoginHeader(),

              const SizedBox(height: AppConstants.xLargeSpacing),

              // Login Form
              _buildLoginForm(),

              const SizedBox(height: AppConstants.mediumSpacing),

              // Forgot Password Link
              _buildForgotPasswordLink(),

              const Spacer(),

              // Login Button
              CustomButton(
                text: AppConstants.loginButton,
                onPressed: _handleLogin,
                isLoading: _isLoading,
              ),

              const SizedBox(height: AppConstants.mediumSpacing),

              // Sign Up Link
              TextLinkWidget(
                text: AppConstants.dontHaveAccount,
                linkText: AppConstants.signUpLink,
                onPressed: () => _navigateToSignUp(),
              ),

              const SizedBox(height: AppConstants.xLargeSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginHeader() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.loginTitle,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 48,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Text(
          AppConstants.loginSubtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          labelText: AppConstants.emailLabel,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: AppConstants.largeSpacing),
        CustomTextField(
          controller: _passwordController,
          labelText: AppConstants.passwordLabel,
          isPassword: true,
          prefixIcon: Icons.lock_outline,
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Navigate to Forgot Password screen
          Navigator.pushNamed(context, RoutesName.forgotPasswordScreen);
        },
        child: Text(
          AppConstants.forgotPassword,
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    // Basic validation
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        _showSuccess('Login successful!');

        // Navigate to home screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.mainNavigation,
          (route) => false,
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.pushReplacementNamed(context, RoutesName.signUpScreen);
  }
}
