import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/notifications_controller.dart';
import '../models/push_notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(NotificationsController());
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: NestedScrollView(
        controller: c.scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _SliverHeader(controller: c),
        ],
        body: Obx(() {
          if (c.isLoading.value) return _buildShimmer(scheme);
          if (c.hasError.value) return _buildError(context, c);
          if (c.items.isEmpty) return _buildEmpty(context);
          return _buildList(context, c, scheme);
        }),
      ),
      bottomNavigationBar: Obx(() {
        if (c.isLoading.value || c.unreadCount == 0) return const SizedBox.shrink();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: FilledButton.icon(
              onPressed: c.markAllAsRead,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.done_all_rounded),
              label: Obx(() => Text(
                    'Mark All as Read  (${c.unreadCount})',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  )),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildList(
    BuildContext context,
    NotificationsController c,
    ColorScheme scheme,
  ) {
    return RefreshIndicator(
      onRefresh: () => c.fetchNotifications(refresh: true),
      color: scheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: c.items.length + (c.hasMore.value ? 1 : 0),
        itemBuilder: (_, index) {
          if (index == c.items.length) return _buildLoaderFooter(scheme);
          return _NotificationTile(item: c.items[index]);
        },
      ),
    );
  }

  Widget _buildLoaderFooter(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary),
        ),
      ),
    );
  }

  Widget _buildShimmer(ColorScheme scheme) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 8,
      itemBuilder: (_, i) => _ShimmerTile(scheme: scheme),
    );
  }

  Widget _buildError(BuildContext context, NotificationsController c) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: scheme.error.withValues(alpha: 0.6)),
          const SizedBox(height: 16),
          Text('Oops! Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(c.errorMessage.value,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => c.fetchNotifications(refresh: true),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off_rounded,
                size: 48, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 20),
          Text('No Notifications',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('You\'re all caught up!',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── Sliver App Bar ────────────────────────────────────────────────────────────

class _SliverHeader extends StatelessWidget {
  final NotificationsController controller;
  const _SliverHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
        title: Obx(() {
          final unread = controller.unreadCount;
          return Row(
            children: [
              const Text('Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              if (unread > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$unread',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ],
            ],
          );
        }),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, scheme.primary.withValues(alpha: 0.7)],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(Icons.notifications_rounded,
                  size: 64, color: scheme.onPrimary.withValues(alpha: 0.15)),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Notification Tile ─────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final PushNotificationModel item;
  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final typeColor = _typeColor(item.notificationType, scheme);
    final typeIcon = _typeIcon(item.notificationType);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: item.isRead ? scheme.surface : scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isRead
              ? theme.dividerColor.withValues(alpha: 0.5)
              : scheme.primary.withValues(alpha: 0.25),
          width: item.isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: item.isRead ? 0.03 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Get.find<NotificationsController>().markAsRead(item),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeBadge(icon: typeIcon, color: typeColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: item.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                                color: scheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (item.notificationType != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.notificationType!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: typeColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(Icons.schedule_rounded,
                              size: 12, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Text(
                            _formatTime(item.sentOn),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM yyyy').format(dt);
  }

  Color _typeColor(String? type, ColorScheme scheme) {
    switch (type?.toLowerCase()) {
      case 'fee':
        return const Color(0xFFF57C00);
      case 'exam':
        return const Color(0xFF1565C0);
      case 'attendance':
        return const Color(0xFF2E7D32);
      case 'result':
        return const Color(0xFF6A1B9A);
      case 'holiday':
        return const Color(0xFF00838F);
      case 'event':
        return const Color(0xFFC62828);
      default:
        return scheme.primary;
    }
  }

  IconData _typeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'fee':
        return Icons.receipt_long_rounded;
      case 'exam':
        return Icons.edit_document;
      case 'attendance':
        return Icons.how_to_reg_rounded;
      case 'result':
        return Icons.emoji_events_rounded;
      case 'holiday':
        return Icons.celebration_rounded;
      case 'event':
        return Icons.event_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}

// ── Type Badge ────────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _TypeBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

// ── Shimmer Tile ──────────────────────────────────────────────────────────────

class _ShimmerTile extends StatefulWidget {
  final ColorScheme scheme;
  const _ShimmerTile({required this.scheme});

  @override
  State<_ShimmerTile> createState() => _ShimmerTileState();
}

class _ShimmerTileState extends State<_ShimmerTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.scheme.surfaceContainerHighest;
    final highlight = widget.scheme.surface;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Color.lerp(base, highlight, _anim.value),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Color.lerp(base, highlight, _anim.value * 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(160, 14, base, highlight),
                  const SizedBox(height: 8),
                  _bar(double.infinity, 11, base, highlight),
                  const SizedBox(height: 4),
                  _bar(200, 11, base, highlight),
                  const SizedBox(height: 8),
                  _bar(80, 10, base, highlight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(double width, double height, Color base, Color highlight) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Color.lerp(base, highlight, _anim.value * 0.6),
          borderRadius: BorderRadius.circular(6),
        ),
      );
}
