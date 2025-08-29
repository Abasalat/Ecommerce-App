import 'package:ecommerce_app/core/constants/app_colors.dart';
import 'package:ecommerce_app/core/constants/app_constants.dart';
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
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
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
                bottom: keyboardHeight > 0
                    ? 20
                    : 0, // Add padding when keyboard is visible
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
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
            fontSize: isKeyboardVisible
                ? 36
                : 48, // Reduce font size when keyboard is visible
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

  Future<void> _handleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.signUpSuccess),
            backgroundColor: AppColors.successColor,
          ),
        );

        Navigator.pushReplacementNamed(context, RoutesName.loginScreen);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: ${e.toString()}'),
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

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, RoutesName.loginScreen);
  }
}
