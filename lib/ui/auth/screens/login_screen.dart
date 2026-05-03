import 'package:flee_front/ui/auth/screens/register_screen.dart';
import 'package:flee_front/ui/auth/viewmodels/login_view_model.dart';
import 'package:flee_front/ui/auth/widgets/auth_button_widget.dart';
import 'package:flee_front/ui/auth/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const msgWelcomeBack = "Welcome back - you were never fleeting!";
  static const msgLogIn = "Log in";
  static const msgNewAccount = "Create new account";
  static const msgThisAccount = "Or continue with";

  static const textLogin = "Login";
  static const textUser = "Username/email";
  static const textPassword = "Password";

  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    msgLogIn,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    msgWelcomeBack,
                    style: TextStyle(color: Color(0xFF9BB4D1), fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  TextFieldWidget(
                    controller: identifierController,
                    label: textUser,
                    labelColor: const Color(0xFF42A5F5),
                    borderColor: const Color(0xFF42A5F5),
                    fillColor: const Color(0xFF1A1F2E),
                  ),
                  const SizedBox(height: 12),
                  TextFieldWidget(
                    controller: passwordController,
                    label: textPassword,
                    obscure: true,
                    labelColor: const Color(0xFF42A5F5),
                    borderColor: const Color(0xFF42A5F5),
                    fillColor: const Color(0xFF1A1F2E),
                  ),

                  // AJUSTE INDISPENSABLE: Mostrar error de login si existe
                  if (model.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        model.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 30),

                  IntrinsicWidth(
                    child: AuthButtonWidget(
                      textButton: textLogin,
                      loading: model.isLoading,
                      color: const Color(0xFF1E88E5),
                      textColor: Colors.white,
                      loaderColor: Colors.white,
                      onPressed: () {
                        model.login(
                          identifierController.text.trim(),
                          passwordController.text.trim(),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      msgNewAccount,
                      style: TextStyle(color: Color(0xFF42A5F5), fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    msgThisAccount,
                    style: TextStyle(color: Color(0xFF9BB4D1), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.g_mobiledata, size: 40, color: Colors.white),
                      SizedBox(width: 20),
                      Icon(Icons.facebook, size: 32, color: Colors.white),
                      SizedBox(width: 20),
                      Icon(Icons.apple, size: 32, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
