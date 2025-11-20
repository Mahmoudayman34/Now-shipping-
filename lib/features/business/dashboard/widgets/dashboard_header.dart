import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../business/notifications/screens/notifications_screen.dart';
import '../../../business/notifications/services/notification_service.dart';

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final service = NotificationService();
  return await service.getUnreadCount();
});

class DashboardHeader extends ConsumerWidget {
  final String userName;
  
  const DashboardHeader({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
        final topPadding = ResponsiveUtils.getResponsiveFontSize(
          context,
          mobile: 20,
          tablet: 24,
          desktop: 28,
        );
        final iconSize = ResponsiveUtils.getResponsiveImageSize(context);
        final logoSize = ResponsiveUtils.getResponsiveFontSize(
          context,
          mobile: 70,
          tablet: 80,
          desktop: 90,
        );
        final spacing = ResponsiveUtils.getResponsiveSpacing(context) / 2;
        
        return Padding(
          padding: EdgeInsets.only(
            top: topPadding,
            left: padding.horizontal / 2,
            right: padding.horizontal / 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: iconSize,
                    width: iconSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(
                        Radius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/icon_only.png',
                        width: iconSize + 10,
                        height: iconSize + 10,
                        color: const Color(0xfff29620),
                      ),
                    ),
                  ),
                  SizedBox(width: spacing),
                  Image.asset(
                    'assets/images/word_only.png',
                    width: logoSize,
                    height: logoSize,
                  ),
                  SizedBox(width: spacing / 2),
                ],
              ),
              // Notification Icon with Badge
              _buildNotificationIcon(context, ref),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationIcon(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(unreadCountProvider);

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationsScreen(),
          ),
        );
        // Refresh unread count after returning from notifications screen
        ref.invalidate(unreadCountProvider);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: Color(0xfff29620),
              size: 24,
            ),
            // Badge
            unreadCountAsync.when(
              data: (count) {
                if (count == 0) return const SizedBox.shrink();
                
                return Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}