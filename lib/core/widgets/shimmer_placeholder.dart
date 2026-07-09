import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ProductGridSkeleton extends StatelessWidget {
  final bool isSliver;

  const ProductGridSkeleton({super.key, this.isSliver = false});

  @override
  Widget build(BuildContext context) {
    final delegate = SliverChildBuilderDelegate(
      (context, index) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ShimmerPlaceholder(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 18,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    ShimmerPlaceholder(width: 40, height: 16),
                    Spacer(),
                    ShimmerPlaceholder(width: 50, height: 30, borderRadius: 10),
                  ],
                ),
                SizedBox(height: 8),
                ShimmerPlaceholder(width: 60, height: 20),
                SizedBox(height: 4),
                ShimmerPlaceholder(width: 100, height: 12),
                SizedBox(height: 8),
                ShimmerPlaceholder(width: 120, height: 16),
                SizedBox(height: 8),
                Row(
                  children: [
                    ShimmerPlaceholder(width: 50, height: 12),
                    Spacer(),
                    ShimmerPlaceholder(width: 40, height: 12),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      childCount: 6,
    );

    final gridDelegate = const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 230,
      mainAxisExtent: 285,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    );

    if (isSliver) {
      return SliverLayoutBuilder(
        builder: (context, constraints) {
          if (constraints.crossAxisExtent <= 0.0) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
          return SliverGrid(
            delegate: delegate,
            gridDelegate: gridDelegate,
          );
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      gridDelegate: gridDelegate,
      itemBuilder: (context, index) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ShimmerPlaceholder(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 18,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    ShimmerPlaceholder(width: 40, height: 16),
                    Spacer(),
                    ShimmerPlaceholder(width: 50, height: 30, borderRadius: 10),
                  ],
                ),
                SizedBox(height: 8),
                ShimmerPlaceholder(width: 60, height: 20),
                SizedBox(height: 4),
                ShimmerPlaceholder(width: 100, height: 12),
                SizedBox(height: 8),
                ShimmerPlaceholder(width: 120, height: 16),
                SizedBox(height: 8),
                Row(
                  children: [
                    ShimmerPlaceholder(width: 50, height: 12),
                    Spacer(),
                    ShimmerPlaceholder(width: 40, height: 12),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  const ShimmerPlaceholder(
                      width: 48, height: 48, borderRadius: 24),
                  const Spacer(),
                  ...List.generate(
                      3,
                      (index) => const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: ShimmerPlaceholder(
                                width: 48, height: 48, borderRadius: 24),
                          )),
                ],
              ),
              const SizedBox(height: 16),
              const ShimmerPlaceholder(
                  width: double.infinity, height: 260, borderRadius: 24),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                    4,
                    (index) => const ShimmerPlaceholder(
                        width: 90, height: 35, borderRadius: 14)),
              ),
              const SizedBox(height: 16),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShimmerPlaceholder(width: 60, height: 18),
                          SizedBox(width: 18),
                          ShimmerPlaceholder(width: 80, height: 18),
                        ],
                      ),
                      SizedBox(height: 16),
                      ShimmerPlaceholder(width: 200, height: 28),
                      SizedBox(height: 8),
                      ShimmerPlaceholder(width: 80, height: 18),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          ShimmerPlaceholder(width: 100, height: 32),
                          SizedBox(width: 8),
                          ShimmerPlaceholder(width: 80, height: 18),
                        ],
                      ),
                      SizedBox(height: 8),
                      ShimmerPlaceholder(width: 120, height: 18),
                      Divider(height: 28),
                      ShimmerPlaceholder(width: 150, height: 20),
                      SizedBox(height: 16),
                      ShimmerPlaceholder(width: double.infinity, height: 16),
                      SizedBox(height: 8),
                      ShimmerPlaceholder(width: double.infinity, height: 16),
                      SizedBox(height: 8),
                      ShimmerPlaceholder(width: double.infinity, height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShimmerPlaceholder(width: 60, height: 16),
                    SizedBox(height: 4),
                    ShimmerPlaceholder(width: 120, height: 16),
                  ],
                ),
              ),
              ShimmerPlaceholder(width: 170, height: 48, borderRadius: 24),
            ],
          ),
        ),
      ],
    );
  }
}
