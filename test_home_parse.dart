import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3000/api/home'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'];
      
      print("Parsing banners...");
      for (var b in data['banners']) {
        // ApiBanner.fromJson
        final id = b['id'] ?? 0;
        final title = b['title'] ?? "";
        final imageUrl = b['image_url'] ?? "";
      }
      
      print("Parsing categories...");
      for (var c in data['categories']) {
        // Category.fromJson
        final id = c['id'];
        final name = c['name'] ?? "";
        final description = c['description'] ?? "";
        final imageUrl = c['image_url'] ?? "";
      }
      
      print("Parsing trendingProducts...");
      for (var p in data['trendingProducts']) {
        final id = p['id'] ?? 0;
        final name = p['name'] ?? "";
        final price = double.tryParse(p['price'].toString()) ?? 0;
        final discountPrice = double.tryParse(p['discount_price'].toString()) ?? 0;
        final category = p['category'] ?? {};
        final catId = category['id'] ?? 0;
        final catName = category['name'] ?? "";
      }
      
      print("All parsing successful");
    } else {
      print("Error: ${response.statusCode}");
    }
  } catch (e, st) {
    print("Crash: $e");
    print(st);
  }
}
