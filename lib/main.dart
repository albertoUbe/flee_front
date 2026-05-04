import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flee_front/data/repositories/auth_repository_impl.dart';
import 'package:flee_front/data/services/auth_service.dart';
import 'package:flee_front/domain/use_cases/login_use_case.dart';
import 'package:flee_front/domain/use_cases/register_use_case.dart';
import 'package:flee_front/ui/auth/viewmodels/login_view_model.dart';
import 'package:flee_front/ui/auth/viewmodels/register_view_model.dart';
import 'package:flee_front/ui/auth/screens/login_screen.dart';
import 'package:flee_front/ui/auth/screens/register_screen.dart';
import 'package:flee_front/ui/auth/screens/welcome_screen.dart';
import 'package:flee_front/ui/auth/screens/home_screen.dart';

void main() {
  final authService = AuthService();
  final authRepository = AuthRepositoryImpl(authService);

  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel(loginUseCase)),
        ChangeNotifierProvider(
          create: (_) => RegisterViewModel(registerUseCase),
        ),
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
      debugShowCheckedModeBanner: false,
      title: 'Flee',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0F1F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF42A5F5),
          brightness: Brightness.dark,
        ),
      ),

      // --- CONFIGURACIÓN DE RUTAS ---

      // La ruta que se cargará al abrir la app
      initialRoute: '/',

      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(emailOrUser: "usuario@flee.com"),
      },

      // Manejo de rutas dinámicas (útil si necesitas pasar argumentos complejos)
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(emailOrUser: args ?? "Guest"),
          );
        }
        return null;
      },
    );
  }
}
