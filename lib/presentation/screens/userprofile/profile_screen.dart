import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/routes_name.dart';
import '../../../core/services/auth_service.dart';
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
            text: 'Sign Out',
            onPressed: _handleSignOut,
            backgroundColor: AppColors.errorColor,
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
    try {
      await _authService.signOut();

      if (mounted) {
        // Navigate back to GetStarted screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.getStartedScreen,
          (route) => false,
        );
      }
    } catch (e) {
      _showError('Failed to sign out');
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
}
