import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          // CONNECTING LINE
          return Expanded(
            child: Container(
              height: 2,
              color: index ~/ 2 < currentStep
                  ? const Color(0xff2563eb)
                  : Colors.grey.shade300,
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isCompleted = stepIndex < currentStep;
        final isActive = stepIndex == currentStep;

        return Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isCompleted || isActive
                  ? const Color(0xff2563eb)
                  : Colors.grey.shade300,
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      "${stepIndex + 1}",
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              ["Account", "Contact", "Address", "Security"][stepIndex],
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        );
      }),
    );
  }
}
