import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';

class StepButtons extends StatelessWidget {
  final int currentStep;
  final Function(int) onStepChanged;

  const StepButtons({
    super.key,
    required this.currentStep,
    required this.onStepChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return ElevatedButton(
          onPressed: () => onStepChanged(index + 1),
          child: Text(localizations.translateWithArgs('step_buttons', [(index + 1).toString()])),
        );
      }),
    );
  }
}