import 'package:flutter/material.dart';

class AuthButtonWidget extends StatelessWidget {
  final String textButton;
  final VoidCallback onPressed;
  final bool loading;

  final Color color;
  final Color textColor;
  final Color loaderColor;

  const AuthButtonWidget({
    super.key,
    required this.textButton,
    required this.onPressed,
    this.loading = false,
    this.color = const Color(0xFF23B7FC),
    this.textColor = Colors.white,
    this.loaderColor = const Color(0xFF23B7FC),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: loaderColor,
                  strokeWidth: 2,
                ),
              )
            : Text(textButton),
      ),
    );
  }
}
