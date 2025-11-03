import 'package:ecommerce_app/core/constants/app_colors.dart';
import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/core/providers/cart_provider.dart';
import 'package:ecommerce_app/core/providers/nav_provider.dart';
import 'package:ecommerce_app/core/providers/theme_provider.dart';
import 'package:ecommerce_app/core/providers/wishlist_provider.dart';
import 'package:ecommerce_app/data/repositories/product_repository.dart';
import 'package:ecommerce_app/data/repositories/category_repository.dart'; // ✅ ADDED
import 'package:ecommerce_app/presentation/screens/auth/wrapper/auth_wrapper.dart';
import 'package:ecommerce_app/viewmodels/chatbot_viewmodel.dart';
import 'package:ecommerce_app/viewmodels/home_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ApiClient - Base provider
        Provider<ApiClient>(create: (_) => const ApiClient()),

        // ✅ ProductRepository - Derived from ApiClient
        ProxyProvider<ApiClient, ProductRepository>(
          update: (_, api, __) => ProductRepository(api),
        ),

        // ✅ ADDED: CategoryRepository - Derived from ApiClient
        ProxyProvider<ApiClient, CategoryRepository>(
          update: (_, api, __) => CategoryRepository(api),
        ),

        // ChatbotViewModel
        ChangeNotifierProvider(create: (_) => ChatbotViewModel()),

        // HomeViewModel
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(ProductRepository(ApiClient())),
        ),

        // Other providers
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()..initializeCart()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()..initialize()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'E-Commerce App',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const AuthWrapper(),
          onGenerateRoute: Routes.generateRoute,
        ),
      ),
    );
  }
}
