import 'package:flutter/material.dart';
import 'package:tes1/core/utils/status_colors.dart';

/// Widget that displays an individual tracking step in the timeline
class TrackingStepItem extends StatelessWidget {
  final bool isCompleted;
  final String title;
  final String status;
  final String description;
  final String time;
  final bool isFirst;
  final bool isLast;

  const TrackingStepItem({
    Key? key,
    required this.isCompleted,
    required this.title,
    required this.status,
    required this.description,
    required this.time,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the StatusColors utility for consistent coloring
    const Color completedColor = Color(0xFF25AB93); // Default green for completed
    final Color incompleteColor = Colors.grey.shade300;
    final Color titleColor = isCompleted 
        ? StatusColors.getTextColor(status) 
        : Colors.grey;
    
    // Calculate the height of the vertical line
    double lineHeight = isCompleted ? 65.0 : 60.0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (isCompleted)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completedColor,
                  border: Border.all(
                    color: completedColor,
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: incompleteColor,
                    width: 1,
                  ),
                ),
              ),
            if (!isLast)
              isCompleted
                ? Container(
                    width: 3,
                    height: lineHeight,
                    color: completedColor,
                  )
                : Column(
                    children: List.generate(
                      5,
                      (index) => Container(
                        width: 1,
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: incompleteColor,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ),
              if (time.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              SizedBox(height: isLast ? 0 : lineHeight - 24),
            ],
          ),
        ),
      ],
    );
  }
}