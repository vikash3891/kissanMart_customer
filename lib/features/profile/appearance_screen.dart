import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_typography.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/design_system/app_radius.dart';
import '../../core/design_system/app_icons.dart';
import '../../core/design_system/app_animation.dart';
import '../../providers/theme_provider.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final tokens = theme.tokens(context);

    return AnimatedTheme(
      data: Theme.of(context),
      duration: AppAnimation.d300,
      curve: AppAnimation.easeInOut,
      child: Scaffold(
        backgroundColor: tokens.background,
        appBar: AppBar(
          backgroundColor: tokens.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(AppIcons.arrowBack, color: tokens.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Appearance & Themes',
            style: AppTypography.titleLarge(color: tokens.textPrimary),
          ),
        ),
        body: ListView(
          padding: AppSpacing.pagePadding,
          children: [
            // ─── Brightness Mode Section ──────────────────────────────────────────
            Text('BRIGHTNESS MODE',
                style: AppTypography.label(color: tokens.textSecondary)),
            AppSpacing.v12,
            _buildModeSelector(context, theme, tokens),
            AppSpacing.v16,
            if (theme.themeMode == ThemeMode.dark ||
                (theme.themeMode == ThemeMode.system &&
                    MediaQuery.platformBrightnessOf(context) ==
                        Brightness.dark))
              _buildAmoledSwitch(context, theme, tokens),
            AppSpacing.v24,

            // ─── Brand Theme Presets Section ──────────────────────────────────────
            Text('THEME PRESETS (8 BRAND STYLES)',
                style: AppTypography.label(color: tokens.textSecondary)),
            AppSpacing.v12,
            _buildPresetGrid(context, theme, tokens),
            AppSpacing.v32,

            // ─── Live UI Previews Section ─────────────────────────────────────────
            Text('LIVE COMPONENT PREVIEW',
                style: AppTypography.label(color: tokens.textSecondary)),
            AppSpacing.v12,
            _buildLivePreview(context, tokens),
            AppSpacing.v32,
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(
      BuildContext context, ThemeProvider theme, AppColorTokens tokens) {
    return Row(
      children: [
        Expanded(
          child: _ModeCard(
            label: 'Light',
            icon: Icons.light_mode_outlined,
            isSelected: theme.themeMode == ThemeMode.light,
            tokens: tokens,
            onTap: () => theme.setThemeMode(ThemeMode.light),
          ),
        ),
        AppSpacing.h12,
        Expanded(
          child: _ModeCard(
            label: 'Dark',
            icon: Icons.dark_mode_outlined,
            isSelected: theme.themeMode == ThemeMode.dark,
            tokens: tokens,
            onTap: () => theme.setThemeMode(ThemeMode.dark),
          ),
        ),
        AppSpacing.h12,
        Expanded(
          child: _ModeCard(
            label: 'System',
            icon: Icons.brightness_auto_outlined,
            isSelected: theme.themeMode == ThemeMode.system,
            tokens: tokens,
            onTap: () => theme.setThemeMode(ThemeMode.system),
          ),
        ),
      ],
    );
  }

  Widget _buildAmoledSwitch(
      BuildContext context, ThemeProvider theme, AppColorTokens tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: AppRadius.card,
        border:
            Border.all(color: theme.isAmoled ? tokens.primary : tokens.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.contrast, color: tokens.primary, size: 24),
              AppSpacing.h12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AMOLED True Black',
                      style:
                          AppTypography.bodyMedium(color: tokens.textPrimary)),
                  Text('Saves battery on OLED displays (#000000)',
                      style:
                          AppTypography.caption(color: tokens.textSecondary)),
                ],
              ),
            ],
          ),
          Switch(
            value: theme.isAmoled,
            activeColor: tokens.primary,
            onChanged: (val) => theme.setAmoled(val),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetGrid(
      BuildContext context, ThemeProvider theme, AppColorTokens tokens) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: AppThemePreset.values.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final preset = AppThemePreset.values[index];
        final bool isSelected = theme.preset == preset;

        return AppAnimation.ripple(
          onTap: () => theme.setPreset(preset),
          borderRadius: AppRadius.card,
          child: AnimatedContainer(
            duration: AppAnimation.d200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: AppRadius.card,
              border: Border.all(
                color: isSelected ? preset.previewColor : tokens.border,
                width: isSelected ? 2.5 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: preset.previewColor.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: preset.previewColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                AppSpacing.h12,
                Expanded(
                  child: Text(
                    preset.nameDisplay,
                    style: AppTypography.bodyMedium(color: tokens.textPrimary)
                        .copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLivePreview(BuildContext context, AppColorTokens tokens) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: AppRadius.card,
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Typography & Accent Preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Typography & Accent',
                  style: AppTypography.titleMedium(color: tokens.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tokens.primary.withOpacity(0.15),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text('20% OFF',
                    style: AppTypography.discount(color: tokens.primary)),
              ),
            ],
          ),
          AppSpacing.v8,
          Text(
            'Fresh Organic Apples (Shimla) - Grade A premium quality crunch.',
            style: AppTypography.bodySmall(color: tokens.textSecondary),
          ),
          AppSpacing.v16,

          // Card & Search Preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: tokens.searchBg,
              borderRadius: AppRadius.search,
            ),
            child: Row(
              children: [
                Icon(AppIcons.search, color: tokens.hint, size: 20),
                AppSpacing.h8,
                Text('Search "organic milk, dal, bread..."',
                    style: AppTypography.bodySmall(color: tokens.hint)),
              ],
            ),
          ),
          AppSpacing.v16,

          // Buttons Preview
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.primary,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.button),
                  ),
                  child: Text('Add to Cart',
                      style: AppTypography.button(color: Colors.white)),
                ),
              ),
              AppSpacing.h12,
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: tokens.primary,
                  side: BorderSide(color: tokens.primary),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.button),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                child: Icon(AppIcons.wishlist, color: tokens.primary, size: 20),
              ),
            ],
          ),
          AppSpacing.v16,

          // Navigation Preview
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: tokens.navigationBg,
              borderRadius: AppRadius.card,
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavPreviewItem(
                    icon: AppIcons.navHomeSelected,
                    label: 'Home',
                    isSelected: true,
                    tokens: tokens),
                _NavPreviewItem(
                    icon: AppIcons.navCategories,
                    label: 'Categories',
                    isSelected: false,
                    tokens: tokens),
                _NavPreviewItem(
                    icon: AppIcons.navCart,
                    label: 'Cart',
                    isSelected: false,
                    tokens: tokens),
                _NavPreviewItem(
                    icon: AppIcons.navProfile,
                    label: 'Profile',
                    isSelected: false,
                    tokens: tokens),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final AppColorTokens tokens;
  final VoidCallback onTap;

  const _ModeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimation.ripple(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: AnimatedContainer(
        duration: AppAnimation.d200,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? tokens.primary.withOpacity(0.12) : tokens.card,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isSelected ? tokens.primary : tokens.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected ? tokens.primary : tokens.textSecondary,
                size: 24),
            AppSpacing.v4,
            Text(
              label,
              style: AppTypography.label(
                color: isSelected ? tokens.primary : tokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavPreviewItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final AppColorTokens tokens;

  const _NavPreviewItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? tokens.primary : tokens.textSecondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        AppSpacing.v4,
        Text(label,
            style:
                AppTypography.navigation(color: color, isSelected: isSelected)),
      ],
    );
  }
}
