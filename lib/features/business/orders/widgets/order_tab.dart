import 'package:flutter/material.dart';

class OrderTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const OrderTab({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xff8cc3d8),
              width: 1,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.blue.shade800 : const Color(0xff2F2F2F),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}