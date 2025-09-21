// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lottie/lottie.dart';
// import 'package:steam/constant/constant.dart';
// import '../constant/cart_persistence.dart';
// import '../screen/cart.dart';
// import '../screen/HomeScreen.dart';
//
// class IroningPriceListPage extends StatefulWidget {
//   const IroningPriceListPage({super.key});
//
//   @override
//   _IroningPriceListPageState createState() => _IroningPriceListPageState();
// }
//
// class _IroningPriceListPageState extends State<IroningPriceListPage> {
//   List<Map<String, dynamic>> ironingPrices = [];
//   List<Map<String, dynamic>> filteredPrices = [];
//   Map<String, int> itemQuantities = {};
//   final TextEditingController _searchController = TextEditingController();
//   bool _isLoading = true;
//   double _ironingTotal = 0;
//   int _totalCartItems = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCart();
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadSavedCart() async {
//     try {
//       final savedCart = await CartPersistence.loadCart();
//       print("Loading saved cart at ${DateTime.now().toString()}: $savedCart");
//       setState(() {
//         if (savedCart != null && savedCart['ironingItems'] != null) {
//           itemQuantities = (savedCart['ironingItems'] as Map<String, dynamic>? ?? {})
//               .map((key, value) => MapEntry(key, value as int));
//           _ironingTotal = _calculateIroningTotal();
//           print("Loaded Ironing Quantities at ${DateTime.now().toString()}: $itemQuantities");
//         }
//         // total cart items for badge
//         _totalCartItems = (savedCart?['dryCleanItems'] as Map<String, dynamic>? ?? {}).length +
//             (savedCart?['ironingItems'] as Map<String, dynamic>? ?? {}).length +
//             (savedCart?['washAndFoldItems'] as Map<String, dynamic>? ?? {}).length +
//             (savedCart?['washAndIronItems'] as Map<String, dynamic>? ?? {}).length +
//             (savedCart?['washIronStarchItems'] as Map<String, dynamic>? ?? {}).length +
//             (savedCart?['prePlatedItems'] as Map<String, dynamic>? ?? {}).length +
//             ((savedCart?['additionalServices'] as Map<String, dynamic>? ?? {})
//                 .values
//                 .expand((items) => items as List<dynamic>)
//                 .where((item) => (item as Map<String, dynamic>?)?["quantity"] > 0)
//                 .length);
//       });
//       _fetchIroningPrices();
//     } catch (e) {
//       print("Error loading saved cart at ${DateTime.now().toString()}: $e");
//       _fetchIroningPrices();
//     }
//   }
//
//   void _fetchIroningPrices() async {
//     try {
//       print("Fetching ironing prices from Firestore at ${DateTime.now().toString()}...");
//       QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("Iron").get();
//       print("Firestore snapshot for Iron collection at ${DateTime.now().toString()}: ${snapshot.docs.length} documents found");
//
//       setState(() {
//         ironingPrices = snapshot.docs.map((doc) {
//           var data = doc.data() as Map<String, dynamic>;
//           String name = doc.id;
//           // Replace '-' with '/' except for "T-shirt"
//           if (name != "T-shirt" && name.contains('-')) {
//             name = name.replaceAll('-', '/');
//           }
//           print("Processing document at ${DateTime.now().toString()}: ID=${doc.id}, Data=$data");
//
//           return {
//             "name": name,
//             "price": data["price"] ?? 0,
//             "image": data["image"] ?? "",
//             "unit": "/piece",
//           };
//         }).toList();
//
//         filteredPrices = ironingPrices;
//         _isLoading = false;
//         _ironingTotal = _calculateIroningTotal();
//         print("Fetched Ironing Prices at ${DateTime.now().toString()}: $ironingPrices");
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       print("Error fetching ironing prices at ${DateTime.now().toString()}: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to load items. Please check you internet or try again later"),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }
//
//   void _filterSearch(String query) {
//     String normalizedQuery = query.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), "");
//
//     setState(() {
//       filteredPrices = ironingPrices.where((item) {
//         String itemName = item["name"].toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), "");
//         return itemName.startsWith(normalizedQuery);
//       }).toList();
//       print("Filtered Ironing Prices at ${DateTime.now().toString()}: $filteredPrices");
//     });
//   }
//
//   bool isItemSelected() {
//     return itemQuantities.isNotEmpty;
//   }
//
//   double _calculateIroningTotal() {
//     double total = 0;
//     itemQuantities.forEach((name, quantity) {
//       var item = ironingPrices.firstWhere(
//             (item) => item["name"] == name,
//         orElse: () => {"price": 0},
//       );
//       total += (item["price"] * quantity);
//     });
//     print("Calculated Ironing Total at ${DateTime.now().toString()}: ₹$total");
//     return total;
//   }
//
//   Future<void> _saveSelections() async {
//     try {
//       print("Saving ironing items at ${DateTime.now().toString()}: $itemQuantities");
//       await CartPersistence.updateCart(
//         ironingItems: itemQuantities,
//       );
//       print("Saved Ironing Items to Cart at ${DateTime.now().toString()}: $itemQuantities");
//     } catch (e) {
//       print("Error saving ironing items at ${DateTime.now().toString()}: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to save selections. Please check your internet or try again later"),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }
//
//   Future<Map<String, dynamic>> _loadCartForNavigation() async {
//     try {
//       final savedCart = await CartPersistence.loadCart();
//       print("Loaded cart for navigation at ${DateTime.now().toString()}: $savedCart");
//       return {
//         'dryCleanItems': (savedCart?['dryCleanItems'] as Map<String, dynamic>? ?? {})
//             .map((key, value) => MapEntry(key, value as int)),
//         'ironingItems': (savedCart?['ironingItems'] as Map<String, dynamic>? ?? {})
//             .map((key, value) => MapEntry(key, value as int)),
//         'washAndFoldItems': (savedCart?['washAndFoldItems'] as Map<String, dynamic>? ?? {})
//             .map((key, value) => MapEntry(key, value as int)),
//         'washAndIronItems': (savedCart?['washAndIronItems'] as Map<String, dynamic>? ?? {})
//             .map((key, value) => MapEntry(key, value as int)),
//         'washIronStarchItems': (savedCart?['washIronStarchItems'] as Map<String, dynamic>? ?? {})
//             .map((key, value) => MapEntry(key, value as int)),
//         'prePlatedItems': (savedCart?['prePlatedItems'] as Map<String, dynamic>? ?? {})
//             .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value))),
//         'additionalServices': (savedCart?['additionalServices'] as Map<String, dynamic>? ?? {})
//             .map((key, value) => MapEntry(
//           key,
//           (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList(),
//         )),
//         'dryCleanTotal': savedCart?['dryCleanTotal'] as double? ?? 0,
//         'additionalTotal': savedCart?['additionalTotal'] as double? ?? 0,
//       };
//     } catch (e) {
//       print("Error loading cart for navigation at ${DateTime.now().toString()}: $e");
//       return {
//         'dryCleanItems': <String, int>{},
//         'ironingItems': <String, int>{},
//         'washAndFoldItems': <String, int>{},
//         'washAndIronItems': <String, int>{},
//         'washIronStarchItems': <String, int>{},
//         'prePlatedItems': <String, Map<String, dynamic>>{},
//         'additionalServices': <String, List<Map<String, dynamic>>>{},
//         'dryCleanTotal': 0.0,
//         'additionalTotal': 0.0,
//       };
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Ironing",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back_ios, size: 20),
//         ),
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(12),
//           ),
//         ),
//         backgroundColor: bgColorPink,
//         foregroundColor: Colors.white,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: IconButton(
//               icon: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   const Icon(Icons.shopping_cart, size: 28),
//                   if (_totalCartItems > 0)
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       child: Container(
//                         padding: const EdgeInsets.all(2),
//                         decoration: BoxDecoration(
//                           color: Colors.red,
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 1),
//                         ),
//                         constraints: const BoxConstraints(
//                           minWidth: 20,
//                           minHeight: 20,
//                         ),
//                         child: Center(
//                           child: Text(
//                             '$_totalCartItems',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               onPressed: () async {
//                 try {
//                   await _saveSelections();
//                   final cartData = await _loadCartForNavigation();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => CartPage(
//                         dryCleanItems: cartData['dryCleanItems'],
//                         ironingItems: cartData['ironingItems'],
//                         washAndFoldItems: cartData['washAndFoldItems'],
//                         washAndIronItems: cartData['washAndIronItems'],
//                         washIronStarchItems: cartData['washIronStarchItems'],
//                         prePlatedItems: cartData['prePlatedItems'],
//                         additionalServices: cartData['additionalServices'],
//                         dryCleanTotal: cartData['dryCleanTotal'],
//                         additionalTotal: cartData['additionalTotal'],
//                       ),
//                     ),
//                   ).then((_) {
//                     _loadSavedCart();
//                   });
//                 } catch (e) {
//                   print("Error navigating to CartPage at ${DateTime.now().toString()}: $e");
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("Error navigating to cart"),
//                       backgroundColor: Colors.red,
//                       duration: const Duration(seconds: 2),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Lottie.asset(
//               'assets/animations/loading.json',
//               width: 200,
//               height: 200,
//               fit: BoxFit.contain,
//             ),
//           ],
//         ),
//       )
//           : Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(30),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 8,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 onChanged: _filterSearch,
//                 decoration: InputDecoration(
//                   prefixIcon: const Icon(Icons.search, color: bgColorPink),
//                   hintText: "Search items...",
//                   hintStyle: TextStyle(color: Colors.grey[600]),
//                   border: InputBorder.none,
//                   contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   suffixIcon: _searchController.text.isNotEmpty
//                       ? IconButton(
//                     icon: const Icon(Icons.clear, color: Colors.grey),
//                     onPressed: () {
//                       _searchController.clear();
//                       _filterSearch('');
//                     },
//                   )
//                       : null,
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//             child: Row(
//               children: [
//                 Text(
//                   "Available Items",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 const Spacer(),
//                 if (isItemSelected())
//                   Text(
//                     "${itemQuantities.length} item${itemQuantities.length > 1 ? 's' : ''} selected",
//                     style: const TextStyle(
//                       color: bgColorPink,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: filteredPrices.isEmpty
//                 ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Lottie.asset(
//                     'assets/animations/empty.json',
//                     width: 200,
//                     height: 200,
//                     fit: BoxFit.contain,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     "No items found",
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       _searchController.clear();
//                       _filterSearch('');
//                     },
//                     child: const Text("Clear search"),
//                   ),
//                 ],
//               ),
//             )
//                 : ListView.separated(
//               padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//               itemCount: filteredPrices.length,
//               separatorBuilder: (context, index) => const SizedBox(height: 8),
//               itemBuilder: (context, index) {
//                 final item = filteredPrices[index];
//                 final isSelected = itemQuantities.containsKey(item["name"]);
//                 final quantity = itemQuantities[item["name"]] ?? 0;
//
//                 return Card(
//                   elevation: isSelected ? 4 : 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     side: isSelected
//                         ? BorderSide(color: bgColorPink, width: 2)
//                         : BorderSide(color: Colors.grey[200]!, width: 1),
//                   ),
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(12),
//                     onTap: () {
//                       setState(() {
//                         if (isSelected) {
//                           itemQuantities.remove(item["name"]);
//                         } else {
//                           itemQuantities[item["name"]] = 1;
//                         }
//                         _ironingTotal = _calculateIroningTotal();
//                         print("Updated itemQuantities on tap at ${DateTime.now().toString()}: $itemQuantities");
//                       });
//                       _saveSelections();
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 70,
//                             height: 70,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               color: item["image"].isEmpty
//                                   ? Colors.grey[200]
//                                   : null,
//                               image: item["image"].isNotEmpty
//                                   ? DecorationImage(
//                                 image: NetworkImage(item["image"]),
//                                 fit: BoxFit.cover,
//                                 onError: (exception, stackTrace) {
//                                   print("Image load error for ${item["name"]} at ${DateTime.now().toString()}: $exception");
//                                 },
//                               )
//                                   : null,
//                             ),
//                             child: item["image"].isEmpty
//                                 ? Icon(
//                               Icons.image_not_supported,
//                               color: Colors.grey[400],
//                               size: 40,
//                             )
//                                 : null,
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   item["name"],
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey[800],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   "₹${item["price"]} ${item["unit"]}",
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: bgColorPink,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           if (isSelected)
//                             Container(
//                               width: 100,
//                               height: 36,
//                               decoration: BoxDecoration(
//                                 color: Colors.pinkAccent.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(18),
//                                 border: Border.all(color: bgColorPink),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   IconButton(
//                                     icon: const Icon(Icons.remove, size: 18),
//                                     padding: EdgeInsets.zero,
//                                     onPressed: () {
//                                       setState(() {
//                                         if (quantity > 1) {
//                                           itemQuantities[item["name"]] =
//                                               quantity - 1;
//                                         } else {
//                                           itemQuantities.remove(item["name"]);
//                                         }
//                                         _ironingTotal = _calculateIroningTotal();
//                                         print("Updated itemQuantities on decrement at ${DateTime.now().toString()}: $itemQuantities");
//                                       });
//                                       _saveSelections();
//                                     },
//                                   ),
//                                   Text(
//                                     "$quantity",
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(Icons.add, size: 18),
//                                     padding: EdgeInsets.zero,
//                                     onPressed: () {
//                                       setState(() {
//                                         itemQuantities[item["name"]] =
//                                             quantity + 1;
//                                         _ironingTotal = _calculateIroningTotal();
//                                         print("Updated itemQuantities on increment at ${DateTime.now().toString()}: $itemQuantities");
//                                       });
//                                       _saveSelections();
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             )
//                           else
//                             Container(
//                               width: 36,
//                               height: 36,
//                               decoration: const BoxDecoration(
//                                 color: bgColorPink,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.add,
//                                 color: Colors.white,
//                                 size: 20,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           if (isItemSelected())
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, -5),
//                   ),
//                 ],
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//               ),
//               child: SafeArea(
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Ironing Total",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           Text(
//                             "₹${_ironingTotal.toStringAsFixed(2)}",
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: bgColorPink,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           await _saveSelections();
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => HomePage(),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: bgColorPink,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               "Continue",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             SizedBox(width: 8),
//                             Icon(Icons.arrow_forward, size: 20, color: Colors.white),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../constant/cart_persistence.dart';
import '../constant/constant.dart';
import '../screen/cart.dart';
import '../screen/HomeScreen.dart';

