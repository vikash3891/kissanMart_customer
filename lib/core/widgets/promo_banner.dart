import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Static promotional banner shown on the home screen.
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.offer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.offer.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GET READY TO CELEBRATE',
            style: TextStyle(color: colors.offer, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Fresh organic staples',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
            ),
          ),
          Text(
            'Rice • Wheat • Oil • Peanuts • Fruits',
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
