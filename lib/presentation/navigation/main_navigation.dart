import 'package:flutter/material.dart';
import 'package:ecommerce_app/core/constants/app_colors.dart';
import 'package:ecommerce_app/presentation/widgets/app_bottom_nav.dart';
import 'package:ecommerce_app/presentation/screens/home/home_screen.dart';
import 'package:ecommerce_app/presentation/screens/wishlist/wishlist_screen.dart';
import 'package:ecommerce_app/presentation/screens/chatbot/chatbot_screen.dart';
import 'package:ecommerce_app/presentation/screens/cart/cart_screen.dart';
import 'package:ecommerce_app/presentation/screens/userprofile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  // One navigator per tab to keep its own back stack
  final _navigatorKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());

  void _selectTab(int i) {
    if (_index == i) {
      // re-tap: pop that tab to root
      _navigatorKeys[i].currentState?.popUntil((r) => r.isFirst);
    } else {
      setState(() => _index = i);
    }
  }

  Future<bool> _onWillPop() async {
    final currentNav = _navigatorKeys[_index].currentState!;
    if (currentNav.canPop()) {
      currentNav.pop();
      return false;
    }
    if (_index != 0) {
      setState(() => _index = 0);
      return false;
    }
    return true; // allow app to exit
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            _TabNavigator(
              navigatorKey: _navigatorKeys[0],
              child: const HomeScreen(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[1],
              child: const WishlistScreen(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[2],
              child: const ChatbotScreen(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[3],
              child: const CartScreen(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[4],
              child: const ProfileScreen(),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _index,
          onTap: _selectTab,
        ),
        backgroundColor: AppColors.backgroundColor,
      ),
    );
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
