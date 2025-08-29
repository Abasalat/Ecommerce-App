import 'package:ecommerce_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'core/routes/routes.dart';
import 'core/routes/routes_name.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Shop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Route Configuration
      initialRoute: RoutesName.getStartedScreen,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
