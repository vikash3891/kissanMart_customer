import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/notification_provider.dart';
import '../favorites/favorites_screen.dart';
import '../address/address_screen.dart';
import '../orders/orders_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_center_screen.dart';
import 'appearance_screen.dart';
import 'help_support_screen.dart';
import 'app_about_screen.dart';

/// Profile tab.
///
/// Cleaned of all legacy mock order history and manual address pages.
/// Displays dynamic backend profile information and redirects to settings.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required bool showBack});

  @override
  Widget build(BuildContext context) {
    /// Local helper so context is always fresh.
    void open(Widget page) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }

    context.watch<ProfileProvider>();
    final notificationProv = context.watch<NotificationProvider>();

    final items1 = [
      _ProfileItem(
        Icons.person_outline,
        'Edit Profile',
        () => open(const EditProfileScreen()),
      ),
      _ProfileItem(
        Icons.receipt_long,
        'Your orders',
        () => open(const OrdersScreen()),
      ),
      _ProfileItem(
        Icons.favorite_border,
        'Your wishlist',
        () => open(const FavoritesScreen()),
      ),
      _ProfileItem(
        Icons.notifications_none,
        'Notifications',
        () => open(const NotificationCenterScreen()),
        badgeCount: notificationProv.unreadCount,
      ),
      _ProfileItem(
        Icons.palette_outlined,
        'Appearance & Themes',
        () => open(const AppearanceScreen()),
      ),
      _ProfileItem(
        Icons.fact_check_outlined,
        'Address book',
        () => open(const AddressScreen()),
      ),
      _ProfileItem(
        Icons.help_outline,
        'Help & Support',
        () => open(const HelpSupportScreen()),
      ),
      _ProfileItem(
        Icons.info_outline,
        'About',
        () => open(const AppAboutScreen()),
      ),
      _ProfileItem(
        Icons.logout,
        'Logout',
        () {
          context.read<AuthProvider>().logout();
          context.read<CartProvider>().clear();
          context.read<NavigationProvider>().reset();
          context.read<ProfileProvider>().clearProfile();
        },
      ),
    ];

    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: RefreshIndicator(
              onRefresh: () => context.read<ProfileProvider>().loadProfile(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
                children: [
                  const _Header(title: 'Profile'),
                  const SizedBox(height: 28),
                  const _SectionTitle('YOUR PROFILE'),
                  ...items1.map((e) => _ProfileRow(item: e)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Internal widgets ─────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>().profile;

    return Column(
      children: [
        Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  context.read<NavigationProvider>().setTab(0);
                }
              },
              child: CircleAvatar(
                backgroundColor: colors.card,
                child: Icon(Icons.arrow_back_ios_new, color: colors.textPrimary, size: 20),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        if (title == 'Profile' && auth.loggedIn) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: colors.primary.withValues(alpha: 0.15),
                    backgroundImage: (profile?.profileImagePath != null &&
                            File(profile!.profileImagePath!).existsSync())
                        ? FileImage(File(profile.profileImagePath!))
                        : null,
                    child: (profile?.profileImagePath == null ||
                            !File(profile!.profileImagePath!).existsSync())
                        ? Text(
                            (profile != null && profile.name.isNotEmpty)
                                ? profile.name[0].toUpperCase()
                                : '👤',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (profile != null && profile.name.isNotEmpty)
                            ? profile.name
                            : (profile?.phone ??
                                auth.currentUser?['phone'] ??
                                'Customer'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (profile != null && profile.email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          profile.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          (profile?.role ??
                                  auth.currentUser?['role'] ??
                                  'CUSTOMER')
                              .toString()
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: colors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final int badgeCount;

  _ProfileItem(this.icon, this.title, this.onTap, {this.badgeCount = 0});
}

class _ProfileRow extends StatelessWidget {
  final _ProfileItem item;

  const _ProfileRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      onTap: item.onTap,
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colors.skeleton,
            child: Icon(item.icon, color: colors.textPrimary),
          ),
          if (item.badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.danger,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    item.badgeCount > 9 ? '9+' : item.badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        item.title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      ),
    );
  }
}
