import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/community_provider.dart';
import 'providers/post_provider.dart';
import 'providers/plan_provider.dart';
import 'services/user_service.dart';
import 'services/community_service.dart';
import 'services/post_service.dart';
import 'services/plan_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final userService = UserService();
  final authProvider = AuthProvider(userService, prefs);
  await authProvider.tryRestoreSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) => CommunityProvider(CommunityService()),
        ),
        ChangeNotifierProvider(
          create: (_) => PostProvider(PostService(), UserService()),
        ),
        ChangeNotifierProvider(create: (_) => PlanProvider(PlanService())),
      ],
      child: const FleeApp(),
    ),
  );
}

class FleeApp extends StatelessWidget {
  const FleeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    return MaterialApp(
      title: 'Flee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: isLoggedIn ? const MainShell() : const LoginScreen(),
    );
  }
}