class IroningPriceListPage extends StatefulWidget {
  const IroningPriceListPage({super.key});

  @override
  _IroningPriceListPageState createState() => _IroningPriceListPageState();
}

class _IroningPriceListPageState extends State<IroningPriceListPage> {
  List<Map<String, dynamic>> ironingPrices = [];
  List<Map<String, dynamic>> filteredPrices = [];
  Map<String, int> itemQuantities = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  double _ironingTotal = 0;
  int _totalCartItems = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedCart();
    _searchController.addListener(() {
      _filterSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCart() async {
    try {
      final savedCart = await CartPersistence.loadCart();
      setState(() {
        if (savedCart != null) {
          itemQuantities = (savedCart['ironingItems'] as Map<String, dynamic>? ?? {})
              .map((key, value) => MapEntry(key, value as int));
          _totalCartItems = _calculateTotalCartItems(savedCart);
        }
      });
      await _fetchIroningPrices(); // Wait for prices to be fetched before calculating total
    } catch (e) {
      print("Error loading saved cart at ${DateTime.now()}: $e");
      await _fetchIroningPrices();
    }
  }

  int _calculateTotalCartItems(Map<String, dynamic> savedCart) {
    int totalItems = 0;
    // Sum quantities from all item categories
    totalItems += (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).values.fold<int>(0, (sum, quantity) => sum + (quantity as int? ?? 0));
    totalItems += (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).values.fold<int>(0, (sum, quantity) => sum + (quantity as int? ?? 0));
    totalItems += (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).values.fold<int>(0, (sum, quantity) => sum + (quantity as int? ?? 0));
    totalItems += (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).values.fold<int>(0, (sum, quantity) => sum + (quantity as int? ?? 0));
    totalItems += (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).values.fold<int>(0, (sum, quantity) => sum + (quantity as int? ?? 0));

    // Sum quantities from pre-plated items
    final prePlatedItemsFromCart = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {});
    prePlatedItemsFromCart.values.forEach((itemData) {
      totalItems += (itemData?["quantity"] as int? ?? 0);
    });

    // Sum quantities from additional services
    final additionalServicesFromCart = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {});
    additionalServicesFromCart.forEach((key, items) {
      if (items is List) {
        for (var item in items) {
          if (item is Map<String, dynamic>) {
            totalItems += (item["quantity"] as int? ?? 0);
          }
        }
      }
    });

    return totalItems;
  }

