import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AppLogo extends StatelessWidget {
  final double? size;
  final bool showText;
  final bool addShadow;
  
  const AppLogo({
    Key? key,
    this.size,
    this.showText = false,
    this.addShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logoSize = size ?? 120.0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Image
        Container(
          width: logoSize,
          height: logoSize,
          decoration: addShadow ? BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ) : null,
          child: Image.asset(
            'assets/images/inturn_logo.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
          ),
        ),
        
        // App name text (optional)
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'InTurn',
            style: TextStyle(
              fontSize: logoSize * 0.25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Internship Platform',
            style: TextStyle(
              fontSize: logoSize * 0.12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }
}

// Alternative compact logo for smaller spaces
class AppLogoCompact extends StatelessWidget {
  final double? size;
  final bool addShadow;
  
  const AppLogoCompact({
    Key? key,
    this.size,
    this.addShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logoSize = size ?? 40.0;
    
    return Container(
      width: logoSize,
      height: logoSize,
      decoration: addShadow ? BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ) : null,
      child: Image.asset(
        'assets/images/inturn_logo.png',
        width: logoSize,
        height: logoSize,
        fit: BoxFit.contain,
      ),
    );
  }
}
