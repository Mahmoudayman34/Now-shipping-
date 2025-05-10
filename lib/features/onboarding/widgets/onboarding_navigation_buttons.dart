import 'package:flutter/material.dart';

class OnboardingNavigationButtons extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final int currentIndex;
  final int totalItems;

  const OnboardingNavigationButtons({
    super.key,
    required this.onSkip,
    required this.onNext,
    required this.currentIndex,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentIndex == totalItems - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: onSkip,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Skip"),
        ),
        ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 105, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: isLastPage ? const Color(0xfff29620) : Colors.blue,
          ),
          child: Text(
            isLastPage ? 'Start' : 'Next',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}