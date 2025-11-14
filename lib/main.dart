
import 'package:btask/providers/notifications_provider.dart';
import 'package:btask/routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// Application entry point
/// Initializes Flutter bindings and sets up the notification provider
/// before running the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (context) => NotificationProvider(),
      child: MyApp(),
    ),
  );
}

/// Root application widget
/// Configures screen responsiveness, routing, and theming for the entire app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize responsive design with 360x690 as base design dimensions
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: router, // Declarative routing configuration
          debugShowCheckedModeBanner: false,
          title: 'b_app',
          theme: ThemeData(primarySwatch: Colors.blue),
        );
      },
    );
  }
}