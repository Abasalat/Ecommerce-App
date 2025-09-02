import 'package:ecommerce_app/core/constants/app_colors.dart';
import 'package:ecommerce_app/core/constants/app_constants.dart';
import 'package:ecommerce_app/core/routes/routes_name.dart';
import 'package:ecommerce_app/data/services/auth_service.dart';
import 'package:ecommerce_app/presentation/widgets/custom_button.dart';
import 'package:ecommerce_app/presentation/widgets/custom_text_field.dart';
import 'package:ecommerce_app/presentation/widgets/text_link_widget.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppConstants.forgotPasswordTitle,
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppConstants.largeSpacing),

              // Forgot Password header
              _buildForgotPasswordHeader(),

              const SizedBox(height: AppConstants.xLargeSpacing),

              // Content based on state
              _emailSent ? _buildSuccessContent() : _buildEmailForm(),

              const SizedBox(height: AppConstants.xLargeSpacing),

              // Action buttons
              _emailSent ? _buildSuccessButtons() : _buildResetButton(),

              const SizedBox(height: AppConstants.mediumSpacing),

              // Back to Login Link
              TextLinkWidget(
                text: '',
                linkText: 'Back to Login',
                onPressed: _navigateToLogin,
                icon: Icons.arrow_back,
                showArrow: false,
              ),

              const SizedBox(height: AppConstants.xLargeSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordHeader() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon illustration
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _emailSent ? Icons.email : Icons.lock_reset,
              size: 60,
              color: AppColors.primaryColor,
            ),
          ),
        ),

        const SizedBox(height: AppConstants.largeSpacing),

        Text(
          'Forgot Password',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 42,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Text(
          _emailSent
              ? 'We\'ve sent a password reset link to your email.'
              : 'Enter your email to reset your password.',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          labelText: 'Email',
          hintText: 'Enter your registered email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: AppConstants.mediumSpacing),

        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Enter the email address associated with your account and we\'ll send you a link to reset your password.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.successColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.mark_email_read, color: AppColors.successColor, size: 48),
          const SizedBox(height: 16),
          Text(
            'Check Your Email',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.successColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ve sent a password reset link to:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _emailController.text.trim(),
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Didn\'t receive the email? Check your spam folder or try again.',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return CustomButton(
      text: 'Send Reset Link',
      onPressed: _handleResetPassword,
      isLoading: _isLoading,
      icon: Icons.send,
    );
  }

  Widget _buildSuccessButtons() {
    return Column(
      children: [
        CustomButton(
          text: 'Resend Email',
          onPressed: _handleResetPassword,
          isLoading: _isLoading,
          backgroundColor: AppColors.accentColor,
          icon: Icons.refresh,
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        CustomButton(
          text: 'Open Email App',
          onPressed: _openEmailApp,
          isOutlined: true,
          icon: Icons.mail_outline,
        ),
      ],
    );
  }

  Future<void> _handleResetPassword() async {
    // Validate email
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email address');
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _showError('Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.resetPassword(email: _emailController.text.trim());

      if (mounted) {
        setState(() {
          _emailSent = true;
        });

        _showSuccess('Password reset email sent successfully!');
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

  void _openEmailApp() {
    _showInfo('Please check your email app for the reset link.');
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, RoutesName.loginScreen);
  }

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

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.infoColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
