import 'package:ecommerce_app/core/constants/app_colors.dart';
import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/core/providers/cart_provider.dart';
import 'package:ecommerce_app/core/providers/nav_provider.dart';
import 'package:ecommerce_app/core/providers/theme_provider.dart';
import 'package:ecommerce_app/core/providers/wishlist_provider.dart';
import 'package:ecommerce_app/data/repositories/product_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/routes.dart';
import 'core/routes/routes_name.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => const ApiClient()),

        // Create ONE ProductRepository derived from ApiClient
        ProxyProvider<ApiClient, ProductRepository>(
          update: (_, api, __) => ProductRepository(api),
        ),

        // Your existing providers...
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
          theme: AppTheme.lightTheme, // your light theme
          darkTheme: AppTheme.darkTheme, // your dark theme
          initialRoute: RoutesName.getStartedScreen,
          onGenerateRoute: Routes.generateRoute,
        ),
      ),
    );
  }
}
