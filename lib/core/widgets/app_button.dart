import 'package:flutter/material.dart';

enum AppButtonType { primary, secondary, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final AppButtonType type;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (type) {
      AppButtonType.primary =>
        icon == null
            ? FilledButton(onPressed: onPressed, child: Text(label))
            : FilledButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(label),
              ),
      AppButtonType.secondary =>
        icon == null
            ? OutlinedButton(onPressed: onPressed, child: Text(label))
            : OutlinedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(label),
              ),
      AppButtonType.danger =>
        icon == null
            ? FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                ),
                child: Text(label),
              )
            : FilledButton.icon(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                ),
                icon: Icon(icon),
                label: Text(label),
              ),
    };
  }
}
