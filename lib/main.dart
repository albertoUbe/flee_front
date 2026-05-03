import 'package:flee_front/data/repositories/auth_repository_impl.dart';
import 'package:flee_front/data/services/auth_service.dart';
import 'package:flee_front/domain/use_cases/login_use_case.dart';
import 'package:flee_front/domain/use_cases/register_use_case.dart';
import 'package:flee_front/ui/auth/screens/welcome_screen.dart';
import 'package:flee_front/ui/auth/viewmodels/login_view_model.dart';
import 'package:flee_front/ui/auth/viewmodels/register_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  // Servicios y Repositorios (Singletons de facto aquí)
  final authService = AuthService();
  final authRepository = AuthRepositoryImpl(authService);

  // Casos de Uso
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository); // AÑADIDO

  runApp(
    MultiProvider(
      providers: [
        // Proveedor para Login
        ChangeNotifierProvider(create: (_) => LoginViewModel(loginUseCase)),

        // Proveedor para Registro (AÑADIDO)
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
        // He ajustado el color para que coincida con el 0xFF0A0F1F que usas en tus pantallas
        scaffoldBackgroundColor: const Color(0xFF0A0F1F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF42A5F5),
          brightness: Brightness.dark,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
