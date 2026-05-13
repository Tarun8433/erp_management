import 'package:flutter/material.dart';

enum AlertTone { warning, info, success, neutral }

class AlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final AlertTone tone;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.tone = AlertTone.neutral,
    this.onTap,
  });

  Color _toneColor(ColorScheme c) {
    switch (tone) {
      case AlertTone.warning:
        return c.error;
      case AlertTone.info:
        return c.primary;
      case AlertTone.success:
        return c.tertiary;
      case AlertTone.neutral:
        return c.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final accent = _toneColor(colorScheme);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
