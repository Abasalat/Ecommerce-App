import 'package:ecommerce_app/presentation/navigation/main_navigation.dart';
import 'package:ecommerce_app/presentation/screens/auth/forgot_password_screen.dart';
import 'package:ecommerce_app/presentation/screens/cart/cart_screen.dart';
import 'package:ecommerce_app/presentation/screens/chatbot/chatbot_screen.dart';
import 'package:ecommerce_app/presentation/screens/userprofile/profile_screen.dart';
import 'package:ecommerce_app/presentation/screens/wishlist/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/presentation/screens/auth/get_start_screen.dart';
import 'package:ecommerce_app/presentation/screens/auth/login_screen.dart';
import 'package:ecommerce_app/presentation/screens/auth/sign_up_screen.dart';
import 'package:ecommerce_app/presentation/screens/home/home_screen.dart';
import 'routes_name.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.getStartedScreen:
        return _createRoute(const GetStartScreen());

      case RoutesName.loginScreen:
        return _createRoute(const LoginScreen());

      case RoutesName.signUpScreen:
        return _createRoute(const SignUpScreen());

      case RoutesName.forgotPasswordScreen:
        return _createRoute(const ForgotPasswordScreen());

      case RoutesName.homeScreen:
        return _createRoute(const HomeScreen());

      // Add more routes as needed
      case RoutesName.profileScreen:
        return _createRoute(const ProfileScreen());

      // Add new routes for bottom navigation
      case RoutesName.mainNavigation:
        return _createRoute(const MainNavigation());

      case RoutesName.wishlistScreen:
        return _createRoute(const WishlistScreen());

      case RoutesName.chatbotScreen:
        return _createRoute(const ChatbotScreen());

      case RoutesName.cartScreen:
        return _createRoute(const CartScreen());
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text(
                'No route defined for this screen',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          ),
        );
    }
  }

  // Custom route with smooth transition
  static PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
