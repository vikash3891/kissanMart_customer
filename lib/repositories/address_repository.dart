import '../api_models/address.dart';
import '../services/address_service.dart';

class AddressRepository {
  final AddressService _addressService = AddressService();

  Future<List<ApiAddress>> getAddresses() {
    return _addressService.getAddresses();
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
  }) {
    return _addressService.addAddress(
      fullName: fullName,
      phone: phone,
      pincode: pincode,
      state: state,
      city: city,
      houseNo: houseNo,
      area: area,
      landmark: landmark,
      addressType: addressType,
    );
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
  }) {
    return _addressService.updateAddress(
      id: id,
      fullName: fullName,
      phone: phone,
      pincode: pincode,
      state: state,
      city: city,
      houseNo: houseNo,
      area: area,
      landmark: landmark,
      addressType: addressType,
    );
  }

  Future<void> deleteAddress(int id) {
    return _addressService.deleteAddress(id);
  }

  Future<ApiAddress> setDefaultAddress(int id) {
    return _addressService.setDefaultAddress(id);
  }
}
