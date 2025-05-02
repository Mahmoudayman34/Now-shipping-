import 'package:flutter/material.dart';

/// A reusable action item button for order actions
class ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? backgroundColor;

  const ActionItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: titleColor ?? const Color(0xff2F2F2F)),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: titleColor ?? const Color(0xff2F2F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}