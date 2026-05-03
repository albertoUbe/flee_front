import 'package:flee_front/ui/auth/viewmodels/register_view_model.dart';
import 'package:flee_front/ui/auth/widgets/auth_button_widget.dart';
import 'package:flee_front/ui/auth/widgets/birthday_picker_widget.dart';
import 'package:flee_front/ui/auth/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const titleCreateAccount = "Create Account";
  static const subtitleCreateAccount = "Create an account in a fleeting moment";
  static const labelName = "Name";
  static const labelUserName = "User name";
  static const labelEmail = "Email";
  static const labelPassword = "Password";
  static const labelConfirmPassword = "Confirm password";
  static const btnSignUp = "Sign up";
  static const textAlreadyHave = "Already have an account?";
  static const passwordError = "Password do not match";

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterViewModel>();

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
                    titleCreateAccount,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    subtitleCreateAccount,
                    style: TextStyle(color: Color(0xFF9BB4D1), fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  TextFieldWidget(
                    controller: nameController,
                    label: labelName,
                    labelColor: const Color(0xFF42A5F5),
                    borderColor: const Color(0xFF42A5F5),
                    fillColor: const Color(0xFF1A1F2E),
                  ),
                  const SizedBox(height: 12),

                  TextFieldWidget(
                    controller: usernameController,
                    label: labelUserName,
                    labelColor: const Color(0xFF42A5F5),
                    borderColor: const Color(0xFF42A5F5),
                    fillColor: const Color(0xFF1A1F2E),
                  ),
                  const SizedBox(height: 12),

                  TextFieldWidget(
                    controller: emailController,
                    label: labelEmail,
                    labelColor: const Color(0xFF42A5F5),
                    borderColor: const Color(0xFF42A5F5),
                    fillColor: const Color(0xFF1A1F2E),
                  ),
                  const SizedBox(height: 12),

                  TextFieldWidget(
                    controller: passwordController,
                    label: labelPassword,
                    obscure: true,
                    labelColor: const Color(0xFF42A5F5),
                    borderColor: const Color(0xFF42A5F5),
                    fillColor: const Color(0xFF1A1F2E),
                  ),
                  const SizedBox(height: 12),

                  TextFieldWidget(
                    controller: confirmController,
                    label: labelConfirmPassword,
                    obscure: true,
                    labelColor: const Color(0xFF42A5F5),
                    borderColor: const Color(0xFF42A5F5),
                    fillColor: const Color(0xFF1A1F2E),
                  ),

                  BirthdayPickerWidget(
                    selectedDate: selectedDate,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1920),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => selectedDate = date);
                    },
                  ),
                  const SizedBox(height: 12),

                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  const SizedBox(height: 30),

                  IntrinsicWidth(
                    child: AuthButtonWidget(
                      textButton: btnSignUp,
                      loading: viewModel.isLoading,
                      color: const Color(0xFF1E88E5),
                      onPressed: () {
                        if (passwordController.text != confirmController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(passwordError),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        viewModel.signUp(
                          name: usernameController.text,
                          username: usernameController.text.trim(),
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                          birthday: selectedDate,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      textAlreadyHave,
                      style: TextStyle(color: Color(0xFF42A5F5), fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
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
