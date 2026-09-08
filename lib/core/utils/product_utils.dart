import 'package:flutter/material.dart';

import '../../models/product.dart';

// ─── Discount ─────────────────────────────────────────────────────────────────

/// Returns the MRP discount percentage for [p].
int discount(Product p) {
  if (p.mrp == 0) return 0;
  return (((p.mrp - p.price) / p.mrp) * 100).round();
}

// ─── Section heading ──────────────────────────────────────────────────────────

/// Bold section heading used on the home screen product grid.
Widget sectionTitle(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
    ),
  );
}

// ─── Category icon ────────────────────────────────────────────────────────────

/// Returns an emoji icon for a category name.
String categoryIcon(String c) {
  return const {
        'Grains': '🌾',
        'Pulses': '🥜',
        'Vegetables': '🥦',
        'Fruits': '🍎',
        'Others': '🛒',
      }[c] ??
      '🛒';
}

// ─── Image Sanitization ──────────────────────────────────────────────────────

/// Domains that are known to be placeholder/broken in the banner DB.
const _kPlaceholderDomains = <String>{
  'example.com',
  'www.example.com',
  'placeholder.com',
  'via.placeholder.com',
  'placehold.it',
  'placeimg.com',
  'lorempixel.com',
  'dummyimage.com',
};

/// Returns true if the [url] is empty, null, or points to a known
/// placeholder/broken domain.
bool isBrokenImageUrl(String? url) {
  if (url == null || url.trim().isEmpty) return true;
  try {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return true;
    return _kPlaceholderDomains.contains(uri.host.toLowerCase());
  } catch (_) {
    return true;
  }
}

/// Returns a deterministic, category-appropriate image from Unsplash
/// based on the [seed] value and [category] (so related items
/// get similar images).
String _categoryFallback(String category, int seed) {
  // Category-specific image categories on Unsplash
  final Map<String, List<String>> categoryImages = {
    'Grains': [
      'https://images.unsplash.com/photo-1586201375761-83865001e8ac?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1573081414229-96d305c2bef1?auto=format&fit=crop&q=80&w=800',
    ],
    'Pulses': [
      'https://images.unsplash.com/photo-1586201375761-83865001e8ac?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1600891964599-f4d37e25c257?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&q=80&w=800',
    ],
    'Vegetables': [
      'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1518606090350-ef18da21bd8b?auto=format&fit=crop&q=80&w=800',
    ],
    'Fruits': [
      'https://images.unsplash.com/photo-1506617420156-8e4536971650?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1527828840614-6896f8103f74?auto=format&fit=crop&q=80&w=800',
    ],
    'Others': [
      'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1506617420156-8e4536971650?auto=format&fit=crop&q=80&w=800',
      'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&q=80&w=800',
    ],
  };

  // Get category-specific images or fall back to general groceries
  final List<String> images = categoryImages[category] ?? [
    'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1506617420156-8e4536971650-8e4536971650?auto=format&fit=crop&q=80&w=800',
  ];

  return images[seed % images.length];
}

/// Returns a deterministic, beautiful grocery image from Unsplash
/// based on the [seed] value (so repeated calls for the same item
/// always return the same image).
String _groceryFallback(int seed) {
  const fallbacks = [
    'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1506617420156-8e4536971650?auto=format&fit=crop&q=80&w=800',
  ];
  return fallbacks[seed % fallbacks.length];
}

/// Formats and redirects image URLs for the Android emulator and fallback scenarios.
///
/// • Null / empty → Unsplash category-specific or grocery fallback
/// • Known placeholder domains (example.com etc.) → Category-specific fallback
/// • Relative path → prepend backend server URL
/// • localhost / 127.0.0.1 → replace with Android emulator alias 10.0.2.2
String sanitizeImageUrl(String? url, {int seed = 0, String? category}) {
  if (isBrokenImageUrl(url)) {
    debugPrint('[ImageSanitize] ⚠️  Broken/placeholder URL detected: "$url"'
        ' — using category-specific fallback image.');
    if (category != null && category.isNotEmpty) {
      return _categoryFallback(category, seed);
    }
    return _groceryFallback(seed);
  }

  String sanitized = url!.trim();

  // Prepend server host if the URL is a relative path
  if (!sanitized.startsWith('http://') && !sanitized.startsWith('https://')) {
    sanitized =
        'https://kissan-backend-e9rm.onrender.com/${sanitized.startsWith('/') ? sanitized.substring(1) : sanitized}';
  }

  // Replace localhost loopback address with Android emulator host address
  sanitized = sanitized.replaceAll('localhost:5000', '10.0.2.2:5000');
  sanitized = sanitized.replaceAll('127.0.0.1:5000', '10.0.2.2:5000');

  return sanitized;
}

