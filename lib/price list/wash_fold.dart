// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lottie/lottie.dart';
// import 'package:steam/constant/constant.dart';
// import 'package:steam/screen/HomeScreen.dart';
// import '../constant/cart_persistence.dart';
// import '../screen/cart.dart';
//
// class WashAndFoldPage extends StatefulWidget {
//   const WashAndFoldPage({super.key});
//
//   @override
//   _WashAndFoldPageState createState() => _WashAndFoldPageState();
// }
//
// class _WashAndFoldPageState extends State<WashAndFoldPage> {
//   // State variables
//   Map<String, int> itemQuantities = {};
//   bool _isLoading = true;
//   double _total = 0;
//   int _totalCartItems = 0;
//
//   // Pricing data
//   Map<String, dynamic>? byWeightPricing;
//   List<Map<String, dynamic>> additionalPrices = [];
//   List<Map<String, dynamic>> oneTimePrices = [];
//   List<Map<String, dynamic>> subscriptionPrices = [];
//   List<Map<String, dynamic>> subscriptionThreePrices = [];
//
//   // UI constants
//   final Color primaryColor = bgColorPink;
//   final Color secondaryColor = Colors.pinkAccent.shade100;
//   final double cardRadius = 12.0;
//   final double sectionSpacing = 24.0;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCart();
//   }
//
//   Future<void> _loadSavedCart() async {
//     try {
//       final savedCart = await CartPersistence.loadCart();
//       setState(() {
//         if (savedCart != null && savedCart['washAndFoldItems'] != null) {
//           final loadedItems = savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {};
//           itemQuantities = loadedItems.map((key, value) {
//             int quantity;
//             if (value is int) {
//               quantity = value;
//             } else if (value is double) {
//               quantity = value.toInt();
//             } else if (value is String) {
//               quantity = int.tryParse(value) ?? 0;
//             } else {
//               quantity = 0;
//             }
//             return MapEntry(key, quantity);
//           });
//         }
//         // Calculate total items for badge
//         if (savedCart != null) {
//           int totalItems = 0;
//           totalItems += (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).length;
//           totalItems += (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).length;
//           totalItems += itemQuantities.length;
//           totalItems += (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).length;
//           totalItems += (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).length;
//           totalItems += (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).length; // Already correct
//           _totalCartItems = totalItems;
//         }
//       });
//       _fetchPricingData();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to load saved cart. Please check Internet"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       _fetchPricingData();
//     }
//   }
//
//   Future<void> _fetchPricingData() async {
//     try {
//       final futures = [
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("By Weight").get(),
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("1 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("7 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("15 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("30 Time").get(),
//       ];
//
//       final results = await Future.wait(futures);
//
//       setState(() {
//         additionalPrices = [];
//         oneTimePrices = [];
//         subscriptionPrices = [];
//         subscriptionThreePrices = [];
//
//         if (results[0].exists) {
//           final data = results[0].data() as Map<String, dynamic>;
//           byWeightPricing = {
//             "name": "By Weight",
//             "price": data["price"] ?? 0,
//             "month": 0,
//             "unit": "/KG",
//           };
//           additionalPrices.add({
//             "label": "By Weight: Regular Wash",
//             "price": data["price"] ?? 0,
//             "unit": "/KG",
//           });
//         }
//
//         if (results[1].exists) {
//           final data = results[1].data() as Map<String, dynamic>;
//           oneTimePrices.addAll([
//             {
//               "label": "One-Time: 3kg Regular Wash",
//               "price": data["three"] ?? 0,
//               "unit": "/2.75 To 3 KG",
//             },
//             {
//               "label": "One-Time: 3kg White Clothes",
//               "price": data["white3"] ?? 0,
//               "unit": "/2.75 To 3 KG",
//             },
//             {
//               "label": "One-Time: 5kg Regular Wash",
//               "price": data["price"] ?? 0,
//               "unit": "/5 to 5.5 KG",
//             },
//             {
//               "label": "One-Time: 5kg White Clothes",
//               "price": data["white"] ?? 0,
//               "unit": "/5 to 5.5 KG",
//             },
//           ]);
//         }
//
//         for (int i = 2; i < results.length; i++) {
//           if (results[i].exists) {
//             final data = results[i].data() as Map<String, dynamic>;
//             final times = [7, 15, 30][i - 2];
//
//             subscriptionPrices.addAll([
//               {
//                 "label": "Subscription: $times Washes (5kg)",
//                 "price": data["price"] ?? 0,
//                 "unit": "/5 to 5.5 KG",
//                 "month": data["month"] ?? 1,
//                 "times": times,
//               },
//               {
//                 "label": "Subscription: $times White Washes (5kg)",
//                 "price": data["white"] ?? 0,
//                 "unit": "/5 to 5.5 KG",
//                 "month": data["month"] ?? 1,
//                 "times": times,
//               },
//             ]);
//
//             subscriptionThreePrices.addAll([
//               {
//                 "label": "Subscription: $times Washes (3kg)",
//                 "price": data["three"] ?? 0,
//                 "unit": "/2.75 To 3 KG",
//                 "month": data["month"] ?? 1,
//                 "times": times,
//               },
//               {
//                 "label": "Subscription: $times White Washes (3kg)",
//                 "price": data["white3"] ?? 0,
//                 "unit": "/2.75 To 3 KG",
//                 "month": data["month"] ?? 1,
//                 "times": times,
//               },
//             ]);
//           }
//         }
//
//         _isLoading = false;
//         _calculateTotal();
//         print("Finished fetching pricing data at 10:29 AM IST on June 07, 2025, _isLoading: $_isLoading");
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       print("Error fetching pricing data at 10:29 AM IST on June 07, 2025, _isLoading: $_isLoading, error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error loading prices. Please check your network connection"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   bool isItemSelected() {
//     return itemQuantities.isNotEmpty;
//   }
//
//   void _calculateTotal() {
//     double total = 0;
//     itemQuantities.forEach((key, quantity) {
//       var priceItem = additionalPrices.firstWhere(
//             (item) => item["label"] == key,
//         orElse: () => {"price": 0},
//       );
//       if (priceItem["price"] != 0) {
//         total += (priceItem["price"] * quantity);
//       } else {
//         priceItem = oneTimePrices.firstWhere(
//               (item) => item["label"] == key,
//           orElse: () => {"price": 0},
//         );
//         if (priceItem["price"] != 0) {
//           total += (priceItem["price"] * quantity);
//         } else {
//           priceItem = subscriptionPrices.firstWhere(
//                 (item) => item["label"] == key,
//             orElse: () => {"price": 0},
//           );
//           if (priceItem["price"] != 0) {
//             total += (priceItem["price"] * quantity);
//           } else {
//             priceItem = subscriptionThreePrices.firstWhere(
//                   (item) => item["label"] == key,
//               orElse: () => {"price": 0},
//             );
//             total += (priceItem["price"] * quantity);
//           }
//         }
//       }
//     });
//     setState(() => _total = total);
//   }
//
//   Future<void> _saveSelections() async {
//     try {
//       final savedCart = await CartPersistence.loadCart();
//       Map<String, Map<String, dynamic>> savedPrePlatedItems = (savedCart?['prePlatedItems'] as Map<String, dynamic>? ?? {})
//           .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
//
//       await CartPersistence.saveCart(
//         dryCleanItems: savedCart?['dryCleanItems'] ?? {},
//         ironingItems: savedCart?['ironingItems'] ?? {},
//         washAndFoldItems: itemQuantities,
//         washAndIronItems: savedCart?['washAndIronItems'] ?? {},
//         washIronStarchItems: savedCart?['washIronStarchItems'] ?? {},
//         prePlatedItems: savedPrePlatedItems,
//         additionalServices: savedCart?['additionalServices'] ?? {},
//         dryCleanTotal: savedCart?['dryCleanTotal'] ?? 0,
//         additionalTotal: savedCart?['additionalTotal'] ?? 0,
//       );
//
//       // Update total cart items for badge
//       final updatedCart = await CartPersistence.loadCart();
//       int totalItems = 0;
//       totalItems += (updatedCart?['dryCleanItems'] as Map<String, dynamic>? ?? {}).length;
//       totalItems += (updatedCart?['ironingItems'] as Map<String, dynamic>? ?? {}).length;
//       totalItems += itemQuantities.length;
//       totalItems += (updatedCart?['washAndIronItems'] as Map<String, dynamic>? ?? {}).length;
//       totalItems += (updatedCart?['washIronStarchItems'] as Map<String, dynamic>? ?? {}).length;
//       totalItems += (updatedCart?['prePlatedItems'] as Map<String, dynamic>? ?? {}).length;
//       setState(() {
//         _totalCartItems = totalItems;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error saving. Please check your network connection"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   Future<void> _saveAndNavigateToCart() async {
//     try {
//       final savedCart = await CartPersistence.loadCart() ?? {};
//
//       Map<String, int> dryCleanItems = (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).map((key, value) {
//         int quantity;
//         if (value is int) {
//           quantity = value;
//         } else if (value is double) {
//           quantity = value.toInt();
//         } else if (value is String) {
//           quantity = int.tryParse(value) ?? 0;
//         } else {
//           quantity = 0;
//         }
//         return MapEntry(key, quantity);
//       });
//
//       Map<String, int> ironingItems = (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).map((key, value) {
//         int quantity;
//         if (value is int) {
//           quantity = value;
//         } else if (value is double) {
//           quantity = value.toInt();
//         } else if (value is String) {
//           quantity = int.tryParse(value) ?? 0;
//         } else {
//           quantity = 0;
//         }
//         return MapEntry(key, quantity);
//       });
//
//       Map<String, int> washAndIronItems = (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).map((key, value) {
//         int quantity;
//         if (value is int) {
//           quantity = value;
//         } else if (value is double) {
//           quantity = value.toInt();
//         } else if (value is String) {
//           quantity = int.tryParse(value) ?? 0;
//         } else {
//           quantity = 0;
//         }
//         return MapEntry(key, quantity);
//       });
//
//       Map<String, int> washIronStarchItems = (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).map((key, value) {
//         int quantity;
//         if (value is int) {
//           quantity = value;
//         } else if (value is double) {
//           quantity = value.toInt();
//         } else if (value is String) {
//           quantity = int.tryParse(value) ?? 0;
//         } else {
//           quantity = 0;
//         }
//         return MapEntry(key, quantity);
//       });
//
//       Map<String, Map<String, dynamic>> savedPrePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {})
//           .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
//
//       Map<String, List<Map<String, dynamic>>> additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).map(
//             (key, value) => MapEntry(
//           key,
//           (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList(),
//         ),
//       );
//
//       await CartPersistence.saveCart(
//         dryCleanItems: dryCleanItems,
//         ironingItems: ironingItems,
//         washAndFoldItems: itemQuantities,
//         washAndIronItems: washAndIronItems,
//         washIronStarchItems: washIronStarchItems,
//         prePlatedItems: savedPrePlatedItems,
//         additionalServices: additionalServices,
//         dryCleanTotal: savedCart['dryCleanTotal'] as double? ?? 0,
//         additionalTotal: savedCart['additionalTotal'] as double? ?? 0,
//       );
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => CartPage(
//             dryCleanItems: dryCleanItems,
//             ironingItems: ironingItems,
//             washAndFoldItems: itemQuantities,
//             washAndIronItems: washAndIronItems,
//             washIronStarchItems: washIronStarchItems,
//             prePlatedItems: savedPrePlatedItems,
//             additionalServices: additionalServices,
//             dryCleanTotal: savedCart['dryCleanTotal'] as double? ?? 0,
//             additionalTotal: savedCart['additionalTotal'] as double? ?? 0,
//           ),
//         ),
//       ).then((_) {
//         _loadSavedCart();
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error saving cart. Please check your network connection"),
//           backgroundColor: Colors.red,
//         ),
//       );
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
//   Widget _buildSection(String title, List<Map<String, dynamic>> items, double aspectRatio) {
//     if (items.isEmpty) return const SizedBox();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
//           child: Align(
//             alignment: Alignment.centerLeft,
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ),
//         ),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: items.length == 1 ? 1 : 2,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             childAspectRatio: items.length == 1 ? 3.0 : aspectRatio,
//           ),
//           itemCount: items.length,
//           itemBuilder: (context, index) {
//             final priceItem = items[index];
//             final isSelected = itemQuantities.containsKey(priceItem["label"]);
//
//             return Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: bgColorPink.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: isSelected ? bgColorPink : Colors.transparent,
//                   width: 1,
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         priceItem["label"].split(": ")[1].replaceAll(" (3kg)", "").replaceAll(" (5kg)", ""),
//                         style: TextStyle(
//                           fontSize: title.contains("Subscription") ? 11 : 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey[800],
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         "₹${priceItem["price"]} ${priceItem["unit"]}",
//                         style: TextStyle(
//                           fontSize: title.contains("Subscription") ? 11 : 12,
//                           fontWeight: FontWeight.bold,
//                           color: bgColorPink,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                       ),
//                       if (title.contains("Subscription")) ...[
//                         const SizedBox(height: 4),
//                         Text(
//                           "${priceItem["month"]} Month${priceItem["month"] != 1 ? 's' : ''} Validity",
//                           style: TextStyle(
//                             fontSize: 10,
//                             color: Colors.grey[600],
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           "Wash for ${priceItem["times"]} Times",
//                           style: TextStyle(
//                             fontSize: 9,
//                             color: Colors.black,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                       ],
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             if (isSelected) {
//                               itemQuantities.remove(priceItem["label"]);
//                             } else {
//                               itemQuantities[priceItem["label"]] = 1;
//                             }
//                             _calculateTotal();
//                           });
//                           _saveSelections(); // Added to save cart dynamically
//                         },
//                         child: Container(
//                           width: 30,
//                           height: 30,
//                           decoration: BoxDecoration(
//                             color: isSelected ? Colors.blue : Colors.pinkAccent.shade200,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             isSelected ? Icons.remove : Icons.add,
//                             color: Colors.white,
//                             size: 16,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Wash & Fold",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(12),
//           ),
//         ),
//         actions: [
//           // Added cart button in AppBar
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
//               onPressed: () {
//                 _saveAndNavigateToCart();
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
//               onLoaded: (composition) {},
//               errorBuilder: (context, error, stackTrace) {
//                 return const Text(
//                   "Failed to load animation",
//                   style: TextStyle(color: Colors.red),
//                 );
//               },
//             ),
//           ],
//         ),
//       )
//           : () {
//         final allItems = [...additionalPrices, ...oneTimePrices, ...subscriptionPrices, ...subscriptionThreePrices];
//         if (allItems.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Lottie.asset(
//                   'assets/animations/empty.json',
//                   width: 200,
//                   height: 200,
//                   fit: BoxFit.contain,
//                   errorBuilder: (context, error, stackTrace) {
//                     print("Error loading empty animation at 10:29 AM IST on June 07, 2025: $error");
//                     return const Text(
//                       "Failed to load empty state animation",
//                       style: TextStyle(color: Colors.red),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   "No services available",
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 TextButton(
//                   onPressed: _fetchPricingData,
//                   child: const Text("Retry"),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
//                       child: Row(
//                         children: [
//                           Text(
//                             "Available Plans",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey[800],
//                             ),
//                           ),
//                           const Spacer(),
//                           if (isItemSelected())
//                             Text(
//                               "${itemQuantities.length} item${itemQuantities.length > 1 ? 's' : ''} selected",
//                               style: const TextStyle(
//                                 color: bgColorPink,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     _buildSection("By Weight Pricing", additionalPrices, 1.5),
//                     _buildSection("One-Time Wash", oneTimePrices, 1.5),
//                     _buildSection("Subscription Based (2.75 To 3 KG)", subscriptionThreePrices, 1.3),
//                     _buildSection("Subscription Based (5 to 5.5 KG)", subscriptionPrices, 1.3),
//                     const SizedBox(height: 16),
//                   ],
//                 ),
//               ),
//             ),
//             if (isItemSelected())
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, -5),
//                     ),
//                   ],
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                 ),
//                 child: SafeArea(
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Wash & Fold Total",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             Text(
//                               "₹${_total.toStringAsFixed(2)}",
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: bgColorPink,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: _navigateToHomePage, // Updated to navigate to homepage
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: bgColorPink,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "More Services", // Updated label
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               SizedBox(width: 8),
//                               Icon(Icons.arrow_forward, size: 20, color: Colors.white),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         );
//       }(),
//     );
//   }
// }
//

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lottie/lottie.dart';
// import 'package:steam/constant/constant.dart';
// import 'package:steam/screen/HomeScreen.dart';
// import '../constant/cart_persistence.dart';
// import '../screen/cart.dart';
//
// class WashAndFoldPage extends StatefulWidget {
//   const WashAndFoldPage({super.key});
//
//   @override
//   _WashAndFoldPageState createState() => _WashAndFoldPageState();
// }
//
// class _WashAndFoldPageState extends State<WashAndFoldPage> {
//   // State variables
//   Map<String, int> itemQuantities = {};
//   bool _isLoading = true;
//   double _total = 0;
//   int _totalCartItems = 0;
//
//   // Pricing data
//   Map<String, dynamic>? byWeightPricing;
//   List<Map<String, dynamic>> additionalPrices = [];
//   List<Map<String, dynamic>> oneTimePrices = [];
//   List<Map<String, dynamic>> subscriptionPrices = [];
//   List<Map<String, dynamic>> subscriptionThreePrices = [];
//
//   // UI constants
//   final Color primaryColor = bgColorPink;
//   final Color secondaryColor = Colors.pinkAccent.shade100;
//   final double cardRadius = 12.0;
//   final double sectionSpacing = 24.0;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCart();
//   }
//
//   Future<void> _loadSavedCart() async {
//     try {
//       final savedCart = await CartPersistence.loadCart();
//       setState(() {
//         if (savedCart != null && savedCart['washAndFoldItems'] != null) {
//           final loadedItems = savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {};
//           itemQuantities = loadedItems.map((key, value) {
//             int quantity;
//             if (value is int) {
//               quantity = value;
//             } else if (value is double) {
//               quantity = value.toInt();
//             } else if (value is String) {
//               quantity = int.tryParse(value) ?? 0;
//             } else {
//               quantity = 0;
//             }
//             return MapEntry(key, quantity);
//           });
//         }
//         // Calculate total items for badge
//         if (savedCart != null) {
//           int totalItems = 0;
//           totalItems += (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).length;
//           totalItems += (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).length;
//           totalItems += itemQuantities.length;
//           totalItems += (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).length;
//           totalItems += (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).length;
//           totalItems += (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).length;
//           _totalCartItems = totalItems;
//         }
//       });
//       _fetchPricingData();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to load saved cart. Please check Internet"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       _fetchPricingData();
//     }
//   }
//
//   Future<void> _fetchPricingData() async {
//     try {
//       final futures = [
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("By Weight").get(),
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("1 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("7 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("15 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("30 Time").get(),
//       ];
//
//       final results = await Future.wait(futures);
//
//       setState(() {
//         additionalPrices = [];
//         oneTimePrices = [];
//         subscriptionPrices = [];
//         subscriptionThreePrices = [];
//
//         if (results[0].exists) {
//           final data = results[0].data() as Map<String, dynamic>;
//           byWeightPricing = {
//             "name": "By Weight",
//             "price": data["price"] ?? 0,
//             "month": 0,
//             "unit": "/KG",
//           };
//           additionalPrices.add({
//             "label": "By Weight: Regular Wash",
//             "price": data["price"] ?? 0,
//             "unit": "/KG",
//           });
//         }
//
//         if (results[1].exists) {
//           final data = results[1].data() as Map<String, dynamic>;
//           oneTimePrices.addAll([
//             {
//               "label": "One-Time: 3kg Regular Wash",
//               "price": data["three"] ?? 0,
//               "unit": "/2.75 To 3 KG",
//             },
//             {
//               "label": "One-Time: 3kg White Clothes",
//               "price": data["white3"] ?? 0,
//               "unit": "/2.75 To 3 KG",
//             },
//             {
//               "label": "One-Time: 5kg Regular Wash",
//               "price": data["price"] ?? 0,
//               "unit": "/5 to 5.5 KG",
//             },
//             {
//               "label": "One-Time: 5kg White Clothes",
//               "price": data["white"] ?? 0,
//               "unit": "/5 to 5.5 KG",
//             },
//           ]);
//         }
//
//         for (int i = 2; i < results.length; i++) {
//           if (results[i].exists) {
//             final data = results[i].data() as Map<String, dynamic>;
//             final times = [7, 15, 30][i - 2];
//
//             subscriptionPrices.addAll([
//               {
//                 "label": "Subscription: $times Washes (5kg)",
//                 "price": data["price"] ?? 0,
//                 "unit": "/5 to 5.5 KG",
//                 "month": data["month"] ?? 1,
//                 "times": times,
//               },
//               {
//                 "label": "Subscription: $times White Washes (5kg)",
//                 "price": data["white"] ?? 0,
//                 "unit": "/5 to 5.5 KG",
//                 "month": data["month"] ?? 1,
//                 "times": times,
//               },
//             ]);
//
//             subscriptionThreePrices.addAll([
//               {
//                 "label": "Subscription: $times Washes (3kg)",
//                 "price": data["three"] ?? 0,
//                 "unit": "/2.75 To 3 KG",
//                 "month": data["month"] ?? 1,
//                 "times": times,
//               },
//               {
//                 "label": "Subscription: $times White Washes (3kg)",
//                 "price": data["white3"] ?? 0,
//                 "unit": "/2.75 To 3 KG",
//                 "month": data["month"] ?? 1,
//                 "times": times,
//               },
//             ]);
//           }
//         }
//
//         _isLoading = false;
//         _calculateTotal();
//         print("Finished fetching pricing data at 10:29 AM IST on June 07, 2025, _isLoading: $_isLoading");
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       print("Error fetching pricing data at 10:29 AM IST on June 07, 2025, _isLoading: $_isLoading, error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error loading prices. Please check your network connection"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   bool isItemSelected() {
//     return itemQuantities.isNotEmpty;
//   }
//
//   void _calculateTotal() {
//     double total = 0;
//     itemQuantities.forEach((key, quantity) {
//       var priceItem = additionalPrices.firstWhere(
//             (item) => item["label"] == key,
//         orElse: () => {"price": 0},
//       );
//       if (priceItem["price"] != 0) {
//         total += (priceItem["price"] * quantity);
//       } else {
//         priceItem = oneTimePrices.firstWhere(
//               (item) => item["label"] == key,
//           orElse: () => {"price": 0},
//         );
//         if (priceItem["price"] != 0) {
//           total += (priceItem["price"] * quantity);
//         } else {
//           priceItem = subscriptionPrices.firstWhere(
//                 (item) => item["label"] == key,
//             orElse: () => {"price": 0},
//           );
//           if (priceItem["price"] != 0) {
//             total += (priceItem["price"] * quantity);
//           } else {
//             priceItem = subscriptionThreePrices.firstWhere(
//                   (item) => item["label"] == key,
//               orElse: () => {"price": 0},
//             );
//             total += (priceItem["price"] * quantity);
//           }
//         }
//       }
//     });
//     setState(() => _total = total);
//   }
//
//   Future<void> _saveSelections() async {
//     try {
//       final savedCart = await CartPersistence.loadCart();
//       Map<String, Map<String, dynamic>> savedPrePlatedItems = (savedCart?['prePlatedItems'] as Map<String, dynamic>? ?? {})
//           .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
//
//       await CartPersistence.saveCart(
//         dryCleanItems: savedCart?['dryCleanItems'] ?? {},
//         ironingItems: savedCart?['ironingItems'] ?? {},
//         washAndFoldItems: itemQuantities,
//         washAndIronItems: savedCart?['washAndIronItems'] ?? {},
//         washIronStarchItems: savedCart?['washIronStarchItems'] ?? {},
//         prePlatedItems: savedPrePlatedItems,
//         additionalServices: savedCart?['additionalServices'] ?? {},
//         dryCleanTotal: savedCart?['dryCleanTotal'] ?? 0,
//         additionalTotal: savedCart?['additionalTotal'] ?? 0,
//       );
//
//       // Update total cart items for badge
//       final updatedCart = await CartPersistence.loadCart();
//       int totalItems = 0;
//       totalItems += (updatedCart?['dryCleanItems'] as Map<String, dynamic>? ?? {}).length;
//       totalItems += (updatedCart?['ironingItems'] as Map<String, dynamic>? ?? {}).length;
//       totalItems += itemQuantities.length;
//       totalItems += (updatedCart?['washAndIronItems'] as Map<String, dynamic>? ?? {}).length;
//       totalItems += (updatedCart?['washIronStarchItems'] as Map<String, dynamic>? ?? {}).length;
//       totalItems += (updatedCart?['prePlatedItems'] as Map<String, dynamic>? ?? {}).length;
//       setState(() {
//         _totalCartItems = totalItems;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error saving. Please check your network connection"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   Future<void> _saveAndNavigateToCart() async {
//     try {
//       final savedCart = await CartPersistence.loadCart() ?? {};
//
//       Map<String, int> dryCleanItems = (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).map((key, value) {
//         int quantity;
//         if (value is int) {
//           quantity = value;
//         } else if (value is double) {
//           quantity = value.toInt();
//         } else if (value is String) {
//           quantity = int.tryParse(value) ?? 0;
//         } else {
//           quantity = 0;
//         }
//         return MapEntry(key, quantity);
//       });
//
//       Map<String, int> ironingItems = (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).map((key, value) {
//         int quantity;
//         if (value is int) {
//           quantity = value;
//         } else if (value is double) {
//           quantity = value.toInt();
//         } else if (value is String) {
//           quantity = int.tryParse(value) ?? 0;
//         } else {
//           quantity = 0;
//         }
//         return MapEntry(key, quantity);
//       });
//
//       Map<String, int> washAndIronItems = (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).map((key, value) {
//         int quantity;
//         if (value is int) {
//           quantity = value;
//         } else if (value is double) {
//           quantity = value.toInt();
//         } else if (value is String) {
//           quantity = int.tryParse(value) ?? 0;
//         } else {
//           quantity = 0;
//         }
//         return MapEntry(key, quantity);
//       });
//
//       Map<String, int> washIronStarchItems = (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).map((key, value) {
//         int quantity;
//         if (value is int) {
//           quantity = value;
//         } else if (value is double) {
//           quantity = value.toInt();
//         } else if (value is String) {
//           quantity = int.tryParse(value) ?? 0;
//         } else {
//           quantity = 0;
//         }
//         return MapEntry(key, quantity);
//       });
//
//       Map<String, Map<String, dynamic>> savedPrePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {})
//           .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
//
//       Map<String, List<Map<String, dynamic>>> additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).map(
//             (key, value) => MapEntry(
//           key,
//           (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList(),
//         ),
//       );
//
//       await CartPersistence.saveCart(
//         dryCleanItems: dryCleanItems,
//         ironingItems: ironingItems,
//         washAndFoldItems: itemQuantities,
//         washAndIronItems: washAndIronItems,
//         washIronStarchItems: washIronStarchItems,
//         prePlatedItems: savedPrePlatedItems,
//         additionalServices: additionalServices,
//         dryCleanTotal: savedCart['dryCleanTotal'] as double? ?? 0,
//         additionalTotal: savedCart['additionalTotal'] as double? ?? 0,
//       );
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => CartPage(
//             dryCleanItems: dryCleanItems,
//             ironingItems: ironingItems,
//             washAndFoldItems: itemQuantities,
//             washAndIronItems: washAndIronItems,
//             washIronStarchItems: washIronStarchItems,
//             prePlatedItems: savedPrePlatedItems,
//             additionalServices: additionalServices,
//             dryCleanTotal: savedCart['dryCleanTotal'] as double? ?? 0,
//             additionalTotal: savedCart['additionalTotal'] as double? ?? 0,
//           ),
//         ),
//       ).then((_) {
//         _loadSavedCart();
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error saving cart. Please check your network connection"),
//           backgroundColor: Colors.red,
//         ),
//       );
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
//   Widget _buildSection(String title, List<Map<String, dynamic>> items, double aspectRatio) {
//     if (items.isEmpty) return const SizedBox();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
//           child: Align(
//             alignment: Alignment.centerLeft,
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//             ),
//           ),
//         ),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: items.length == 1 ? 1 : 2,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             childAspectRatio: items.length == 1 ? 3.0 : aspectRatio,
//           ),
//           itemCount: items.length,
//           itemBuilder: (context, index) {
//             final priceItem = items[index];
//             final isSelected = itemQuantities.containsKey(priceItem["label"]);
//
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   if (isSelected) {
//                     itemQuantities.remove(priceItem["label"]);
//                   } else {
//                     itemQuantities[priceItem["label"]] = 1; // Add item with quantity 1
//                   }
//                   _calculateTotal();
//                   _saveSelections(); // Save cart dynamically on selection
//                 });
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: bgColorPink.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: isSelected ? bgColorPink : Colors.transparent,
//                     width: 1,
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           priceItem["label"].split(": ")[1].replaceAll(" (3kg)", "").replaceAll(" (5kg)", ""),
//                           style: TextStyle(
//                             fontSize: title.contains("Subscription") ? 11 : 12,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[800],
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           "₹${priceItem["price"]} ${priceItem["unit"]}",
//                           style: TextStyle(
//                             fontSize: title.contains("Subscription") ? 11 : 12,
//                             fontWeight: FontWeight.bold,
//                             color: bgColorPink,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                         if (title.contains("Subscription")) ...[
//                           const SizedBox(height: 4),
//                           Text(
//                             "${priceItem["month"]} Month${priceItem["month"] != 1 ? 's' : ''} Validity",
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.black,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             "Wash for ${priceItem["times"]} Times",
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.black,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                           ),
//                         ],
//                       ],
//                     ),
//                     // Removed the "+" button, now handled by GestureDetector
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Wash & Fold",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(12),
//           ),
//         ),
//         actions: [
//           // Added cart button in AppBar
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
//               onPressed: () {
//                 _saveAndNavigateToCart();
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
//               onLoaded: (composition) {},
//               errorBuilder: (context, error, stackTrace) {
//                 return const Text(
//                   "Failed to load animation",
//                   style: TextStyle(color: Colors.red),
//                 );
//               },
//             ),
//           ],
//         ),
//       )
//           : () {
//         final allItems = [...additionalPrices, ...oneTimePrices, ...subscriptionPrices, ...subscriptionThreePrices];
//         if (allItems.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Lottie.asset(
//                   'assets/animations/empty.json',
//                   width: 200,
//                   height: 200,
//                   fit: BoxFit.contain,
//                   errorBuilder: (context, error, stackTrace) {
//                     print("Error loading empty animation at 10:29 AM IST on June 07, 2025: $error");
//                     return const Text(
//                       "Failed to load empty state animation",
//                       style: TextStyle(color: Colors.red),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   "No services available",
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 TextButton(
//                   onPressed: _fetchPricingData,
//                   child: const Text("Retry"),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
//                       child: Row(
//                         children: [
//                           Text(
//                             "Available Plans",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey[800],
//                             ),
//                           ),
//                           const Spacer(),
//                           if (isItemSelected())
//                             Text(
//                               "${itemQuantities.length} item${itemQuantities.length > 1 ? 's' : ''} selected",
//                               style: const TextStyle(
//                                 color: bgColorPink,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     _buildSection("By Weight Pricing", additionalPrices, 1.5),
//                     _buildSection("One-Time Wash", oneTimePrices, 1.5),
//                     _buildSection("Subscription Based (2.75 To 3 KG)", subscriptionThreePrices, 1.3),
//                     _buildSection("Subscription Based (5 to 5.5 KG)", subscriptionPrices, 1.3),
//                     const SizedBox(height: 16),
//                   ],
//                 ),
//               ),
//             ),
//             if (isItemSelected())
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, -5),
//                     ),
//                   ],
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                 ),
//                 child: SafeArea(
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Wash & Fold Total",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             Text(
//                               "₹${_total.toStringAsFixed(2)}",
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: bgColorPink,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: _navigateToHomePage,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: bgColorPink,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Continue",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               SizedBox(width: 8),
//                               Icon(Icons.arrow_forward, size: 20, color: Colors.white),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         );
//       }(),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:steam/constant/constant.dart';
import 'package:steam/screen/HomeScreen.dart';
import '../constant/cart_persistence.dart';
import '../screen/cart.dart';

class WashAndFoldPage extends StatefulWidget {
  const WashAndFoldPage({super.key});

  @override
  _WashAndFoldPageState createState() => _WashAndFoldPageState();
}

class _WashAndFoldPageState extends State<WashAndFoldPage> {
  // State variables
  Map<String, int> itemQuantities = {};
  bool _isLoading = true;
  double _total = 0;
  int _totalCartItems = 0;

  // Pricing data
  List<Map<String, dynamic>> additionalPrices = [];
  List<Map<String, dynamic>> oneTimePrices = [];
  List<Map<String, dynamic>> subscriptionPrices = [];
  List<Map<String, dynamic>> subscriptionThreePrices = [];

  // UI constants
  final Color primaryColor = bgColorPink;
  final double sectionSpacing = 24.0;

  @override
  void initState() {
    super.initState();
    _loadSavedCart();
  }

  Future<void> _loadSavedCart() async {
    try {
      final savedCart = await CartPersistence.loadCart();
      setState(() {
        if (savedCart != null && savedCart['washAndFoldItems'] != null) {
          final loadedItems = savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {};
          itemQuantities = loadedItems.map((key, value) {
            int quantity;
            if (value is int) {
              quantity = value;
            } else if (value is double) {
              quantity = value.toInt();
            } else if (value is String) {
              quantity = int.tryParse(value) ?? 0;
            } else {
              quantity = 0;
            }
            return MapEntry(key, quantity);
          });
        }
        if (savedCart != null) {
          int totalItems = 0;
          totalItems += (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).length;
          totalItems += (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).length;
          totalItems += itemQuantities.length;
          totalItems += (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).length;
          totalItems += (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).length;
          totalItems += (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).length;
          _totalCartItems = totalItems;
        }
      });
      _fetchPricingData();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load saved cart. Please check Internet"),
          backgroundColor: Colors.red,
        ),
      );
      _fetchPricingData();
    }
  }

  Future<void> _fetchPricingData() async {
    try {
      final futures = [
        FirebaseFirestore.instance.collection("Wash-Fold").doc("By Weight").get(),
        FirebaseFirestore.instance.collection("Wash-Fold").doc("1 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Fold").doc("7 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Fold").doc("15 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Fold").doc("30 Time").get(),
      ];

      final results = await Future.wait(futures);

      setState(() {
        additionalPrices = [];
        oneTimePrices = [];
        subscriptionPrices = [];
        subscriptionThreePrices = [];

        if (results[0].exists) {
          final data = results[0].data() as Map<String, dynamic>;
          additionalPrices.add({
            "label": "By Weight: Regular Wash",
            "price": data["price"] ?? 0,
            "unit": "/KG",
          });
        }

        if (results[1].exists) {
          final data = results[1].data() as Map<String, dynamic>;
          oneTimePrices.addAll([
            {
              "label": "One-Time: 3kg Regular Wash",
              "price": data["three"] ?? 0,
              "unit": "/2.75 To 3 KG",
            },
            {
              "label": "One-Time: 3kg White Clothes",
              "price": data["white3"] ?? 0,
              "unit": "/2.75 To 3 KG",
            },
            {
              "label": "One-Time: 5kg Regular Wash",
              "price": data["price"] ?? 0,
              "unit": "/5 to 5.5 KG",
            },
            {
              "label": "One-Time: 5kg White Clothes",
              "price": data["white"] ?? 0,
              "unit": "/5 to 5.5 KG",
            },
          ]);
        }

        for (int i = 2; i < results.length; i++) {
          if (results[i].exists) {
            final data = results[i].data() as Map<String, dynamic>;
            final times = [7, 15, 30][i - 2];

            subscriptionPrices.addAll([
              {
                "label": "Subscription: $times Washes (5kg)",
                "price": data["price"] ?? 0,
                "unit": "/5 to 5.5 KG",
                "month": data["month"] ?? 1,
                "times": times,
              },
              {
                "label": "Subscription: $times White Washes (5kg)",
                "price": data["white"] ?? 0,
                "unit": "/5 to 5.5 KG",
                "month": data["month"] ?? 1,
                "times": times,
              },
            ]);

            subscriptionThreePrices.addAll([
              {
                "label": "Subscription: $times Washes (3kg)",
                "price": data["three"] ?? 0,
                "unit": "/2.75 To 3 KG",
                "month": data["month"] ?? 1,
                "times": times,
              },
              {
                "label": "Subscription: $times White Washes (3kg)",
                "price": data["white3"] ?? 0,
                "unit": "/2.75 To 3 KG",
                "month": data["month"] ?? 1,
                "times": times,
              },
            ]);
          }
        }

        _isLoading = false;
        _calculateTotal();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error loading prices. Please check your network connection"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool isItemSelected() {
    return itemQuantities.isNotEmpty;
  }

  void _calculateTotal() {
    double total = 0;
    itemQuantities.forEach((key, quantity) {
      var priceItem = additionalPrices.firstWhere(
            (item) => item["label"] == key,
        orElse: () => {"price": 0},
      );
      if (priceItem["price"] != 0) {
        total += (priceItem["price"] * quantity);
      } else {
        priceItem = oneTimePrices.firstWhere(
              (item) => item["label"] == key,
          orElse: () => {"price": 0},
        );
        if (priceItem["price"] != 0) {
          total += (priceItem["price"] * quantity);
        } else {
          priceItem = subscriptionPrices.firstWhere(
                (item) => item["label"] == key,
            orElse: () => {"price": 0},
          );
          if (priceItem["price"] != 0) {
            total += (priceItem["price"] * quantity);
          } else {
            priceItem = subscriptionThreePrices.firstWhere(
                  (item) => item["label"] == key,
              orElse: () => {"price": 0},
            );
            total += (priceItem["price"] * quantity);
          }
        }
      }
    });
    setState(() => _total = total);
  }

  Future<void> _saveSelections() async {
    try {
      final savedCart = await CartPersistence.loadCart();
      Map<String, Map<String, dynamic>> savedPrePlatedItems = (savedCart?['prePlatedItems'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));

      await CartPersistence.saveCart(
        dryCleanItems: savedCart?['dryCleanItems'] ?? {},
        ironingItems: savedCart?['ironingItems'] ?? {},
        washAndFoldItems: itemQuantities,
        washAndIronItems: savedCart?['washAndIronItems'] ?? {},
        washIronStarchItems: savedCart?['washIronStarchItems'] ?? {},
        prePlatedItems: savedPrePlatedItems,
        additionalServices: savedCart?['additionalServices'] ?? {},
        dryCleanTotal: savedCart?['dryCleanTotal'] ?? 0,
        additionalTotal: savedCart?['additionalTotal'] ?? 0,
      );

      final updatedCart = await CartPersistence.loadCart();
      int totalItems = 0;
      totalItems += (updatedCart?['dryCleanItems'] as Map<String, dynamic>? ?? {}).length;
      totalItems += (updatedCart?['ironingItems'] as Map<String, dynamic>? ?? {}).length;
      totalItems += itemQuantities.length;
      totalItems += (updatedCart?['washAndIronItems'] as Map<String, dynamic>? ?? {}).length;
      totalItems += (updatedCart?['washIronStarchItems'] as Map<String, dynamic>? ?? {}).length;
      totalItems += (updatedCart?['prePlatedItems'] as Map<String, dynamic>? ?? {}).length;
      setState(() {
        _totalCartItems = totalItems;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error saving. Please check your network connection"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveAndNavigateToCart() async {
    try {
      final savedCart = await CartPersistence.loadCart() ?? {};

      Map<String, int> dryCleanItems = (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).map((key, value) {
        int quantity;
        if (value is int) {
          quantity = value;
        } else if (value is double) {
          quantity = value.toInt();
        } else if (value is String) {
          quantity = int.tryParse(value) ?? 0;
        } else {
          quantity = 0;
        }
        return MapEntry(key, quantity);
      });

      Map<String, int> ironingItems = (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).map((key, value) {
        int quantity;
        if (value is int) {
          quantity = value;
        } else if (value is double) {
          quantity = value.toInt();
        } else if (value is String) {
          quantity = int.tryParse(value) ?? 0;
        } else {
          quantity = 0;
        }
        return MapEntry(key, quantity);
      });

      Map<String, int> washAndIronItems = (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).map((key, value) {
        int quantity;
        if (value is int) {
          quantity = value;
        } else if (value is double) {
          quantity = value.toInt();
        } else if (value is String) {
          quantity = int.tryParse(value) ?? 0;
        } else {
          quantity = 0;
        }
        return MapEntry(key, quantity);
      });

      Map<String, int> washIronStarchItems = (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).map((key, value) {
        int quantity;
        if (value is int) {
          quantity = value;
        } else if (value is double) {
          quantity = value.toInt();
        } else if (value is String) {
          quantity = int.tryParse(value) ?? 0;
        } else {
          quantity = 0;
        }
        return MapEntry(key, quantity);
      });

      Map<String, Map<String, dynamic>> savedPrePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));

      Map<String, List<Map<String, dynamic>>> additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).map(
            (key, value) => MapEntry(
          key,
          (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList(),
        ),
      );

      await CartPersistence.saveCart(
        dryCleanItems: dryCleanItems,
        ironingItems: ironingItems,
        washAndFoldItems: itemQuantities,
        washAndIronItems: washAndIronItems,
        washIronStarchItems: washIronStarchItems,
        prePlatedItems: savedPrePlatedItems,
        additionalServices: additionalServices,
        dryCleanTotal: savedCart['dryCleanTotal'] as double? ?? 0,
        additionalTotal: savedCart['additionalTotal'] as double? ?? 0,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CartPage(
            dryCleanItems: dryCleanItems,
            ironingItems: ironingItems,
            washAndFoldItems: itemQuantities,
            washAndIronItems: washAndIronItems,
            washIronStarchItems: washIronStarchItems,
            prePlatedItems: savedPrePlatedItems,
            additionalServices: additionalServices,
            dryCleanTotal: savedCart['dryCleanTotal'] as double? ?? 0,
            additionalTotal: savedCart['additionalTotal'] as double? ?? 0,
          ),
        ),
      ).then((_) {
        _loadSavedCart();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error saving cart. Please check your network connection"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  // --- Mobile-specific UI Build Method ---
  Widget _buildSection(String title, List<Map<String, dynamic>> items, double aspectRatio) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: MediaQuery.of(context).size.width > 1200 ? 300 : 250,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final priceItem = items[index];
            final isSelected = itemQuantities.containsKey(priceItem["label"]);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    itemQuantities.remove(priceItem["label"]);
                  } else {
                    itemQuantities[priceItem["label"]] = 1;
                  }
                  _calculateTotal();
                  _saveSelections();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColorPink.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? bgColorPink : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          priceItem["label"].split(": ")[1].replaceAll(" (3kg)", "").replaceAll(" (5kg)", ""),
                          style: TextStyle(
                            fontSize: title.contains("Subscription") ? 11 : 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${priceItem["price"]} ${priceItem["unit"]}",
                          style: TextStyle(
                            fontSize: title.contains("Subscription") ? 11 : 12,
                            fontWeight: FontWeight.bold,
                            color: bgColorPink,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        if (title.contains("Subscription")) ...[
                          const SizedBox(height: 4),
                          Text(
                            "${priceItem["month"]} Month${priceItem["month"] != 1 ? 's' : ''} Validity",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Wash for ${priceItem["times"]} Times",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- Web-specific UI Build Methods ---

  Widget _buildWebLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F7),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text("Wash & Fold", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: IconButton(
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
                        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                        child: Center(
                          child: Text(
                            '$_totalCartItems',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: _saveAndNavigateToCart,
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
              Expanded(flex: 3, child: _buildWebServiceList()),
              if (isItemSelected()) Expanded(flex: 2, child: _buildWebFooter()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebServiceList() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                const Text("Available Plans", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (isItemSelected())
                  Text(
                    "${itemQuantities.length} plan selected",
                    style: const TextStyle(color: bgColorPink, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          _buildWebSection("By Weight Pricing", additionalPrices),
          _buildWebSection("One-Time Wash", oneTimePrices),
          _buildWebSection("Subscription Based (2.75 To 3 KG)", subscriptionThreePrices),
          _buildWebSection("Subscription Based (5 to 5.5 KG)", subscriptionPrices),
          SizedBox(height: sectionSpacing),
        ],
      ),
    );
  }

  Widget _buildWebSection(String title, List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: MediaQuery.of(context).size.width > 1200 ? 300 : 250,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final priceItem = items[index];
            final isSelected = itemQuantities.containsKey(priceItem["label"]);
            final isSubscription = (priceItem["label"] as String).contains("Subscription");

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    itemQuantities.remove(priceItem["label"]);
                  } else {
                    itemQuantities[priceItem["label"]] = 1;
                  }
                  _calculateTotal();
                  _saveSelections();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor.withOpacity(0.2) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300, width: 1.5),
                  boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 8)] : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      priceItem["label"].split(": ")[1].replaceAll(" (3kg)", "").replaceAll(" (5kg)", ""),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      "₹${priceItem["price"]} ${priceItem["unit"]}",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: bgColorPink),
                    ),
                    if (isSubscription) ...[
                      const SizedBox(height: 4),
                      Text(
                        "${priceItem["month"]} Month${priceItem["month"] != 1 ? 's' : ''} | ${priceItem["times"]} Washes",
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWebFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            const Text("Wash & Fold Total", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 4),
            Text("₹${_total.toStringAsFixed(2)}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _navigateToHomePage,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
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
    final isWeb = MediaQuery.of(context).size.width > 800;
    final allItems = [...additionalPrices, ...oneTimePrices, ...subscriptionPrices, ...subscriptionThreePrices];

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
                errorBuilder: (context, error, stackTrace) {
                  return const Text("Failed to load animation", style: TextStyle(color: Colors.red));
                },
              ),
            ],
          ),
        ),
      );
    }

    if (allItems.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/empty.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text("Failed to load empty state animation", style: TextStyle(color: Colors.red));
                },
              ),
              const SizedBox(height: 16),
              Text("No services available", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
              const SizedBox(height: 8),
              TextButton(onPressed: _fetchPricingData, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    if (isWeb) {
      return _buildWebLayout();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Wash & Fold",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, size: 28),
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
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Center(
                            child: Text(
                              '$_totalCartItems',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: _saveAndNavigateToCart,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Row(
                        children: [
                          Text("Available Plans", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                          const Spacer(),
                          if (isItemSelected())
                            Text("${itemQuantities.length} item${itemQuantities.length > 1 ? 's' : ''} selected", style: const TextStyle(color: bgColorPink, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    _buildSection("By Weight Pricing", additionalPrices, 1.5),
                    _buildSection("One-Time Wash", oneTimePrices, 1.5),
                    _buildSection("Subscription Based (2.75 To 3 KG)", subscriptionThreePrices, 1.3),
                    _buildSection("Subscription Based (5 to 5.5 KG)", subscriptionPrices, 1.3),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (isItemSelected())
              Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Wash & Fold Total", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                            Text("₹${_total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: bgColorPink)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _navigateToHomePage,
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
              ),
          ],
        ),
      );
    }
  }
}
