import 'package:ecommerce_app/core/constants/app_colors.dart';
import 'package:ecommerce_app/core/providers/theme_provider.dart';
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

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'E-Shop',
  //     debugShowCheckedModeBanner: false,
  //     theme: AppTheme.lightTheme,
  //     // Route Configuration
  //     initialRoute: RoutesName.getStartedScreen,
  //     onGenerateRoute: Routes.generateRoute,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'E-Commerce App',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme, // Your existing light theme
            darkTheme: AppTheme.darkTheme, // New dark theme
            initialRoute: RoutesName.getStartedScreen,
            onGenerateRoute: Routes.generateRoute,
          );
        },
      ),
    );
  }
}
