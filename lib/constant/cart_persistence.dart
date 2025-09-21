// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../constant/address_persistence.dart';
//
// class CartPersistence {
//   static const String _cartKey = 'cart_data';
//
//   static Future<void> saveCart({
//     required Map<String, int> dryCleanItems,
//     required Map<String, int> ironingItems,
//     required Map<String, int> washAndFoldItems,
//     required Map<String, int> washAndIronItems,
//     required Map<String, int> washIronStarchItems,
//     required Map<String, Map<String, dynamic>> prePlatedItems,
//     required Map<String, List<Map<String, dynamic>>> additionalServices,
//     required double dryCleanTotal,
//     required double additionalTotal,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cart = {
//         'dryCleanItems': dryCleanItems,
//         'ironingItems': ironingItems,
//         'washAndFoldItems': washAndFoldItems,
//         'washAndIronItems': washAndIronItems,
//         'washIronStarchItems': washIronStarchItems,
//         'prePlatedItems': prePlatedItems,
//         'additionalServices': additionalServices,
//         'dryCleanTotal': dryCleanTotal,
//         'additionalTotal': additionalTotal,
//       };
//       await prefs.setString(_cartKey, json.encode(cart));
//       print("Saved Cart at 03:37 PM IST on June 18, 2025: $cart");
//     } catch (e) {
//       print("Error saving cart at 03:37 PM IST on June 18, 2025: $e");
//       throw Exception("Failed to save cart: $e");
//     }
//   }
//
//   static Future<Map<String, dynamic>?> loadCart() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cartString = prefs.getString(_cartKey);
//       if (cartString != null) {
//         final cart = json.decode(cartString) as Map<String, dynamic>;
//
//         final validatedCart = <String, dynamic>{
//           'dryCleanItems': (cart['dryCleanItems'] as Map<String, dynamic>?)?.map(
//                 (key, value) => MapEntry(key, value as int),
//           ) ?? <String, int>{},
//           'ironingItems': (cart['ironingItems'] as Map<String, dynamic>?)?.map(
//                 (key, value) => MapEntry(key, value as int),
//           ) ?? <String, int>{},
//           'washAndFoldItems': (cart['washAndFoldItems'] as Map<String, dynamic>?)?.map(
//                 (key, value) => MapEntry(key, value as int),
//           ) ?? <String, int>{},
//           'washAndIronItems': (cart['washAndIronItems'] as Map<String, dynamic>?)?.map(
//                 (key, value) => MapEntry(key, value as int),
//           ) ?? <String, int>{},
//           'washIronStarchItems': (cart['washIronStarchItems'] as Map<String, dynamic>?)?.map(
//                 (key, value) => MapEntry(key, value as int),
//           ) ?? <String, int>{},
//           'prePlatedItems': (cart['prePlatedItems'] as Map<String, dynamic>?)?.map(
//                 (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
//           ) ?? <String, Map<String, dynamic>>{},
//           'additionalServices': (cart['additionalServices'] as Map<String, dynamic>?)?.map(
//                 (key, value) => MapEntry(
//               key,
//               (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList(),
//             ),
//           ) ?? <String, List<Map<String, dynamic>>>{},
//           'dryCleanTotal': (cart['dryCleanTotal'] as num?)?.toDouble() ?? 0.0,
//           'additionalTotal': (cart['additionalTotal'] as num?)?.toDouble() ?? 0.0,
//         };
//
//         print("Loaded Cart at 03:37 PM IST on June 18, 2025: $validatedCart");
//         return validatedCart;
//       }
//       print("No cart found at 03:37 PM IST on June 18, 2025");
//       return null;
//     } catch (e) {
//       print("Error loading cart at 03:37 PM IST on June 18, 2025: $e");
//       throw Exception("Failed to load cart: $e");
//     }
//   }
//
//   static Future<void> updateCart({
//     Map<String, int>? dryCleanItems,
//     Map<String, int>? ironingItems,
//     Map<String, int>? washAndFoldItems,
//     Map<String, int>? washAndIronItems,
//     Map<String, int>? washIronStarchItems,
//     Map<String, Map<String, dynamic>>? prePlatedItems,
//     Map<String, List<Map<String, dynamic>>>? additionalServices,
//     double? dryCleanTotal,
//     double? additionalTotal,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       final existingCart = await loadCart() ?? <String, dynamic>{};
//
//       final updatedCart = <String, dynamic>{
//         'dryCleanItems': dryCleanItems ??
//             (existingCart['dryCleanItems'] as Map<String, int>? ?? <String, int>{}),
//         'ironingItems': ironingItems ??
//             (existingCart['ironingItems'] as Map<String, int>? ?? <String, int>{}),
//         'washAndFoldItems': washAndFoldItems ??
//             (existingCart['washAndFoldItems'] as Map<String, int>? ?? <String, int>{}),
//         'washAndIronItems': washAndIronItems ??
//             (existingCart['washAndIronItems'] as Map<String, int>? ?? <String, int>{}),
//         'washIronStarchItems': washIronStarchItems ??
//             (existingCart['washIronStarchItems'] as Map<String, int>? ?? <String, int>{}),
//         'prePlatedItems': prePlatedItems ??
//             (existingCart['prePlatedItems'] as Map<String, Map<String, dynamic>>? ?? <String, Map<String, dynamic>>{}),
//         'additionalServices': additionalServices ??
//             (existingCart['additionalServices'] as Map<String, List<Map<String, dynamic>>>? ??
//                 <String, List<Map<String, dynamic>>>{}),
//         'dryCleanTotal':
//         dryCleanTotal ?? (existingCart['dryCleanTotal'] as double? ?? 0.0),
//         'additionalTotal':
//         additionalTotal ?? (existingCart['additionalTotal'] as double? ?? 0.0),
//       };
//
//       await prefs.setString(_cartKey, json.encode(updatedCart));
//       print("Updated Cart at 03:37 PM IST on June 18, 2025: $updatedCart");
//     } catch (e) {
//       print("Error updating cart at 03:37 PM IST on June 18, 2025: $e");
//       throw Exception("Failed to update cart: $e");
//     }
//   }
//
//   static Future<void> clearCart() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_cartKey);
//       print("Cart cleared at 03:37 PM IST on June 18, 2025");
//     } catch (e) {
//       print("Error clearing cart at 03:37 PM IST on June 18, 2025: $e");
//       throw Exception("Failed to clear cart: $e");
//     }
//   }
//
//   static Future<String> _generateUniqueOrderId() async {
//     const prefix = "V12";
//     int counter = 1;
//     String orderId = "$prefix$counter";
//
//     while (true) {
//       final doc = await FirebaseFirestore.instance.collection('orders').doc(orderId).get();
//       if (!doc.exists) {
//         return orderId;
//       }
//       counter++;
//       orderId = "$prefix$counter";
//     }
//   }
//
//   static Future<String> saveOrder({
//     required Map<String, int> dryCleanItems,
//     required Map<String, int> ironingItems,
//     required Map<String, int> washAndFoldItems,
//     required Map<String, int> washAndIronItems,
//     required Map<String, int> washIronStarchItems,
//     required Map<String, Map<String, dynamic>> prePlatedItems,
//     required Map<String, List<Map<String, dynamic>>> additionalServices,
//     required double dryCleanTotal,
//     required double additionalTotal,
//   }) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null || user.phoneNumber == null) {
//         throw Exception("User not logged in or phone number not available.");
//       }
//
//       final phoneNumber = user.phoneNumber!;
//       final userDocRef = FirebaseFirestore.instance.collection('users').doc(phoneNumber);
//       final userDoc = await userDocRef.get();
//       final userName = userDoc.exists && userDoc.data() != null
//           ? userDoc.data()!['name'] as String? ?? 'Unknown'
//           : 'Unknown';
//
//       final savedAddress = await AddressPersistence.loadAddress();
//       if (savedAddress == null) {
//         throw Exception("No address found. Please set an address before placing an order.");
//       }
//
//       final orderId = await _generateUniqueOrderId();
//
//       // Detect subscriptions
//       final hasSubscription = washAndFoldItems.keys.any((key) => key.contains('Subscription')) ||
//           washAndIronItems.keys.any((key) => key.contains('Subscription')) ||
//           washIronStarchItems.keys.any((key) => key.contains('Subscription'));
//
//       final orderData = {
//         'orderId': orderId,
//         'phoneNumber': phoneNumber,
//         'userName': userName,
//         'address': savedAddress['streetAddress'] ?? '',
//         'doorNumber': savedAddress['doorNumber'] ?? '',
//         'streetName': savedAddress['streetName'] ?? '',
//         'latitude': savedAddress['latitude'] as double? ?? 0.0,
//         'longitude': savedAddress['longitude'] as double? ?? 0.0,
//         'dryCleanItems': dryCleanItems.map((key, value) => MapEntry('dryClean_$key', value)),
//         'ironingItems': ironingItems.map((key, value) => MapEntry('ironing_$key', value)),
//         'washAndFoldItems': washAndFoldItems.map((key, value) => MapEntry('washAndFold_$key', value)),
//         'washAndIronItems': washAndIronItems.map((key, value) => MapEntry('washAndIron_$key', value)),
//         'washIronStarchItems': washIronStarchItems.map((key, value) => MapEntry('washIronStarch_$key', value)),
//         'prePlatedItems': prePlatedItems.map((key, value) => MapEntry('prePlated_$key', Map<String, dynamic>.from(value))),
//         'additionalServices': additionalServices,
//         'dryCleanTotal': dryCleanTotal,
//         'additionalTotal': additionalTotal,
//         'orderStatus': 'Ready for Pickup',
//         'paymentStatus': hasSubscription ? 'Pending' : 'Confirmed', // Set based on subscription presence
//         'orderDate': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       };
//
//       await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);
//
//       await userDocRef.update({
//         'orderIds': FieldValue.arrayUnion([orderId]),
//       });
//
//       print("Order $orderId saved successfully at 05:59 PM IST on June 19, 2025: $orderData");
//       return orderId;
//     } catch (e, stackTrace) {
//       print("Error saving order at 05:59 PM IST on June 19, 2025: $e");
//       throw Exception("Failed to save order: $e");
//     }
//   }
// }

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constant/address_persistence.dart';

