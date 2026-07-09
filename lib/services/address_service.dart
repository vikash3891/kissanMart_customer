import '../api_models/address.dart';
import 'api_service.dart';

class AddressService {
  final ApiService _apiService = ApiService();

  Future<List<ApiAddress>> getAddresses() async {
    final response = await _apiService.get('/address');
    final payload = response['data'];
    if (payload is List) {
      return payload.map((e) => ApiAddress.fromJson(e)).toList();
    }
    return [];
  }

  Future<ApiAddress> addAddress({
    required String fullName,
    required String phone,
    required String pincode,
    required String state,
    required String city,
    required String houseNo,
    required String area,
    String? landmark,
    required String addressType,
  }) async {
    final response = await _apiService.post('/address', {
      'full_name': fullName,
      'phone': phone,
      'pincode': pincode,
      'state': state,
      'city': city,
      'house_no': houseNo,
      'area': area,
      if (landmark != null) 'landmark': landmark,
      'address_type': addressType,
    });
    return ApiAddress.fromJson(response['data']);
  }

  Future<ApiAddress> updateAddress({
    required int id,
    required String fullName,
    required String phone,
    required String pincode,
    required String state,
    required String city,
    required String houseNo,
    required String area,
    String? landmark,
    required String addressType,
  }) async {
    final response = await _apiService.put('/address/$id', {
      'full_name': fullName,
      'phone': phone,
      'pincode': pincode,
      'state': state,
      'city': city,
      'house_no': houseNo,
      'area': area,
      if (landmark != null) 'landmark': landmark,
      'address_type': addressType,
    });
    return ApiAddress.fromJson(response['data']);
  }

  Future<void> deleteAddress(int id) async {
    await _apiService.delete('/address/$id');
  }

  Future<ApiAddress> setDefaultAddress(int id) async {
    final response = await _apiService.patch('/address/default/$id', {});
    return ApiAddress.fromJson(response['data']);
  }
}
