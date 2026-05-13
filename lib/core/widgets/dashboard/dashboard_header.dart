import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String avatarText;
  final String? avatarImageUrl;
  final String title;
  final String subtitle;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final int notificationCount;

  const DashboardHeader({
    super.key,
    required this.avatarText,
    this.avatarImageUrl,
    required this.title,
    required this.subtitle,
    this.onNotificationTap,
    this.onAvatarTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: colorScheme.primary,
              backgroundImage: avatarImageUrl != null
                  ? NetworkImage(avatarImageUrl!)
                  : null,
              child: avatarImageUrl == null
                  ? (onAvatarTap != null
                        ? Icon(
                            Icons.menu,
                            color: colorScheme.onPrimaryContainer,
                          )
                        : Text(
                            avatarText,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ))
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: onNotificationTap,
                icon: Icon(
                  Icons.notifications_outlined,
                  color: colorScheme.onSurface,
                ),
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$notificationCount',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onError,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
