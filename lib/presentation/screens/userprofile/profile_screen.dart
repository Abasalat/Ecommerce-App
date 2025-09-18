import 'package:ecommerce_app/core/providers/nav_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/routes_name.dart';
import 'package:ecommerce_app/data/services/auth_service.dart';
import '../../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final data = await _authService.getUserData(user.uid);
        setState(() {
          userData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surfaceColor,
        automaticallyImplyLeading: false,
        elevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleSignOut),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            child: Icon(Icons.person, size: 60, color: AppColors.primaryColor),
          ),

          const SizedBox(height: AppConstants.largeSpacing),

          // User Information Cards
          _buildInfoCard(
            title: 'Full Name',
            value: userData?['fullName'] ?? 'Not provided',
            icon: Icons.person_outline,
          ),

          _buildInfoCard(
            title: 'Email',
            value: user?.email ?? 'Not provided',
            icon: Icons.email_outlined,
          ),

          _buildInfoCard(
            title: 'Phone',
            value: userData?['phoneNumber'] ?? 'Not provided',
            icon: Icons.phone_outlined,
          ),

          _buildInfoCard(
            title: 'Member Since',
            value: _formatDate(userData?['createdAt']),
            icon: Icons.calendar_today_outlined,
          ),

          const SizedBox(height: AppConstants.xLargeSpacing),

          // Sign Out Button
          CustomButton(
            text: _isSigningOut ? 'Signing Out...' : 'Sign Out',
            onPressed: _isSigningOut ? null : _handleSignOut,
            backgroundColor: AppColors.errorColor,
            isLoading: _isSigningOut,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.mediumSpacing),
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 24),
          const SizedBox(width: AppConstants.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _handleSignOut() async {
    final shouldSignOut = await _showSignOutDialog();
    if (!shouldSignOut) return;

    setState(() => _isSigningOut = true);

    try {
      await _authService.signOut();

      if (!mounted) return;

      // (optional) also reset your selected bottom tab to Home if you use a NavProvider
      context.read<NavProvider>().setIndex(0);

      // IMPORTANT: use the ROOT navigator so we exit the tab's inner navigator
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil(RoutesName.getStartedScreen, (route) => false);
    } catch (e) {
      if (mounted) {
        _showError('Failed to sign out: $e');
      }
    } finally {
      if (mounted) {
        // If navigation happened, this widget is disposed and this won’t run;
        // if it didn’t, this ensures the spinner stops.
        setState(() => _isSigningOut = false);
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

  Future<bool> _showSignOutDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sign Out'),
            content: Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Sign Out'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.errorColor,
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
