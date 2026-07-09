import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../providers/coupon_provider.dart';

class CouponsBottomSheet extends StatefulWidget {
  final double orderAmount;

  const CouponsBottomSheet({
    super.key,
    required this.orderAmount,
  });

  @override
  State<CouponsBottomSheet> createState() => _CouponsBottomSheetState();
}

class _CouponsBottomSheetState extends State<CouponsBottomSheet> {
  final TextEditingController _customCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CouponProvider>().loadAvailableCoupons();
    });
  }

  @override
  void dispose() {
    _customCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CouponProvider>();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle/Bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Apply Coupon',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kDark,
                  ),
                ),
                TextButton(
                  onPressed: () => provider.autoApplyBest(widget.orderAmount),
                  child: const Text(
                    'Auto Apply Best',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: kGreen),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Custom Input Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customCodeController,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code manually',
                      hintStyle: const TextStyle(fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kGreen),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: provider.loading
                      ? null
                      : () async {
                          final code =
                              _customCodeController.text.trim().toUpperCase();
                          if (code.isEmpty) return;
                          final success = await provider.applyCoupon(
                              code, widget.orderAmount);
                          if (!mounted) return;
                          if (success) {
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    provider.error ?? 'Failed to apply coupon'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Available coupons list
          Flexible(
            child: _buildCouponsList(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsList(CouponProvider provider) {
    if (provider.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: LoadingWidget(message: 'Loading active offers...'),
      );
    }

    final coupons = provider.availableCoupons;
    if (coupons.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: EmptyStateWidget(
          icon: Icons.percent,
          title: 'No Coupons Available',
          subtitle: 'Check back later for exciting offers and discount codes!',
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        final isEligible = widget.orderAmount >= coupon.minimumOrderAmount;
        final potentialSavings = coupon.calculateDiscount(widget.orderAmount);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: provider.appliedCoupon?.couponCode == coupon.code
                  ? kGreen
                  : Colors.grey[200]!,
              width: provider.appliedCoupon?.couponCode == coupon.code ? 2 : 1,
            ),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isEligible
                            ? kGreen.withValues(alpha: 0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        coupon.code,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isEligible ? kGreen : Colors.grey[600],
                        ),
                      ),
                    ),
                    if (isEligible)
                      TextButton(
                        onPressed: () async {
                          final success = await provider.applyCoupon(
                              coupon.code, widget.orderAmount);
                          if (!mounted) return;
                          if (success) {
                            Navigator.pop(context, true);
                          }
                        },
                        child: const Text(
                          'APPLY',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: kGreen),
                        ),
                      )
                    else
                      Text(
                        'Add ₹${(coupon.minimumOrderAmount - widget.orderAmount).toStringAsFixed(0)} more',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[400],
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  coupon.description,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expires: ${_formatDate(coupon.expiryDate)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    if (isEligible && potentialSavings > 0)
                      Text(
                        'Saves ₹${potentialSavings.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: kGreen,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
