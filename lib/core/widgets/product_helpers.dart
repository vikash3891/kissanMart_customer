import 'dart:async';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Flash Sale Countdown Timer (Feature 8)
// ─────────────────────────────────────────────────────────────────────────────

class FlashSaleTimer extends StatefulWidget {
  final Duration duration;
  const FlashSaleTimer(
      {super.key,
      this.duration = const Duration(hours: 2, minutes: 15, seconds: 34)});

  @override
  State<FlashSaleTimer> createState() => _FlashSaleTimerState();
}

class _FlashSaleTimerState extends State<FlashSaleTimer> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 0) {
        _timer?.cancel();
      } else {
        setState(() {
          _remaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.inSeconds <= 0) return const SizedBox.shrink();
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.danger.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flash_on, color: colors.danger, size: 16),
          const SizedBox(width: 4),
          Text(
            'Flash Sale  ',
            style: TextStyle(
                color: colors.danger, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(
            _formatDuration(_remaining),
            style: TextStyle(
              color: colors.danger,
              fontWeight: FontWeight.w900,
              fontFamily: 'Courier',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stock Indicator (Feature 9)
// ─────────────────────────────────────────────────────────────────────────────

class StockIndicator extends StatelessWidget {
  final int stock;
  final bool isAvailable;

  const StockIndicator({
    super.key,
    required this.stock,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (!isAvailable || stock <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Out of Stock',
          style: TextStyle(
              color: colors.danger, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      );
    }

    if (stock == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Only 1 left!',
          style: TextStyle(
              color: colors.danger, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      );
    }

    if (stock <= 3) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Only $stock left',
          style: TextStyle(
              color: colors.warning, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      );
    }

    if (stock <= 10) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Low Stock',
          style: TextStyle(
              color: colors.warning, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'In Stock',
        style: TextStyle(
            color: colors.success, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Delivery ETA Widget (Feature 10)
// ─────────────────────────────────────────────────────────────────────────────

class DeliveryEtaWidget extends StatelessWidget {
  final int id;
  const DeliveryEtaWidget({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Deterministic ETA mapping for presentation
    final eta = id % 3 == 0
        ? '10 min'
        : id % 3 == 1
            ? '15 min'
            : '25 min';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flash_on, size: 14, color: colors.warning),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            'Deliver in $eta',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product Badges Widget (Feature 11)
// ─────────────────────────────────────────────────────────────────────────────

class ProductBadge extends StatelessWidget {
  final int id;
  const ProductBadge({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Configurable list of badges based on product ID
    final badges = [
      'Organic',
      'Best Seller',
      'New Arrival',
      'Limited Stock',
      'Top Rated',
      'Fresh Today',
      'Local Farm',
      'Fast Delivery'
    ];
    final label = badges[id % badges.length];

    Color color = colors.primary;
    if (label == 'Best Seller' || label == 'Top Rated') {
      color = colors.coupon;
    } else if (label == 'Limited Stock' || label == 'New Arrival') {
      color = colors.warning;
    } else if (label == 'Fast Delivery') {
      color = colors.delivery;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 7,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
