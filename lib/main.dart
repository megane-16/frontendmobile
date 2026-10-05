import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bottom_navigation_bar.dart';
import 'constants/app_colors.dart';
import 'provider/auth_provider.dart';
import 'models/user_model.dart';
import 'views/login_view.dart';
import 'views/monitor_navigation.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          debugPrint("DEBUG MAIN: isAuthenticated=${auth.isAuthenticated}, User=${auth.user?.nom}, Role=${auth.user?.role}");
          
          if (auth.isAuthenticated) {
            if (auth.user?.role == UserRole.moniteur) {
              return const MonitorNavigation();
            }
            return const CustomBottomNavigationBar();
          }
          return const LoginView();
        },
      ),
    );
  }
}
