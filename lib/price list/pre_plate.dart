// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lottie/lottie.dart';
// import 'package:steam/screen/HomeScreen.dart';
// import '../constant/cart_persistence.dart';
// import '../constant/constant.dart';
// import '../screen/cart.dart';
//
// class PrePlatedPage extends StatefulWidget {
//   const PrePlatedPage({super.key});
//
//   @override
//   _PrePlatedPageState createState() => _PrePlatedPageState();
// }
//
// class _PrePlatedPageState extends State<PrePlatedPage> {
//   double prePlatedPrice = 0.0;
//   int sareeQuantity = 0;
//   bool isLoading = true;
//   int _totalCartItems = 0;
//
//   double washPrice = 0.0;
//   double totalWashPrePlatedPrice = 0.0;
//   int washPrePlatedQuantity = 0;
//
//   double starchPrice = 0.0;
//   double totalWashStarchPrePlatedPrice = 0.0;
//   int washStarchPrePlatedQuantity = 0;
//
//   Map<String, double> dryCleanItemPrices = {};
//   double commonDryCleanStarchPrice = 0.0;
//   Map<String, double> dryCleanCalculatedTotals = {};
//   Map<String, int> dryCleanQuantities = {
//     "Saree Fancy": 0,
//     "Saree Medium": 0,
//     "Saree Heavy": 0,
//     "Saree Plain": 0,
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAppAndFetchData();
//   }
//
//   Future<void> _initializeAppAndFetchData() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       await Future.wait([
//         _fetchPrePlatedPrice(),
//         _fetchWashPrePlatedPrice(),
//         _fetchStarchPrePlatedPrice(),
//         _fetchDryCleanPrices(),
//       ]);
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//       _loadCart();
//     }
//   }
//
//   Future<void> _fetchPrePlatedPrice() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection("Dry Clean")
//           .doc("Saree Fancy")
//           .get();
//
//       if (doc.exists && doc.data() != null) {
//         setState(() {
//           prePlatedPrice = (doc.data()!["pleat"] as num?)?.toDouble() ?? 0.0;
//         });
//       } else {
//         _showSnackBar("Pre-Plated price for Saree not found in 'Dry Clean/Saree Fancy'.");
//       }
//     } catch (e) {
//       _showSnackBar("Failed to load Pre-Plated Saree price. Please check your internet connection or try again later.");
//     }
//   }
//
//   Future<void> _fetchWashPrePlatedPrice() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection("Pre-Plate")
//           .doc("Wash Pre")
//           .get();
//
//       if (doc.exists && doc.data() != null) {
//         setState(() {
//           washPrice = (doc.data()!["wash"] as num?)?.toDouble() ?? 0.0;
//           totalWashPrePlatedPrice = (doc.data()!["price"] as num?)?.toDouble() ?? 0.0;
//         });
//       } else {
//         _showSnackBar("Wash & Pre-Plated prices not found in 'Pre-Plate/Wash Pre'.");
//       }
//     } catch (e) {
//       _showSnackBar("Failed to load Wash & Pre-Plated prices. Please check your internet connection or try again later.");
//     }
//   }
//
//   Future<void> _fetchStarchPrePlatedPrice() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection("Pre-Plate")
//           .doc("Starch Pre")
//           .get();
//
//       if (doc.exists && doc.data() != null) {
//         setState(() {
//           starchPrice = (doc.data()!["starch"] as num?)?.toDouble() ?? 0.0;
//           totalWashStarchPrePlatedPrice = (doc.data()!["price"] as num?)?.toDouble() ?? 0.0;
//         });
//       } else {
//         _showSnackBar("Wash & Starch & Pre-Plated prices not found in 'Pre-Plate/Starch Pre'.");
//       }
//     } catch (e) {
//       _showSnackBar("Failed to load Wash & Starch & Pre-Plated prices. Please check your internet connection or try again later.");
//     }
//   }
//
//   Future<void> _fetchDryCleanPrices() async {
//     try {
//       final sareeFancyDoc = await FirebaseFirestore.instance.collection("Dry Clean").doc("Saree Fancy").get();
//       final sareeMediumDoc = await FirebaseFirestore.instance.collection("Dry Clean").doc("Saree Medium").get();
//       final sareeHeavyDoc = await FirebaseFirestore.instance.collection("Dry Clean").doc("Saree Heavy").get();
//       final sareePlainDoc = await FirebaseFirestore.instance.collection("Dry Clean").doc("Saree Plain").get();
//
//       final dryCleanPrePlateDoc = await FirebaseFirestore.instance
//           .collection("Pre-Plate")
//           .doc("dryclean")
//           .get();
//
//       setState(() {
//         dryCleanItemPrices = {
//           "Saree Fancy": (sareeFancyDoc.data() as Map<String, dynamic>?)?["dry_clean"]?.toDouble() ?? 0.0,
//           "Saree Medium": (sareeMediumDoc.data() as Map<String, dynamic>?)?["dry_clean"]?.toDouble() ?? 0.0,
//           "Saree Heavy": (sareeHeavyDoc.data() as Map<String, dynamic>?)?["dry_clean"]?.toDouble() ?? 0.0,
//           "Saree Plain": (sareePlainDoc.data() as Map<String, dynamic>?)?["dry_clean"]?.toDouble() ?? 0.0,
//         };
//         commonDryCleanStarchPrice = (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["starch"]?.toDouble() ?? 0.0;
//         dryCleanCalculatedTotals = {
//           "Saree Fancy": (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["fancy"]?.toDouble() ?? 0.0,
//           "Saree Medium": (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["medium"]?.toDouble() ?? 0.0,
//           "Saree Heavy": (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["heavy"]?.toDouble() ?? 0.0,
//           "Saree Plain": (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["plain"]?.toDouble() ?? 0.0,
//         };
//       });
//     } catch (e) {
//       _showSnackBar("Failed to load Dry Clean prices. Please check your internet connection or try again later.");
//     }
//   }
//
//   Future<void> _loadCart() async {
//     try {
//       final savedCart = await CartPersistence.loadCart();
//       if (savedCart != null) {
//         final prePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {});
//
//         setState(() {
//           sareeQuantity = (prePlatedItems["Saree"]?["quantity"] as int?) ?? 0;
//           washPrePlatedQuantity = (prePlatedItems["Wash & Pre-Pleat"]?["quantity"] as int?) ?? 0;
//           washStarchPrePlatedQuantity = (prePlatedItems["Wash & Starch & Pre-Pleat"]?["quantity"] as int?) ?? 0;
//
//           dryCleanQuantities["Saree Fancy"] = (prePlatedItems["Saree Fancy"]?["quantity"] as int?) ?? 0;
//           dryCleanQuantities["Saree Medium"] = (prePlatedItems["Saree Medium"]?["quantity"] as int?) ?? 0;
//           dryCleanQuantities["Saree Heavy"] = (prePlatedItems["Saree Heavy"]?["quantity"] as int?) ?? 0;
//           dryCleanQuantities["Saree Plain"] = (prePlatedItems["Saree Plain"]?["quantity"] as int?) ?? 0;
//
//           _totalCartItems = _calculateTotalCartItems(savedCart);
//         });
//       }
//     } catch (e) {
//       _showSnackBar("Error loading cart. Please check your internet connection or try again later.");
//     }
//   }
//
//   int _calculateTotalCartItems(Map<String, dynamic> savedCart) {
//     int totalItems = 0;
//     totalItems += (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).length;
//     totalItems += (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).length;
//     totalItems += (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).length;
//     totalItems += (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).length;
//     totalItems += (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).length;
//
//     final prePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {});
//     totalItems += prePlatedItems.keys.where((key) => (prePlatedItems[key]?["quantity"] as int? ?? 0) > 0).length;
//
//     final additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {})
//         .map((key, value) => MapEntry(key, (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList()));
//     additionalServices.forEach((key, items) {
//       totalItems += items.where((item) => (item["quantity"] ?? 0) > 0).length;
//     });
//     return totalItems;
//   }
//
//   void _updateQuantity(int delta, {bool isWashPrePlated = false, bool isWashStarchPrePlated = false, String? dryCleanItem}) {
//     setState(() {
//       if (dryCleanItem != null) {
//         dryCleanQuantities[dryCleanItem] = (dryCleanQuantities[dryCleanItem]! + delta).clamp(0, 100);
//       } else if (isWashStarchPrePlated) {
//         washStarchPrePlatedQuantity = (washStarchPrePlatedQuantity + delta).clamp(0, 100);
//       } else if (isWashPrePlated) {
//         washPrePlatedQuantity = (washPrePlatedQuantity + delta).clamp(0, 100);
//       } else {
//         sareeQuantity = (sareeQuantity + delta).clamp(0, 100);
//       }
//     });
//     _saveSelections();
//   }
//
//   Future<void> _saveSelections() async {
//     try {
//       final Map<String, Map<String, dynamic>> prePlatedItems = {};
//       if (sareeQuantity > 0) {
//         prePlatedItems["Saree"] = {"quantity": sareeQuantity, "pricePerItem": prePlatedPrice};
//       }
//       if (washPrePlatedQuantity > 0) {
//         prePlatedItems["Wash & Pre-Pleat"] = {"quantity": washPrePlatedQuantity, "pricePerItem": washPrice + prePlatedPrice};
//       }
//       if (washStarchPrePlatedQuantity > 0) {
//         prePlatedItems["Wash & Starch & Pre-Pleat"] = {"quantity": washStarchPrePlatedQuantity, "pricePerItem": washPrice + starchPrice + prePlatedPrice};
//       }
//
//       dryCleanQuantities.forEach((itemKey, quantity) {
//         if (quantity > 0 && dryCleanCalculatedTotals.containsKey(itemKey)) {
//           prePlatedItems[itemKey] = {"quantity": quantity, "pricePerItem": dryCleanCalculatedTotals[itemKey]!};
//         }
//       });
//
//       final savedCart = await CartPersistence.loadCart();
//       await CartPersistence.saveCart(
//         dryCleanItems: (savedCart?['dryCleanItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//         ironingItems: (savedCart?['ironingItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//         washAndFoldItems: (savedCart?['washAndFoldItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//         washAndIronItems: (savedCart?['washAndIronItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//         washIronStarchItems: (savedCart?['washIronStarchItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//         prePlatedItems: prePlatedItems,
//         additionalServices: (savedCart?['additionalServices'] as Map<String, dynamic>? ?? {}).map(
//               (key, value) => MapEntry(key, (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList()),
//         ),
//         dryCleanTotal: savedCart?['dryCleanTotal'] as double? ?? 0,
//         additionalTotal: savedCart?['additionalTotal'] as double? ?? 0,
//       );
//
//       setState(() {
//         _totalCartItems = _calculateTotalCartItems(savedCart ?? {});
//       });
//     } catch (e) {
//       _showSnackBar("Error saving selections: $e", isError: true);
//     }
//   }
//
//   Future<void> _saveCartAndNavigateToCartPage() async {
//     await _saveSelections();
//
//     try {
//       final savedCart = await CartPersistence.loadCart();
//       if (savedCart != null) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => CartPage(
//               dryCleanItems: (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//               ironingItems: (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//               washAndFoldItems: (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//               washAndIronItems: (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//               washIronStarchItems: (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//               prePlatedItems: (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).cast<String, Map<String, dynamic>>(),
//               additionalServices: (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).map(
//                     (key, value) => MapEntry(key, (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList()),
//               ),
//               dryCleanTotal: savedCart['dryCleanTotal'] as double? ?? 0,
//               additionalTotal: savedCart['additionalTotal'] as double? ?? 0,
//             ),
//           ),
//         ).then((_) => _loadCart());
//       }
//     } catch (e) {
//       _showSnackBar("Error navigating to cart: $e", isError: true);
//     }
//   }
//
//   void _navigateToHomePage() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => HomePage(),
//       ),
//     );
//   }
//
//   double _calculateTotal() {
//     final sareeTotal = prePlatedPrice * sareeQuantity;
//     final washPrePlatedTotal = (washPrice + prePlatedPrice) * washPrePlatedQuantity;
//     final washStarchPrePlatedTotal = (washPrice + starchPrice + prePlatedPrice) * washStarchPrePlatedQuantity;
//
//     final dryCleanTotal = dryCleanQuantities.entries
//         .map((entry) => (dryCleanCalculatedTotals[entry.key] ?? 0.0) * entry.value)
//         .fold(0.0, (previousValue, element) => previousValue + element);
//
//     return sareeTotal + washPrePlatedTotal + washStarchPrePlatedTotal + dryCleanTotal;
//   }
//
//   void _showSnackBar(String message, {bool isError = false, bool isWarning = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : (isWarning ? Colors.orange : Colors.green),
//       ),
//     );
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           "Saree Pre-Pleat",
//           style: TextStyle(
//             fontWeight: FontWeight.w700,
//             fontSize: 20,
//             letterSpacing: 0.5,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, size: 20),
//           onPressed: () => Navigator.pop(context),
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
//             padding: const EdgeInsets.only(right: 12),
//             child: IconButton(
//               icon: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   const Icon(Icons.shopping_cart_outlined, size: 26),
//                   if (_totalCartItems > 0)
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       child: Container(
//                         padding: const EdgeInsets.all(2),
//                         decoration: BoxDecoration(
//                           color: Colors.red[600],
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 1.5),
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
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               onPressed: _saveCartAndNavigateToCartPage,
//             ),
//           ),
//         ],
//       ),
//       body: isLoading
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
//
//           ],
//         ),
//       )
//           : Column(
//         children: [
//           // Header Section
//           // Container(
//           //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           //   color: bgColorPink.withOpacity(0.1),
//           //   child: Row(
//           //     children: [
//           //       Icon(Icons.info_outline, color: bgColorPink, size: 20),
//           //       const SizedBox(width: 8),
//           //       Flexible(
//           //         child: Text(
//           //           'Select your pre-pleating services below',
//           //           style: TextStyle(
//           //             color: Colors.grey[700],
//           //             fontSize: 14,
//           //           ),
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//
//           // Main Content
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Pre-Plated Saree Section
//                   _buildSectionHeader("Pre-Pleat Saree"),
//                   _buildServiceCard(
//                     title: "Saree",
//                     price: prePlatedPrice,
//                     quantity: sareeQuantity,
//                     onDecrement: () => _updateQuantity(-1),
//                     onIncrement: () => _updateQuantity(1),
//                     showTotalPrice: true,
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   // Wash & Pre-Plated Section
//                   _buildSectionHeader("Wash & Pre-Pleat Saree"),
//                   _buildMultiPriceServiceCard(
//                     title: "Wash & Pre-Pleat Saree",
//                     priceComponents: [
//                       {"label": "Wash", "value": washPrice},
//                       {"label": "Pleat", "value": prePlatedPrice},
//                       {"label": "Total", "value": totalWashPrePlatedPrice, "isTotal": true},
//                     ],
//                     quantity: washPrePlatedQuantity,
//                     onDecrement: () => _updateQuantity(-1, isWashPrePlated: true),
//                     onIncrement: () => _updateQuantity(1, isWashPrePlated: true),
//                     totalPrice: (washPrice + prePlatedPrice) * washPrePlatedQuantity,
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   // Wash & Starch & Pre-Plated Section
//                   _buildSectionHeader("Wash & Starch & Pre-Pleat"),
//                   _buildMultiPriceServiceCard(
//                     title: "Wash & Starch & Pre-Pleat Saree",
//                     priceComponents: [
//                       {"label": "Wash", "value": washPrice},
//                       {"label": "Starch", "value": starchPrice},
//                       {"label": "Pleat", "value": prePlatedPrice},
//                       {"label": "Total", "value": totalWashStarchPrePlatedPrice, "isTotal": true},
//                     ],
//                     quantity: washStarchPrePlatedQuantity,
//                     onDecrement: () => _updateQuantity(-1, isWashStarchPrePlated: true),
//                     onIncrement: () => _updateQuantity(1, isWashStarchPrePlated: true),
//                     totalPrice: (washPrice + starchPrice + prePlatedPrice) * washStarchPrePlatedQuantity,
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   // Dry Clean Sections
//                   _buildSectionHeader("Dry Clean"),
//
//                   // Saree Fancy
//                   _buildDryCleanServiceCard(
//                     title: "Saree Fancy",
//                     priceComponents: [
//                       {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Fancy"] ?? 0.0},
//                       {"label": "Starch", "value": commonDryCleanStarchPrice},
//                       {"label": "Pleat", "value": prePlatedPrice},
//                       {"label": "Total", "value": dryCleanCalculatedTotals["Saree Fancy"] ?? 0.0, "isTotal": true},
//                     ],
//                     quantity: dryCleanQuantities["Saree Fancy"] ?? 0,
//                     onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Fancy"),
//                     onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Fancy"),
//                     totalPrice: (dryCleanCalculatedTotals["Saree Fancy"] ?? 0.0) * (dryCleanQuantities["Saree Fancy"] ?? 0),
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   // Saree Medium
//                   _buildDryCleanServiceCard(
//                     title: "Saree Medium",
//                     priceComponents: [
//                       {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Medium"] ?? 0.0},
//                       {"label": "Starch", "value": commonDryCleanStarchPrice},
//                       {"label": "Pleat", "value": prePlatedPrice},
//                       {"label": "Total", "value": dryCleanCalculatedTotals["Saree Medium"] ?? 0.0, "isTotal": true},
//                     ],
//                     quantity: dryCleanQuantities["Saree Medium"] ?? 0,
//                     onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Medium"),
//                     onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Medium"),
//                     totalPrice: (dryCleanCalculatedTotals["Saree Medium"] ?? 0.0) * (dryCleanQuantities["Saree Medium"] ?? 0),
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   // Saree Heavy
//                   _buildDryCleanServiceCard(
//                     title: "Saree Heavy",
//                     priceComponents: [
//                       {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Heavy"] ?? 0.0},
//                       {"label": "Starch", "value": commonDryCleanStarchPrice},
//                       {"label": "Pleat", "value": prePlatedPrice},
//                       {"label": "Total", "value": dryCleanCalculatedTotals["Saree Heavy"] ?? 0.0, "isTotal": true},
//                     ],
//                     quantity: dryCleanQuantities["Saree Heavy"] ?? 0,
//                     onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Heavy"),
//                     onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Heavy"),
//                     totalPrice: (dryCleanCalculatedTotals["Saree Heavy"] ?? 0.0) * (dryCleanQuantities["Saree Heavy"] ?? 0),
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   // Saree Plain
//                   _buildDryCleanServiceCard(
//                     title: "Saree Plain",
//                     priceComponents: [
//                       {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Plain"] ?? 0.0},
//                       {"label": "Starch", "value": commonDryCleanStarchPrice},
//                       {"label": "Pleat", "value": prePlatedPrice},
//                       {"label": "Total", "value": dryCleanCalculatedTotals["Saree Plain"] ?? 0.0, "isTotal": true},
//                     ],
//                     quantity: dryCleanQuantities["Saree Plain"] ?? 0,
//                     onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Plain"),
//                     onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Plain"),
//                     totalPrice: (dryCleanCalculatedTotals["Saree Plain"] ?? 0.0) * (dryCleanQuantities["Saree Plain"] ?? 0),
//                   ),
//
//                   const SizedBox(height: 100),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomSheet: Container(
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, -5),
//             ),
//           ],
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//         ),
//         child: SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 5),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Pre-Pleat Total",
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[700],
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Text(
//                       "₹${_calculateTotal().toStringAsFixed(2)}",
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                         color: bgColorPink,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ElevatedButton(
//                 onPressed: _navigateToHomePage,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: bgColorPink,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "More Services",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Icon(Icons.arrow_forward, size: 20, color: Colors.white),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Helper Widget: Section Header
//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w700,
//           color: Colors.grey[800],
//           letterSpacing: 0.3,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildServiceCard({
//     required String title,
//     required double price,
//     required int quantity,
//     required VoidCallback onDecrement,
//     required VoidCallback onIncrement,
//     bool showTotalPrice = false,
//   }) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey[200]!, width: 1),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 Text(
//                   "₹${price.toStringAsFixed(2)}",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: bgColorPink,
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 12),
//
//             Row(
//               children: [
//                 Text(
//                   "Quantity",
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const Spacer(),
//
//                 // Quantity Controls
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.remove, size: 18, color: quantity > 0 ? Colors.grey[800] : Colors.grey[400]),
//                         onPressed: quantity > 0 ? onDecrement : null,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         splashRadius: 20,
//                       ),
//                       Container(
//                         width: 40,
//                         alignment: Alignment.center,
//                         child: Text(
//                           "$quantity",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.add, size: 18, color: Colors.grey[800]),
//                         onPressed: onIncrement,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         splashRadius: 20,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 if (showTotalPrice) ...[
//                   const SizedBox(width: 12),
//                   Text(
//                     "₹${(price * quantity).toStringAsFixed(2)}",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: bgColorPink,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMultiPriceServiceCard({
//     required String title,
//     required List<Map<String, dynamic>> priceComponents,
//     required int quantity,
//     required VoidCallback onDecrement,
//     required VoidCallback onIncrement,
//     required double totalPrice,
//   }) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey[200]!, width: 1),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//             ),
//
//             const SizedBox(height: 8),
//
//             // Price Breakdown
//             Column(
//               children: priceComponents.map((component) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 2),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         component["label"],
//                         style: TextStyle(
//                           fontSize: component["isTotal"] == true ? 15 : 14,
//                           fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
//                           color: component["isTotal"] == true ? Colors.grey[800] : Colors.grey[600],
//                         ),
//                       ),
//                       Text(
//                         component["isTotal"] == true
//                             ? "₹${component["value"].toStringAsFixed(2)} /Piece"
//                             : "₹${component["value"].toStringAsFixed(2)}",
//                         style: TextStyle(
//                           fontSize: component["isTotal"] == true ? 15 : 14,
//                           fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
//                           color: bgColorPink,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//
//             const SizedBox(height: 12),
//
//             // Quantity Controls
//             Row(
//               children: [
//                 Text(
//                   "Quantity",
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const Spacer(),
//
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.remove, size: 18, color: quantity > 0 ? Colors.grey[800] : Colors.grey[400]),
//                         onPressed: quantity > 0 ? onDecrement : null,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         splashRadius: 20,
//                       ),
//                       Container(
//                         width: 40,
//                         alignment: Alignment.center,
//                         child: Text(
//                           "$quantity",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon:  Icon(Icons.add, size: 18, color: Colors.grey[800]),
//                         onPressed: onIncrement,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         splashRadius: 20,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(width: 12),
//                 Text(
//                   "₹${totalPrice.toStringAsFixed(2)}",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: bgColorPink,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDryCleanServiceCard({
//     required String title,
//     required List<Map<String, dynamic>> priceComponents,
//     required int quantity,
//     required VoidCallback onDecrement,
//     required VoidCallback onIncrement,
//     required double totalPrice,
//   }) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey[200]!, width: 1),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//             ),
//
//             const SizedBox(height: 8),
//
//             // Price Breakdown
//             Column(
//               children: priceComponents.map((component) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 2),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         component["label"],
//                         style: TextStyle(
//                           fontSize: component["isTotal"] == true ? 15 : 14,
//                           fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
//                           color: component["isTotal"] == true ? Colors.grey[800] : Colors.grey[600],
//                         ),
//                       ),
//                       Text(
//                         component["isTotal"] == true
//                             ? "₹${component["value"].toStringAsFixed(2)} /Piece"
//                             : "₹${component["value"].toStringAsFixed(2)}",
//                         style: TextStyle(
//                           fontSize: component["isTotal"] == true ? 15 : 14,
//                           fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
//                           color: bgColorPink,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//
//             const SizedBox(height: 12),
//
//             // Quantity Controls
//             Row(
//               children: [
//                 Text(
//                   "Quantity",
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const Spacer(),
//
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.remove, size: 18, color: quantity > 0 ? Colors.grey[800] : Colors.grey[400]),
//                         onPressed: quantity > 0 ? onDecrement : null,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         splashRadius: 20,
//                       ),
//                       Container(
//                         width: 40,
//                         alignment: Alignment.center,
//                         child: Text(
//                           "$quantity",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon:  Icon(Icons.add, size: 18, color: Colors.grey[800]),
//                         onPressed: onIncrement,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         splashRadius: 20,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(width: 12),
//                 Text(
//                   "₹${totalPrice.toStringAsFixed(2)}",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: bgColorPink,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lottie/lottie.dart';
// // Make sure to import your project-specific files.
// // I'm using placeholder imports for these.
// import 'package:steam/screen/HomeScreen.dart';
// import '../constant/cart_persistence.dart';
// import '../constant/constant.dart';
// import '../screen/cart.dart';
//
// class PrePlatedPage extends StatefulWidget {
//   const PrePlatedPage({super.key});
//
//   @override
//   _PrePlatedPageState createState() => _PrePlatedPageState();
// }
//
// class _PrePlatedPageState extends State<PrePlatedPage> {
//   double prePlatedPrice = 0.0;
//   int sareeQuantity = 0;
//   bool isLoading = true;
//   int _totalCartItems = 0;
//
//   double washPrice = 0.0;
//   double totalWashPrePlatedPrice = 0.0;
//   int washPrePlatedQuantity = 0;
//
//   double starchPrice = 0.0;
//   double totalWashStarchPrePlatedPrice = 0.0;
//   int washStarchPrePlatedQuantity = 0;
//
//   Map<String, double> dryCleanItemPrices = {};
//   double commonDryCleanStarchPrice = 0.0;
//   Map<String, double> dryCleanCalculatedTotals = {};
//   Map<String, int> dryCleanQuantities = {
//     "Saree Fancy": 0,
//     "Saree Medium": 0,
//     "Saree Heavy": 0,
//     "Saree Plain": 0,
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAppAndFetchData();
//   }
//
//   Future<void> _initializeAppAndFetchData() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       await Future.wait([
//         _fetchPrePlatedPrice(),
//         _fetchWashPrePlatedPrice(),
//         _fetchStarchPrePlatedPrice(),
//         _fetchDryCleanPrices(),
//       ]);
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//       _loadCart();
//     }
//   }
//
//   Future<void> _fetchPrePlatedPrice() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection("Dry Clean")
//           .doc("Saree Fancy")
//           .get();
//
//       if (doc.exists && doc.data() != null) {
//         setState(() {
//           prePlatedPrice = (doc.data()!["pleat"] as num?)?.toDouble() ?? 0.0;
//         });
//       } else {
//         _showSnackBar("Pre-Plated price for Saree not found in 'Dry Clean/Saree Fancy'.");
//       }
//     } catch (e) {
//       _showSnackBar("Failed to load Pre-Plated Saree price. Please check your internet connection or try again later.");
//     }
//   }
//
//   Future<void> _fetchWashPrePlatedPrice() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection("Pre-Plate")
//           .doc("Wash Pre")
//           .get();
//
//       if (doc.exists && doc.data() != null) {
//         setState(() {
//           washPrice = (doc.data()!["wash"] as num?)?.toDouble() ?? 0.0;
//           totalWashPrePlatedPrice = (doc.data()!["price"] as num?)?.toDouble() ?? 0.0;
//         });
//       } else {
//         _showSnackBar("Wash & Pre-Plated prices not found in 'Pre-Plate/Wash Pre'.");
//       }
//     } catch (e) {
//       _showSnackBar("Failed to load Wash & Pre-Plated prices. Please check your internet connection or try again later.");
//     }
//   }
//
//   Future<void> _fetchStarchPrePlatedPrice() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection("Pre-Plate")
//           .doc("Starch Pre")
//           .get();
//
//       if (doc.exists && doc.data() != null) {
//         setState(() {
//           starchPrice = (doc.data()!["starch"] as num?)?.toDouble() ?? 0.0;
//           totalWashStarchPrePlatedPrice = (doc.data()!["price"] as num?)?.toDouble() ?? 0.0;
//         });
//       } else {
//         _showSnackBar("Wash & Starch & Pre-Plated prices not found in 'Pre-Plate/Starch Pre'.");
//       }
//     } catch (e) {
//       _showSnackBar("Failed to load Wash & Starch & Pre-Plated prices. Please check your internet connection or try again later.");
//     }
//   }
//
//   Future<void> _fetchDryCleanPrices() async {
//     try {
//       final sareeFancyDoc = await FirebaseFirestore.instance.collection("Dry Clean").doc("Saree Fancy").get();
//       final sareeMediumDoc = await FirebaseFirestore.instance.collection("Dry Clean").doc("Saree Medium").get();
//       final sareeHeavyDoc = await FirebaseFirestore.instance.collection("Dry Clean").doc("Saree Heavy").get();
//       final sareePlainDoc = await FirebaseFirestore.instance.collection("Dry Clean").doc("Saree Plain").get();
//
//       final dryCleanPrePlateDoc = await FirebaseFirestore.instance
//           .collection("Pre-Plate")
//           .doc("dryclean")
//           .get();
//
//       setState(() {
//         dryCleanItemPrices = {
//           "Saree Fancy": (sareeFancyDoc.data() as Map<String, dynamic>?)?["dry_clean"]?.toDouble() ?? 0.0,
//           "Saree Medium": (sareeMediumDoc.data() as Map<String, dynamic>?)?["dry_clean"]?.toDouble() ?? 0.0,
//           "Saree Heavy": (sareeHeavyDoc.data() as Map<String, dynamic>?)?["dry_clean"]?.toDouble() ?? 0.0,
//           "Saree Plain": (sareePlainDoc.data() as Map<String, dynamic>?)?["dry_clean"]?.toDouble() ?? 0.0,
//         };
//         commonDryCleanStarchPrice = (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["starch"]?.toDouble() ?? 0.0;
//         dryCleanCalculatedTotals = {
//           "Saree Fancy": (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["fancy"]?.toDouble() ?? 0.0,
//           "Saree Medium": (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["medium"]?.toDouble() ?? 0.0,
//           "Saree Heavy": (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["heavy"]?.toDouble() ?? 0.0,
//           "Saree Plain": (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["plain"]?.toDouble() ?? 0.0,
//         };
//       });
//     } catch (e) {
//       _showSnackBar("Failed to load Dry Clean prices. Please check your internet connection or try again later.");
//     }
//   }
//
//   Future<void> _loadCart() async {
//     try {
//       final savedCart = await CartPersistence.loadCart();
//       if (savedCart != null) {
//         final prePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {});
//
//         setState(() {
//           sareeQuantity = (prePlatedItems["Saree"]?["quantity"] as int?) ?? 0;
//           washPrePlatedQuantity = (prePlatedItems["Wash & Pre-Pleat"]?["quantity"] as int?) ?? 0;
//           washStarchPrePlatedQuantity = (prePlatedItems["Wash & Starch & Pre-Pleat"]?["quantity"] as int?) ?? 0;
//
//           dryCleanQuantities["Saree Fancy"] = (prePlatedItems["Saree Fancy"]?["quantity"] as int?) ?? 0;
//           dryCleanQuantities["Saree Medium"] = (prePlatedItems["Saree Medium"]?["quantity"] as int?) ?? 0;
//           dryCleanQuantities["Saree Heavy"] = (prePlatedItems["Saree Heavy"]?["quantity"] as int?) ?? 0;
//           dryCleanQuantities["Saree Plain"] = (prePlatedItems["Saree Plain"]?["quantity"] as int?) ?? 0;
//
//           _totalCartItems = _calculateTotalCartItems(savedCart);
//         });
//       }
//     } catch (e) {
//       _showSnackBar("Error loading cart. Please check your internet connection or try again later.");
//     }
//   }
//
//   int _calculateTotalCartItems(Map<String, dynamic> savedCart) {
//     int totalItems = 0;
//     totalItems += (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).length;
//     totalItems += (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).length;
//     totalItems += (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).length;
//     totalItems += (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).length;
//     totalItems += (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).length;
//
//     final prePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {});
//     totalItems += prePlatedItems.keys.where((key) => (prePlatedItems[key]?["quantity"] as int? ?? 0) > 0).length;
//
//     final additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {})
//         .map((key, value) => MapEntry(key, (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList()));
//     additionalServices.forEach((key, items) {
//       totalItems += items.where((item) => (item["quantity"] ?? 0) > 0).length;
//     });
//     return totalItems;
//   }
//
//   void _updateQuantity(int delta, {bool isWashPrePlated = false, bool isWashStarchPrePlated = false, String? dryCleanItem}) {
//     setState(() {
//       if (dryCleanItem != null) {
//         dryCleanQuantities[dryCleanItem] = (dryCleanQuantities[dryCleanItem]! + delta).clamp(0, 100);
//       } else if (isWashStarchPrePlated) {
//         washStarchPrePlatedQuantity = (washStarchPrePlatedQuantity + delta).clamp(0, 100);
//       } else if (isWashPrePlated) {
//         washPrePlatedQuantity = (washPrePlatedQuantity + delta).clamp(0, 100);
//       } else {
//         sareeQuantity = (sareeQuantity + delta).clamp(0, 100);
//       }
//     });
//     _saveSelections();
//   }
//
//   Future<void> _saveSelections() async {
//     try {
//       final Map<String, Map<String, dynamic>> prePlatedItems = {};
//       if (sareeQuantity > 0) {
//         prePlatedItems["Saree"] = {"quantity": sareeQuantity, "pricePerItem": prePlatedPrice};
//       }
//       if (washPrePlatedQuantity > 0) {
//         prePlatedItems["Wash & Pre-Pleat"] = {"quantity": washPrePlatedQuantity, "pricePerItem": washPrice + prePlatedPrice};
//       }
//       if (washStarchPrePlatedQuantity > 0) {
//         prePlatedItems["Wash & Starch & Pre-Pleat"] = {"quantity": washStarchPrePlatedQuantity, "pricePerItem": washPrice + starchPrice + prePlatedPrice};
//       }
//
//       dryCleanQuantities.forEach((itemKey, quantity) {
//         if (quantity > 0 && dryCleanCalculatedTotals.containsKey(itemKey)) {
//           prePlatedItems[itemKey] = {"quantity": quantity, "pricePerItem": dryCleanCalculatedTotals[itemKey]!};
//         }
//       });
//
//       final savedCart = await CartPersistence.loadCart();
//       await CartPersistence.saveCart(
//         dryCleanItems: (savedCart?['dryCleanItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//         ironingItems: (savedCart?['ironingItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//         washAndFoldItems: (savedCart?['washAndFoldItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//         washAndIronItems: (savedCart?['washAndIronItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//         washIronStarchItems: (savedCart?['washIronStarchItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//         prePlatedItems: prePlatedItems,
//         additionalServices: (savedCart?['additionalServices'] as Map<String, dynamic>? ?? {}).map(
//               (key, value) => MapEntry(key, (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList()),
//         ),
//         dryCleanTotal: savedCart?['dryCleanTotal'] as double? ?? 0,
//         additionalTotal: savedCart?['additionalTotal'] as double? ?? 0,
//       );
//
//       // Recalculate total items for the badge after saving
//       final updatedCart = await CartPersistence.loadCart();
//       setState(() {
//         _totalCartItems = _calculateTotalCartItems(updatedCart ?? {});
//       });
//     } catch (e) {
//       _showSnackBar("Error saving selections: $e", isError: true);
//     }
//   }
//
//   Future<void> _saveCartAndNavigateToCartPage() async {
//     await _saveSelections();
//
//     try {
//       final savedCart = await CartPersistence.loadCart();
//       if (savedCart != null && mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => CartPage(
//               dryCleanItems: (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//               ironingItems: (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//               washAndFoldItems: (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//               washAndIronItems: (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//               washIronStarchItems: (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
//               prePlatedItems: (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).cast<String, Map<String, dynamic>>(),
//               additionalServices: (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).map(
//                     (key, value) => MapEntry(key, (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList()),
//               ),
//               dryCleanTotal: savedCart['dryCleanTotal'] as double? ?? 0,
//               additionalTotal: savedCart['additionalTotal'] as double? ?? 0,
//             ),
//           ),
//         ).then((_) => _loadCart());
//       }
//     } catch (e) {
//       _showSnackBar("Error navigating to cart: $e", isError: true);
//     }
//   }
//
//   void _navigateToHomePage() {
//     if(mounted) {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => HomePage()),
//             (Route<dynamic> route) => false,
//       );
//     }
//   }
//
//   double _calculateTotal() {
//     final sareeTotal = prePlatedPrice * sareeQuantity;
//     final washPrePlatedTotal = (washPrice + prePlatedPrice) * washPrePlatedQuantity;
//     final washStarchPrePlatedTotal = (washPrice + starchPrice + prePlatedPrice) * washStarchPrePlatedQuantity;
//
//     final dryCleanTotal = dryCleanQuantities.entries
//         .map((entry) => (dryCleanCalculatedTotals[entry.key] ?? 0.0) * entry.value)
//         .fold(0.0, (previousValue, element) => previousValue + element);
//
//     return sareeTotal + washPrePlatedTotal + washStarchPrePlatedTotal + dryCleanTotal;
//   }
//
//   bool isItemSelected() {
//     return sareeQuantity > 0 || washPrePlatedQuantity > 0 || washStarchPrePlatedQuantity > 0 ||
//         dryCleanQuantities.values.any((quantity) => quantity > 0);
//   }
//
//   void _showSnackBar(String message, {bool isError = false, bool isWarning = false}) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: isError ? Colors.red : (isWarning ? Colors.orange : Colors.green),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           "Saree Pre-Pleat",
//           style: TextStyle(
//             fontWeight: FontWeight.w700,
//             fontSize: 20,
//             letterSpacing: 0.5,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, size: 20),
//           onPressed: () => Navigator.pop(context),
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
//             padding: EdgeInsets.only(right: screenWidth * 0.03),
//             child: IconButton(
//               icon: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   const Icon(Icons.shopping_cart_outlined, size: 26),
//                   if (_totalCartItems > 0)
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       child: Container(
//                         padding: EdgeInsets.all(screenWidth * 0.01),
//                         decoration: BoxDecoration(
//                           color: Colors.red[600],
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 1.5),
//                         ),
//                         constraints: BoxConstraints(
//                           minWidth: screenWidth * 0.05,
//                           minHeight: screenWidth * 0.05,
//                         ),
//                         child: Center(
//                           child: Text(
//                             '$_totalCartItems',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: screenWidth * 0.025,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               onPressed: _saveCartAndNavigateToCartPage,
//             ),
//           ),
//         ],
//       ),
//       body: isLoading
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Lottie.asset(
//               'assets/animations/loading.json',
//               width: screenWidth * 0.5,
//               height: screenHeight * 0.3,
//               fit: BoxFit.contain,
//             ),
//           ],
//         ),
//       )
//           : Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildSectionHeader("Pre-Pleat Saree", screenWidth, screenHeight),
//                   _buildServiceCard(
//                     title: "Saree",
//                     price: prePlatedPrice,
//                     quantity: sareeQuantity,
//                     onDecrement: () => _updateQuantity(-1),
//                     onIncrement: () => _updateQuantity(1),
//                     showTotalPrice: true,
//                     screenWidth: screenWidth,
//                     screenHeight: screenHeight,
//                   ),
//                   SizedBox(height: screenHeight * 0.02),
//                   _buildSectionHeader("Wash & Pre-Pleat Saree", screenWidth, screenHeight),
//                   _buildMultiPriceServiceCard(
//                     title: "Wash & Pre-Pleat Saree",
//                     priceComponents: [
//                       {"label": "Wash", "value": washPrice},
//                       {"label": "Pleat", "value": prePlatedPrice},
//                       {"label": "Total", "value": totalWashPrePlatedPrice, "isTotal": true},
//                     ],
//                     quantity: washPrePlatedQuantity,
//                     onDecrement: () => _updateQuantity(-1, isWashPrePlated: true),
//                     onIncrement: () => _updateQuantity(1, isWashPrePlated: true),
//                     totalPrice: (washPrice + prePlatedPrice) * washPrePlatedQuantity,
//                     screenWidth: screenWidth,
//                     screenHeight: screenHeight,
//                   ),
//                   SizedBox(height: screenHeight * 0.02),
//                   _buildSectionHeader("Wash & Starch & Pre-Pleat", screenWidth, screenHeight),
//                   _buildMultiPriceServiceCard(
//                     title: "Wash & Starch & Pre-Pleat Saree",
//                     priceComponents: [
//                       {"label": "Wash", "value": washPrice},
//                       {"label": "Starch", "value": starchPrice},
//                       {"label": "Pleat", "value": prePlatedPrice},
//                       {"label": "Total", "value": totalWashStarchPrePlatedPrice, "isTotal": true},
//                     ],
//                     quantity: washStarchPrePlatedQuantity,
//                     onDecrement: () => _updateQuantity(-1, isWashStarchPrePlated: true),
//                     onIncrement: () => _updateQuantity(1, isWashStarchPrePlated: true),
//                     totalPrice: (washPrice + starchPrice + prePlatedPrice) * washStarchPrePlatedQuantity,
//                     screenWidth: screenWidth,
//                     screenHeight: screenHeight,
//                   ),
//                   SizedBox(height: screenHeight * 0.02),
//                   _buildSectionHeader("Dry Clean", screenWidth, screenHeight),
//                   _buildDryCleanServiceCard(
//                     title: "Saree Fancy",
//                     priceComponents: [
//                       {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Fancy"] ?? 0.0},
//                       {"label": "Starch", "value": commonDryCleanStarchPrice},
//                       {"label": "Pleat", "value": prePlatedPrice},
//                       {"label": "Total", "value": dryCleanCalculatedTotals["Saree Fancy"] ?? 0.0, "isTotal": true},
//                     ],
//                     quantity: dryCleanQuantities["Saree Fancy"] ?? 0,
//                     onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Fancy"),
//                     onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Fancy"),
//                     totalPrice: (dryCleanCalculatedTotals["Saree Fancy"] ?? 0.0) * (dryCleanQuantities["Saree Fancy"] ?? 0),
//                     screenWidth: screenWidth,
//                     screenHeight: screenHeight,
//                   ),
//                   SizedBox(height: screenHeight * 0.02),
//                   _buildDryCleanServiceCard(
//                     title: "Saree Medium",
//                     priceComponents: [
//                       {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Medium"] ?? 0.0},
//                       {"label": "Starch", "value": commonDryCleanStarchPrice},
//                       {"label": "Pleat", "value": prePlatedPrice},
//                       {"label": "Total", "value": dryCleanCalculatedTotals["Saree Medium"] ?? 0.0, "isTotal": true},
//                     ],
//                     quantity: dryCleanQuantities["Saree Medium"] ?? 0,
//                     onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Medium"),
//                     onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Medium"),
//                     totalPrice: (dryCleanCalculatedTotals["Saree Medium"] ?? 0.0) * (dryCleanQuantities["Saree Medium"] ?? 0),
//                     screenWidth: screenWidth,
//                     screenHeight: screenHeight,
//                   ),
//                   SizedBox(height: screenHeight * 0.02),
//                   _buildDryCleanServiceCard(
//                     title: "Saree Heavy",
//                     priceComponents: [
//                       {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Heavy"] ?? 0.0},
//                       {"label": "Starch", "value": commonDryCleanStarchPrice},
//                       {"label": "Pleat", "value": prePlatedPrice},
//                       {"label": "Total", "value": dryCleanCalculatedTotals["Saree Heavy"] ?? 0.0, "isTotal": true},
//                     ],
//                     quantity: dryCleanQuantities["Saree Heavy"] ?? 0,
//                     onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Heavy"),
//                     onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Heavy"),
//                     totalPrice: (dryCleanCalculatedTotals["Saree Heavy"] ?? 0.0) * (dryCleanQuantities["Saree Heavy"] ?? 0),
//                     screenWidth: screenWidth,
//                     screenHeight: screenHeight,
//                   ),
//                   SizedBox(height: screenHeight * 0.02),
//                   _buildDryCleanServiceCard(
//                     title: "Saree Plain",
//                     priceComponents: [
//                       {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Plain"] ?? 0.0},
//                       {"label": "Starch", "value": commonDryCleanStarchPrice},
//                       {"label": "Pleat", "value": prePlatedPrice},
//                       {"label": "Total", "value": dryCleanCalculatedTotals["Saree Plain"] ?? 0.0, "isTotal": true},
//                     ],
//                     quantity: dryCleanQuantities["Saree Plain"] ?? 0,
//                     onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Plain"),
//                     onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Plain"),
//                     totalPrice: (dryCleanCalculatedTotals["Saree Plain"] ?? 0.0) * (dryCleanQuantities["Saree Plain"] ?? 0),
//                     screenWidth: screenWidth,
//                     screenHeight: screenHeight,
//                   ),
//                   // The unnecessary SizedBox that was here has been removed.
//                 ],
//               ),
//             ),
//           ),
//           if (isItemSelected())
//             Container(
//               padding: EdgeInsets.all(screenWidth * 0.04),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: screenWidth * 0.025,
//                     offset: Offset(0, -screenHeight * 0.01),
//                   ),
//                 ],
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.04)),
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
//                             "Pre-Pleat Total",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           Text(
//                             "₹${_calculateTotal().toStringAsFixed(2)}",
//                             style: TextStyle(
//                               fontSize: screenWidth * 0.05,
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
//                           _navigateToHomePage();
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: bgColorPink,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(screenWidth * 0.03),
//                           ),
//                           padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               "Continue",
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.04,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             SizedBox(width: screenWidth * 0.02),
//                             Icon(Icons.arrow_forward, size: screenWidth * 0.05, color: Colors.white),
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
//   Widget _buildSectionHeader(String title, double screenWidth, double screenHeight) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: screenWidth * 0.045,
//           fontWeight: FontWeight.w700,
//           color: Colors.grey[800],
//           letterSpacing: 0.3,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildServiceCard({
//     required String title,
//     required double price,
//     required int quantity,
//     required VoidCallback onDecrement,
//     required VoidCallback onIncrement,
//     bool showTotalPrice = false,
//     required double screenWidth,
//     required double screenHeight,
//   }) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(screenWidth * 0.03),
//         side: BorderSide(color: Colors.grey[200]!, width: 1),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.04,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 Text(
//                   "₹${price.toStringAsFixed(2)}",
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.04,
//                     fontWeight: FontWeight.w600,
//                     color: bgColorPink,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.02),
//             Row(
//               children: [
//                 Text(
//                   "Quantity",
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.035,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                   ),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.remove, size: screenWidth * 0.045, color: quantity > 0 ? Colors.grey[800] : Colors.grey[400]),
//                         onPressed: quantity > 0 ? onDecrement : null,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         splashRadius: screenWidth * 0.05,
//                       ),
//                       Container(
//                         width: screenWidth * 0.1,
//                         alignment: Alignment.center,
//                         child: Text(
//                           "$quantity",
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.04,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.add, size: screenWidth * 0.045, color: Colors.grey[800]),
//                         onPressed: onIncrement,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         splashRadius: screenWidth * 0.05,
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (showTotalPrice) ...[
//                   SizedBox(width: screenWidth * 0.03),
//                   Text(
//                     "₹${(price * quantity).toStringAsFixed(2)}",
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.04,
//                       fontWeight: FontWeight.bold,
//                       color: bgColorPink,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMultiPriceServiceCard({
//     required String title,
//     required List<Map<String, dynamic>> priceComponents,
//     required int quantity,
//     required VoidCallback onDecrement,
//     required VoidCallback onIncrement,
//     required double totalPrice,
//     required double screenWidth,
//     required double screenHeight,
//   }) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(screenWidth * 0.03),
//         side: BorderSide(color: Colors.grey[200]!, width: 1),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: screenWidth * 0.04,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.02),
//             Column(
//               children: priceComponents.map((component) {
//                 return Padding(
//                   padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         component["label"],
//                         style: TextStyle(
//                           fontSize: component["isTotal"] == true ? screenWidth * 0.0375 : screenWidth * 0.035,
//                           fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
//                           color: component["isTotal"] == true ? Colors.grey[800] : Colors.grey[600],
//                         ),
//                       ),
//                       Text(
//                         component["isTotal"] == true
//                             ? "₹${component["value"].toStringAsFixed(2)} /Piece"
//                             : "₹${component["value"].toStringAsFixed(2)}",
//                         style: TextStyle(
//                           fontSize: component["isTotal"] == true ? screenWidth * 0.0375 : screenWidth * 0.035,
//                           fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
//                           color: bgColorPink,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: screenHeight * 0.02),
//             Row(
//               children: [
//                 Text(
//                   "Quantity",
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.035,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                   ),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.remove, size: screenWidth * 0.045, color: quantity > 0 ? Colors.grey[800] : Colors.grey[400]),
//                         onPressed: quantity > 0 ? onDecrement : null,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         splashRadius: screenWidth * 0.05,
//                       ),
//                       Container(
//                         width: screenWidth * 0.1,
//                         alignment: Alignment.center,
//                         child: Text(
//                           "$quantity",
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.04,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.add, size: screenWidth * 0.045, color: Colors.grey[800]),
//                         onPressed: onIncrement,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         splashRadius: screenWidth * 0.05,
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: screenWidth * 0.03),
//                 Text(
//                   "₹${totalPrice.toStringAsFixed(2)}",
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.04,
//                     fontWeight: FontWeight.bold,
//                     color: bgColorPink,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDryCleanServiceCard({
//     required String title,
//     required List<Map<String, dynamic>> priceComponents,
//     required int quantity,
//     required VoidCallback onDecrement,
//     required VoidCallback onIncrement,
//     required double totalPrice,
//     required double screenWidth,
//     required double screenHeight,
//   }) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(screenWidth * 0.03),
//         side: BorderSide(color: Colors.grey[200]!, width: 1),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.04),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: screenWidth * 0.04,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.02),
//             Column(
//               children: priceComponents.map((component) {
//                 return Padding(
//                   padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         component["label"],
//                         style: TextStyle(
//                           fontSize: component["isTotal"] == true ? screenWidth * 0.0375 : screenWidth * 0.035,
//                           fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
//                           color: component["isTotal"] == true ? Colors.grey[800] : Colors.grey[600],
//                         ),
//                       ),
//                       Text(
//                         component["isTotal"] == true
//                             ? "₹${component["value"].toStringAsFixed(2)} /Piece"
//                             : "₹${component["value"].toStringAsFixed(2)}",
//                         style: TextStyle(
//                           fontSize: component["isTotal"] == true ? screenWidth * 0.0375 : screenWidth * 0.035,
//                           fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
//                           color: bgColorPink,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: screenHeight * 0.02),
//             Row(
//               children: [
//                 Text(
//                   "Quantity",
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.035,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                   ),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.remove, size: screenWidth * 0.045, color: quantity > 0 ? Colors.grey[800] : Colors.grey[400]),
//                         onPressed: quantity > 0 ? onDecrement : null,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         splashRadius: screenWidth * 0.05,
//                       ),
//                       Container(
//                         width: screenWidth * 0.1,
//                         alignment: Alignment.center,
//                         child: Text(
//                           "$quantity",
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.04,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.add, size: screenWidth * 0.045, color: Colors.grey[800]),
//                         onPressed: onIncrement,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         splashRadius: screenWidth * 0.05,
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: screenWidth * 0.03),
//                 Text(
//                   "₹${totalPrice.toStringAsFixed(2)}",
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.04,
//                     fontWeight: FontWeight.bold,
//                     color: bgColorPink,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:steam/screen/HomeScreen.dart';
import 'package:steam/sub%20screen/measurementPage.dart';
import '../constant/cart_persistence.dart';
import '../constant/constant.dart';
import '../screen/cart.dart';

