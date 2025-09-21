
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddressPersistence {
  static const String _currentAddressKey = 'current_user_address';

  static const String _addressListKey = 'user_address_list';

  /// Saves the currently selected address.
  static Future<void> saveCurrentAddress(Map<String, dynamic> addressData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentAddressKey, json.encode(addressData));
    } catch (e) {
      print('Error saving current address: $e');
    }
  }

  /// Loads the currently selected address.
  static Future<Map<String, dynamic>?> loadCurrentAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? addressJson = prefs.getString(_currentAddressKey);
      if (addressJson != null) {
        return json.decode(addressJson);
      }
    } catch (e) {
      print('Error loading current address: $e');
    }
    return null;
  }

  /// Loads the entire list of saved addresses.
  static Future<List<Map<String, dynamic>>> loadAllAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? addressListJson = prefs.getStringList(_addressListKey);
      if (addressListJson != null) {
        return addressListJson
            .map((address) => json.decode(address) as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      print('Error loading address list: $e');
    }
    return [];
  }

  /// Adds or Updates a new address to the list of saved addresses.
  static Future<void> saveOrUpdateAddress(Map<String, dynamic> newAddress) async {
    try {
      final List<Map<String, dynamic>> addresses = await loadAllAddresses();
      final String newLabel = newAddress['label'];

      int existingIndex = addresses.indexWhere((addr) => addr['label'] == newLabel);

      if (existingIndex != -1) {
        addresses[existingIndex] = newAddress;
      } else {
        addresses.add(newAddress);
      }

      final prefs = await SharedPreferences.getInstance();
      final List<String> addressListJson =
      addresses.map((address) => json.encode(address)).toList();
      await prefs.setStringList(_addressListKey, addressListJson);
    } catch (e) {
      print('Error saving or updating address: $e');
    }
  }

  /// Clears the currently selected address.
  static Future<void> clearCurrentAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentAddressKey);
    } catch (e) {
      print('Error clearing current address: $e');
    }
  }

  /// Clears all saved addresses.
  static Future<void> clearAllAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_addressListKey);
    } catch (e) {
      print('Error clearing all addresses: $e');
    }
  }
  static Future<void> deleteAddress(Map<String, dynamic> addressToDelete) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> addresses = await loadAllAddresses();
      final currentAddress = await loadCurrentAddress();

      // Remove the specified address from the list
      addresses.removeWhere((address) =>
      address['label'] == addressToDelete['label'] &&
          address['street'] == addressToDelete['street']
      );

      // Save the updated list back to storage
      final List<String> addressListJson =
      addresses.map((address) => json.encode(address)).toList();
      await prefs.setStringList(_addressListKey, addressListJson);

      // If the deleted address was the currently selected one, clear it
      if (currentAddress != null &&
          currentAddress['label'] == addressToDelete['label'] &&
          currentAddress['street'] == addressToDelete['street']) {
        await clearCurrentAddress();
      }
    } catch (e) {
      print('Error deleting address: $e');
    }
  }
}