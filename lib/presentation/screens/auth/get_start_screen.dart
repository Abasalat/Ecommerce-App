import 'package:ecommerce_app/core/constants/app_colors.dart';
import 'package:ecommerce_app/core/constants/app_constants.dart';
import 'package:ecommerce_app/core/routes/routes_name.dart';
import 'package:ecommerce_app/presentation/widgets/custom_button.dart';
import 'package:ecommerce_app/presentation/widgets/text_link_widget.dart';
import 'package:flutter/material.dart';

class GetStartScreen extends StatelessWidget {
  const GetStartScreen({super.key});

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
              const Spacer(flex: 3),

              // Logo Section
              _buildLogo(),

              const SizedBox(height: AppConstants.xLargeSpacing),

              // Welcome Text Section
              _buildWelcomeText(context),

              const Spacer(flex: 2),

              // Get Started Button using CustomButton
              CustomButton(
                text: AppConstants.getStartedButton,
                onPressed: () => _handleGetStarted(context),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Already have account link using TextLinkWidget
              TextLinkWidget(
                text: '',
                linkText: AppConstants.alreadyHaveAccount,
                onPressed: () => _navigateToLogin(context),
                showArrow: true,
              ),

              const SizedBox(height: AppConstants.xLargeSpacing),
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
              color: AppColors.shadowColor,
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
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
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.shopping_bag,
                  size: 80,
                  color: AppColors.primaryColor,
                ),
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
          AppConstants.welcomeTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallSpacing + 4),
        Text(
          AppConstants.welcomeSubtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        Text(
          AppConstants.welcomeDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Navigation handler
  void _handleGetStarted(BuildContext context) {
    Navigator.pushNamed(context, RoutesName.signUpScreen);
  }

  // Navigation to the Login
  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, RoutesName.loginScreen);
  }
}
