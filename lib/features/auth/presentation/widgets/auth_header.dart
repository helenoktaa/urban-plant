import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    // icon dan iconColor dihapus, diganti logo
    IconData? icon,
    Color? iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
            'assets/images/urban-plant.png',
            width: 120,
            height: 80,
          ),
        
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}