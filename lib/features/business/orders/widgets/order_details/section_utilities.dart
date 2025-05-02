import 'package:flutter/material.dart';

/// Container widget for each section of the order details
class SectionContainer extends StatelessWidget {
  final Widget child;

  const SectionContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Section header with icon and title
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF26A2B9)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2F2F2F),
          ),
        ),
      ],
    );
  }
}

/// Detail row with label and value
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;
  final bool isHighlighted;
  final Color? valueColor;

  const DetailRow({
    Key? key,
    required this.label,
    required this.value,
    this.maxLines = 1,
    this.isHighlighted = false,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
            color: valueColor ?? (isHighlighted ? const Color(0xFFF89C29) : const Color(0xFF2F2F2F)),
          ),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}