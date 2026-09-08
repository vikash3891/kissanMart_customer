void main() {
  final query = {'category_id': '1'};
  final uri = Uri(path: '/products', queryParameters: query);
  print(uri.toString());
}
