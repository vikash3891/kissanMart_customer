import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../theme/app_colors.dart';
import 'shimmer_placeholder.dart';
import '../../models/product.dart';
import '../../features/products/product_details_screen.dart';

class CompactProductCard extends StatelessWidget {
  final Product product;

  const CompactProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kLightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: product.image.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.image,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: ShimmerPlaceholder(
                                width: double.infinity,
                                height: double.infinity,
                                borderRadius: 12,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.image, size: 40),
                          )
                        : const Icon(Icons.image, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                '₹${product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 14, color: kGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
