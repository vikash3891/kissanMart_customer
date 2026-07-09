import 'address.dart';
import 'orderItem.dart';

class Order {
  final int id;
  final int userId;

  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;

  final double totalAmount;
  final double discountAmount;
  final double finalAmount;

  final String? couponCode;

  final DateTime createdAt;

  final Address address;

  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    this.couponCode,
    required this.createdAt,
    required this.address,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json["id"],
      userId: json["user_id"],
      orderStatus: json["order_status"] ?? "",
      paymentStatus: json["payment_status"] ?? "",
      paymentMethod: json["payment_method"] ?? "",
      totalAmount: double.tryParse(json["total_amount"].toString()) ?? 0,
      discountAmount: double.tryParse(json["discount_amount"].toString()) ?? 0,
      finalAmount: double.tryParse(json["final_amount"].toString()) ?? 0,
      couponCode: json["coupon_code"],
      createdAt: DateTime.parse(json["created_at"]),
      address: Address.fromJson(json["address"]),
      items: (json["items"] as List).map((e) => OrderItem.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "order_status": orderStatus,
      "payment_status": paymentStatus,
      "payment_method": paymentMethod,
      "total_amount": totalAmount,
      "discount_amount": discountAmount,
      "final_amount": finalAmount,
      "coupon_code": couponCode,
      "created_at": createdAt.toIso8601String(),
      "address": address.toJson(),
      "items": items.map((e) => e.toJson()).toList(),
    };
  }
}