class PrePlatedPage extends StatefulWidget {
  const PrePlatedPage({super.key});

  @override
  _PrePlatedPageState createState() => _PrePlatedPageState();
}

class _PrePlatedPageState extends State<PrePlatedPage> {
  // --- State & Data ---
  double prePlatedPrice = 0.0;
  int sareeQuantity = 0;
  bool isLoading = true;
  int _totalCartItems = 0;

  double washPrice = 0.0;
  double totalWashPrePlatedPrice = 0.0;
  int washPrePlatedQuantity = 0;

  double starchPrice = 0.0;
  double totalWashStarchPrePlatedPrice = 0.0;
  int washStarchPrePlatedQuantity = 0;

  Map<String, double> dryCleanItemPrices = {};
  double commonDryCleanStarchPrice = 0.0;
  Map<String, double> dryCleanCalculatedTotals = {};
  Map<String, int> dryCleanQuantities = {
    "Saree Fancy": 0,
    "Saree Medium": 0,
    "Saree Heavy": 0,
    "Saree Plain": 0,
  };

  @override
  void initState() {
    super.initState();
    _initializeAppAndFetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeAppAndFetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await Future.wait([
        _fetchPrePlatedPrice(),
        _fetchWashPrePlatedPrice(),
        _fetchStarchPrePlatedPrice(),
        _fetchDryCleanPrices(),
      ]);
    } finally {
      setState(() {
        isLoading = false;
      });
      _loadCart();
    }
  }

  Future<void> _fetchPrePlatedPrice() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("Dry Clean")
          .doc("Saree Fancy")
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          prePlatedPrice = (doc.data()!["pleat"] as num?)?.toDouble() ?? 0.0;
        });
      } else {
        _showSnackBar("Pre-Plated price for Saree not found in 'Dry Clean/Saree Fancy'.");
      }
    } catch (e) {
      _showSnackBar("Failed to load Pre-Plated Saree price. Please check your internet connection or try again later.");
    }
  }

  Future<void> _fetchWashPrePlatedPrice() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("Pre-Plate")
          .doc("Wash Pre")
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          washPrice = (doc.data()!["wash"] as num?)?.toDouble() ?? 0.0;
          totalWashPrePlatedPrice = (doc.data()!["price"] as num?)?.toDouble() ?? 0.0;
        });
      } else {
        _showSnackBar("Wash & Pre-Plated prices not found in 'Pre-Plate/Wash Pre'.");
      }
    } catch (e) {
      _showSnackBar("Failed to load Wash & Pre-Plated prices. Please check your internet connection or try again later.");
    }
  }

  Future<void> _fetchStarchPrePlatedPrice() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("Pre-Plate")
          .doc("Starch Pre")
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          starchPrice = (doc.data()!["starch"] as num?)?.toDouble() ?? 0.0;
          totalWashStarchPrePlatedPrice = (doc.data()!["price"] as num?)?.toDouble() ?? 0.0;
        });
      } else {
        _showSnackBar("Wash & Starch & Pre-Plated prices not found in 'Pre-Plate/Starch Pre'.");
      }
    } catch (e) {
      _showSnackBar("Failed to load Wash & Starch & Pre-Plated prices. Please check your internet connection or try again later.");
    }
  }

  Future<void> _fetchDryCleanPrices() async {
    try {
      final sareeFancyDoc = await FirebaseFirestore.instance.collection("Dry Clean").doc("Saree Fancy").get();
      final sareeMediumDoc = await FirebaseFirestore.instance.collection("Dry Clean").doc("Saree Medium").get();
      final sareeHeavyDoc = await FirebaseFirestore.instance.collection("Dry Clean").doc("Saree Heavy").get();
      final sareePlainDoc = await FirebaseFirestore.instance.collection("Dry Clean").doc("Saree Plain").get();

      final dryCleanPrePlateDoc = await FirebaseFirestore.instance
          .collection("Pre-Plate")
          .doc("dryclean")
          .get();

      setState(() {
        dryCleanItemPrices = {
          "Saree Fancy": (sareeFancyDoc.data() as Map<String, dynamic>?)?["dry_clean"]?.toDouble() ?? 0.0,
          "Saree Medium": (sareeMediumDoc.data() as Map<String, dynamic>?)?["dry_clean"]?.toDouble() ?? 0.0,
          "Saree Heavy": (sareeHeavyDoc.data() as Map<String, dynamic>?)?["dry_clean"]?.toDouble() ?? 0.0,
          "Saree Plain": (sareePlainDoc.data() as Map<String, dynamic>?)?["dry_clean"]?.toDouble() ?? 0.0,
        };
        commonDryCleanStarchPrice = (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["starch"]?.toDouble() ?? 0.0;
        dryCleanCalculatedTotals = {
          "Saree Fancy": (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["fancy"]?.toDouble() ?? 0.0,
          "Saree Medium": (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["medium"]?.toDouble() ?? 0.0,
          "Saree Heavy": (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["heavy"]?.toDouble() ?? 0.0,
          "Saree Plain": (dryCleanPrePlateDoc.data() as Map<String, dynamic>?)?["plain"]?.toDouble() ?? 0.0,
        };
      });
    } catch (e) {
      _showSnackBar("Failed to load Dry Clean prices. Please check your internet connection or try again later.");
    }
  }

  Future<void> _loadCart() async {
    try {
      final savedCart = await CartPersistence.loadCart();
      if (savedCart != null) {
        final prePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {});

        setState(() {
          sareeQuantity = (prePlatedItems["Saree"]?["quantity"] as int?) ?? 0;
          washPrePlatedQuantity = (prePlatedItems["Wash & Pre-Pleat"]?["quantity"] as int?) ?? 0;
          washStarchPrePlatedQuantity = (prePlatedItems["Wash & Starch & Pre-Pleat"]?["quantity"] as int?) ?? 0;

          dryCleanQuantities["Saree Fancy"] = (prePlatedItems["Saree Fancy"]?["quantity"] as int?) ?? 0;
          dryCleanQuantities["Saree Medium"] = (prePlatedItems["Saree Medium"]?["quantity"] as int?) ?? 0;
          dryCleanQuantities["Saree Heavy"] = (prePlatedItems["Saree Heavy"]?["quantity"] as int?) ?? 0;
          dryCleanQuantities["Saree Plain"] = (prePlatedItems["Saree Plain"]?["quantity"] as int?) ?? 0;

          _totalCartItems = _calculateTotalCartItems(savedCart);
        });
      }
    } catch (e) {
      _showSnackBar("Error loading cart. Please check your internet connection or try again later.");
    }
  }

  int _calculateTotalCartItems(Map<String, dynamic> savedCart) {
    int totalItems = 0;
    totalItems += (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).length;
    totalItems += (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).length;
    totalItems += (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).length;
    totalItems += (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).length;
    totalItems += (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).length;

    final prePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {});
    totalItems += prePlatedItems.keys.where((key) => (prePlatedItems[key]?["quantity"] as int? ?? 0) > 0).length;

    final additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {})
        .map((key, value) => MapEntry(key, (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList()));
    additionalServices.forEach((key, items) {
      totalItems += items.where((item) => (item["quantity"] ?? 0) > 0).length;
    });
    return totalItems;
  }

  void _updateQuantity(int delta, {bool isWashPrePlated = false, bool isWashStarchPrePlated = false, String? dryCleanItem}) {
    setState(() {
      if (dryCleanItem != null) {
        dryCleanQuantities[dryCleanItem] = (dryCleanQuantities[dryCleanItem]! + delta).clamp(0, 100);
      } else if (isWashStarchPrePlated) {
        washStarchPrePlatedQuantity = (washStarchPrePlatedQuantity + delta).clamp(0, 100);
      } else if (isWashPrePlated) {
        washPrePlatedQuantity = (washPrePlatedQuantity + delta).clamp(0, 100);
      } else {
        sareeQuantity = (sareeQuantity + delta).clamp(0, 100);
      }
    });
    _saveSelections();
  }

  Future<void> _saveSelections() async {
    try {
      final Map<String, Map<String, dynamic>> prePlatedItems = {};
      if (sareeQuantity > 0) {
        prePlatedItems["Saree"] = {"quantity": sareeQuantity, "pricePerItem": prePlatedPrice};
      }
      if (washPrePlatedQuantity > 0) {
        prePlatedItems["Wash & Pre-Pleat"] = {"quantity": washPrePlatedQuantity, "pricePerItem": washPrice + prePlatedPrice};
      }
      if (washStarchPrePlatedQuantity > 0) {
        prePlatedItems["Wash & Starch & Pre-Pleat"] = {"quantity": washStarchPrePlatedQuantity, "pricePerItem": washPrice + starchPrice + prePlatedPrice};
      }

      dryCleanQuantities.forEach((itemKey, quantity) {
        if (quantity > 0 && dryCleanCalculatedTotals.containsKey(itemKey)) {
          prePlatedItems[itemKey] = {"quantity": quantity, "pricePerItem": dryCleanCalculatedTotals[itemKey]!};
        }
      });

      final savedCart = await CartPersistence.loadCart();
      await CartPersistence.saveCart(
        dryCleanItems: (savedCart?['dryCleanItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
        ironingItems: (savedCart?['ironingItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
        washAndFoldItems: (savedCart?['washAndFoldItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
        washAndIronItems: (savedCart?['washAndIronItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
        washIronStarchItems: (savedCart?['washIronStarchItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
        prePlatedItems: prePlatedItems,
        additionalServices: (savedCart?['additionalServices'] as Map<String, dynamic>? ?? {}).map(
              (key, value) => MapEntry(key, (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList()),
        ),
        dryCleanTotal: savedCart?['dryCleanTotal'] as double? ?? 0,
        additionalTotal: savedCart?['additionalTotal'] as double? ?? 0,
      );

      // Recalculate total items for the badge after saving
      final updatedCart = await CartPersistence.loadCart();
      setState(() {
        _totalCartItems = _calculateTotalCartItems(updatedCart ?? {});
      });
    } catch (e) {
      _showSnackBar("Error saving selections: $e", isError: true);
    }
  }

  Future<void> _saveCartAndNavigateToCartPage() async {
    await _saveSelections();

    try {
      final savedCart = await CartPersistence.loadCart();
      if (savedCart != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartPage(
              dryCleanItems: (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
              ironingItems: (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
              washAndFoldItems: (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
              washAndIronItems: (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
              washIronStarchItems: (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).cast<String, int>(),
              prePlatedItems: (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).cast<String, Map<String, dynamic>>(),
              additionalServices: (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).map(
                    (key, value) => MapEntry(key, (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList()),
              ),
              dryCleanTotal: savedCart['dryCleanTotal'] as double? ?? 0,
              additionalTotal: savedCart['additionalTotal'] as double? ?? 0,
            ),
          ),
        ).then((_) => _loadCart());
      }
    } catch (e) {
      _showSnackBar("Error navigating to cart: $e", isError: true);
    }
  }

  void _navigateToMeasure() {
    if(mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MeasurementsPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  double _calculateTotal() {
    final sareeTotal = prePlatedPrice * sareeQuantity;
    final washPrePlatedTotal = (washPrice + prePlatedPrice) * washPrePlatedQuantity;
    final washStarchPrePlatedTotal = (washPrice + starchPrice + prePlatedPrice) * washStarchPrePlatedQuantity;

    final dryCleanTotal = dryCleanQuantities.entries
        .map((entry) => (dryCleanCalculatedTotals[entry.key] ?? 0.0) * entry.value)
        .fold(0.0, (previousValue, element) => previousValue + element);

    return sareeTotal + washPrePlatedTotal + washStarchPrePlatedTotal + dryCleanTotal;
  }

  bool isItemSelected() {
    return sareeQuantity > 0 || washPrePlatedQuantity > 0 || washStarchPrePlatedQuantity > 0 ||
        dryCleanQuantities.values.any((quantity) => quantity > 0);
  }

  void _showSnackBar(String message, {bool isError = false, bool isWarning = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : (isWarning ? Colors.orange : Colors.green),
        ),
      );
    }
  }

  // --- Mobile Layout Widgets ---
  Widget _buildSectionHeader(String title, double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.w700,
          color: Colors.grey[800],
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required double price,
    required int quantity,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    bool showTotalPrice = false,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  "₹${price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: bgColorPink,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              children: [
                Text(
                  "Quantity",
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, size: screenWidth * 0.045, color: quantity > 0 ? Colors.grey[800] : Colors.grey[400]),
                        onPressed: quantity > 0 ? onDecrement : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: screenWidth * 0.05,
                      ),
                      Container(
                        width: screenWidth * 0.1,
                        alignment: Alignment.center,
                        child: Text(
                          "$quantity",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, size: screenWidth * 0.045, color: Colors.grey[800]),
                        onPressed: onIncrement,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: screenWidth * 0.05,
                      ),
                    ],
                  ),
                ),
                if (showTotalPrice) ...[
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    "₹${(price * quantity).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: bgColorPink,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiPriceServiceCard({
    required String title,
    required List<Map<String, dynamic>> priceComponents,
    required int quantity,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required double totalPrice,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Column(
              children: priceComponents.map((component) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        component["label"],
                        style: TextStyle(
                          fontSize: component["isTotal"] == true ? screenWidth * 0.0375 : screenWidth * 0.035,
                          fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
                          color: component["isTotal"] == true ? Colors.grey[800] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        component["isTotal"] == true
                            ? "₹${component["value"].toStringAsFixed(2)} /Piece"
                            : "₹${component["value"].toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: component["isTotal"] == true ? screenWidth * 0.0375 : screenWidth * 0.035,
                          fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
                          color: bgColorPink,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              children: [
                Text(
                  "Quantity",
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, size: screenWidth * 0.045, color: quantity > 0 ? Colors.grey[800] : Colors.grey[400]),
                        onPressed: quantity > 0 ? onDecrement : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: screenWidth * 0.05,
                      ),
                      Container(
                        width: screenWidth * 0.1,
                        alignment: Alignment.center,
                        child: Text(
                          "$quantity",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, size: screenWidth * 0.045, color: Colors.grey[800]),
                        onPressed: onIncrement,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: screenWidth * 0.05,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  "₹${totalPrice.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: bgColorPink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDryCleanServiceCard({
    required String title,
    required List<Map<String, dynamic>> priceComponents,
    required int quantity,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required double totalPrice,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Column(
              children: priceComponents.map((component) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        component["label"],
                        style: TextStyle(
                          fontSize: component["isTotal"] == true ? screenWidth * 0.0375 : screenWidth * 0.035,
                          fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
                          color: component["isTotal"] == true ? Colors.grey[800] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        component["isTotal"] == true
                            ? "₹${component["value"].toStringAsFixed(2)} /Piece"
                            : "₹${component["value"].toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: component["isTotal"] == true ? screenWidth * 0.0375 : screenWidth * 0.035,
                          fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
                          color: bgColorPink,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              children: [
                Text(
                  "Quantity",
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, size: screenWidth * 0.045, color: quantity > 0 ? Colors.grey[800] : Colors.grey[400]),
                        onPressed: quantity > 0 ? onDecrement : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: screenWidth * 0.05,
                      ),
                      Container(
                        width: screenWidth * 0.1,
                        alignment: Alignment.center,
                        child: Text(
                          "$quantity",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, size: screenWidth * 0.045, color: Colors.grey[800]),
                        onPressed: onIncrement,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: screenWidth * 0.05,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  "₹${totalPrice.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: bgColorPink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Mobile Layout ---
  // Widget _buildMobileLayout() {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final screenHeight = MediaQuery.of(context).size.height;
  //
  //   return Scaffold(
  //     backgroundColor: Colors.grey[50],
  //     appBar: AppBar(
  //       title: const Text(
  //         "Saree Pre-Pleat",
  //         style: TextStyle(
  //           fontWeight: FontWeight.w700,
  //           fontSize: 20,
  //           letterSpacing: 0.5,
  //         ),
  //       ),
  //       centerTitle: true,
  //       leading: IconButton(
  //         icon: const Icon(Icons.arrow_back_ios, size: 20),
  //         onPressed: () => Navigator.pop(context),
  //       ),
  //       elevation: 0,
  //       shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.vertical(
  //           bottom: Radius.circular(12),
  //         ),
  //       ),
  //       backgroundColor: bgColorPink,
  //       foregroundColor: Colors.white,
  //       actions: [
  //         Padding(
  //           padding: EdgeInsets.only(right: screenWidth * 0.03),
  //           child: IconButton(
  //             icon: Stack(
  //               alignment: Alignment.center,
  //               children: [
  //                 const Icon(Icons.shopping_cart_outlined, size: 26),
  //                 if (_totalCartItems > 0)
  //                   Positioned(
  //                     right: 0,
  //                     top: 0,
  //                     child: Container(
  //                       padding: EdgeInsets.all(screenWidth * 0.01),
  //                       decoration: BoxDecoration(
  //                         color: Colors.red[600],
  //                         shape: BoxShape.circle,
  //                         border: Border.all(color: Colors.white, width: 1.5),
  //                       ),
  //                       constraints: BoxConstraints(
  //                         minWidth: screenWidth * 0.05,
  //                         minHeight: screenWidth * 0.05,
  //                       ),
  //                       child: Center(
  //                         child: Text(
  //                           '$_totalCartItems',
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontSize: screenWidth * 0.025,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //               ],
  //             ),
  //             onPressed: _saveCartAndNavigateToCartPage,
  //           ),
  //         ),
  //       ],
  //     ),
  //     body: Column(
  //       children: [
  //         Expanded(
  //           child: SingleChildScrollView(
  //             padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 _buildSectionHeader("Pre-Pleat Saree", screenWidth, screenHeight),
  //                 _buildServiceCard(
  //                   title: "Saree",
  //                   price: prePlatedPrice,
  //                   quantity: sareeQuantity,
  //                   onDecrement: () => _updateQuantity(-1),
  //                   onIncrement: () => _updateQuantity(1),
  //                   showTotalPrice: true,
  //                   screenWidth: screenWidth,
  //                   screenHeight: screenHeight,
  //                 ),
  //                 SizedBox(height: screenHeight * 0.02),
  //                 _buildSectionHeader("Wash & Pre-Pleat Saree", screenWidth, screenHeight),
  //                 _buildMultiPriceServiceCard(
  //                   title: "Wash & Pre-Pleat Saree",
  //                   priceComponents: [
  //                     {"label": "Wash", "value": washPrice},
  //                     {"label": "Pleat", "value": prePlatedPrice},
  //                     {"label": "Total", "value": totalWashPrePlatedPrice, "isTotal": true},
  //                   ],
  //                   quantity: washPrePlatedQuantity,
  //                   onDecrement: () => _updateQuantity(-1, isWashPrePlated: true),
  //                   onIncrement: () => _updateQuantity(1, isWashPrePlated: true),
  //                   totalPrice: (washPrice + prePlatedPrice) * washPrePlatedQuantity,
  //                   screenWidth: screenWidth,
  //                   screenHeight: screenHeight,
  //                 ),
  //                 SizedBox(height: screenHeight * 0.02),
  //                 _buildSectionHeader("Wash & Starch & Pre-Pleat", screenWidth, screenHeight),
  //                 _buildMultiPriceServiceCard(
  //                   title: "Wash & Starch & Pre-Pleat Saree",
  //                   priceComponents: [
  //                     {"label": "Wash", "value": washPrice},
  //                     {"label": "Starch", "value": starchPrice},
  //                     {"label": "Pleat", "value": prePlatedPrice},
  //                     {"label": "Total", "value": totalWashStarchPrePlatedPrice, "isTotal": true},
  //                   ],
  //                   quantity: washStarchPrePlatedQuantity,
  //                   onDecrement: () => _updateQuantity(-1, isWashStarchPrePlated: true),
  //                   onIncrement: () => _updateQuantity(1, isWashStarchPrePlated: true),
  //                   totalPrice: (washPrice + starchPrice + prePlatedPrice) * washStarchPrePlatedQuantity,
  //                   screenWidth: screenWidth,
  //                   screenHeight: screenHeight,
  //                 ),
  //                 SizedBox(height: screenHeight * 0.02),
  //                 _buildSectionHeader("Dry Clean", screenWidth, screenHeight),
  //                 _buildDryCleanServiceCard(
  //                   title: "Saree Fancy",
  //                   priceComponents: [
  //                     {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Fancy"] ?? 0.0},
  //                     {"label": "Starch", "value": commonDryCleanStarchPrice},
  //                     {"label": "Pleat", "value": prePlatedPrice},
  //                     {"label": "Total", "value": dryCleanCalculatedTotals["Saree Fancy"] ?? 0.0, "isTotal": true},
  //                   ],
  //                   quantity: dryCleanQuantities["Saree Fancy"] ?? 0,
  //                   onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Fancy"),
  //                   onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Fancy"),
  //                   totalPrice: (dryCleanCalculatedTotals["Saree Fancy"] ?? 0.0) * (dryCleanQuantities["Saree Fancy"] ?? 0),
  //                   screenWidth: screenWidth,
  //                   screenHeight: screenHeight,
  //                 ),
  //                 SizedBox(height: screenHeight * 0.02),
  //                 _buildDryCleanServiceCard(
  //                   title: "Saree Medium",
  //                   priceComponents: [
  //                     {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Medium"] ?? 0.0},
  //                     {"label": "Starch", "value": commonDryCleanStarchPrice},
  //                     {"label": "Pleat", "value": prePlatedPrice},
  //                     {"label": "Total", "value": dryCleanCalculatedTotals["Saree Medium"] ?? 0.0, "isTotal": true},
  //                   ],
  //                   quantity: dryCleanQuantities["Saree Medium"] ?? 0,
  //                   onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Medium"),
  //                   onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Medium"),
  //                   totalPrice: (dryCleanCalculatedTotals["Saree Medium"] ?? 0.0) * (dryCleanQuantities["Saree Medium"] ?? 0),
  //                   screenWidth: screenWidth,
  //                   screenHeight: screenHeight,
  //                 ),
  //                 SizedBox(height: screenHeight * 0.02),
  //                 _buildDryCleanServiceCard(
  //                   title: "Saree Heavy",
  //                   priceComponents: [
  //                     {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Heavy"] ?? 0.0},
  //                     {"label": "Starch", "value": commonDryCleanStarchPrice},
  //                     {"label": "Pleat", "value": prePlatedPrice},
  //                     {"label": "Total", "value": dryCleanCalculatedTotals["Saree Heavy"] ?? 0.0, "isTotal": true},
  //                   ],
  //                   quantity: dryCleanQuantities["Saree Heavy"] ?? 0,
  //                   onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Heavy"),
  //                   onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Heavy"),
  //                   totalPrice: (dryCleanCalculatedTotals["Saree Heavy"] ?? 0.0) * (dryCleanQuantities["Saree Heavy"] ?? 0),
  //                   screenWidth: screenWidth,
  //                   screenHeight: screenHeight,
  //                 ),
  //                 SizedBox(height: screenHeight * 0.02),
  //                 _buildDryCleanServiceCard(
  //                   title: "Saree Plain",
  //                   priceComponents: [
  //                     {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Plain"] ?? 0.0},
  //                     {"label": "Starch", "value": commonDryCleanStarchPrice},
  //                     {"label": "Pleat", "value": prePlatedPrice},
  //                     {"label": "Total", "value": dryCleanCalculatedTotals["Saree Plain"] ?? 0.0, "isTotal": true},
  //                   ],
  //                   quantity: dryCleanQuantities["Saree Plain"] ?? 0,
  //                   onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Plain"),
  //                   onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Plain"),
  //                   totalPrice: (dryCleanCalculatedTotals["Saree Plain"] ?? 0.0) * (dryCleanQuantities["Saree Plain"] ?? 0),
  //                   screenWidth: screenWidth,
  //                   screenHeight: screenHeight,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         if (isItemSelected())
  //           Container(
  //             padding: EdgeInsets.all(screenWidth * 0.04),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.1),
  //                   blurRadius: screenWidth * 0.025,
  //                   offset: Offset(0, -screenHeight * 0.01),
  //                 ),
  //               ],
  //               borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.04)),
  //             ),
  //             child: SafeArea(
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           "Pre-Pleat Total",
  //                           style: TextStyle(
  //                             fontSize: 14,
  //                             color: Colors.grey[600],
  //                           ),
  //                         ),
  //                         Text(
  //                           "₹${_calculateTotal().toStringAsFixed(2)}",
  //                           style: TextStyle(
  //                             fontSize: screenWidth * 0.05,
  //                             fontWeight: FontWeight.bold,
  //                             color: bgColorPink,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: ElevatedButton(
  //                       onPressed: () async {
  //                         await _saveSelections();
  //                         _navigateToHomePage();
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: bgColorPink,
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(screenWidth * 0.03),
  //                         ),
  //                         padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
  //                       ),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Text(
  //                             "Continue",
  //                             style: TextStyle(
  //                               fontSize: screenWidth * 0.04,
  //                               fontWeight: FontWeight.bold,
  //                               color: Colors.white,
  //                             ),
  //                           ),
  //                           SizedBox(width: screenWidth * 0.02),
  //                           Icon(Icons.arrow_forward, size: screenWidth * 0.05, color: Colors.white),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  // --- Web Layout ---
  Widget _buildWebLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Saree Pre-Pleat",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: bgColorPink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.01),
            child: IconButton(
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 26, color: Colors.white),
                  if (_totalCartItems > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                        child: Center(
                          child: Text(
                            '$_totalCartItems',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: _saveCartAndNavigateToCartPage,
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWebSectionHeader("Pre-Pleat Saree"),
                      _buildWebServiceCard(
                        title: "Saree",
                        price: prePlatedPrice,
                        quantity: sareeQuantity,
                        onDecrement: () => _updateQuantity(-1),
                        onIncrement: () => _updateQuantity(1),
                        showTotalPrice: true,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildWebSectionHeader("Wash & Pre-Pleat Saree"),
                      _buildWebMultiPriceServiceCard(
                        title: "Wash & Pre-Pleat Saree",
                        priceComponents: [
                          {"label": "Wash", "value": washPrice},
                          {"label": "Pleat", "value": prePlatedPrice},
                          {"label": "Total", "value": totalWashPrePlatedPrice, "isTotal": true},
                        ],
                        quantity: washPrePlatedQuantity,
                        onDecrement: () => _updateQuantity(-1, isWashPrePlated: true),
                        onIncrement: () => _updateQuantity(1, isWashPrePlated: true),
                        totalPrice: (washPrice + prePlatedPrice) * washPrePlatedQuantity,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildWebSectionHeader("Wash & Starch & Pre-Pleat"),
                      _buildWebMultiPriceServiceCard(
                        title: "Wash & Starch & Pre-Pleat Saree",
                        priceComponents: [
                          {"label": "Wash", "value": washPrice},
                          {"label": "Starch", "value": starchPrice},
                          {"label": "Pleat", "value": prePlatedPrice},
                          {"label": "Total", "value": totalWashStarchPrePlatedPrice, "isTotal": true},
                        ],
                        quantity: washStarchPrePlatedQuantity,
                        onDecrement: () => _updateQuantity(-1, isWashStarchPrePlated: true),
                        onIncrement: () => _updateQuantity(1, isWashStarchPrePlated: true),
                        totalPrice: (washPrice + starchPrice + prePlatedPrice) * washStarchPrePlatedQuantity,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildWebSectionHeader("Dry Clean"),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.0,
                        ),
                        itemCount: dryCleanQuantities.length,
                        itemBuilder: (context, index) {
                          final itemTitle = dryCleanQuantities.keys.elementAt(index);
                          return _buildWebDryCleanServiceCard(
                            title: itemTitle,
                            priceComponents: [
                              {"label": "Dry Clean", "value": dryCleanItemPrices[itemTitle] ?? 0.0},
                              {"label": "Starch", "value": commonDryCleanStarchPrice},
                              {"label": "Pleat", "value": prePlatedPrice},
                              {"label": "Total", "value": dryCleanCalculatedTotals[itemTitle] ?? 0.0, "isTotal": true},
                            ],
                            quantity: dryCleanQuantities[itemTitle] ?? 0,
                            onDecrement: () => _updateQuantity(-1, dryCleanItem: itemTitle),
                            onIncrement: () => _updateQuantity(1, dryCleanItem: itemTitle),
                            totalPrice: (dryCleanCalculatedTotals[itemTitle] ?? 0.0) * (dryCleanQuantities[itemTitle] ?? 0),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (isItemSelected())
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildWebFooter(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildWebServiceCard({
    required String title,
    required double price,
    required int quantity,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    bool showTotalPrice = false,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "₹${price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: bgColorPink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  "Quantity",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, size: 20, color: quantity > 0 ? Colors.black87 : Colors.grey[400]),
                        onPressed: quantity > 0 ? onDecrement : null,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          "$quantity",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20, color: Colors.black87),
                        onPressed: onIncrement,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
                if (showTotalPrice) ...[
                  const SizedBox(width: 16),
                  Text(
                    "₹${(price * quantity).toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: bgColorPink,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebMultiPriceServiceCard({
    required String title,
    required List<Map<String, dynamic>> priceComponents,
    required int quantity,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required double totalPrice,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: priceComponents.map((component) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        component["label"],
                        style: TextStyle(
                          fontSize: component["isTotal"] == true ? 14 : 13,
                          fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
                          color: component["isTotal"] == true ? Colors.black87 : Colors.black54,
                        ),
                      ),
                      Text(
                        component["isTotal"] == true
                            ? "₹${component["value"].toStringAsFixed(2)} /Piece"
                            : "₹${component["value"].toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: component["isTotal"] == true ? 14 : 13,
                          fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
                          color: bgColorPink,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  "Quantity",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, size: 20, color: quantity > 0 ? Colors.black87 : Colors.grey[400]),
                        onPressed: quantity > 0 ? onDecrement : null,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          "$quantity",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20, color: Colors.black87),
                        onPressed: onIncrement,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "₹${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: bgColorPink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebDryCleanServiceCard({
    required String title,
    required List<Map<String, dynamic>> priceComponents,
    required int quantity,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required double totalPrice,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: priceComponents.map((component) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        component["label"],
                        style: TextStyle(
                          fontSize: component["isTotal"] == true ? 14 : 13,
                          fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
                          color: component["isTotal"] == true ? Colors.black87 : Colors.black54,
                        ),
                      ),
                      Text(
                        component["isTotal"] == true
                            ? "₹${component["value"].toStringAsFixed(2)} /Piece"
                            : "₹${component["value"].toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: component["isTotal"] == true ? 14 : 13,
                          fontWeight: component["isTotal"] == true ? FontWeight.w600 : FontWeight.w500,
                          color: bgColorPink,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  "Quantity",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, size: 20, color: quantity > 0 ? Colors.black87 : Colors.grey[400]),
                        onPressed: quantity > 0 ? onDecrement : null,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          "$quantity",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20, color: Colors.black87),
                        onPressed: onIncrement,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "₹${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: bgColorPink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Web Footer ---
  Widget _buildWebFooter() {
    final total = _calculateTotal();
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            const Text(
              "Pre-Pleat Total",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              "₹${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: bgColorPink),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await _saveSelections();
                _navigateToMeasure();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColorPink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Add Measurement", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/animations/loading.json', width: 200, height: 200, fit: BoxFit.contain),
            ],
          ),
        ),
      );
    }

    if (isWeb) {
      return _buildWebLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  // Encapsulated the original mobile layout
  Widget _buildMobileLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Saree Pre-Pleat",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        backgroundColor: bgColorPink,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.03),
            child: IconButton(
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 26),
                  if (_totalCartItems > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.01),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: BoxConstraints(
                          minWidth: screenWidth * 0.05,
                          minHeight: screenWidth * 0.05,
                        ),
                        child: Center(
                          child: Text(
                            '$_totalCartItems',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.025,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: _saveCartAndNavigateToCartPage,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Pre-Pleat Saree", screenWidth, screenHeight),
                  _buildServiceCard(
                    title: "Saree",
                    price: prePlatedPrice,
                    quantity: sareeQuantity,
                    onDecrement: () => _updateQuantity(-1),
                    onIncrement: () => _updateQuantity(1),
                    showTotalPrice: true,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildSectionHeader("Wash & Pre-Pleat Saree", screenWidth, screenHeight),
                  _buildMultiPriceServiceCard(
                    title: "Wash & Pre-Pleat Saree",
                    priceComponents: [
                      {"label": "Wash", "value": washPrice},
                      {"label": "Pleat", "value": prePlatedPrice},
                      {"label": "Total", "value": totalWashPrePlatedPrice, "isTotal": true},
                    ],
                    quantity: washPrePlatedQuantity,
                    onDecrement: () => _updateQuantity(-1, isWashPrePlated: true),
                    onIncrement: () => _updateQuantity(1, isWashPrePlated: true),
                    totalPrice: (washPrice + prePlatedPrice) * washPrePlatedQuantity,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildSectionHeader("Wash & Starch & Pre-Pleat", screenWidth, screenHeight),
                  _buildMultiPriceServiceCard(
                    title: "Wash & Starch & Pre-Pleat Saree",
                    priceComponents: [
                      {"label": "Wash", "value": washPrice},
                      {"label": "Starch", "value": starchPrice},
                      {"label": "Pleat", "value": prePlatedPrice},
                      {"label": "Total", "value": totalWashStarchPrePlatedPrice, "isTotal": true},
                    ],
                    quantity: washStarchPrePlatedQuantity,
                    onDecrement: () => _updateQuantity(-1, isWashStarchPrePlated: true),
                    onIncrement: () => _updateQuantity(1, isWashStarchPrePlated: true),
                    totalPrice: (washPrice + starchPrice + prePlatedPrice) * washStarchPrePlatedQuantity,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildSectionHeader("Dry Clean", screenWidth, screenHeight),
                  _buildDryCleanServiceCard(
                    title: "Saree Fancy",
                    priceComponents: [
                      {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Fancy"] ?? 0.0},
                      {"label": "Starch", "value": commonDryCleanStarchPrice},
                      {"label": "Pleat", "value": prePlatedPrice},
                      {"label": "Total", "value": dryCleanCalculatedTotals["Saree Fancy"] ?? 0.0, "isTotal": true},
                    ],
                    quantity: dryCleanQuantities["Saree Fancy"] ?? 0,
                    onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Fancy"),
                    onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Fancy"),
                    totalPrice: (dryCleanCalculatedTotals["Saree Fancy"] ?? 0.0) * (dryCleanQuantities["Saree Fancy"] ?? 0),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildDryCleanServiceCard(
                    title: "Saree Medium",
                    priceComponents: [
                      {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Medium"] ?? 0.0},
                      {"label": "Starch", "value": commonDryCleanStarchPrice},
                      {"label": "Pleat", "value": prePlatedPrice},
                      {"label": "Total", "value": dryCleanCalculatedTotals["Saree Medium"] ?? 0.0, "isTotal": true},
                    ],
                    quantity: dryCleanQuantities["Saree Medium"] ?? 0,
                    onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Medium"),
                    onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Medium"),
                    totalPrice: (dryCleanCalculatedTotals["Saree Medium"] ?? 0.0) * (dryCleanQuantities["Saree Medium"] ?? 0),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildDryCleanServiceCard(
                    title: "Saree Heavy",
                    priceComponents: [
                      {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Heavy"] ?? 0.0},
                      {"label": "Starch", "value": commonDryCleanStarchPrice},
                      {"label": "Pleat", "value": prePlatedPrice},
                      {"label": "Total", "value": dryCleanCalculatedTotals["Saree Heavy"] ?? 0.0, "isTotal": true},
                    ],
                    quantity: dryCleanQuantities["Saree Heavy"] ?? 0,
                    onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Heavy"),
                    onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Heavy"),
                    totalPrice: (dryCleanCalculatedTotals["Saree Heavy"] ?? 0.0) * (dryCleanQuantities["Saree Heavy"] ?? 0),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildDryCleanServiceCard(
                    title: "Saree Plain",
                    priceComponents: [
                      {"label": "Dry Clean", "value": dryCleanItemPrices["Saree Plain"] ?? 0.0},
                      {"label": "Starch", "value": commonDryCleanStarchPrice},
                      {"label": "Pleat", "value": prePlatedPrice},
                      {"label": "Total", "value": dryCleanCalculatedTotals["Saree Plain"] ?? 0.0, "isTotal": true},
                    ],
                    quantity: dryCleanQuantities["Saree Plain"] ?? 0,
                    onDecrement: () => _updateQuantity(-1, dryCleanItem: "Saree Plain"),
                    onIncrement: () => _updateQuantity(1, dryCleanItem: "Saree Plain"),
                    totalPrice: (dryCleanCalculatedTotals["Saree Plain"] ?? 0.0) * (dryCleanQuantities["Saree Plain"] ?? 0),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ],
              ),
            ),
          ),
          if (isItemSelected())
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: screenWidth * 0.025,
                    offset: Offset(0, -screenHeight * 0.01),
                  ),
                ],
                borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.04)),
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
                            "Pre-Pleat Total",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "₹${_calculateTotal().toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: bgColorPink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _saveSelections();
                          _navigateToMeasure();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgColorPink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Add Measurement",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Icon(Icons.arrow_forward, size: screenWidth * 0.05, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}