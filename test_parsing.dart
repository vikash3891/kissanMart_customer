import 'package:http/http.dart' as http;
import 'dart:convert';
import 'lib/api_models/address.dart';
import 'lib/api_models/api_order.dart';

void main() {
  final mockAddressJson = {
    "id": 1,
    "user_id": 1,
    "full_name": "John Doe",
    "phone": "1234567890",
    "pincode": "123456",
    "state": "State",
    "city": "City",
    "house_no": "123",
    "area": "Area",
    "landmark": null,
    "address_type": "home",
    "is_default": true,
    "created_at": "2026-07-16T12:39:41.535Z"
  };

  try {
    print("Parsing address...");
    final address = ApiAddress.fromJson(mockAddressJson);
    print("Address parsed successfully: ${address.id}");
  } catch (e, st) {
    print("Address parse error: $e\n$st");
  }

  final mockOrderJson = {
    "id": 1,
    "user_id": 1,
    "order_status": "PENDING",
    "payment_status": "UNPAID",
    "payment_method": "COD",
    "total_amount": "100.00",
    "discount_amount": "10.00",
    "final_amount": "90.00",
    "coupon_code": null,
    "created_at": "2026-07-16T12:39:41.535Z",
    "address": mockAddressJson,
    "items": [
      {
        "id": 1,
        "quantity": 2,
        "price": "45.00",
        "product": {
          "id": 1,
          "name": "Product 1",
          "image_url": "url",
          "brand": "Brand",
          "unit": "1 kg",
          "price": "50.00",
          "discount_price": "45.00"
        }
      }
    ]
  };

  try {
    print("Parsing order...");
    final order = ApiOrder.fromJson(mockOrderJson);
    print("Order parsed successfully: ${order.id}");
  } catch (e, st) {
    print("Order parse error: $e\n$st");
  }
}
