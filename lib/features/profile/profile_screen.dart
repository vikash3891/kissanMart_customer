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

    return Scaffold(
      backgroundColor: kBg,
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
    final profileProv = context.watch<ProfileProvider>();
    final profile = profileProv.profile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back_ios_new, color: kDark, size: 20),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
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
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF3F4F8)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: kLightGreen,
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
                          style: const TextStyle(fontSize: 28),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (profile != null && profile.name.isNotEmpty)
                            ? profile.name
                            : (profile?.phone ??
                                auth.currentUser?['phone'] ??
                                ''),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kDark,
                        ),
                      ),
                      if (profile != null && profile.email.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          profile.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Role: ${(profile?.role ?? auth.currentUser?['role'] ?? 'CUSTOMER').toString().toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black54,
          letterSpacing: .8,
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
    return ListTile(
      onTap: item.onTap,
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFF0F1F5),
            child: Icon(item.icon, color: kDark),
          ),
          if (item.badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
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
