import 'package:ecommerce_app/core/constants/app_colors.dart';
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
          // TODO: Implement forgot password
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Forgot password feature coming soon!'),
            ),
          );
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
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual login logic here
      // For now, just simulate a delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.loginSuccess),
            backgroundColor: AppColors.successColor,
          ),
        );

        // Navigate to home screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.homeScreen,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToSignUp() {
    Navigator.pushReplacementNamed(context, RoutesName.signUpScreen);
  }
}
