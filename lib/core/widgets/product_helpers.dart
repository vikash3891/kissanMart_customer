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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flash_on, color: Colors.red, size: 16),
          const SizedBox(width: 4),
          const Text(
            'Flash Sale  ',
            style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(
            _formatDuration(_remaining),
            style: const TextStyle(
              color: Colors.red,
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
    if (!isAvailable || stock <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Out of Stock',
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      );
    }

    if (stock == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Only 1 left!',
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      );
    }

    if (stock <= 3) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Only $stock left',
          style: const TextStyle(
              color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      );
    }

    if (stock <= 10) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Low Stock',
          style: TextStyle(
              color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'In Stock',
        style:
            TextStyle(color: kGreen, fontWeight: FontWeight.bold, fontSize: 11),
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
    // Deterministic ETA mapping for presentation
    final eta = id % 3 == 0
        ? '10 min'
        : id % 3 == 1
            ? '15 min'
            : '25 min';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.flash_on, size: 14, color: Colors.orange),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            'Deliver in $eta',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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

    Color color = kGreen;
    if (label == 'Best Seller' || label == 'Top Rated') {
      color = Colors.amber[800]!;
    } else if (label == 'Limited Stock' || label == 'New Arrival') {
      color = Colors.orange[800]!;
    } else if (label == 'Fast Delivery') {
      color = Colors.blue[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
