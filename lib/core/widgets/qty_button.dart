import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';

/// Add / Remove quantity control for a [Product].
///
/// Shows an "ADD" outlined button when qty == 0,
/// and a green counter row otherwise. Includes full accessibility support (Feature 17).
/// Disables ADD button for out-of-stock products.
class QtyButton extends StatelessWidget {
  final Product p;
  const QtyButton({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final q = cart.qty(p);
    final isOutOfStock = p.stock <= 0 || !p.isAvailable;
    final colors = context.colors;

    if (q == 0) {
      // Out of stock → show disabled label
      if (isOutOfStock) {
        return Semantics(
          label: '${p.name} is out of stock',
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.disabled,
              side: BorderSide(color: colors.disabled),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              minimumSize: const Size(48, 24),
            ),
            onPressed: null,
            child: const Text('OUT OF STOCK', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
          ),
        );
      }

      return Semantics(
        button: true,
        label: 'Add ${p.name} to cart',
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.primary,
            side: BorderSide(color: colors.primary),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            minimumSize: const Size(48, 24),
          ),
          onPressed: () async {
            final success = await context.read<CartProvider>().add(p);
            if (!success && context.mounted) {
              final error = context.read<CartProvider>().error;
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error)),
                );
                context.read<CartProvider>().clearError();
              }
            }
          },
          child: const Text('ADD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: 'Decrease quantity of ${p.name}',
            child: InkWell(
              onTap: () => context.read<CartProvider>().remove(p),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Icon(Icons.remove, color: Colors.white, size: 14),
              ),
            ),
          ),
          Semantics(
            liveRegion: true,
            label: 'Current quantity: $q',
            child: Text(
              '$q',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Increase quantity of ${p.name}',
            child: InkWell(
              onTap: () async {
                final success = await context.read<CartProvider>().add(p);
                if (!success && context.mounted) {
                  final error = context.read<CartProvider>().error;
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                    context.read<CartProvider>().clearError();
                  }
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Icon(Icons.add, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
