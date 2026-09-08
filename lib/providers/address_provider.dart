import 'package:flutter/material.dart';

import '../api_models/address.dart';
import '../repositories/address_repository.dart';
import '../services/api_exception.dart';

class AddressProvider extends ChangeNotifier {
  final AddressRepository _addressRepository = AddressRepository();

  List<ApiAddress> _addresses = [];
  ApiAddress? _selectedAddress;
  bool _loading = false;
  String? _error;

  List<ApiAddress> get addresses => _addresses;
  ApiAddress? get selectedAddress => _selectedAddress;
  bool get loading => _loading;
  String? get error => _error;

  AddressProvider() {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _addresses = await _addressRepository.getAddresses();
      if (_addresses.isNotEmpty) {
        // Find default or select the first one
        final defaultAddress = _addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => _addresses.first,
        );
        _selectedAddress = defaultAddress;
      } else {
        _selectedAddress = null;
      }
      _error = null;
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress({
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
    if (_loading) return false;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final newAddress = await _addressRepository.addAddress(
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
      _addresses.add(newAddress);
      if (_selectedAddress == null || newAddress.isDefault) {
        _selectedAddress = newAddress;
      }
      _error = null;
      notifyListeners();
      _loading = false;
      await loadAddresses();
      return true;
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAddress({
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
    if (_loading) return false;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedAddress = await _addressRepository.updateAddress(
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
      final idx = _addresses.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _addresses[idx] = updatedAddress;
      }
      if (_selectedAddress?.id == id) {
        _selectedAddress = updatedAddress;
      }
      _error = null;
      notifyListeners();
      _loading = false;
      await loadAddresses();
      return true;
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAddress(int id) async {
    if (_loading) return false;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _addressRepository.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);
      if (_selectedAddress?.id == id) {
        _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
      }
      _error = null;
      notifyListeners();
      _loading = false;
      await loadAddresses();
      return true;
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> setDefaultAddress(int id) async {
    if (_loading) return false;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedDefault = await _addressRepository.setDefaultAddress(id);
      _selectedAddress = updatedDefault;
      _error = null;
      notifyListeners();
      _loading = false;
      await loadAddresses();
      return true;
    } catch (e) {
      _error = e is ApiException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  void selectAddress(ApiAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<void> refresh() {
    return loadAddresses();
  }

  void clear() {
    _addresses = []; _selectedAddress = null; _error = null; notifyListeners();
  }
}
