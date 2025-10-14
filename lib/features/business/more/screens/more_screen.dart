import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/services/auth_service.dart' hide UserModel;
import '../../../../features/auth/screens/login_screen.dart';
import '../../../../features/business/services/user_service.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/mixins/refreshable_screen_mixin.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'notifications_screen.dart';
import 'personal_info_screen.dart';
import 'language_screen.dart';
import 'contact_us_screen.dart';
import 'about_screen.dart';
import 'delete_account_screen.dart';


class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> with RefreshableScreenMixin {
  
  @override
  void initState() {
    super.initState();
    // Register refresh callback for tab tap refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      registerRefreshCallback(_refreshMore, 4);
    });
  }
  
  @override
  void dispose() {
    // Unregister refresh callback
    unregisterRefreshCallback(4);
    super.dispose();
  }
  
  void _refreshMore() {
    // Refresh more screen data
    ref.invalidate(userDataProvider);
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);
    final userData = ref.watch(userDataProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return ResponsiveUtils.wrapScreen(
      body: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.more,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context, 
                mobile: 18, 
                tablet: 20, 
                desktop: 22,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
              onPressed: () {
                // Navigate to notifications screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: userData.when(
          data: (user) => SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile section
              Container(
                padding: ResponsiveUtils.getResponsivePadding(context),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) * 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: ResponsiveUtils.getResponsiveSpacing(context) * 0.8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildProfileAvatar(user),
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 
                                mobile: 18, 
                                tablet: 20, 
                                desktop: 22,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 0.3),
                          Text(
                            user?.email ?? 'No email',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 
                                mobile: 12, 
                                tablet: 14, 
                                desktop: 16,
                              ),
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: ResponsiveUtils.getResponsiveIconSize(context),
                      ),
                      onPressed: () {
                        // Navigate to profile edit
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditPersonalInfoScreen(),
                          ),
                        ).then((_) {
                          // Refresh user data when returning from edit screen
                          ref.invalidate(userDataProvider);
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 1.5),
              
              // Account settings section
              _buildSectionTitle(l10n.accountSettings),
              _buildSettingItem(
                icon: Icons.account_circle_outlined,
                title: l10n.personalInfo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalInfoScreen(),
                    ),
                  ).then((_) {
                    // Refresh user data when returning from info screen
                    ref.invalidate(userDataProvider);
                  });
                },
              ),

              // Commenting out Security option
              /* 
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: 'Security',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecurityScreen(),
                    ),
                  );
                },
              ),
              */
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 1.5),
              
              // Application settings section
              _buildSectionTitle(l10n.applicationSettings),
              _buildSettingItem(
                icon: Icons.language_outlined,
                title: l10n.languageTitle,
                value: locale.languageCode == 'ar' ? 'العربية' : 'English',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageScreen(),
                    ),
                  );
                },
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 1.5),
              
              // Support section
              _buildSectionTitle(l10n.support),
              // Commenting out Help Center option
              /*
              _buildSettingItem(
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpCenterScreen(),
                    ),
                  );
                },
              ),
              */
              _buildSettingItem(
                icon: Icons.chat_outlined,
                title: l10n.contactUs,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactUsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.info_outline,
                title: l10n.about,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 1.5),
              
              // Account Actions section
              _buildSectionTitle(l10n.accountActions),
              _buildSettingItem(
                icon: Icons.delete_outline,
                title: l10n.deleteAccount,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeleteAccountScreen(),
                    ),
                  );
                },
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context) * 0.5),
              
              // Logout button
              Padding(
                padding: ResponsiveUtils.getResponsivePadding(context),
                child: SizedBox(
                  
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Show confirmation dialog
                      final shouldLogout = await _showLogoutConfirmationDialog(context);
                      if (shouldLogout == true && context.mounted) {
                        // Perform logout
                        await authService.logout();
                        // Navigate to login screen and clear the navigation stack
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false, // Remove all previous routes
                          );
                        }
                      }
                    },
                    icon: Icon(
                      Icons.exit_to_app,
                      size: ResponsiveUtils.getResponsiveIconSize(context),
                    ),
                    label: Text(
                      l10n.logout,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context, 
                          mobile: 14, 
                          tablet: 16, 
                          desktop: 18,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfff29620),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.getResponsiveSpacing(context),
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) * 1.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xfff29620),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading profile: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(userDataProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff29620),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
  
  Widget _buildProfileAvatar(UserModel? user) {
    final avatarSize = ResponsiveUtils.getResponsiveImageSize(context) * 1.5;
    
    if (user == null) {
      return CircleAvatar(
        radius: avatarSize,
        backgroundColor: Colors.grey[200],
        child: Icon(
          Icons.person,
          size: avatarSize,
          color: Colors.grey,
        ),
      );
    }
    
    final hasValidImage = user.profileImage.isNotEmpty && 
                          user.profileImage != "https://example.com/images/profile.jpg";
        
    if (!hasValidImage) {
      // Default avatar when no valid image is available
      return CircleAvatar(
        radius: avatarSize,
        backgroundColor: Colors.grey[200],
        child: Icon(
          Icons.person,
          size: avatarSize,
          color: Colors.grey,
        ),
      );
    }
    
    // Use image with error handler
    return CircleAvatar(
      radius: avatarSize,
      backgroundColor: Colors.grey[200],
      backgroundImage: NetworkImage(user.profileImage),
      onBackgroundImageError: (exception, stackTrace) {
        // This handles network image loading errors silently
        print('Error loading profile image: $exception');
      },
      child: null,
    );
  }
  
  // Helper method to show logout confirmation dialog
  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppDialog.show(
      context,
      title: l10n.logout,
      message: l10n.areYouSureLogout,
      confirmText: l10n.logout,
      cancelText: l10n.cancel,
      confirmColor: const Color(0xfff29620),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context) * 0.8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context, 
            mobile: 14, 
            tablet: 16, 
            desktop: 18,
          ),
          fontWeight: FontWeight.bold,
          color: const Color(0xfff29620),
        ),
      ),
    );
  }
  
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getResponsiveSpacing(context) * 0.8),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context) * 0.6),
              decoration: BoxDecoration(
                color: const Color(0xfff29620).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xfff29620),
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context, 
                    mobile: 14, 
                    tablet: 16, 
                    desktop: 18,
                  ),
                ),
              ),
            ),
            if (value != null)
              Text(
                value,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context, 
                    mobile: 12, 
                    tablet: 14, 
                    desktop: 16,
                  ),
                ),
              ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context) * 0.5),
            Icon(
              Icons.arrow_forward_ios,
              size: ResponsiveUtils.getResponsiveIconSize(context) * 0.7,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}