import 'package:ecommerce_app/core/providers/nav_provider.dart';
import 'package:ecommerce_app/presentation/screens/mostPopular/most_popular_products_screen.dart';
import 'package:ecommerce_app/presentation/screens/product/product_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/routes_name.dart';
import 'package:ecommerce_app/data/services/auth_service.dart';
import '../../widgets/custom_button.dart';

// Import your product-related widgets and models
import 'package:ecommerce_app/data/models/product.dart';
import 'package:ecommerce_app/data/repositories/product_repository.dart';
import 'package:ecommerce_app/presentation/widgets/most_popular_section.dart';
import 'package:ecommerce_app/presentation/widgets/just_for_you_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late final ProductRepository _productRepo;

  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool _isSigningOut = false;
  bool _firstSectionLoaded = false;
  bool _popularReady = false;
  bool _jfyReady = false;

  @override
  void initState() {
    super.initState();
    _productRepo = context.read<ProductRepository>();
    _loadUserData();
    _loadSections();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final data = await _authService.getUserData(user.uid);
        if (mounted) {
          setState(() {
            userData = data;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _showError('Failed to load user data');
      }
    }
  }

  Future<void> _loadSections() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _firstSectionLoaded = true;
        _popularReady = true;
        _jfyReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(isDark),
      backgroundColor: isDark
          ? AppColors.darkBackgroundColor
          : AppColors.backgroundColor,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.primaryLight : AppColors.primaryColor,
              ),
            )
          : CustomScrollView(
              slivers: [
                _buildProfileHeader(isDark),
                _buildQuickActions(isDark),
                _buildUserInfoSection(isDark),
                _buildMostPopularSection(),
                _buildJustForYouSection(),
                SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark
          ? AppColors.darkSurfaceColor
          : AppColors.surfaceColor,
      automaticallyImplyLeading: false,
      title: Text(
        'Profile',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
      actions: [
        // Settings
        IconButton(
          icon: Icon(
            Icons.settings_outlined,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () {
            _showSettingsBottomSheet(isDark);
          },
        ),
        // Logout
        IconButton(
          icon: Icon(Icons.logout, color: AppColors.errorColor),
          onPressed: _handleSignOut,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = userData?['fullName'] ?? 'User';
    final initials = userName.isNotEmpty
        ? userName.substring(0, 1).toUpperCase()
        : 'U';

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceColor : AppColors.surfaceColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Profile Picture with gradient border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isDark
                    ? AppColors.darkPrimaryGradient
                    : AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.darkShadowColor
                        : AppColors.shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: isDark
                    ? AppColors.darkBackgroundColor
                    : AppColors.backgroundColor,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.primaryLight
                        : AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User Name
            Text(
              userName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // User Email
            Text(
              user?.email ?? 'No email',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.shopping_bag_outlined,
                label: 'My Orders',
                color: AppColors.primaryColor,
                isDark: isDark,
                onTap: () {
                  // Navigate to orders
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.favorite_border,
                label: 'Wishlist',
                color: AppColors.errorColor,
                isDark: isDark,
                onTap: () {
                  // Navigate to wishlist using NavProvider
                  context.read<NavProvider>().setIndex(1);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.location_on_outlined,
                label: 'Address',
                color: AppColors.successColor,
                isDark: isDark,
                onTap: () {
                  // Navigate to addresses
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardColor : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorderColor : AppColors.borderColor,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: 'Full Name',
              value: userData?['fullName'] ?? 'Not provided',
              icon: Icons.person_outline,
              isDark: isDark,
            ),
            _buildInfoCard(
              title: 'Phone',
              value: userData?['phoneNumber'] ?? 'Not provided',
              icon: Icons.phone_outlined,
              isDark: isDark,
            ),
            _buildInfoCard(
              title: 'Member Since',
              value: _formatDate(userData?['createdAt']),
              icon: Icons.calendar_today_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardColor : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorderColor : AppColors.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
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

  Widget _buildMostPopularSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: !_firstSectionLoaded || !_popularReady
            ? const SizedBox.shrink()
            : MostPopularSection(
                productRepository: _productRepo,
                title: 'Most Popular',
                productLimit: 8,
                onSeeAllTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => MostPopularProductsScreen(),
                    ),
                  );
                },
                onProductTapFull: (Product p) {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: p),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildJustForYouSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: !_firstSectionLoaded || !_jfyReady
            ? const SizedBox.shrink()
            : JustForYouSection(
                productRepository: _productRepo,
                title: 'Just For You',
                onProductTap: (product) {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      final date = timestamp.toDate();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showSettingsBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceColor : AppColors.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              isDark: isDark,
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              isDark: isDark,
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              isDark: isDark,
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About',
              isDark: isDark,
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Future<void> _handleSignOut() async {
    final shouldSignOut = await _showSignOutDialog();
    if (!shouldSignOut) return;

    setState(() => _isSigningOut = true);

    try {
      await _authService.signOut();

      if (!mounted) return;

      context.read<NavProvider>().setIndex(0);

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark
                ? AppColors.darkCardColor
                : AppColors.surfaceColor,
            title: Text(
              'Sign Out',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            content: Text(
              'Are you sure you want to sign out?',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.errorColor,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
