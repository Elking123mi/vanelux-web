import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/locale_provider.dart';

/// Overlay panel that slides in from the top-right showing notifications.
class NotificationsPanel extends StatelessWidget {
  const NotificationsPanel({super.key});

  static const _gold = Color(0xFFD4AF37);
  static const _navy = Color(0xFF0B3254);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final t = context.read<LocaleProvider>().t;
        return Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0D1B2E),
          child: Container(
            width: 360,
            constraints: const BoxConstraints(maxHeight: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                  decoration: const BoxDecoration(
                    color: _navy,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_rounded, color: _gold, size: 20),
                      const SizedBox(width: 8),
                      Text(t('notif_title'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      const Spacer(),
                      if (provider.all.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            provider.markAllRead();
                            provider.clearAll();
                          },
                          child: Text(t('notif_clear'),
                              style: const TextStyle(color: _gold, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
                // List
                if (provider.all.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(Icons.notifications_none_rounded, color: Colors.white24, size: 40),
                        const SizedBox(height: 8),
                        Text(t('notif_empty'),
                            style: const TextStyle(color: Colors.white38, fontSize: 14)),
                      ],
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shrinkWrap: true,
                      itemCount: provider.all.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.white10, height: 1),
                      itemBuilder: (context, index) {
                        final n = provider.all[index];
                        return _NotificationTile(
                          notification: n,
                          onTap: () => provider.markRead(n.id),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final VaneluxNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: notification.read ? Colors.transparent : Colors.white.withOpacity(0.04),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 5, right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: notification.read
                    ? Colors.transparent
                    : const Color(0xFFD4AF37),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: notification.read ? FontWeight.w400 : FontWeight.w700,
                        fontSize: 14,
                      )),
                  const SizedBox(height: 3),
                  Text(notification.body,
                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(_timeAgo(notification.timestamp),
                      style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Notification bell icon with unread badge — drop into any AppBar/header.
class NotificationBell extends StatefulWidget {
  final Color? iconColor;
  const NotificationBell({super.key, this.iconColor});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;

  void _showPanel() {
    final provider = context.read<NotificationProvider>();
    provider.markAllRead();

    final overlay = Overlay.of(context);
    _overlay = OverlayEntry(
      builder: (overlayCtx) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _hidePanel,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              child: CompositedTransformFollower(
                link: _layerLink,
                offset: const Offset(-300, 48),
                child: GestureDetector(
                  onTap: () {}, // prevent dismiss on panel tap
                  child: MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: provider),
                      ChangeNotifierProvider.value(
                        value: context.read<LocaleProvider>(),
                      ),
                    ],
                    child: const NotificationsPanel(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    overlay.insert(_overlay!);
  }

  void _hidePanel() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _hidePanel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Consumer<NotificationProvider>(
        builder: (_, provider, __) {
          final unread = provider.unreadCount;
          return InkWell(
            onTap: () => _overlay == null ? _showPanel() : _hidePanel(),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_rounded,
                    color: widget.iconColor ?? Colors.white,
                    size: 26,
                  ),
                  if (unread > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD4AF37),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: const TextStyle(
                            color: Color(0xFF0B3254),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
