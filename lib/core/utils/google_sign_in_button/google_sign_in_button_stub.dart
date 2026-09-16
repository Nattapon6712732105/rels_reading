import 'package:flutter/material.dart';

Widget buildGoogleSignInButton({
  required VoidCallback onNonWebPressed,
  bool isLoading = false,
}) {
  return Builder(
    builder: (context) => OutlinedButton.icon(
      onPressed: isLoading ? null : onNonWebPressed,
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontWeight: FontWeight.w900,
            fontSize: 16,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      label: const Text('เข้าสู่ระบบด้วย Google'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
    ),
  );
}
