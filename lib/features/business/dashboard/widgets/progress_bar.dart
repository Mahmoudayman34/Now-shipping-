import 'package:flutter/material.dart';

/// A progress bar component that shows the current step in a multi-step form process.
class ProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;
  final Function(int)? onStepTap;
  
  // Define the theme color
  static const Color themeColor = Color(0xfff29620);

  const ProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onStepTap,
    this.stepLabels = const [
      "Email",
      "Brand",
      "Pickup",
      "Payment",
      "Type",
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line between steps
            return Expanded(
              child: Container(
                height: 2,
                color: (i ~/ 2) < currentStep - 1 ? themeColor : Colors.grey.shade300,
              ),
            );
          } else {
            final index = i ~/ 2;
            
            // Logic to distinguish between completed, current and future steps
            final isCompleted = index < currentStep - 1;  // Step is already completed
            final isCurrent = index == currentStep - 1;   // This is the current step
            // Note: Future steps are those where index > currentStep - 1

            Color circleColor;
            Widget inner;

            if (isCompleted) {
              circleColor = themeColor;
              inner = const Icon(Icons.check, color: Colors.white, size: 16);
            } else if (isCurrent) {
              circleColor = themeColor;
              inner = const Icon(Icons.radio_button_checked, color: Colors.white, size: 16);
            } else {
              circleColor = Colors.grey.shade400;
              inner = const Icon(Icons.circle, color: Colors.white, size: 10);
            }

            return GestureDetector(
              onTap: () {
                // Allow tapping on any step for free navigation
                if (onStepTap != null) {
                  onStepTap!(index);
                }
              },
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: circleColor,
                    radius: 16,
                    child: inner,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    index < stepLabels.length ? stepLabels[index] : "",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? themeColor : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}