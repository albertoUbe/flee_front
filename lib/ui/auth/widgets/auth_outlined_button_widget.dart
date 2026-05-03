import 'package:flutter/material.dart';

class AuthOutlinedButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;

  const AuthOutlinedButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderColor = const Color(0xFF23B7FC),
    this.textColor = const Color(0xFF23B7FC),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor),
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
