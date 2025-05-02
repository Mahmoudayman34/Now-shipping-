import 'package:flutter/material.dart';
import '../data/onboarding_items.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
        item.title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(height: 4),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
        item.description,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).hintColor,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.left,
          ),
        ),
        Center(child: Image.asset(item.imagePath, height: 400)),
      ],
    );
  }
}
