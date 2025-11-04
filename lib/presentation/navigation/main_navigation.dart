import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:ecommerce_app/core/constants/app_colors.dart';
import 'package:ecommerce_app/presentation/widgets/app_bottom_nav.dart';
import 'package:ecommerce_app/presentation/screens/home/home_screen.dart';
import 'package:ecommerce_app/presentation/screens/wishlist/wishlist_screen.dart';
import 'package:ecommerce_app/presentation/screens/chatbot/chatbot_screen.dart';
import 'package:ecommerce_app/presentation/screens/cart/cart_screen.dart';
import 'package:ecommerce_app/presentation/screens/userprofile/profile_screen.dart';
import 'package:ecommerce_app/core/providers/nav_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late final List<GlobalKey<NavigatorState>> _navigatorKeys;
  late final List<Widget> _screens;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    _navigatorKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());

    _screens = const [
      HomeScreen(),
      WishlistScreen(),
      ChatbotScreen(),
      CartScreen(),
      ProfileScreen(),
    ];
  }

  void _selectTab(int i) {
    final nav = context.read<NavProvider>();
    if (nav.index == i) {
      // Re-tap: pop that tab to its root
      _navigatorKeys[i].currentState?.popUntil((r) => r.isFirst);
    } else {
      nav.setIndex(i);
    }
  }

  Future<bool> _handleBackButton() async {
    final nav = context.read<NavProvider>();
    final currentNav = _navigatorKeys[nav.index].currentState;

    // First, try to pop within the current tab's navigator
    if (currentNav != null && currentNav.canPop()) {
      currentNav.pop();
      return false; // Don't exit app
    }

    // If not on home tab, switch to home
    if (nav.index != 0) {
      nav.setIndex(0);
      return false; // Don't exit app
    }

    // Already on home tab and at root - implement double-tap to exit
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;

      // Show snackbar message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false; // Don't exit app
    }

    // Double-tap confirmed - exit app
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldExit = await _handleBackButton();
          if (shouldExit && mounted) {
            // Exit the app
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: _BodyBuilder(navigatorKeys: _navigatorKeys, screens: _screens),
        bottomNavigationBar: _BottomNavBuilder(onTap: _selectTab),
        backgroundColor: AppColors.backgroundColor,
      ),
    );
  }
}

class _BodyBuilder extends StatelessWidget {
  final List<GlobalKey<NavigatorState>> navigatorKeys;
  final List<Widget> screens;

  const _BodyBuilder({required this.navigatorKeys, required this.screens});

  @override
  Widget build(BuildContext context) {
    final index = context.select<NavProvider, int>((nav) => nav.index);

    return IndexedStack(
      index: index,
      children: List.generate(
        5,
        (i) => _TabNavigator(navigatorKey: navigatorKeys[i], child: screens[i]),
      ),
    );
  }
}

class _BottomNavBuilder extends StatelessWidget {
  final Function(int) onTap;

  const _BottomNavBuilder({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final index = context.select<NavProvider, int>((nav) => nav.index);

    return AppBottomNav(currentIndex: index, onTap: onTap);
  }
}

class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const _TabNavigator({required this.navigatorKey, required this.child});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (_) => child, settings: settings),
    );
  }
}