class CartPersistence {
  static const String _cartKey = 'cart_data';

  static Future<void> saveCart({
    required Map<String, int> dryCleanItems,
    required Map<String, int> ironingItems,
    required Map<String, int> washAndFoldItems,
    required Map<String, int> washAndIronItems,
    required Map<String, int> washIronStarchItems,
    required Map<String, Map<String, dynamic>> prePlatedItems,
    required Map<String, List<Map<String, dynamic>>> additionalServices,
    required double dryCleanTotal,
    required double additionalTotal,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cart = {
        'dryCleanItems': dryCleanItems,
        'ironingItems': ironingItems,
        'washAndFoldItems': washAndFoldItems,
        'washAndIronItems': washAndIronItems,
        'washIronStarchItems': washIronStarchItems,
        'prePlatedItems': prePlatedItems,
        'additionalServices': additionalServices,
        'dryCleanTotal': dryCleanTotal,
        'additionalTotal': additionalTotal,
      };
      await prefs.setString(_cartKey, json.encode(cart));
      print("Saved Cart at 01:08 PM IST on June 20, 2025: $cart");
    } catch (e) {
      print("Error saving cart at 01:08 PM IST on June 20, 2025: $e");
      throw Exception("Failed to save cart: $e");
    }
  }

  static Future<Map<String, dynamic>?> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_cartKey);
      if (cartString != null) {
        final cart = json.decode(cartString) as Map<String, dynamic>;

        final validatedCart = <String, dynamic>{
          'dryCleanItems': (cart['dryCleanItems'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, value as int),
          ) ?? <String, int>{},
          'ironingItems': (cart['ironingItems'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, value as int),
          ) ?? <String, int>{},
          'washAndFoldItems': (cart['washAndFoldItems'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, value as int),
          ) ?? <String, int>{},
          'washAndIronItems': (cart['washAndIronItems'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, value as int),
          ) ?? <String, int>{},
          'washIronStarchItems': (cart['washIronStarchItems'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, value as int),
          ) ?? <String, int>{},
          'prePlatedItems': (cart['prePlatedItems'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
          ) ?? <String, Map<String, dynamic>>{},
          'additionalServices': (cart['additionalServices'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(
              key,
              (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList(),
            ),
          ) ?? <String, List<Map<String, dynamic>>>{},
          'dryCleanTotal': (cart['dryCleanTotal'] as num?)?.toDouble() ?? 0.0,
          'additionalTotal': (cart['additionalTotal'] as num?)?.toDouble() ?? 0.0,
        };

        print("Loaded Cart at 01:08 PM IST on June 20, 2025: $validatedCart");
        return validatedCart;
      }
      print("No cart found at 01:08 PM IST on June 20, 2025");
      return null;
    } catch (e) {
      print("Error loading cart at 01:08 PM IST on June 20, 2025: $e");
      throw Exception("Failed to load cart: $e");
    }
  }

  static Future<void> updateCart({
    Map<String, int>? dryCleanItems,
    Map<String, int>? ironingItems,
    Map<String, int>? washAndFoldItems,
    Map<String, int>? washAndIronItems,
    Map<String, int>? washIronStarchItems,
    Map<String, Map<String, dynamic>>? prePlatedItems,
    Map<String, List<Map<String, dynamic>>>? additionalServices,
    double? dryCleanTotal,
    double? additionalTotal,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final existingCart = await loadCart() ?? <String, dynamic>{};

      final updatedCart = <String, dynamic>{
        'dryCleanItems': dryCleanItems ??
            (existingCart['dryCleanItems'] as Map<String, int>? ?? <String, int>{}),
        'ironingItems': ironingItems ??
            (existingCart['ironingItems'] as Map<String, int>? ?? <String, int>{}),
        'washAndFoldItems': washAndFoldItems ??
            (existingCart['washAndFoldItems'] as Map<String, int>? ?? <String, int>{}),
        'washAndIronItems': washAndIronItems ??
            (existingCart['washAndIronItems'] as Map<String, int>? ?? <String, int>{}),
        'washIronStarchItems': washIronStarchItems ??
            (existingCart['washIronStarchItems'] as Map<String, int>? ?? <String, int>{}),
        'prePlatedItems': prePlatedItems ??
            (existingCart['prePlatedItems'] as Map<String, Map<String, dynamic>>? ?? <String, Map<String, dynamic>>{}),
        'additionalServices': additionalServices ??
            (existingCart['additionalServices'] as Map<String, List<Map<String, dynamic>>>? ??
                <String, List<Map<String, dynamic>>>{}),
        'dryCleanTotal':
        dryCleanTotal ?? (existingCart['dryCleanTotal'] as double? ?? 0.0),
        'additionalTotal':
        additionalTotal ?? (existingCart['additionalTotal'] as double? ?? 0.0),
      };

      await prefs.setString(_cartKey, json.encode(updatedCart));
      print("Updated Cart at 01:08 PM IST on June 20, 2025: $updatedCart");
    } catch (e) {
      print("Error updating cart at 01:08 PM IST on June 20, 2025: $e");
      throw Exception("Failed to update cart: $e");
    }
  }

  static Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
      print("Cart cleared at 01:08 PM IST on June 20, 2025");
    } catch (e) {
      print("Error clearing cart at 01:08 PM IST on June 20, 2025: $e");
      throw Exception("Failed to clear cart: $e");
    }
  }

  static Future<String> _generateUniqueOrderId() async {
    const prefix = "V12";
    int counter = 1;
    String orderId = "$prefix$counter";

    while (true) {
      final doc = await FirebaseFirestore.instance.collection('orders').doc(orderId).get();
      if (!doc.exists) {
        return orderId;
      }
      counter++;
      orderId = "$prefix$counter";
    }
  }

  static Future<String> saveOrder({
    required Map<String, int> dryCleanItems,
    required Map<String, int> ironingItems,
    required Map<String, int> washAndFoldItems,
    required Map<String, int> washAndIronItems,
    required Map<String, int> washIronStarchItems,
    required Map<String, Map<String, dynamic>> prePlatedItems,
    required Map<String, List<Map<String, dynamic>>> additionalServices,
    required double dryCleanTotal,
    required double additionalTotal,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.phoneNumber == null) {
        throw Exception("User not logged in or phone number not available.");
      }

      final phoneNumber = user.phoneNumber!;
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(phoneNumber);
      final userDoc = await userDocRef.get();
      final userName = userDoc.exists && userDoc.data() != null
          ? userDoc.data()!['name'] as String? ?? 'Unknown'
          : 'Unknown';

      final savedAddress = await AddressPersistence.loadCurrentAddress();
      if (savedAddress == null) {
        throw Exception("No address found. Please set an address before placing an order.");
      }

      final orderId = await _generateUniqueOrderId();

      final hasSubscription = washAndFoldItems.keys.any((key) => key.contains('Subscription')) ||
          washAndIronItems.keys.any((key) => key.contains('Subscription')) ||
          washIronStarchItems.keys.any((key) => key.contains('Subscription'));

      final orderData = {
        'orderId': orderId,
        'phoneNumber': phoneNumber,
        'userName': userName,
        'address': savedAddress['streetAddress'] ?? '',
        'doorNumber': savedAddress['doorNumber'] ?? '',
        'streetName': savedAddress['streetName'] ?? '',
        'latitude': savedAddress['latitude'] as double? ?? 0.0,
        'longitude': savedAddress['longitude'] as double? ?? 0.0,
        'dryCleanItems': dryCleanItems.map((key, value) => MapEntry('dryClean_$key', value)),
        'ironingItems': ironingItems.map((key, value) => MapEntry('ironing_$key', value)),
        'washAndFoldItems': washAndFoldItems.map((key, value) => MapEntry('washAndFold_$key', value)),
        'washAndIronItems': washAndIronItems.map((key, value) => MapEntry('washAndIron_$key', value)),
        'washIronStarchItems': washIronStarchItems.map((key, value) => MapEntry('washIronStarch_$key', value)),
        'prePlatedItems': prePlatedItems.map((key, value) => MapEntry('prePlated_$key', Map<String, dynamic>.from(value))),
        'additionalServices': additionalServices,
        'dryCleanTotal': dryCleanTotal,
        'additionalTotal': additionalTotal,
        'orderStatus': 'Awaiting Pickup',
        'paymentStatus': hasSubscription ? 'Pending' : 'Confirmed',
        'orderDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);

      await userDocRef.update({
        'orderIds': FieldValue.arrayUnion([orderId]),
      });

      print("Order $orderId saved successfully at 01:08 PM IST on June 20, 2025: $orderData");
      return orderId;
    } catch (e, stackTrace) {
      print("Error saving order at 01:08 PM IST on June 20, 2025: $e");
      throw Exception("Failed to save order: $e");
    }
  }

  static Future<String> saveSubscriptionOrder({
    required String subscriptionId,
    required String category,
    required String label,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.phoneNumber == null) {
        throw Exception("User not logged in or phone number not available.");
      }

      final phoneNumber = user.phoneNumber!;
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(phoneNumber);
      final userDoc = await userDocRef.get();
      final userName = userDoc.exists && userDoc.data() != null
          ? userDoc.data()!['name'] as String? ?? 'Unknown'
          : 'Unknown';

      final savedAddress = await AddressPersistence.loadCurrentAddress();
      if (savedAddress == null) {
        throw Exception("No address found. Please set an address before placing an order.");
      }

      final orderId = await _generateUniqueOrderId();

      final orderData = {
        'orderId': orderId,
        'phoneNumber': phoneNumber,
        'userName': userName,
        'address': savedAddress['streetAddress'] ?? '',
        'doorNumber': savedAddress['doorNumber'] ?? '',
        'streetName': savedAddress['streetName'] ?? '',
        'latitude': savedAddress['latitude'] as double? ?? 0.0,
        'longitude': savedAddress['longitude'] as double? ?? 0.0,
        'subscriptionId': subscriptionId,
        'category': category,
        'label': label,
        'quantity': 1,
        'orderStatus': 'Awaiting Pickup',
        'paymentStatus': 'Pending',
        'orderDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);

      await userDocRef.update({
        'orderIds': FieldValue.arrayUnion([orderId]),
      });

      print("Subscription order $orderId saved successfully at 01:08 PM IST on June 20, 2025: $orderData");
      return orderId;
    } catch (e, stackTrace) {
      print("Error saving subscription order at 01:08 PM IST on June 20, 2025: $e");
      throw Exception("Failed to save subscription order: $e");
    }
  }
}