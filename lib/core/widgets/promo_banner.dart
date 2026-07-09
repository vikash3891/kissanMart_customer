import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Static promotional banner shown on the home screen.
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kYellow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GET READY TO CELEBRATE',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            'Fresh organic staples',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          Text('Rice • Wheat • Oil • Peanuts • Fruits'),
        ],
      ),
    );
  }
}
