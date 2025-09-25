import 'package:flutter/material.dart';

class SocialIconButton extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  const SocialIconButton({required this.icon, this.backgroundColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(30),
      child: Ink(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? Colors.grey,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
