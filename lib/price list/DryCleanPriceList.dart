// void _filterSearch(String query) {
//   String normalizedQuery = query.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), "");
//
//   setState(() {
//     filteredPrices = dryCleanPrices.where((item) {
//       String itemName = item["name"].toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), "");
//       return itemName.startsWith(normalizedQuery);
//     }).toList();
//     print("Filtered Ironing Prices at ${DateTime.now().toString()}: $filteredPrices");
//   });
// }

//////////////////////////////////////////////////////////


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lottie/lottie.dart';
// import 'package:steam/constant/constant.dart';
// import '../constant/cart_persistence.dart';
// import 'AdditionalService.dart';
//
// class DryCleanPriceListPage extends StatefulWidget {
//   const DryCleanPriceListPage({super.key});
//
//   @override
//   _DryCleanPriceListPageState createState() => _DryCleanPriceListPageState();
// }
//
// class _DryCleanPriceListPageState extends State<DryCleanPriceListPage> {
//   List<Map<String, dynamic>> dryCleanPrices = [];
//   List<Map<String, dynamic>> filteredPrices = [];
//   Map<String, int> itemQuantities = {};
//   Map<String, List<Map<String, dynamic>>> additionalServices = {};
//   final TextEditingController _searchController = TextEditingController();
//   bool _isLoading = true;
//   double _dryCleanTotal = 0;
//   double _additionalTotal = 0;
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
//       setState(() {
//         if (savedCart != null) {
//           itemQuantities = (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {})
//               .map((key, value) => MapEntry(key, value as int));
//           additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {})
//               .map((key, value) => MapEntry(
//             key,
//             (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList(),
//           ));
//           _dryCleanTotal = savedCart['dryCleanTotal'] as double? ?? 0;
//           _additionalTotal = savedCart['additionalTotal'] as double? ?? 0;
//           print("Loaded Dry Clean Quantities: $itemQuantities at ${DateTime.now().toString()}");
//           print("Loaded Additional Services: $additionalServices at ${DateTime.now().toString()}");
//         }
//       });
//       _fetchDryCleanPrices();
//     } catch (e) {
//       print("Error loading saved cart at ${DateTime.now().toString()}: $e");
//       _fetchDryCleanPrices();
//     }
//   }
//
//   void _fetchDryCleanPrices() async {
//     try {
//       QuerySnapshot snapshot =
//       await FirebaseFirestore.instance.collection("Dry Clean").get();
//
//       setState(() {
//         dryCleanPrices = snapshot.docs.map((doc) {
//           var data = doc.data() as Map<String, dynamic>;
//           String name = doc.id;
//           // Replace '-' with '/' except for "T-Shirt"
//           if (name != "T-Shirt" && name.contains('-')) {
//             name = name.replaceAll('-', '/');
//           }
//           String choice;
//           if (name.toLowerCase().contains("shoes") ||
//               name.toLowerCase().contains("gloves") ||
//               name.toLowerCase().contains("sandal")) {
//             choice = "${data["dry_clean"]?.toString() ?? "0"} /Pair";
//           } else if (name.toLowerCase().contains("dari") ||
//               name.toLowerCase().contains("carpet")) {
//             choice = "${data["dry_clean"]?.toString() ?? "0"} /Sq Ft";
//           } else {
//             choice = "${data["dry_clean"]?.toString() ?? "0"} /Piece";
//           }
//
//           return {
//             "name": name,
//             "dry_clean": choice,
//             "image": data["image"] ?? "",
//             "price": data["dry_clean"] ?? 0,
//           };
//         }).toList();
//
//         filteredPrices = dryCleanPrices;
//         _isLoading = false;
//         _dryCleanTotal = _calculateDryCleanTotal();
//         print("Fetched Dry Clean Prices at ${DateTime.now().toString()}: $dryCleanPrices");
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       print("Error fetching dry clean prices at ${DateTime.now().toString()}: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Failed to load items. Please check your internet or try again."),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//
//   void _filterSearch(String query) {
//     if (query.isEmpty) {
//       setState(() {
//         filteredPrices = dryCleanPrices;
//       });
//       return;
//     }
//
//     String normalizedQuery = query.toLowerCase().trim();
//     setState(() {
//       filteredPrices = dryCleanPrices.where((item) {
//         String itemName = item["name"].toLowerCase();
//         return itemName.contains(normalizedQuery); // Substring matching
//       }).toList();
//       print("Filtered Dry Clean Prices at ${DateTime.now().toString()}: $filteredPrices");
//     });
//   }
//
//   bool isItemSelected() {
//     return itemQuantities.isNotEmpty;
//   }
//
//   double _calculateDryCleanTotal() {
//     double total = 0;
//     itemQuantities.forEach((name, quantity) {
//       var item = dryCleanPrices.firstWhere(
//             (item) => item["name"] == name,
//         orElse: () => {"price": 0},
//       );
//       total += (item["price"] * quantity);
//     });
//     return total;
//   }
//
//   Future<void> _saveCart() async {
//     try {
//       await CartPersistence.updateCart(
//         dryCleanItems: itemQuantities,
//         additionalServices: additionalServices,
//         dryCleanTotal: _dryCleanTotal,
//         additionalTotal: _additionalTotal,
//       );
//     } catch (e) {
//       print("Error saving cart at ${DateTime.now().toString()}: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to save cart. Please check your internet or try again later"),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Dry Cleaning",
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
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(12),
//                     onTap: () {
//                       setState(() {
//                         if (isSelected) {
//                           itemQuantities.remove(item["name"]);
//                           // Remove related additional services
//                           additionalServices.forEach((category, items) {
//                             items.removeWhere((service) => service["name"] == item["name"]);
//                             if (items.isEmpty) {
//                               additionalServices.remove(category);
//                             }
//                           });
//                         } else {
//                           itemQuantities[item["name"]] = 1;
//                         }
//                         _dryCleanTotal = _calculateDryCleanTotal();
//                         _additionalTotal = _calculateAdditionalTotal();
//                       });
//                       _saveCart();
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
//                                 onError: (exception, stackTrace) {},
//                               )
//                                   : null,
//                               border: Border.all(
//                                 color: isSelected
//                                     ? bgColorPink
//                                     : Colors.grey[200]!,
//                                 width: isSelected ? 2 : 1,
//                               ),
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
//                                   "₹${item["dry_clean"]}",
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
//                                           // Adjust additional services if necessary
//                                           additionalServices.forEach((category, items) {
//                                             for (var service in items) {
//                                               if (service["name"] == item["name"]) {
//                                                 final maxQuantity = itemQuantities[item["name"]] ?? 0;
//                                                 if ((service["quantity"] ?? 0) > maxQuantity) {
//                                                   service["quantity"] = maxQuantity;
//                                                 }
//                                               }
//                                             }
//                                           });
//                                         } else {
//                                           itemQuantities.remove(item["name"]);
//                                           // Remove related additional services
//                                           additionalServices.forEach((category, items) {
//                                             items.removeWhere((service) => service["name"] == item["name"]);
//                                             if (items.isEmpty) {
//                                               additionalServices.remove(category);
//                                             }
//                                           });
//                                         }
//                                         _dryCleanTotal = _calculateDryCleanTotal();
//                                         _additionalTotal = _calculateAdditionalTotal();
//                                       });
//                                       _saveCart();
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
//                                         _dryCleanTotal = _calculateDryCleanTotal();
//                                       });
//                                       _saveCart();
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
//                             "Dry Clean Total",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           Text(
//                             "₹${_dryCleanTotal.toStringAsFixed(2)}",
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
//                         onPressed: () {
//                           _saveCart().then((_) {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => AdditionalService(
//                                   selectedItems: itemQuantities,
//                                   initialTotal: _dryCleanTotal,
//                                   dryCleanPrices: dryCleanPrices,
//                                 ),
//                               ),
//                             ).then((_) {
//                               _loadSavedCart();
//                             });
//                           });
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
//
//   double _calculateAdditionalTotal() {
//     double total = 0;
//     additionalServices.forEach((category, items) {
//       for (var item in items) {
//         total += (item["price"] * (item["quantity"] ?? 0));
//       }
//     });
//     return total;
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lottie/lottie.dart';
// import 'package:steam/constant/constant.dart';
// import '../constant/cart_persistence.dart';
// import 'AdditionalService.dart';
//
// class DryCleanPriceListPage extends StatefulWidget {
//   const DryCleanPriceListPage({super.key});
//
//   @override
//   _DryCleanPriceListPageState createState() => _DryCleanPriceListPageState();
// }
//
// class _DryCleanPriceListPageState extends State<DryCleanPriceListPage> {
//   List<Map<String, dynamic>> dryCleanPrices = [];
//   List<Map<String, dynamic>> filteredPrices = [];
//   Map<String, int> itemQuantities = {};
//   Map<String, List<Map<String, dynamic>>> additionalServices = {};
//   final TextEditingController _searchController = TextEditingController();
//   bool _isLoading = true;
//   double _dryCleanTotal = 0;
//   double _additionalTotal = 0;
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
//       setState(() {
//         if (savedCart != null) {
//           itemQuantities = (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {})
//               .map((key, value) => MapEntry(key, value as int));
//           additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {})
//               .map((key, value) => MapEntry(
//             key,
//             (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList(),
//           ));
//           _dryCleanTotal = savedCart['dryCleanTotal'] as double? ?? 0;
//           _additionalTotal = savedCart['additionalTotal'] as double? ?? 0;
//           print("Loaded Dry Clean Quantities: $itemQuantities at ${DateTime.now().toString()}");
//           print("Loaded Additional Services: $additionalServices at ${DateTime.now().toString()}");
//         }
//       });
//       _fetchDryCleanPrices();
//     } catch (e) {
//       print("Error loading saved cart at ${DateTime.now().toString()}: $e");
//       _fetchDryCleanPrices();
//     }
//   }
//
//   void _fetchDryCleanPrices() async {
//     try {
//       QuerySnapshot snapshot =
//       await FirebaseFirestore.instance.collection("Dry Clean").get();
//
//       setState(() {
//         dryCleanPrices = snapshot.docs.map((doc) {
//           var data = doc.data() as Map<String, dynamic>;
//           String name = doc.id;
//           // Replace '-' with '/' except for "T-Shirt"
//           if (name != "T-Shirt" && name.contains('-')) {
//             name = name.replaceAll('-', '/');
//           }
//           String choice;
//           if (name.toLowerCase().contains("shoes") ||
//               name.toLowerCase().contains("gloves") ||
//               name.toLowerCase().contains("sandal")) {
//             choice = "${data["dry_clean"]?.toString() ?? "0"} /Pair";
//           } else if (name.toLowerCase().contains("dari") ||
//               name.toLowerCase().contains("carpet")) {
//             choice = "${data["dry_clean"]?.toString() ?? "0"} /Sq Ft";
//           } else {
//             choice = "${data["dry_clean"]?.toString() ?? "0"} /Piece";
//           }
//
//           return {
//             "name": name,
//             "dry_clean": choice,
//             "image": data["image"] ?? "",
//             "price": data["dry_clean"] ?? 0,
//           };
//         }).toList();
//
//         filteredPrices = dryCleanPrices;
//         _isLoading = false;
//         _dryCleanTotal = _calculateDryCleanTotal();
//         print("Fetched Dry Clean Prices at ${DateTime.now().toString()}: $dryCleanPrices");
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       print("Error fetching dry clean prices at ${DateTime.now().toString()}: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Failed to load items. Please check your internet or try again."),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   void _filterSearch(String query) {
//     if (query.isEmpty) {
//       setState(() {
//         filteredPrices = dryCleanPrices;
//       });
//       return;
//     }
//
//     String normalizedQuery = query.toLowerCase().trim();
//     setState(() {
//       filteredPrices = dryCleanPrices.where((item) {
//         String itemName = item["name"].toLowerCase();
//         return itemName.contains(normalizedQuery); // Substring matching
//       }).toList();
//       print("Filtered Dry Clean Prices at ${DateTime.now().toString()}: $filteredPrices");
//     });
//   }
//
//   bool isItemSelected() {
//     return itemQuantities.isNotEmpty;
//   }
//
//   double _calculateDryCleanTotal() {
//     double total = 0;
//     itemQuantities.forEach((name, quantity) {
//       var item = dryCleanPrices.firstWhere(
//             (item) => item["name"] == name,
//         orElse: () => {"price": 0},
//       );
//       total += (item["price"] * quantity);
//     });
//     return total;
//   }
//
//   Future<void> _saveCart() async {
//     try {
//       await CartPersistence.updateCart(
//         dryCleanItems: itemQuantities,
//         additionalServices: additionalServices,
//         dryCleanTotal: _dryCleanTotal,
//         additionalTotal: _additionalTotal,
//       );
//     } catch (e) {
//       print("Error saving cart at ${DateTime.now().toString()}: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to save cart. Please check your internet or try again later"),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Dry Cleaning",
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
//                           // Remove related additional services
//                           additionalServices.forEach((category, items) {
//                             items.removeWhere((service) => service["name"] == item["name"]);
//                             if (items.isEmpty) {
//                               additionalServices.remove(category);
//                             }
//                           });
//                         } else {
//                           itemQuantities[item["name"]] = 1;
//                         }
//                         _dryCleanTotal = _calculateDryCleanTotal();
//                         _additionalTotal = _calculateAdditionalTotal();
//                       });
//                       _saveCart();
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
//                                 onError: (exception, stackTrace) {},
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
//                                   "₹${item["dry_clean"]}",
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
//                                           // Adjust additional services if necessary
//                                           additionalServices.forEach((category, items) {
//                                             for (var service in items) {
//                                               if (service["name"] == item["name"]) {
//                                                 final maxQuantity = itemQuantities[item["name"]] ?? 0;
//                                                 if ((service["quantity"] ?? 0) > maxQuantity) {
//                                                   service["quantity"] = maxQuantity;
//                                                 }
//                                               }
//                                             }
//                                           });
//                                         } else {
//                                           itemQuantities.remove(item["name"]);
//                                           // Remove related additional services
//                                           additionalServices.forEach((category, items) {
//                                             items.removeWhere((service) => service["name"] == item["name"]);
//                                             if (items.isEmpty) {
//                                               additionalServices.remove(category);
//                                             }
//                                           });
//                                         }
//                                         _dryCleanTotal = _calculateDryCleanTotal();
//                                         _additionalTotal = _calculateAdditionalTotal();
//                                       });
//                                       _saveCart();
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
//                                         _dryCleanTotal = _calculateDryCleanTotal();
//                                       });
//                                       _saveCart();
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
//                             "Dry Clean Total",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           Text(
//                             "₹${_dryCleanTotal.toStringAsFixed(2)}",
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
//                         onPressed: () {
//                           _saveCart().then((_) {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => AdditionalService(
//                                   selectedItems: itemQuantities,
//                                   initialTotal: _dryCleanTotal,
//                                   dryCleanPrices: dryCleanPrices,
//                                 ),
//                               ),
//                             ).then((_) {
//                               _loadSavedCart();
//                             });
//                           });
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
//
//   double _calculateAdditionalTotal() {
//     double total = 0;
//     additionalServices.forEach((category, items) {
//       for (var item in items) {
//         total += (item["price"] * (item["quantity"] ?? 0));
//       }
//     });
//     return total;
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import '../constant/constant.dart';
import '../constant/cart_persistence.dart';
import '../screen/cart.dart';
import 'AdditionalService.dart';

class DryCleanPriceListPage extends StatefulWidget {
  const DryCleanPriceListPage({super.key});

  @override
  _DryCleanPriceListPageState createState() => _DryCleanPriceListPageState();
}

class _DryCleanPriceListPageState extends State<DryCleanPriceListPage> {
  List<Map<String, dynamic>> dryCleanPrices = [];
  List<Map<String, dynamic>> filteredPrices = [];
  Map<String, int> itemQuantities = {};
  Map<String, List<Map<String, dynamic>>> additionalServices = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  double _dryCleanTotal = 0;
  double _additionalTotal = 0;
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
          itemQuantities = (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {})
              .map((key, value) => MapEntry(key, value as int));
          additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {})
              .map((key, value) => MapEntry(
            key,
            (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList(),
          ));
          _dryCleanTotal = savedCart['dryCleanTotal'] as double? ?? 0;
          _additionalTotal = savedCart['additionalTotal'] as double? ?? 0;
          _totalCartItems = _calculateTotalCartItems(savedCart);
        }
      });
      _fetchDryCleanPrices();
    } catch (e) {
      _fetchDryCleanPrices();
    }
  }

  int _calculateTotalCartItems(Map<String, dynamic> savedCart) {
    int totalItems = 0;
    totalItems += (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).values.fold<int>(0, (sum, quantity) => sum + (quantity as int? ?? 0));
    totalItems += (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).values.fold<int>(0, (sum, quantity) => sum + (quantity as int? ?? 0));
    totalItems += (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).values.fold<int>(0, (sum, quantity) => sum + (quantity as int? ?? 0));
    totalItems += (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).values.fold<int>(0, (sum, quantity) => sum + (quantity as int? ?? 0));
    totalItems += (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).values.fold<int>(0, (sum, quantity) => sum + (quantity as int? ?? 0));
    final prePlatedItemsFromCart = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {});
    prePlatedItemsFromCart.values.forEach((itemData) {
      totalItems += (itemData?["quantity"] as int? ?? 0);
    });
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

  void _fetchDryCleanPrices() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection("Dry Clean").get();

      setState(() {
        dryCleanPrices = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          String name = doc.id;
          if (name != "T-Shirt" && name.contains('-')) {
            name = name.replaceAll('-', '/');
          }
          String choice;
          if (name.toLowerCase().contains("shoes") ||
              name.toLowerCase().contains("gloves") ||
              name.toLowerCase().contains("sandal")) {
            choice = "${data["dry_clean"]?.toString() ?? "0"} /Pair";
          } else if (name.toLowerCase().contains("dari") ||
              name.toLowerCase().contains("carpet")) {
            choice = "${data["dry_clean"]?.toString() ?? "0"} /Sq Ft";
          } else {
            choice = "${data["dry_clean"]?.toString() ?? "0"} /Piece";
          }

          return {
            "name": name,
            "dry_clean": choice,
            "image": data["image"] ?? "",
            "price": data["dry_clean"] ?? 0,
          };
        }).toList();

        filteredPrices = dryCleanPrices;
        _isLoading = false;
        _dryCleanTotal = _calculateDryCleanTotal();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load items. Please check your internet or try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredPrices = dryCleanPrices;
      });
      return;
    }

    String normalizedQuery = query.toLowerCase().trim();
    setState(() {
      filteredPrices = dryCleanPrices.where((item) {
        String itemName = item["name"].toLowerCase();
        return itemName.contains(normalizedQuery);
      }).toList();
    });
  }

  bool isItemSelected() {
    return itemQuantities.isNotEmpty;
  }

  double _calculateDryCleanTotal() {
    double total = 0;
    itemQuantities.forEach((name, quantity) {
      var item = dryCleanPrices.firstWhere(
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
        dryCleanItems: itemQuantities,
        additionalServices: additionalServices,
        dryCleanTotal: _dryCleanTotal,
        additionalTotal: _additionalTotal,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save cart. Please check your internet or try again later"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToAdditionalServices() {
    _saveCart().then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdditionalService(
            selectedItems: itemQuantities,
            initialTotal: _dryCleanTotal,
            dryCleanPrices: dryCleanPrices,
          ),
        ),
      ).then((_) {
        _loadSavedCart();
      });
    });
  }
  double _calculateAdditionalTotal() {
    double total = 0;
    additionalServices.forEach((category, items) {
      for (var item in items) {
        total += (item["price"] * (item["quantity"] ?? 0));
      }
    });
    return total;
  }
  void _navigateToCartPage() async {
    await _saveCart();
    try {
      final savedCart = await CartPersistence.loadCart();
      if (savedCart != null && mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage(
          dryCleanItems: (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
          ironingItems: (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
          washAndFoldItems: (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
          washAndIronItems: (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
          washIronStarchItems: (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
          prePlatedItems: (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).cast<String, Map<String, dynamic>>(),
          additionalServices: (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList()),),
          dryCleanTotal: savedCart['dryCleanTotal'] as double? ?? 0,
          additionalTotal: savedCart['additionalTotal'] as double? ?? 0,
        ),),).then((_) => _loadSavedCart());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to navigate to cart. Please try again later"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildItemCard(BuildContext context, Map<String, dynamic> item, {bool isWeb = false}) {
    final isSelected = itemQuantities.containsKey(item["name"]);
    final quantity = itemQuantities[item["name"]] ?? 0;

    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: bgColorPink, width: 2)
            : BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            if (isSelected) {
              itemQuantities.remove(item["name"]);
              additionalServices.forEach((category, items) {
                items.removeWhere((service) => service["name"] == item["name"]);
                if (items.isEmpty) {
                  additionalServices.remove(category);
                }
              });
            } else {
              itemQuantities[item["name"]] = 1;
            }
            _dryCleanTotal = _calculateDryCleanTotal();
            _additionalTotal = _calculateAdditionalTotal();
          });
          _saveCart();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: isWeb ? 50 : 70,
                height: isWeb ? 50 : 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: item["image"].isEmpty
                      ? Colors.grey[200]
                      : null,
                  image: item["image"].isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(item["image"]),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  )
                      : null,
                ),
                child: item["image"].isEmpty
                    ? Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[400],
                  size: 40,
                )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["name"],
                      style: TextStyle(
                        fontSize: isWeb ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${item["dry_clean"]}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: bgColorPink,
                      ),
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
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) {
                              itemQuantities[item["name"]] =
                                  quantity - 1;
                              additionalServices.forEach((category, items) {
                                for (var service in items) {
                                  if (service["name"] == item["name"]) {
                                    final maxQuantity = itemQuantities[item["name"]] ?? 0;
                                    if ((service["quantity"] ?? 0) > maxQuantity) {
                                      service["quantity"] = maxQuantity;
                                    }
                                  }
                                }
                              });
                            } else {
                              itemQuantities.remove(item["name"]);
                              additionalServices.forEach((category, items) {
                                items.removeWhere((service) => service["name"] == item["name"]);
                                if (items.isEmpty) {
                                  additionalServices.remove(category);
                                }
                              });
                            }
                            _dryCleanTotal = _calculateDryCleanTotal();
                            _additionalTotal = _calculateAdditionalTotal();
                          });
                          _saveCart();
                        },
                      ),
                      Text(
                        "$quantity",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            itemQuantities[item["name"]] =
                                quantity + 1;
                            _dryCleanTotal = _calculateDryCleanTotal();
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
                  decoration: const BoxDecoration(
                    color: bgColorPink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterSearch,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: bgColorPink),
            hintText: "Search items...",
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _filterSearch('');
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
          Text(
            "Available Items",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          if (isItemSelected())
            Text(
              "${itemQuantities.length} item${itemQuantities.length > 1 ? 's' : ''} selected",
              style: const TextStyle(
                color: bgColorPink,
                fontWeight: FontWeight.w600,
              ),
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
          Lottie.asset(
            'assets/animations/empty.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            "No items found",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              _filterSearch('');
            },
            child: const Text("Clear search"),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dry Cleaning",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/loading.json', width: 200, height: 200, fit: BoxFit.contain),
          ],
        ),
      )
          : Column(
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
      ),
    );
  }

  Widget _buildMobileFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
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
                  Text(
                    "Dry Clean Total",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "₹${_dryCleanTotal.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: bgColorPink,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: _navigateToAdditionalServices,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColorPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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

  Widget _buildWebLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F7),
      appBar: AppBar(
        title: const Text(
          "Dry Cleaning",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
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
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          '$_totalCartItems',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
      body: Center(
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
                          childAspectRatio: 1.3,
                        ),
                        itemCount: filteredPrices.length,
                        itemBuilder: (context, index) {
                          return _buildItemCard(context, filteredPrices[index], isWeb: true);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (isItemSelected())
                    SizedBox(
                      width: 300,
                      child: _buildWebFooter(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildWebFooter() {
  //   return Container(
  //     height: 150,
  //     padding: const EdgeInsets.all(24),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.1),
  //           blurRadius: 10,
  //           offset: const Offset(0, -5),
  //         ),
  //       ],
  //       borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         Text(
  //           "Dry Clean Total",
  //           style: TextStyle(
  //             fontSize: 16,
  //             color: Colors.grey[600],
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           "₹${_dryCleanTotal.toStringAsFixed(2)}",
  //           style: const TextStyle(
  //             fontSize: 24,
  //             fontWeight: FontWeight.bold,
  //             color: bgColorPink,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         ElevatedButton(
  //           onPressed: _navigateToAdditionalServices,
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: bgColorPink,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             padding: const EdgeInsets.symmetric(vertical: 16),
  //           ),
  //           child: const Text(
  //             "Continue",
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.white,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
              "₹${_dryCleanTotal.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: bgColorPink),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _navigateToAdditionalServices,
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

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/loading.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      );
    }
    return isMobile ? _buildMobileLayout() : _buildWebLayout();
  }
}