  Future<void> _fetchIroningPrices() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("Iron").get();

      setState(() {
        ironingPrices = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          String name = doc.id;
          // Replace '-' with '/' except for "T-shirt"
          if (name != "T-shirt" && name.contains('-')) {
            name = name.replaceAll('-', '/');
          }
          return {
            "name": name,
            "price": data["price"] ?? 0,
            "image": data["image"] ?? "",
            "unit": "/piece",
          };
        }).toList();

        filteredPrices = ironingPrices;
        _isLoading = false;
        _ironingTotal = _calculateIroningTotal(); // Calculate total after fetching prices
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching ironing prices at ${DateTime.now()}: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load items. Please check your internet or try again later"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredPrices = ironingPrices;
      });
      return;
    }
    String normalizedQuery = query.toLowerCase().trim();
    setState(() {
      filteredPrices = ironingPrices.where((item) {
        String itemName = item["name"].toLowerCase();
        return itemName.contains(normalizedQuery);
      }).toList();
    });
  }

  bool isItemSelected() {
    return itemQuantities.values.any((quantity) => quantity > 0);
  }

  double _calculateIroningTotal() {
    double total = 0;
    itemQuantities.forEach((name, quantity) {
      var item = ironingPrices.firstWhere(
            (item) => item["name"] == name,
        orElse: () => {"price": 0},
      );
      total += (item["price"] * quantity);
    });
    return total;
  }

  Future<void> _saveCart() async {
    try {
      await CartPersistence.updateCart(
        ironingItems: itemQuantities,
      );
      // Recalculate total items for the badge after saving
      final savedCart = await CartPersistence.loadCart();
      if (savedCart != null) {
        setState(() {
          _totalCartItems = _calculateTotalCartItems(savedCart);
        });
      }
    } catch (e) {
      print("Error saving ironing items at ${DateTime.now()}: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save selections. Please check your internet or try again later."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToCartPage() async {
    await _saveCart();
    try {
      final savedCart = await CartPersistence.loadCart();
      if (savedCart != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartPage(
            dryCleanItems: (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
            ironingItems: (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
            washAndFoldItems: (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
            washAndIronItems: (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
            washIronStarchItems: (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
            prePlatedItems: (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).cast<String, Map<String, dynamic>>(),
            additionalServices: (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList())),
            dryCleanTotal: savedCart['dryCleanTotal'] as double? ?? 0,
            additionalTotal: savedCart['additionalTotal'] as double? ?? 0,
          )),
        ).then((_) => _loadSavedCart());
      }
    } catch (e) {
      print("Error navigating to CartPage at ${DateTime.now()}: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to navigate to cart. Please try again later."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _continueShopping() async {
    await _saveCart();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  Widget _buildItemCard(BuildContext context, Map<String, dynamic> item) {
    final isSelected = itemQuantities.containsKey(item["name"]);
    final quantity = itemQuantities[item["name"]] ?? 0;

    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: bgColorPink, width: 2)
            : BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            if (isSelected) {
              itemQuantities.remove(item["name"]);
            } else {
              itemQuantities[item["name"]] = 1;
            }
            _ironingTotal = _calculateIroningTotal();
          });
          _saveCart();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: item["image"].isEmpty ? Colors.grey[200] : null,
                  image: item["image"].isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(item["image"]),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: item["image"].isEmpty
                    ? Icon(Icons.image_not_supported, color: Colors.grey[400], size: 40)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["name"],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${item["price"]} ${item["unit"]}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: bgColorPink),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isSelected)
                Container(
                  width: 100,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: bgColorPink),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) {
                              itemQuantities[item["name"]] = quantity - 1;
                            } else {
                              itemQuantities.remove(item["name"]);
                            }
                            _ironingTotal = _calculateIroningTotal();
                          });
                          _saveCart();
                        },
                      ),
                      Text("$quantity", style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            itemQuantities[item["name"]] = quantity + 1;
                            _ironingTotal = _calculateIroningTotal();
                          });
                          _saveCart();
                        },
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(color: bgColorPink, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildSearchField(),
        _buildHeaderRow(),
        Expanded(
          child: filteredPrices.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: filteredPrices.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildItemCard(context, filteredPrices[index]);
            },
          ),
        ),
        if (isItemSelected()) _buildMobileFooter(),
      ],
    );
  }

  Widget _buildWebLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildSearchField(),
                  _buildHeaderRow(),
                  Expanded(
                    child: filteredPrices.isEmpty
                        ? _buildEmptyState()
                        : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.3, // Adjust for item card proportions
                      ),
                      itemCount: filteredPrices.length,
                      itemBuilder: (context, index) {
                        return _buildItemCard(context, filteredPrices[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (isItemSelected())
              SizedBox(
                width: 320,
                child: _buildWebFooter(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, spreadRadius: 2)],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: bgColorPink),
            hintText: "Search items...",
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
              },
            )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Text("Available Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const Spacer(),
          if (isItemSelected())
            Text(
              "${itemQuantities.length} item${itemQuantities.length > 1 ? 's' : ''} selected",
              style: const TextStyle(color: bgColorPink, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animations/empty.json', width: 200, height: 200, fit: BoxFit.contain),
          const SizedBox(height: 16),
          Text("No items found", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          TextButton(
            onPressed: () => _searchController.clear(),
            child: const Text("Clear search"),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ironing Total", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  Text(
                    "₹${_ironingTotal.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: bgColorPink),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: _continueShopping,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColorPink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 16.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Ironing Total", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(
              "₹${_ironingTotal.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: bgColorPink),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _continueShopping,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColorPink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ironing", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
        backgroundColor: bgColorPink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.shopping_cart, size: 28, color: Colors.white),
                if (_totalCartItems > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Center(
                        child: Text(
                          '$_totalCartItems',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _navigateToCartPage,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Lottie.asset('assets/animations/loading.json', width: 200, height: 200, fit: BoxFit.contain),
      )
          : isMobile ? _buildMobileLayout() : _buildWebLayout(),
    );
  }
}