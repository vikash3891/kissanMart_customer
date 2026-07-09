class ApiAddress {
  final int id;
  final int userId;
  final String fullName;
  final String phone;
  final String pincode;
  final String state;
  final String city;
  final String houseNo;
  final String area;
  final String? landmark;
  final String addressType;
  final bool isDefault;
  final DateTime? createdAt;

  ApiAddress({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.pincode,
    required this.state,
    required this.city,
    required this.houseNo,
    required this.area,
    this.landmark,
    required this.addressType,
    required this.isDefault,
    this.createdAt,
  });

  factory ApiAddress.fromJson(Map<String, dynamic> json) {
    return ApiAddress(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? 0,
      fullName: json["full_name"] ?? "",
      phone: json["phone"] ?? "",
      pincode: json["pincode"] ?? "",
      state: json["state"] ?? "",
      city: json["city"] ?? "",
      houseNo: json["house_no"] ?? "",
      area: json["area"] ?? "",
      landmark: json["landmark"],
      addressType: json["address_type"] ?? "home",
      isDefault: json["is_default"] ?? false,
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "full_name": fullName,
      "phone": phone,
      "pincode": pincode,
      "state": state,
      "city": city,
      "house_no": houseNo,
      "area": area,
      "landmark": landmark,
      "address_type": addressType,
      "is_default": isDefault,
      if (createdAt != null) "created_at": createdAt!.toIso8601String(),
    };
  }

  ApiAddress copyWith({
    int? id,
    int? userId,
    String? fullName,
    String? phone,
    String? pincode,
    String? state,
    String? city,
    String? houseNo,
    String? area,
    String? landmark,
    String? addressType,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return ApiAddress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      pincode: pincode ?? this.pincode,
      state: state ?? this.state,
      city: city ?? this.city,
      houseNo: houseNo ?? this.houseNo,
      area: area ?? this.area,
      landmark: landmark ?? this.landmark,
      addressType: addressType ?? this.addressType,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

typedef Address = ApiAddress;
