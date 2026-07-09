class ApiOrderAddress {
  final int id;
  final String fullName;
  final String phone;
  final String houseNo;
  final String area;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final String addressType;

  ApiOrderAddress({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.houseNo,
    required this.area,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    required this.addressType,
  });

  factory ApiOrderAddress.fromJson(Map<String, dynamic> json) {
    return ApiOrderAddress(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      houseNo: json['house_no'] ?? json['houseNo'] ?? '',
      area: json['area'] ?? '',
      landmark: json['landmark'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      addressType: json['address_type'] ?? json['addressType'] ?? 'home',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'house_no': houseNo,
      'area': area,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'address_type': addressType,
    };
  }
}
