// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lottie/lottie.dart';
// import 'package:steam/screen/HomeScreen.dart';
// import '../constant/cart_persistence.dart';
// import '../constant/constant.dart' as constants;
// import '../screen/order_confirmation_page.dart';
// import '../constant/address_persistence.dart';
// import 'AddressPage.dart';
//
// class CartPage extends StatefulWidget {
//   final Map<String, int> dryCleanItems;
//   final Map<String, int> ironingItems;
//   final Map<String, int> washAndFoldItems;
//   final Map<String, int> washAndIronItems;
//   final Map<String, int> washIronStarchItems;
//   final Map<String, Map<String, dynamic>> prePlatedItems;
//   final Map<String, List<Map<String, dynamic>>> additionalServices;
//   final double dryCleanTotal;
//   final double additionalTotal;
//
//   const CartPage({
//     required this.dryCleanItems,
//     required this.ironingItems,
//     required this.washAndFoldItems,
//     required this.washAndIronItems,
//     required this.washIronStarchItems,
//     required this.prePlatedItems,
//     required this.additionalServices,
//     required this.dryCleanTotal,
//     required this.additionalTotal,
//     super.key,
//   });
//
//   @override
//   _CartPageState createState() => _CartPageState();
// }
//
// class _CartPageState extends State<CartPage> {
//   Map<String, int> _dryCleanQuantities = {};
//   Map<String, int> _ironingQuantities = {};
//   Map<String, int> _washAndFoldQuantities = {};
//   Map<String, int> _washAndIronQuantities = {};
//   Map<String, int> _washIronStarchQuantities = {};
//   Map<String, Map<String, dynamic>> _prePlatedQuantities = {};
//   Map<String, List<Map<String, dynamic>>> _additionalServices = {};
//   List<Map<String, dynamic>> _dryCleanPrices = [];
//   List<Map<String, dynamic>> _ironingPrices = [];
//   List<Map<String, dynamic>> _washAndFoldPrices = [];
//   List<Map<String, dynamic>> _washAndIronPrices = [];
//   List<Map<String, dynamic>> _washIronStarchPrices = [];
//   bool _isInitialLoading = true;
//   bool _isOrderLoading = false;
//   double _dryCleanTotal = 0;
//   double _ironingTotal = 0;
//   double _washAndFoldTotal = 0;
//   double _washAndIronTotal = 0;
//   double _washIronStarchTotal = 0;
//   double _prePlatedTotal = 0;
//   double _additionalTotal = 0;
//   double _regularWashPrice = 0;
//
//   Map<String, dynamic>? _currentAddress;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCart();
//   }
//
//   Future<void> _initializeCart() async {
//     try {
//       // ### START: LOAD ADDRESS ON INIT ###
//       await _loadCurrentAddress();
//       // ### END: LOAD ADDRESS ON INIT ###
//
//       final savedCart = await CartPersistence.loadCart();
//       setState(() {
//         if (savedCart != null) {
//           _dryCleanQuantities = (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key.replaceAll('/', '-'), value is int ? value : int.tryParse(value.toString()) ?? 0));
//           _ironingQuantities = (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key.replaceAll('/', '-'), value is int ? value : int.tryParse(value.toString()) ?? 0));
//           _washAndFoldQuantities = (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//           _washAndIronQuantities = (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//           _washIronStarchQuantities = (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//           _prePlatedQuantities = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
//           _additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList()));
//           _dryCleanTotal = (savedCart['dryCleanTotal'] as num?)?.toDouble() ?? 0.0;
//           _additionalTotal = (savedCart['additionalTotal'] as num?)?.toDouble() ?? 0.0;
//         }
//       });
//
//       QuerySnapshot dryCleanSnapshot = await FirebaseFirestore.instance.collection("Dry Clean").get();
//       QuerySnapshot ironingSnapshot = await FirebaseFirestore.instance.collection("Iron").get();
//
//       final washFoldFutures = [
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("By Weight").get(),
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("1 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("7 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("15 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Fold").doc("30 Time").get(),
//       ];
//       final washIronFutures = [
//         FirebaseFirestore.instance.collection("Wash-Iron").doc("By Weight").get(),
//         FirebaseFirestore.instance.collection("Wash-Iron").doc("1 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Iron").doc("7 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Iron").doc("15 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Iron").doc("30 Time").get(),
//       ];
//       final washStarchFutures = [
//         FirebaseFirestore.instance.collection("Wash-Starch").doc("By Weight").get(),
//         FirebaseFirestore.instance.collection("Wash-Starch").doc("1 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Starch").doc("7 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Starch").doc("15 Time").get(),
//         FirebaseFirestore.instance.collection("Wash-Starch").doc("30 Time").get(),
//       ];
//
//       final washFoldResults = await Future.wait(washFoldFutures);
//       final washIronResults = await Future.wait(washIronFutures);
//       final washStarchResults = await Future.wait(washStarchFutures);
//
//       setState(() {
//         _dryCleanPrices = dryCleanSnapshot.docs.map((doc) {
//           var data = doc.data() as Map<String, dynamic>;
//           return {"name": doc.id.replaceAll('/', '-'), "dry_clean": (data["dry_clean"] as num?)?.toDouble() ?? 0.0, "image": data["image"] ?? ""};
//         }).toList();
//         _ironingPrices = ironingSnapshot.docs.map((doc) {
//           var data = doc.data() as Map<String, dynamic>;
//           return {"name": doc.id.replaceAll('/', '-'), "price": (data["price"] as num?)?.toDouble() ?? 0.0, "image": data["image"] ?? ""};
//         }).toList();
//
//         // ... (Rest of price list processing remains the same)
//         _washAndFoldPrices = [];
//         if (washFoldResults.isNotEmpty && washFoldResults[0].exists) {
//           final data = washFoldResults[0].data() as Map<String, dynamic>? ?? {};
//           _washAndFoldPrices.add({"label": "By Weight: Regular Wash", "price": (data["price"] as num?)?.toDouble() ?? 0.0, "unit": "/KG"});
//           _regularWashPrice = (data["price"] as num?)?.toDouble() ?? 0.0;
//           _washAndFoldPrices.add({"label": "Premium Laundry", "price": (data["premium_price"] as num?)?.toDouble() ?? 159.0, "unit": "/KG"});
//         }
//         if (washFoldResults.length > 1 && washFoldResults[1].exists) {
//           final data = washFoldResults[1].data() as Map<String, dynamic>? ?? {};
//           _washAndFoldPrices.addAll([
//             {"label": "One-Time: 3kg Regular Wash", "price": (data["three"] as num?)?.toDouble() ?? 0.0, "unit": "/2.75 To 3 KG"},
//             {"label": "One-Time: 3kg White Clothes", "price": (data["white3"] as num?)?.toDouble() ?? 0.0, "unit": "/2.75 To 3 KG"},
//             {"label": "One-Time: 5kg Regular Wash", "price": (data["price"] as num?)?.toDouble() ?? 0.0, "unit": "/5 To 5.5 KG"},
//             {"label": "One-Time: 5kg White Clothes", "price": (data["white"] as num?)?.toDouble() ?? 0.0, "unit": "/5 To 5.5 KG"},
//           ]);
//         }
//         final subscriptionTimes = {2: 7, 3: 15, 4: 30};
//         for (int i = 2; i < washFoldResults.length; i++) {
//           if (washFoldResults[i].exists) {
//             final data = washFoldResults[i].data() as Map<String, dynamic>? ?? {};
//             final times = subscriptionTimes[i] ?? 0;
//             if (times > 0) {
//               _washAndFoldPrices.addAll([
//                 {"label": "Subscription: $times Washes (5kg)", "price": (data["price"] as num?)?.toDouble() ?? 0.0, "unit": "/5 To 5.5 KG", "month": data["month"] ?? 1, "times": times},
//                 {"label": "Subscription: $times White Washes (5kg)", "price": (data["white"] as num?)?.toDouble() ?? 0.0, "unit": "/5 To 5.5 KG", "month": data["month"] ?? 1, "times": times},
//                 {"label": "Subscription: $times Washes (3kg)", "price": (data["three"] as num?)?.toDouble() ?? 0.0, "unit": "/2.75 To 3 KG", "month": data["month"] ?? 1, "times": times},
//                 {"label": "Subscription: $times White Washes (3kg)", "price": (data["white3"] as num?)?.toDouble() ?? 0.0, "unit": "/2.75 To 3 KG", "month": data["month"] ?? 1, "times": times},
//               ]);
//             }
//           }
//         }
//         _washAndIronPrices = [];
//         if (washIronResults.isNotEmpty && washIronResults[0].exists) {
//           final data = washIronResults[0].data() as Map<String, dynamic>? ?? {};
//           _washAndIronPrices.add({"label": "By Weight: Regular Wash", "price": (data["price"] as num?)?.toDouble() ?? 0.0, "unit": "/KG"});
//           if (_regularWashPrice == 0) _regularWashPrice = (data["price"] as num?)?.toDouble() ?? 0.0;
//           _washAndIronPrices.add({"label": "Premium Laundry", "price": (data["premium_price"] as num?)?.toDouble() ?? 159.0, "unit": "/KG"});
//         }
//         if (washIronResults.length > 1 && washIronResults[1].exists) {
//           final data = washIronResults[1].data() as Map<String, dynamic>? ?? {};
//           _washAndIronPrices.addAll([
//             {"label": "One-Time: 3kg Regular Wash", "price": (data["three"] as num?)?.toDouble() ?? 0.0, "unit": "/2.75 To 3 KG"},
//             {"label": "One-Time: 3kg White Clothes", "price": (data["white3"] as num?)?.toDouble() ?? 0.0, "unit": "/2.75 To 3 KG"},
//             {"label": "One-Time: 5kg Regular Wash", "price": (data["price"] as num?)?.toDouble() ?? 0.0, "unit": "/5 To 5.5 KG"},
//             {"label": "One-Time: 5kg White Clothes", "price": (data["white"] as num?)?.toDouble() ?? 0.0, "unit": "/5 To 5.5 KG"},
//           ]);
//         }
//         for (int i = 2; i < washIronResults.length; i++) {
//           if (washIronResults[i].exists) {
//             final data = washIronResults[i].data() as Map<String, dynamic>? ?? {};
//             final times = subscriptionTimes[i] ?? 0;
//             if (times > 0) {
//               _washAndIronPrices.addAll([
//                 {"label": "Subscription: $times Washes (5kg)", "price": (data["price"] as num?)?.toDouble() ?? 0.0, "unit": "/5 To 5.5 KG", "month": data["month"] ?? 1, "times": times},
//                 {"label": "Subscription: $times White Washes (5kg)", "price": (data["white"] as num?)?.toDouble() ?? 0.0, "unit": "/5 To 5.5 KG", "month": data["month"] ?? 1, "times": times},
//                 {"label": "Subscription: $times Washes (3kg)", "price": (data["three"] as num?)?.toDouble() ?? 0.0, "unit": "/2.75 To 3 KG", "month": data["month"] ?? 1, "times": times},
//                 {"label": "Subscription: $times White Washes (3kg)", "price": (data["white3"] as num?)?.toDouble() ?? 0.0, "unit": "/2.75 To 3 KG", "month": data["month"] ?? 1, "times": times},
//               ]);
//             }
//           }
//         }
//         _washIronStarchPrices = [];
//         if (washStarchResults.isNotEmpty && washStarchResults[0].exists) {
//           final data = washStarchResults[0].data() as Map<String, dynamic>? ?? {};
//           _washIronStarchPrices.add({"label": "By Weight: Regular Wash", "price": (data["price"] as num?)?.toDouble() ?? 0.0, "unit": "/KG"});
//           if (_regularWashPrice == 0) _regularWashPrice = (data["price"] as num?)?.toDouble() ?? 0.0;
//         }
//         if (washStarchResults.length > 1 && washStarchResults[1].exists) {
//           final data = washStarchResults[1].data() as Map<String, dynamic>? ?? {};
//           _washIronStarchPrices.addAll([
//             {"label": "One-Time: 3kg Regular Wash", "price": (data["three"] as num?)?.toDouble() ?? 0.0, "unit": "/2.75 To 3 KG"},
//             {"label": "One-Time: 3kg White Clothes", "price": (data["white3"] as num?)?.toDouble() ?? 0.0, "unit": "/2.75 To 3 KG"},
//             {"label": "One-Time: 5kg Regular Wash", "price": (data["price"] as num?)?.toDouble() ?? 0.0, "unit": "/5 To 5.5 KG"},
//             {"label": "One-Time: 5kg White Clothes", "price": (data["white"] as num?)?.toDouble() ?? 0.0, "unit": "/5 To 5.5 KG"},
//           ]);
//         }
//         for (int i = 2; i < washStarchResults.length; i++) {
//           if (washStarchResults[i].exists) {
//             final data = washStarchResults[i].data() as Map<String, dynamic>? ?? {};
//             final times = subscriptionTimes[i] ?? 0;
//             if (times > 0) {
//               _washIronStarchPrices.addAll([
//                 {"label": "Subscription: $times Washes (5kg)", "price": (data["price"] as num?)?.toDouble() ?? 0.0, "unit": "/5 To 5.5 KG", "month": data["month"] ?? 1, "times": times},
//                 {"label": "Subscription: $times White (5kg)", "price": (data["white"] as num?)?.toDouble() ?? 0.0, "unit": "/5 To 5.5 KG", "month": data["month"] ?? 1, "times": times},
//                 {"label": "Subscription: $times Washes (3kg)", "price": (data["three"] as num?)?.toDouble() ?? 0.0, "unit": "/2.75 To 3 KG", "month": data["month"] ?? 1, "times": times},
//                 {"label": "Subscription: $times White (3kg)", "price": (data["white3"] as num?)?.toDouble() ?? 0.0, "unit": "/2.75 To 3 KG", "month": data["month"] ?? 1, "times": times},
//               ]);
//             }
//           }
//         }
//         _ironingTotal = _calculateIroningTotal();
//         _washAndFoldTotal = _calculateWashAndFoldTotal();
//         _washAndIronTotal = _calculateWashAndIronTotal();
//         _washIronStarchTotal = _calculateWashIronStarchTotal();
//         _prePlatedTotal = _calculatePrePlatedTotal();
//         _isInitialLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isInitialLoading = false);
//       _showSnackBar("Error initializing cart: $e", isError: true);
//     }
//   }
//
//   // ### START: NEW ADDRESS HANDLING FUNCTIONS (COPIED FROM HOMEPAGE) ###
//   Future<void> _loadCurrentAddress() async {
//     try {
//       final savedAddress = await AddressPersistence.loadCurrentAddress();
//       setState(() {
//         _currentAddress = savedAddress;
//       });
//     } catch (e) {
//       _showSnackBar("Failed to load address: ${e.toString()}", isError: true);
//       setState(() {
//         _currentAddress = null;
//       });
//     }
//   }
//
//   Future<void> _handleDeleteAddress(Map<String, dynamic> addressToDelete) async {
//     final bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Address'),
//         content: const Text('Are you sure you want to delete this address?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm == true) {
//       await AddressPersistence.deleteAddress(addressToDelete);
//       await _loadCurrentAddress();
//
//       if (mounted) {
//         Navigator.pop(context);
//         _showAddressSelectionSheet();
//       }
//     }
//   }
//
//   Future<void> _showAddressSelectionSheet() async {
//     final List<Map<String, dynamic>> savedAddresses = await AddressPersistence.loadAllAddresses();
//     final Map<String, dynamic>? currentAddress = await AddressPersistence.loadCurrentAddress();
//     if (!mounted) return;
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       isDismissible: false,
//       enableDrag: false,
//       builder: (BuildContext context) {
//         final screenWidth = MediaQuery.of(context).size.width;
//         final screenHeight = MediaQuery.of(context).size.height;
//         return Container(
//           padding: EdgeInsets.only(top: screenHeight * 0.025, left: screenWidth * 0.05, right: screenWidth * 0.05, bottom: screenHeight * 0.025 + MediaQuery.of(context).viewPadding.bottom),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Select Pickup Address", style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold)),
//               SizedBox(height: screenHeight * 0.018),
//               if (savedAddresses.isEmpty)
//                 Center(child: Padding(padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025), child: const Text("No saved addresses found.")))
//               else
//                 Flexible(
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: savedAddresses.length,
//                     itemBuilder: (context, index) {
//                       final address = savedAddresses[index];
//                       final label = address['label'] ?? 'Address';
//                       final street = address['street'] ?? '';
//                       final door = address['doorNumber'] ?? '';
//                       final bool isSelected = currentAddress != null && currentAddress['label'] == address['label'] && currentAddress['street'] == address['street'];
//                       return Card(
//                         margin: EdgeInsets.symmetric(vertical: screenHeight * 0.006),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? constants.bgColorPink : Colors.transparent, width: 1.5)),
//                         child: ListTile(
//                           leading: const Icon(Icons.location_on_outlined, color: constants.bgColorPink),
//                           title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//                           subtitle: Text("$door, $street"),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               if (isSelected)
//                                 const Icon(Icons.check_circle, color: constants.bgColorPink),
//                               IconButton(
//                                 icon: Icon(Icons.close, color: Colors.grey[400]),
//                                 onPressed: () => _handleDeleteAddress(address),
//                                 tooltip: 'Delete Address',
//                               ),
//                             ],
//                           ),
//                           onTap: () async {
//                             await AddressPersistence.saveCurrentAddress(address);
//                             await _loadCurrentAddress();
//                             Navigator.pop(context);
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               SizedBox(height: screenHeight * 0.018),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
//                   label: const Text("Add New Address", style: TextStyle(color: Colors.white)),
//                   onPressed: () async {
//                     Navigator.pop(context);
//                     await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressPage()));
//                     _showAddressSelectionSheet();
//                   },
//                   style: ElevatedButton.styleFrom(backgroundColor: constants.bgColorPink, padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025))),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//   // ### END: NEW ADDRESS HANDLING FUNCTIONS ###
//
//   // ... (All other cart logic and build methods remain the same)
//   void _showSnackBar(String message, {bool isError = false}) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
//       );
//     }
//   }
//
//   Map<String, int> _transformSubscriptionKeys(Map<String, int> quantities, List<Map<String, dynamic>> prices) {
//     final transformed = <String, int>{};
//     for (var entry in quantities.entries) {
//       final originalKey = entry.key;
//       final quantity = entry.value;
//       final priceItem = prices.firstWhere((item) => item["label"]?.contains(originalKey) ?? false, orElse: () => {"label": originalKey, "price": 0.0});
//       final newKey = priceItem["label"] ?? originalKey;
//       transformed[newKey] = quantity;
//     }
//     return transformed;
//   }
//
//   double _calculateDryCleanTotal() {
//     double total = 0.0;
//     _dryCleanQuantities.forEach((name, quantity) {
//       var item = _dryCleanPrices.firstWhere((item) => item["name"] == name, orElse: () => {"dry_clean": 0.0});
//       total += (item["dry_clean"] as double) * quantity;
//     });
//     return total;
//   }
//
//   double _calculateIroningTotal() {
//     double total = 0.0;
//     _ironingQuantities.forEach((name, quantity) {
//       var item = _ironingPrices.firstWhere((item) => item["name"] == name, orElse: () => {"price": 0.0});
//       total += (item["price"] as double) * quantity;
//     });
//     return total;
//   }
//
//   double _calculateWashAndFoldTotal() {
//     double total = 0.0;
//     _washAndFoldQuantities.forEach((label, quantity) {
//       if (!label.contains("By Weight: Regular Wash")) {
//         var item = _washAndFoldPrices.firstWhere((item) => item["label"] == label, orElse: () => {"price": 0.0});
//         total += (item["price"] as double) * quantity;
//       }
//     });
//     return total;
//   }
//
//   double _calculateWashAndIronTotal() {
//     double total = 0.0;
//     _washAndIronQuantities.forEach((label, quantity) {
//       if (!label.contains("By Weight: Regular Wash")) {
//         var item = _washAndIronPrices.firstWhere((item) => item["label"] == label, orElse: () => {"price": 0.0});
//         total += (item["price"] as double) * quantity;
//       }
//     });
//     return total;
//   }
//
//   double _calculateWashIronStarchTotal() {
//     double total = 0.0;
//     _washIronStarchQuantities.forEach((label, quantity) {
//       if (!label.contains("By Weight: Regular Wash")) {
//         var item = _washIronStarchPrices.firstWhere((item) => item["label"] == label, orElse: () => {"price": 0.0});
//         total += (item["price"] as double) * quantity;
//       }
//     });
//     return total;
//   }
//
//   double _calculatePrePlatedTotal() {
//     double total = 0.0;
//     _prePlatedQuantities.forEach((name, item) {
//       final quantity = item["quantity"] as int? ?? 0;
//       final pricePerItem = (item["pricePerItem"] as num?)?.toDouble() ?? 0.0;
//       total += pricePerItem * quantity;
//     });
//     return total;
//   }
//
//   double _calculateAdditionalTotal() {
//     double total = 0.0;
//     _additionalServices.forEach((category, items) {
//       for (var item in items) {
//         total += ((item["price"] as num?)?.toDouble() ?? 0.0) * (item["quantity"] ?? 0);
//       }
//     });
//     return total;
//   }
//
//   Future<void> _navigateToCheckout() async {
//     try {
//       final savedAddress = await AddressPersistence.loadCurrentAddress();
//       if (savedAddress == null) {
//         _showSnackBar("Please select a pickup address first.", isError: true);
//         _showAddressSelectionSheet(); // Prompt user to select an address
//         return;
//       }
//
//       await CartPersistence.updateCart(
//         dryCleanItems: _dryCleanQuantities,
//         ironingItems: _ironingQuantities,
//         washAndFoldItems: _washAndFoldQuantities,
//         washAndIronItems: _washAndIronQuantities,
//         washIronStarchItems: _washIronStarchQuantities,
//         prePlatedItems: _prePlatedQuantities,
//         additionalServices: _additionalServices,
//         dryCleanTotal: _dryCleanTotal,
//         additionalTotal: _additionalTotal,
//       );
//
//       final orderId = await CartPersistence.saveOrder(
//         dryCleanItems: _dryCleanQuantities,
//         ironingItems: _ironingQuantities,
//         washAndFoldItems: _washAndFoldQuantities,
//         washAndIronItems: _washAndIronQuantities,
//         washIronStarchItems: _washIronStarchQuantities,
//         prePlatedItems: _prePlatedQuantities,
//         additionalServices: _additionalServices,
//         dryCleanTotal: _dryCleanTotal,
//         additionalTotal: _additionalTotal,
//       );
//
//       await CartPersistence.clearCart();
//
//       setState(() {
//         _dryCleanQuantities.clear();
//         _ironingQuantities.clear();
//         _washAndFoldQuantities.clear();
//         _washAndIronQuantities.clear();
//         _washIronStarchQuantities.clear();
//         _prePlatedQuantities.clear();
//         _additionalServices.clear();
//       });
//
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderConfirmationPage(orderId: orderId)));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to place order: $e"), backgroundColor: Colors.red));
//     } finally {
//       setState(() => _isOrderLoading = false);
//     }
//   }
//
//   void _navigateToHome() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => const HomePage()),
//           (route) => false,
//     );
//   }
//
//   void _clearCart() async {
//     try {
//       await CartPersistence.clearCart();
//       _initializeCart();
//       _showSnackBar("Cart cleared", isError: false);
//       _navigateToHome();
//     } catch (e) {
//       _showSnackBar("Error clearing cart: $e", isError: true);
//     }
//   }
//
//   Future<void> _updateRemainingWashes(String label, String category, int change) async {
//     try {
//       final userId = FirebaseAuth.instance.currentUser?.uid;
//       if (userId == null) return;
//       final snapshot = await FirebaseFirestore.instance.collection('subscriptions').where('userId', isEqualTo: userId).where('label', isEqualTo: label).where('category', isEqualTo: category).where('status', isEqualTo: 'Active').limit(1).get();
//       if (snapshot.docs.isNotEmpty) {
//         final doc = snapshot.docs.first;
//         final currentRemaining = (doc['remainingWashes'] as int?) ?? 0;
//         if (currentRemaining + change >= 0) {
//           await doc.reference.update({'remainingWashes': FieldValue.increment(change)});
//         } else {
//           _showSnackBar("No remaining washes available", isError: true);
//         }
//       }
//     } catch (e) {
//       _showSnackBar("Error updating remaining washes: $e", isError: true);
//     }
//   }
//
//   bool _isOnlyRegularWash() {
//     bool hasRegularWash = _washAndFoldQuantities.containsKey("By Weight: Regular Wash") || _washAndIronQuantities.containsKey("By Weight: Regular Wash") || _washIronStarchQuantities.containsKey("By Weight: Regular Wash");
//     bool hasOtherItems = _dryCleanQuantities.isNotEmpty || _ironingQuantities.isNotEmpty || _prePlatedQuantities.isNotEmpty || _additionalServices.isNotEmpty || _washAndFoldQuantities.keys.any((key) => key != "By Weight: Regular Wash") || _washAndIronQuantities.keys.any((key) => key != "By Weight: Regular Wash") || _washIronStarchQuantities.keys.any((key) => key != "By Weight: Regular Wash");
//     return hasRegularWash && !hasOtherItems;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isInitialLoading) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Lottie.asset('assets/animations/loading.json', width: 200, height: 200, fit: BoxFit.contain),
//               const SizedBox(height: 20),
//               Text("Loading Your Cart", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800])),
//               const SizedBox(height: 8),
//               Text("Please wait while we prepare your items", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//             ],
//           ),
//         ),
//       );
//     }
//
//     if (_isOrderLoading) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Lottie.asset('assets/animations/ordering.json', width: 200, height: 200, fit: BoxFit.contain),
//               const SizedBox(height: 20),
//               Text("Sending your clothes to the queue...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800])),
//               const SizedBox(height: 8),
//               Text("Please wait while we process your order", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//             ],
//           ),
//         ),
//       );
//     }
//
//     final total = _dryCleanTotal + _ironingTotal + _washAndFoldTotal + _washAndIronTotal + _washIronStarchTotal + _prePlatedTotal + _additionalTotal;
//     final showPlaceOrderButton = total > 0 || _isOnlyRegularWash();
//
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         // ### START: MODIFIED APPBAR ###
//         title: const Text(''), // Title is empty to make space
//         centerTitle: false, // Align title to the left
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           // Address Chip
//           InkWell(
//             onTap: _showAddressSelectionSheet,
//             borderRadius: BorderRadius.circular(20),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.location_on, color: Colors.white, size: 18),
//                   const SizedBox(width: 8),
//                   Flexible(
//                     child: Text(
//                       _currentAddress != null ? (_currentAddress!['label'] as String? ?? 'Select Address') : 'Select Address',
//                       style: const TextStyle(color: Colors.white, fontSize: 14),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(width: 4),
//           // Clear Cart Button
//           IconButton(
//             icon: const Icon(Icons.delete_forever, size: 24, color: Colors.white),
//             onPressed: _clearCart,
//             tooltip: 'Clear Cart',
//           ),
//         ],
//         // ### END: MODIFIED APPBAR ###
//         backgroundColor: constants.bgColorPink,
//         elevation: 0,
//         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
//       ),
//       body: _dryCleanQuantities.isEmpty && _ironingQuantities.isEmpty && _washAndFoldQuantities.isEmpty && _washAndIronQuantities.isEmpty && _washIronStarchQuantities.isEmpty && _prePlatedQuantities.isEmpty && _additionalServices.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Lottie.asset('assets/animations/empty.json', width: 250, height: 250, fit: BoxFit.contain),
//             const SizedBox(height: 20),
//             Text("Your Cart is Empty", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800])),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 40),
//               child: Text("Add some items to get started with your laundry", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: 200,
//               child: ElevatedButton(
//                 onPressed: _navigateToHome,
//                 style: ElevatedButton.styleFrom(backgroundColor: constants.bgColorPink, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
//                 child: const Text("Browse Services", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//               ),
//             ),
//           ],
//         ),
//       )
//           : Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.only(bottom: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 8),
//                   if (_dryCleanQuantities.isNotEmpty) ...[
//                     _buildSectionHeader("Dry Clean"),
//                     ..._dryCleanQuantities.entries.map((entry) {
//                       final transformedName = entry.key.replaceAll('/', '-');
//                       final item = _dryCleanPrices.firstWhere((item) => item["name"] == transformedName, orElse: () => {"dry_clean": 0.0, "image": ""});
//                       final price = item["dry_clean"] as double;
//                       return _buildCartItem(context, leading: item["image"] != "" ? Image.network(item["image"], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Icon(Icons.dry_cleaning, color: Colors.blue[700], size: 40)) : Icon(Icons.dry_cleaning, color: Colors.blue[700], size: 40), title: transformedName, subtitle: price > 0 ? "₹${price.toStringAsFixed(2)} each" : "Price not available", quantity: entry.value, onDecrement: () { setState(() { if (entry.value > 1) { _dryCleanQuantities[entry.key] = entry.value - 1; _additionalServices.forEach((category, items) { for (var item in items) { if (item["name"] == entry.key) { final maxQuantity = _dryCleanQuantities[entry.key] ?? 0; if ((item["quantity"] ?? 0) > maxQuantity) { item["quantity"] = maxQuantity; } } } }); } else { _dryCleanQuantities.remove(entry.key); _additionalServices.forEach((category, items) { items.removeWhere((item) => item["name"] == entry.key); if (items.isEmpty) { _additionalServices.remove(category); } }); } _dryCleanTotal = _calculateDryCleanTotal(); _additionalTotal = _calculateAdditionalTotal(); CartPersistence.updateCart(dryCleanItems: _dryCleanQuantities, additionalServices: _additionalServices, dryCleanTotal: _dryCleanTotal, additionalTotal: _additionalTotal); }); }, onIncrement: () { setState(() { _dryCleanQuantities[entry.key] = entry.value + 1; _dryCleanTotal = _calculateDryCleanTotal(); CartPersistence.updateCart(dryCleanItems: _dryCleanQuantities, dryCleanTotal: _dryCleanTotal); }); }, onRemove: () { setState(() { _dryCleanQuantities.remove(entry.key); _additionalServices.forEach((category, items) { items.removeWhere((item) => item["name"] == entry.key); if (items.isEmpty) { _additionalServices.remove(category); } }); _dryCleanTotal = _calculateDryCleanTotal(); _additionalTotal = _calculateAdditionalTotal(); CartPersistence.updateCart(dryCleanItems: _dryCleanQuantities, additionalServices: _additionalServices, dryCleanTotal: _dryCleanTotal, additionalTotal: _additionalTotal); }); });
//                     }),
//                   ],
//                   if (_ironingQuantities.isNotEmpty) ...[
//                     _buildSectionHeader("Ironing"),
//                     ..._ironingQuantities.entries.map((entry) {
//                       final transformedName = entry.key.replaceAll('/', '-');
//                       final item = _ironingPrices.firstWhere((item) => item["name"] == transformedName, orElse: () => {"price": 0.0, "image": ""});
//                       final price = item["price"] as double;
//                       return _buildCartItem(context, leading: item["image"] != "" ? Image.network(item["image"], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Icon(Icons.iron, color: Colors.red[700], size: 40)) : Icon(Icons.iron, color: Colors.red[700], size: 40), title: transformedName, subtitle: price > 0 ? "₹${price.toStringAsFixed(2)} each" : "Price not available", quantity: entry.value, onDecrement: () { setState(() { if (entry.value > 1) { _ironingQuantities[entry.key] = entry.value - 1; } else { _ironingQuantities.remove(entry.key); } _ironingTotal = _calculateIroningTotal(); CartPersistence.updateCart(ironingItems: _ironingQuantities); }); }, onIncrement: () { setState(() { _ironingQuantities[entry.key] = entry.value + 1; _ironingTotal = _calculateIroningTotal(); CartPersistence.updateCart(ironingItems: _ironingQuantities); }); }, onRemove: () { setState(() { _ironingQuantities.remove(entry.key); _ironingTotal = _calculateIroningTotal(); CartPersistence.updateCart(ironingItems: _ironingQuantities); }); });
//                     }),
//                   ],
//                   if (_washAndFoldQuantities.isNotEmpty) ...[
//                     _buildSectionHeader("Wash & Fold"),
//                     ..._washAndFoldQuantities.entries.map((entry) {
//                       final item = _washAndFoldPrices.firstWhere((item) => item["label"] == entry.key, orElse: () => {"price": 0.0, "unit": ""});
//                       final price = item["price"] as double;
//                       final unit = item["unit"] ?? "";
//                       final displayName = entry.key.contains(": ") ? entry.key.split(": ")[1] : entry.key;
//                       return _buildCartItem(context, leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(12)), child: Icon(Icons.local_laundry_service, color: Colors.green[700], size: 30)), title: displayName, subtitle: price > 0 ? "₹${price.toStringAsFixed(2)} $unit" : "Price not available", quantity: entry.value, showQuantityControls: false, showQuantity: false, onRemove: () { setState(() { _washAndFoldQuantities.remove(entry.key); _washAndFoldTotal = _calculateWashAndFoldTotal(); _updateRemainingWashes(entry.key, 'washAndFold', 1); CartPersistence.updateCart(washAndFoldItems: _washAndFoldQuantities); }); });
//                     }),
//                   ],
//                   if (_washAndIronQuantities.isNotEmpty) ...[
//                     _buildSectionHeader("Wash & Iron"),
//                     ..._washAndIronQuantities.entries.map((entry) {
//                       final item = _washAndIronPrices.firstWhere((item) => item["label"] == entry.key, orElse: () => {"price": 0.0, "unit": ""});
//                       final price = item["price"] as double;
//                       final unit = item["unit"] ?? "";
//                       final displayName = entry.key.contains(": ") ? entry.key.split(": ")[1] : entry.key;
//                       return _buildCartItem(context, leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(12)), child: Icon(Icons.local_laundry_service, color: Colors.blue[700], size: 30)), title: displayName, subtitle: price > 0 ? "₹${price.toStringAsFixed(2)} $unit" : "Price not available", quantity: entry.value, showQuantityControls: false, showQuantity: false, onRemove: () { setState(() { _washAndIronQuantities.remove(entry.key); _washAndIronTotal = _calculateWashAndIronTotal(); _updateRemainingWashes(entry.key, 'washAndIron', 1); CartPersistence.updateCart(washAndIronItems: _washAndIronQuantities); }); });
//                     }),
//                   ],
//                   if (_washIronStarchQuantities.isNotEmpty) ...[
//                     _buildSectionHeader("Wash & Starch"),
//                     ..._washIronStarchQuantities.entries.map((entry) {
//                       final item = _washIronStarchPrices.firstWhere((item) => item["label"] == entry.key, orElse: () => {"price": 0.0, "unit": ""});
//                       final price = item["price"] as double;
//                       final unit = item["unit"] ?? "";
//                       final displayName = entry.key.contains(": ") ? entry.key.split(": ")[1] : entry.key;
//                       return _buildCartItem(context, leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.purple[100], borderRadius: BorderRadius.circular(12)), child: Icon(Icons.local_laundry_service, color: Colors.purple[700], size: 30)), title: displayName, subtitle: price > 0 ? "₹${price.toStringAsFixed(2)} $unit" : "Price not available", quantity: entry.value, showQuantityControls: false, showQuantity: false, onRemove: () { setState(() { _washIronStarchQuantities.remove(entry.key); _washIronStarchTotal = _calculateWashIronStarchTotal(); _updateRemainingWashes(entry.key, 'washIronStarch', 1); CartPersistence.updateCart(washIronStarchItems: _washIronStarchQuantities); }); });
//                     }),
//                   ],
//                   if (_prePlatedQuantities.isNotEmpty) ...[
//                     _buildSectionHeader("Pre-Pleat"),
//                     ..._prePlatedQuantities.entries.map((entry) {
//                       final quantity = entry.value["quantity"] as int? ?? 0;
//                       final pricePerItem = (entry.value["pricePerItem"] as num?)?.toDouble() ?? 0.0;
//                       return _buildCartItem(context, leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.pink[100], borderRadius: BorderRadius.circular(12)), child: Icon(Icons.iron, color: Colors.pink[700], size: 30)), title: entry.key, subtitle: pricePerItem > 0 ? "₹${pricePerItem.toStringAsFixed(2)} each" : "Price not available", quantity: quantity, onDecrement: () { setState(() { if (quantity > 1) { entry.value["quantity"] = quantity - 1; } else { _prePlatedQuantities.remove(entry.key); } _prePlatedTotal = _calculatePrePlatedTotal(); CartPersistence.updateCart(prePlatedItems: _prePlatedQuantities); }); }, onIncrement: () { setState(() { entry.value["quantity"] = quantity + 1; _prePlatedTotal = _calculatePrePlatedTotal(); CartPersistence.updateCart(prePlatedItems: _prePlatedQuantities); }); }, onRemove: () { setState(() { _prePlatedQuantities.remove(entry.key); _prePlatedTotal = _calculatePrePlatedTotal(); CartPersistence.updateCart(prePlatedItems: _prePlatedQuantities); }); });
//                     }),
//                   ],
//                   if (_additionalServices.isNotEmpty) ...[
//                     _buildSectionHeader("Additional Services"),
//                     ..._additionalServices.entries.map((entry) {
//                       final category = entry.key;
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(padding: const EdgeInsets.only(bottom: 4, top: 8), child: Text(category, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]))),
//                             ...entry.value.map((item) {
//                               final price = (item["price"] as num?)?.toDouble() ?? 0.0;
//                               final quantity = item["quantity"] ?? 0;
//                               final name = item["name"] ?? "";
//                               final maxQuantity = _dryCleanQuantities[name] ?? 0;
//                               return Card(
//                                 elevation: 0,
//                                 margin: const EdgeInsets.symmetric(vertical: 4),
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!, width: 1)),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(12),
//                                   child: Row(
//                                     children: [
//                                       Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(12)), child: Icon(Icons.add_circle, color: Colors.orange[700], size: 30)),
//                                       const SizedBox(width: 16),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
//                                             const SizedBox(height: 4),
//                                             Text(price > 0 ? "₹${price.toStringAsFixed(2)} each" : "Price not available", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//                                             Row(
//                                               children: [
//                                                 IconButton(icon: Container(decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.all(4), child: const Icon(Icons.remove, size: 18, color: Colors.grey)), onPressed: () { setState(() { if (quantity > 1) { item["quantity"] = quantity - 1; } else { _additionalServices[category]!.remove(item); if (_additionalServices[category]!.isEmpty) { _additionalServices.remove(category); } } _additionalTotal = _calculateAdditionalTotal(); CartPersistence.updateCart(additionalServices: _additionalServices, additionalTotal: _additionalTotal); }); }, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
//                                                 Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text("$quantity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]))),
//                                                 IconButton(icon: Container(decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.all(4), child: Icon(Icons.add, size: 18, color: Colors.green[700])), onPressed: () { if (quantity >= maxQuantity) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cannot exceed Dry Clean quantity ($maxQuantity) for $name"), backgroundColor: Colors.orange, duration: const Duration(seconds: 2))); return; } setState(() { item["quantity"] = quantity + 1; _additionalTotal = _calculateAdditionalTotal(); CartPersistence.updateCart(additionalServices: _additionalServices, additionalTotal: _additionalTotal); }); }, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       IconButton(icon: Icon(Icons.delete_outline, size: 22, color: Colors.red[400]), onPressed: () { setState(() { _additionalServices[category]!.remove(item); if (_additionalServices[category]!.isEmpty) { _additionalServices.remove(category); } _additionalTotal = _calculateAdditionalTotal(); CartPersistence.updateCart(additionalServices: _additionalServices, additionalTotal: _additionalTotal); }); }, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }),
//                           ],
//                         ),
//                       );
//                     }),
//                   ],
//                   const SizedBox(height: 16),
//                 ],
//               ),
//             ),
//           ),
//           if (showPlaceOrderButton)
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//               ),
//               child: SafeArea(
//                 child: Column(
//                   children: [
//                     if (total > 0) ...[
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
//                           Text("₹${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: constants.bgColorPink)),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                     ],
//                     if (_isOnlyRegularWash()) ...[
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text("Regular Wash Price", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
//                           Text("₹${_regularWashPrice.toStringAsFixed(2)} /KG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600])),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           setState(() => _isOrderLoading = true);
//                           await _navigateToCheckout();
//                         },
//                         style: ElevatedButton.styleFrom(backgroundColor: constants.bgColorPink, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0),
//                         child: const Text("Place Order", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//       child: Text(
//         title,
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800]),
//       ),
//     );
//   }
//
//   Widget _buildCartItem(
//       BuildContext context, {
//         required Widget leading,
//         required String title,
//         required String subtitle,
//         required int quantity,
//         bool showQuantityControls = true,
//         bool showQuantity = true,
//         VoidCallback? onDecrement,
//         VoidCallback? onIncrement,
//         VoidCallback? onRemove,
//       }) {
//     return Card(
//       elevation: 0,
//       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!, width: 1)),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           children: [
//             leading,
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
//                   const SizedBox(height: 4),
//                   Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//                   if (showQuantityControls) ...[
//                     Row(
//                       children: [
//                         IconButton(icon: Container(decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.all(4), child: const Icon(Icons.remove, size: 18, color: Colors.grey)), onPressed: onDecrement, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
//                         Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text("$quantity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]))),
//                         IconButton(icon: Container(decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.all(4), child: Icon(Icons.add, size: 18, color: Colors.green[700])), onPressed: onIncrement, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
//                       ],
//                     ),
//                   ] else if (showQuantity) ...[
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
//                       child: Text("$quantity", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800])),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             IconButton(icon: Icon(Icons.delete_outline, size: 22, color: Colors.red[400]), onPressed: onRemove, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/cart_persistence.dart';
import '../constant/constant.dart' as constants;
import '../sub screen/edit_measure.dart';
import 'HomeScreen.dart';
import 'order_confirmation_page.dart';
import '../constant/address_persistence.dart';
import 'AddressPage.dart';

class CartPage extends StatefulWidget {
  final Map<String, int> dryCleanItems;
  final Map<String, int> ironingItems;
  final Map<String, int> washAndFoldItems;
  final Map<String, int> washAndIronItems;
  final Map<String, int> washIronStarchItems;
  final Map<String, Map<String, dynamic>> prePlatedItems;
  final Map<String, List<Map<String, dynamic>>> additionalServices;
  final double dryCleanTotal;
  final double additionalTotal;

  const CartPage({
    required this.dryCleanItems,
    required this.ironingItems,
    required this.washAndFoldItems,
    required this.washAndIronItems,
    required this.washIronStarchItems,
    required this.prePlatedItems,
    required this.additionalServices,
    required this.dryCleanTotal,
    required this.additionalTotal,
    super.key,
  });

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, int> _dryCleanQuantities = {};
  Map<String, int> _ironingQuantities = {};
  Map<String, int> _washAndFoldQuantities = {};
  Map<String, int> _washAndIronQuantities = {};
  Map<String, int> _washIronStarchQuantities = {};
  Map<String, Map<String, dynamic>> _prePlatedQuantities = {};
  Map<String, List<Map<String, dynamic>>> _additionalServices = {};
  List<Map<String, dynamic>> _dryCleanPrices = [];
  List<Map<String, dynamic>> _ironingPrices = [];
  List<Map<String, dynamic>> _washAndFoldPrices = [];
  List<Map<String, dynamic>> _washAndIronPrices = [];
  List<Map<String, dynamic>> _washIronStarchPrices = [];
  bool _isInitialLoading = true;
  bool _isOrderLoading = false;
  double _dryCleanTotal = 0;
  double _ironingTotal = 0;
  double _washAndFoldTotal = 0;
  double _washAndIronTotal = 0;
  double _washIronStarchTotal = 0;
  double _prePlatedTotal = 0;
  double _additionalTotal = 0;
  double _regularWashPrice = 0;
  bool _measurementsExist = false;

  Map<String, dynamic>? _currentAddress;
  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    await _checkIfMeasurementsExist();
    try {
      final savedCart = await CartPersistence.loadCart();
      await _loadCurrentAddress();
      setState(() {
        _dryCleanQuantities = Map<String, int>.from(widget.dryCleanItems);
        _ironingQuantities = Map<String, int>.from(widget.ironingItems);
        _washAndFoldQuantities = _transformSubscriptionKeys(
            Map<String, int>.from(widget.washAndFoldItems), _washAndFoldPrices);
        _washAndIronQuantities = _transformSubscriptionKeys(
            Map<String, int>.from(widget.washAndIronItems), _washAndIronPrices);
        _washIronStarchQuantities = _transformSubscriptionKeys(
            Map<String, int>.from(widget.washIronStarchItems), _washIronStarchPrices);
        _prePlatedQuantities = Map<String, Map<String, dynamic>>.from(widget.prePlatedItems);
        _additionalServices = Map<String, List<Map<String, dynamic>>>.from(widget.additionalServices);
        _dryCleanTotal = widget.dryCleanTotal;
        _additionalTotal = widget.additionalTotal;

        if (savedCart != null) {
          _dryCleanQuantities = (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {})
              .map((key, value) => MapEntry(key.replaceAll('/', '-'), value is int ? value : int.tryParse(value.toString()) ?? 0));
          _ironingQuantities = (savedCart['ironingItems'] as Map<String, dynamic>? ?? {})
              .map((key, value) => MapEntry(key.replaceAll('/', '-'), value is int ? value : int.tryParse(value.toString()) ?? 0));
          _washAndFoldQuantities = _transformSubscriptionKeys(
              (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {})
                  .map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0)),
              _washAndFoldPrices);
          _washAndIronQuantities = _transformSubscriptionKeys(
              (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {})
                  .map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0)),
              _washAndIronPrices);
          _washIronStarchQuantities = _transformSubscriptionKeys(
              (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {})
                  .map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0)),
              _washIronStarchPrices);
          _prePlatedQuantities = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {})
              .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
          _additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {})
              .map((key, value) => MapEntry(key, (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList()));
          _dryCleanTotal = (savedCart['dryCleanTotal'] as num?)?.toDouble() ?? 0.0;
          _additionalTotal = (savedCart['additionalTotal'] as num?)?.toDouble() ?? 0.0;

          _dryCleanQuantities.removeWhere((key, value) => value <= 0);
          _ironingQuantities.removeWhere((key, value) => value <= 0);
          _washAndFoldQuantities.removeWhere((key, value) => value <= 0);
          _washAndIronQuantities.removeWhere((key, value) => value <= 0);
          _washIronStarchQuantities.removeWhere((key, value) => value <= 0);
          _prePlatedQuantities.removeWhere((key, value) => (value["quantity"] ?? 0) <= 0);
          _additionalServices.forEach((key, value) {
            value.removeWhere((item) => (item["quantity"] ?? 0) <= 0);
            if (value.isEmpty) _additionalServices.remove(key);
          });
        }
      });

      QuerySnapshot dryCleanSnapshot = await FirebaseFirestore.instance.collection("Dry Clean").get();
      QuerySnapshot ironingSnapshot = await FirebaseFirestore.instance.collection("Iron").get();

      final washFoldFutures = [
        FirebaseFirestore.instance.collection("Wash-Fold").doc("By Weight").get(),
        FirebaseFirestore.instance.collection("Wash-Fold").doc("1 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Fold").doc("7 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Fold").doc("15 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Fold").doc("30 Time").get(),
      ];
      final washIronFutures = [
        FirebaseFirestore.instance.collection("Wash-Iron").doc("By Weight").get(),
        FirebaseFirestore.instance.collection("Wash-Iron").doc("1 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Iron").doc("7 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Iron").doc("15 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Iron").doc("30 Time").get(),
      ];
      final washStarchFutures = [
        FirebaseFirestore.instance.collection("Wash-Starch").doc("By Weight").get(),
        FirebaseFirestore.instance.collection("Wash-Starch").doc("1 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Starch").doc("7 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Starch").doc("15 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Starch").doc("30 Time").get(),
      ];

      final washFoldResults = await Future.wait(washFoldFutures);
      final washIronResults = await Future.wait(washIronFutures);
      final washStarchResults = await Future.wait(washStarchFutures);

      setState(() {
        _dryCleanPrices = dryCleanSnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            "name": doc.id.replaceAll('/', '-'),
            "dry_clean": (data["dry_clean"] as num?)?.toDouble() ?? 0.0,
            "image": data["image"] ?? "",
          };
        }).toList();
        _ironingPrices = ironingSnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            "name": doc.id.replaceAll('/', '-'),
            "price": (data["price"] as num?)?.toDouble() ?? 0.0,
            "image": data["image"] ?? "",
          };
        }).toList();

        _washAndFoldPrices = [];
        if (washFoldResults.isNotEmpty && washFoldResults[0].exists) {
          final data = washFoldResults[0].data() as Map<String, dynamic>? ?? {};
          _washAndFoldPrices.add({
            "label": "By Weight: Regular Wash",
            "price": (data["price"] as num?)?.toDouble() ?? 0.0,
            "unit": "/KG",
          });
          _regularWashPrice = (data["price"] as num?)?.toDouble() ?? 0.0;
          _washAndFoldPrices.add({
            "label": "Premium Laundry",
            "price": (data["premium_price"] as num?)?.toDouble() ?? 159.0,
            "unit": "/KG",
          });
        }
        if (washFoldResults.length > 1 && washFoldResults[1].exists) {
          final data = washFoldResults[1].data() as Map<String, dynamic>? ?? {};
          _washAndFoldPrices.addAll([
            {
              "label": "One-Time: 3kg Regular Wash",
              "price": (data["three"] as num?)?.toDouble() ?? 0.0,
              "unit": "/2.75 To 3 KG",
            },
            {
              "label": "One-Time: 3kg White Clothes",
              "price": (data["white3"] as num?)?.toDouble() ?? 0.0,
              "unit": "/2.75 To 3 KG",
            },
            {
              "label": "One-Time: 5kg Regular Wash",
              "price": (data["price"] as num?)?.toDouble() ?? 0.0,
              "unit": "/5 To 5.5 KG",
            },
            {
              "label": "One-Time: 5kg White Clothes",
              "price": (data["white"] as num?)?.toDouble() ?? 0.0,
              "unit": "/5 To 5.5 KG",
            },
          ]);
        }
        final subscriptionTimes = {2: 7, 3: 15, 4: 30};
        for (int i = 2; i < washFoldResults.length; i++) {
          if (washFoldResults[i].exists) {
            final data = washFoldResults[i].data() as Map<String, dynamic>? ?? {};
            final times = subscriptionTimes[i] ?? 0;
            if (times > 0) {
              _washAndFoldPrices.addAll([
                {
                  "label": "Subscription: $times Washes (5kg)",
                  "price": (data["price"] as num?)?.toDouble() ?? 0.0,
                  "unit": "/5 To 5.5 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
                {
                  "label": "Subscription: $times White Washes (5kg)",
                  "price": (data["white"] as num?)?.toDouble() ?? 0.0,
                  "unit": "/5 To 5.5 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
                {
                  "label": "Subscription: $times Washes (3kg)",
                  "price": (data["three"] as num?)?.toDouble() ?? 0.0,
                  "unit": "/2.75 To 3 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
                {
                  "label": "Subscription: $times White Washes (3kg)",
                  "price": (data["white3"] as num?)?.toDouble() ?? 0.0,
                  "unit": "/2.75 To 3 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
              ]);
            }
          }
        }

        _washAndIronPrices = [];
        if (washIronResults.isNotEmpty && washIronResults[0].exists) {
          final data = washIronResults[0].data() as Map<String, dynamic>? ?? {};
          _washAndIronPrices.add({
            "label": "By Weight: Regular Wash",
            "price": (data["price"] as num?)?.toDouble() ?? 0.0,
            "unit": "/KG",
          });
          if (_regularWashPrice == 0) _regularWashPrice = (data["price"] as num?)?.toDouble() ?? 0.0;
          _washAndIronPrices.add({
            "label": "Premium Laundry",
            "price": (data["premium_price"] as num?)?.toDouble() ?? 159.0,
            "unit": "/KG",
          });
        }
        if (washIronResults.length > 1 && washIronResults[1].exists) {
          final data = washIronResults[1].data() as Map<String, dynamic>? ?? {};
          _washAndIronPrices.addAll([
            {
              "label": "One-Time: 3kg Regular Wash",
              "price": (data["three"] as num?)?.toDouble() ?? 0.0,
              "unit": "/2.75 To 3 KG",
            },
            {
              "label": "One-Time: 3kg White Clothes",
              "price": (data["white3"] as num?)?.toDouble() ?? 0.0,
              "unit": "/2.75 To 3 KG",
            },
            {
              "label": "One-Time: 5kg Regular Wash",
              "price": (data["price"] as num?)?.toDouble() ?? 0.0,
              "unit": "/5 To 5.5 KG",
            },
            {
              "label": "One-Time: 5kg White Clothes",
              "price": (data["white"] as num?)?.toDouble() ?? 0.0,
              "unit": "/5 To 5.5 KG",
            },
          ]);
        }
        for (int i = 2; i < washIronResults.length; i++) {
          if (washIronResults[i].exists) {
            final data = washIronResults[i].data() as Map<String, dynamic>? ?? {};
            final times = subscriptionTimes[i] ?? 0;
            if (times > 0) {
              _washAndIronPrices.addAll([
                {
                  "label": "Subscription: $times Washes (5kg)",
                  "price": (data["price"] as num?)?.toDouble() ?? 0.0,
                  "unit": "/5 To 5.5 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
                {
                  "label": "Subscription: $times White Washes (5kg)",
                  "price": (data["white"] as num?)?.toDouble() ?? 0.0,
                  "unit": "/5 To 5.5 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
                {
                  "label": "Subscription: $times Washes (3kg)",
                  "price": (data["three"] as num?)?.toDouble() ?? 0.0,
                  "unit": "/2.75 To 3 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
                {
                  "label": "Subscription: $times White Washes (3kg)",
                  "price": (data["white3"] as num?)?.toDouble() ?? 0.0,
                  "unit": "/2.75 To 3 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
              ]);
            }
          }
        }

        _washIronStarchPrices = [];
        if (washStarchResults.isNotEmpty && washStarchResults[0].exists) {
          final data = washStarchResults[0].data() as Map<String, dynamic>? ?? {};
          _washIronStarchPrices.add({
            "label": "By Weight: Regular Wash",
            "price": (data["price"] as num?)?.toDouble() ?? 0.0,
            "unit": "/KG",
          });
          if (_regularWashPrice == 0) _regularWashPrice = (data["price"] as num?)?.toDouble() ?? 0.0;
        }
        if (washStarchResults.length > 1 && washStarchResults[1].exists) {
          final data = washStarchResults[1].data() as Map<String, dynamic>? ?? {};
          _washIronStarchPrices.addAll([
            {
              "label": "One-Time: 3kg Regular Wash",
              "price": (data["three"] as num?)?.toDouble() ?? 0.0,
              "unit": "/2.75 To 3 KG",
            },
            {
              "label": "One-Time: 3kg White Clothes",
              "price": (data["white3"] as num?)?.toDouble() ?? 0.0,
              "unit": "/2.75 To 3 KG",
            },
            {
              "label": "One-Time: 5kg Regular Wash",
              "price": (data["price"] as num?)?.toDouble() ?? 0.0,
              "unit": "/5 To 5.5 KG",
            },
            {
              "label": "One-Time: 5kg White Clothes",
              "price": (data["white"] as num?)?.toDouble() ?? 0.0,
              "unit": "/5 To 5.5 KG",
            },
          ]);
        }
        for (int i = 2; i < washStarchResults.length; i++) {
          if (washStarchResults[i].exists) {
            final data = washStarchResults[i].data() as Map<String, dynamic>? ?? {};
            final times = subscriptionTimes[i] ?? 0;
            if (times > 0) {
              _washIronStarchPrices.addAll([
                {
                  "label": "Subscription: $times Washes (5kg)",
                  "price": (data["price"] as num?)?.toDouble() ?? 0.0,
                  "unit": "/5 To 5.5 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
                {
                  "label": "Subscription: $times White (5kg)",
                  "price": (data["white"] as num?)?.toDouble() ?? 0.0,
                  "unit": "/5 To 5.5 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
                {
                  "label": "Subscription: $times Washes (3kg)",
                  "price": (data["three"] as num?)?.toDouble() ?? 0.0,
                  "unit": "/2.75 To 3 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
                {
                  "label": "Subscription: $times White (3kg)",
                  "price": (data["white3"] as num?)?.toDouble() ?? 0.0,
                  "unit": "/2.75 To 3 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
              ]);
            }
          }
        }

        _dryCleanTotal = _calculateDryCleanTotal();
        _ironingTotal = _calculateIroningTotal();
        _washAndFoldTotal = _calculateWashAndFoldTotal();
        _washAndIronTotal = _calculateWashAndIronTotal();
        _washIronStarchTotal = _calculateWashIronStarchTotal();
        _prePlatedTotal = _calculatePrePlatedTotal();
        _additionalTotal = _calculateAdditionalTotal();
        _isInitialLoading = false;
      });
    } catch (e) {
      setState(() {
        _isInitialLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error initializing cart: $e. Please check your internet connection or try again later"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, int> _transformSubscriptionKeys(Map<String, int> quantities, List<Map<String, dynamic>> prices) {
    final transformed = <String, int>{};
    for (var entry in quantities.entries) {
      final originalKey = entry.key;
      final quantity = entry.value;
      final priceItem = prices.firstWhere(
            (item) => item["label"]?.contains(originalKey) ?? false,
        orElse: () => {"label": originalKey, "price": 0.0},
      );
      final newKey = priceItem["label"] ?? originalKey;
      transformed[newKey] = quantity;
    }
    return transformed;
  }

  double _calculateDryCleanTotal() {
    double total = 0.0;
    _dryCleanQuantities.forEach((name, quantity) {
      var item = _dryCleanPrices.firstWhere(
            (item) => item["name"] == name,
        orElse: () => {"dry_clean": 0.0},
      );
      total += (item["dry_clean"] as double) * quantity;
    });
    return total;
  }

  double _calculateIroningTotal() {
    double total = 0.0;
    _ironingQuantities.forEach((name, quantity) {
      var item = _ironingPrices.firstWhere(
            (item) => item["name"] == name,
        orElse: () => {"price": 0.0},
      );
      total += (item["price"] as double) * quantity;
    });
    return total;
  }

  double _calculateWashAndFoldTotal() {
    double total = 0.0;
    _washAndFoldQuantities.forEach((label, quantity) {
      if (!label.contains("By Weight: Regular Wash")) {
        var item = _washAndFoldPrices.firstWhere(
              (item) => item["label"] == label,
          orElse: () => {"price": 0.0},
        );
        total += (item["price"] as double) * quantity;
      }
    });
    return total;
  }

  double _calculateWashAndIronTotal() {
    double total = 0.0;
    _washAndIronQuantities.forEach((label, quantity) {
      if (!label.contains("By Weight: Regular Wash")) {
        var item = _washAndIronPrices.firstWhere(
              (item) => item["label"] == label,
          orElse: () => {"price": 0.0},
        );
        total += (item["price"] as double) * quantity;
      }
    });
    return total;
  }

  double _calculateWashIronStarchTotal() {
    double total = 0.0;
    _washIronStarchQuantities.forEach((label, quantity) {
      if (!label.contains("By Weight: Regular Wash")) {
        var item = _washIronStarchPrices.firstWhere(
              (item) => item["label"] == label,
          orElse: () => {"price": 0.0},
        );
        total += (item["price"] as double) * quantity;
      }
    });
    return total;
  }

  double _calculatePrePlatedTotal() {
    double total = 0.0;
    _prePlatedQuantities.forEach((name, item) {
      final quantity = item["quantity"] as int? ?? 0;
      final pricePerItem = (item["pricePerItem"] as num?)?.toDouble() ?? 0.0;
      total += pricePerItem * quantity;
    });
    return total;
  }

  double _calculateAdditionalTotal() {
    double total = 0.0;
    _additionalServices.forEach((category, items) {
      for (var item in items) {
        total += ((item["price"] as num?)?.toDouble() ?? 0.0) * (item["quantity"] ?? 0);
      }
    });
    return total;
  }

  Future<void> _navigateToCheckout() async {
    try {
      final savedAddress = await AddressPersistence.loadCurrentAddress();
      if (savedAddress == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddressPage()),
        );
        return;
      }

      await CartPersistence.updateCart(
        dryCleanItems: _dryCleanQuantities,
        ironingItems: _ironingQuantities,
        washAndFoldItems: _washAndFoldQuantities,
        washAndIronItems: _washAndIronQuantities,
        washIronStarchItems: _washIronStarchQuantities,
        prePlatedItems: _prePlatedQuantities,
        additionalServices: _additionalServices,
        dryCleanTotal: _dryCleanTotal,
        additionalTotal: _additionalTotal,
      );

      final orderId = await CartPersistence.saveOrder(
        dryCleanItems: _dryCleanQuantities,
        ironingItems: _ironingQuantities,
        washAndFoldItems: _washAndFoldQuantities,
        washAndIronItems: _washAndIronQuantities,
        washIronStarchItems: _washIronStarchQuantities,
        prePlatedItems: _prePlatedQuantities,
        additionalServices: _additionalServices,
        dryCleanTotal: _dryCleanTotal,
        additionalTotal: _additionalTotal,
      );

      await CartPersistence.clearCart();

      setState(() {
        _dryCleanQuantities.clear();
        _ironingQuantities.clear();
        _washAndFoldQuantities.clear();
        _washAndIronQuantities.clear();
        _washIronStarchQuantities.clear();
        _prePlatedQuantities.clear();
        _additionalServices.clear();
        _dryCleanTotal = 0;
        _ironingTotal = 0;
        _washAndFoldTotal = 0;
        _washAndIronTotal = 0;
        _washIronStarchTotal = 0;
        _prePlatedTotal = 0;
        _additionalTotal = 0;
        _regularWashPrice = 0;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationPage(orderId: orderId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to place order: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isOrderLoading = false);
    }
  }

  void _navigateToHome() {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }


  Widget _buildEditMeasurementsButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditMeasurementsPage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        child: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            "Edit measurement",
            style: TextStyle(
              color: constants.bgColorPink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkIfMeasurementsExist() async {
    final prefs = await SharedPreferences.getInstance();

    // Define the keys again so we can check them
    const shoulderToScalpKey = 'shoulder_to_scalp';
    const shoulderToThighKey = 'shoulder_to_thigh';
    const hipCircumferenceKey = 'hip_circumference';
    const chestPleatKey = 'chest_pleat';

    // Get all four values
    final value1 = prefs.getString(shoulderToScalpKey);
    final value2 = prefs.getString(shoulderToThighKey);
    final value3 = prefs.getString(hipCircumferenceKey);
    final value4 = prefs.getString(chestPleatKey);

    // Check if all values are not null and not empty
    if (value1 != null && value1.isNotEmpty &&
        value2 != null && value2.isNotEmpty &&
        value3 != null && value3.isNotEmpty &&
        value4 != null && value4.isNotEmpty) {
      if (mounted) {
        setState(() {
          _measurementsExist = true;
        });
      }
    }
  }

  void _clearCart() async {
    try {
      await CartPersistence.clearCart();
      setState(() {
        _dryCleanQuantities.clear();
        _ironingQuantities.clear();
        _washAndFoldQuantities.clear();
        _washAndIronQuantities.clear();
        _washIronStarchQuantities.clear();
        _prePlatedQuantities.clear();
        _additionalServices.clear();
        _dryCleanTotal = 0;
        _ironingTotal = 0;
        _washAndFoldTotal = 0;
        _washAndIronTotal = 0;
        _washIronStarchTotal = 0;
        _prePlatedTotal = 0;
        _additionalTotal = 0;
        _regularWashPrice = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cart cleared"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error clearing cart: $e. Try again later"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _useSubscriptionWash(String subscriptionLabel, String category) {
    setState(() {
      if (_washAndFoldQuantities.containsKey(subscriptionLabel) && category == 'washAndFold') {
        _washAndFoldQuantities[subscriptionLabel] = (_washAndFoldQuantities[subscriptionLabel] ?? 0) + 1;
        _washAndFoldTotal = _calculateWashAndFoldTotal();
      } else if (_washAndIronQuantities.containsKey(subscriptionLabel) && category == 'washAndIron') {
        _washAndIronQuantities[subscriptionLabel] = (_washAndIronQuantities[subscriptionLabel] ?? 0) + 1;
        _washAndIronTotal = _calculateWashAndIronTotal();
      } else if (_washIronStarchQuantities.containsKey(subscriptionLabel) && category == 'washIronStarch') {
        _washIronStarchQuantities[subscriptionLabel] = (_washIronStarchQuantities[subscriptionLabel] ?? 0) + 1;
        _washIronStarchTotal = _calculateWashIronStarchTotal();
      } else {
        if (category == 'washAndFold') {
          _washAndFoldQuantities[subscriptionLabel] = 1;
          _washAndFoldTotal = _calculateWashAndFoldTotal();
        } else if (category == 'washAndIron') {
          _washAndIronQuantities[subscriptionLabel] = 1;
          _washAndIronTotal = _calculateWashAndIronTotal();
        } else if (category == 'washIronStarch') {
          _washIronStarchQuantities[subscriptionLabel] = 1;
          _washIronStarchTotal = _calculateWashIronStarchTotal();
        }
      }
      CartPersistence.updateCart(
        dryCleanItems: _dryCleanQuantities,
        ironingItems: _ironingQuantities,
        washAndFoldItems: _washAndFoldQuantities,
        washAndIronItems: _washAndIronQuantities,
        washIronStarchItems: _washIronStarchQuantities,
        prePlatedItems: _prePlatedQuantities,
        additionalServices: _additionalServices,
        dryCleanTotal: _dryCleanTotal,
        additionalTotal: _additionalTotal,
      );
      _updateRemainingWashes(subscriptionLabel, category, -1);
    });
  }

  Future<void> _updateRemainingWashes(String label, String category, int change) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .where('label', isEqualTo: label)
          .where('category', isEqualTo: category)
          .where('status', isEqualTo: 'Active')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final currentRemaining = (doc['remainingWashes'] as int?) ?? 0;
        if (currentRemaining + change >= 0) {
          await doc.reference.update({
            'remainingWashes': FieldValue.increment(change),
          });
          print("Updated remaining washes for $label to ${currentRemaining + change} at 12:16 PM IST on July 27, 2025");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No remaining washes available"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating remaining washes: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isOnlyRegularWash() {
    bool hasRegularWash = _washAndFoldQuantities.containsKey("By Weight: Regular Wash") ||
        _washAndIronQuantities.containsKey("By Weight: Regular Wash") ||
        _washIronStarchQuantities.containsKey("By Weight: Regular Wash");

    bool hasOtherItems = _dryCleanQuantities.isNotEmpty ||
        _ironingQuantities.isNotEmpty ||
        _prePlatedQuantities.isNotEmpty ||
        _additionalServices.isNotEmpty ||
        _washAndFoldQuantities.keys.any((key) => key != "By Weight: Regular Wash") ||
        _washAndIronQuantities.keys.any((key) => key != "By Weight: Regular Wash") ||
        _washIronStarchQuantities.keys.any((key) => key != "By Weight: Regular Wash");

    return hasRegularWash && !hasOtherItems;
  }

  Future<void> _loadCurrentAddress() async {
    try {
      final savedAddress = await AddressPersistence.loadCurrentAddress();
      setState(() {
        _currentAddress = savedAddress;
      });
    } catch (e) {

      setState(() {
        _currentAddress = null;
      });
    }
  }

  Future<void> _handleDeleteAddress(Map<String, dynamic> addressToDelete) async  {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AddressPersistence.deleteAddress(addressToDelete);
      await _loadCurrentAddress();

      if (mounted) {
        Navigator.pop(context);
        _showAddressSelectionSheet();
      }
    }
  }

  Future<void> _showAddressSelectionSheet() async {
    final List<Map<String, dynamic>> savedAddresses = await AddressPersistence.loadAllAddresses();
    final Map<String, dynamic>? currentAddress = await AddressPersistence.loadCurrentAddress();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        return Container(
          padding: EdgeInsets.only(top: screenHeight * 0.025, left: screenWidth * 0.05, right: screenWidth * 0.05, bottom: screenHeight * 0.025 + MediaQuery.of(context).viewPadding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Pickup Address", style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold)),
              SizedBox(height: screenHeight * 0.018),
              if (savedAddresses.isEmpty)
                Center(child: Padding(padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025), child: const Text("No saved addresses found.")))
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: savedAddresses.length,
                    itemBuilder: (context, index) {
                      final address = savedAddresses[index];
                      final label = address['label'] ?? 'Address';
                      final street = address['street'] ?? '';
                      final door = address['doorNumber'] ?? '';
                      final bool isSelected = currentAddress != null && currentAddress['label'] == address['label'] && currentAddress['street'] == address['street'];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.006),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? constants.bgColorPink : Colors.transparent, width: 1.5)),
                        child: ListTile(
                          leading: const Icon(Icons.location_on_outlined, color: constants.bgColorPink),
                          title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("$door, $street"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                const Icon(Icons.check_circle, color: constants.bgColorPink),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.grey[400]),
                                onPressed: () => _handleDeleteAddress(address),
                                tooltip: 'Delete Address',
                              ),
                            ],
                          ),
                          onTap: () async {
                            await AddressPersistence.saveCurrentAddress(address);
                            await _loadCurrentAddress();
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: screenHeight * 0.018),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
                  label: const Text("Add New Address", style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    final result =await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressPage()));
                    if (result !=null && result is Map<String, dynamic> && mounted){
                      await AddressPersistence.saveCurrentAddress(result);
                      await _loadCurrentAddress();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: constants.bgColorPink, padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponsiveBody({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {

        if (constraints.maxWidth > 600) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800), // Max width for web/tablet
              child: child,
            ),
          );
        } else {
          return child;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: _buildResponsiveBody(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/loading.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Loading Your Cart",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please wait while we prepare your items",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // UPDATED to use the responsive wrapper
    if (_isOrderLoading) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: _buildResponsiveBody(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/ordering.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Sending your clothes to the queue...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please wait while we process your order",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final total = _dryCleanTotal +
        _ironingTotal +
        _washAndFoldTotal +
        _washAndIronTotal +
        _washIronStarchTotal +
        _prePlatedTotal +
        _additionalTotal;

    final showPlaceOrderButton = total > 0 || _isOnlyRegularWash();

    return Title(
      title: 'V12 Laundry | Cart',
      color: constants.bgColorPink,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "Cart",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage())),
          ),
          actions: [
            InkWell(
              onTap: _showAddressSelectionSheet,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _currentAddress != null ? (_currentAddress!['label'] as String? ?? 'Select Address') : 'Select Address',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_forever, size: 24, color: Colors.white),
              onPressed: _clearCart,
              tooltip: 'Clear Cart',
            ),

          ],
          backgroundColor: constants.bgColorPink,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
          ),
        ),
        // UPDATED to use the responsive wrapper
        body: _buildResponsiveBody(
          child: _dryCleanQuantities.isEmpty &&
              _ironingQuantities.isEmpty &&
              _washAndFoldQuantities.isEmpty &&
              _washAndIronQuantities.isEmpty &&
              _washIronStarchQuantities.isEmpty &&
              _prePlatedQuantities.isEmpty &&
              _additionalServices.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/empty.json',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  "Your Cart is Empty",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Add some items to get started with your laundry",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _navigateToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: constants.bgColorPink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Browse Services",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
              : Column(
            children: [
              if (_measurementsExist)
                _buildEditMeasurementsButton(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      if (_dryCleanQuantities.isNotEmpty) ...[
                        _buildSectionHeader("Dry Clean"),
                        ..._dryCleanQuantities.entries.map((entry) {
                          final transformedName = entry.key.replaceAll('/', '-');
                          final item = _dryCleanPrices.firstWhere(
                                (item) => item["name"] == transformedName,
                            orElse: () => {"dry_clean": 0.0, "image": ""},
                          );
                          final price = item["dry_clean"] as double;
                          return _buildCartItem(
                            context,
                            leading: item["image"] != ""
                                ? Image.network(
                              item["image"],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.dry_cleaning, color: Colors.blue[700], size: 40),
                            )
                                : Icon(Icons.dry_cleaning, color: Colors.blue[700], size: 40),
                            title: transformedName,
                            subtitle: price > 0 ? "₹${price.toStringAsFixed(2)} each" : "Price not available",
                            quantity: entry.value,
                            onDecrement: () {
                              setState(() {
                                if (entry.value > 1) {
                                  _dryCleanQuantities[entry.key] = entry.value - 1;
                                  _additionalServices.forEach((category, items) {
                                    for (var item in items) {
                                      if (item["name"] == entry.key) {
                                        final maxQuantity = _dryCleanQuantities[entry.key] ?? 0;
                                        if ((item["quantity"] ?? 0) > maxQuantity) {
                                          item["quantity"] = maxQuantity;
                                        }
                                      }
                                    }
                                  });
                                } else {
                                  _dryCleanQuantities.remove(entry.key);
                                  _additionalServices.forEach((category, items) {
                                    items.removeWhere((item) => item["name"] == entry.key);
                                    if (items.isEmpty) {
                                      _additionalServices.remove(category);
                                    }
                                  });
                                }
                                _dryCleanTotal = _calculateDryCleanTotal();
                                _additionalTotal = _calculateAdditionalTotal();
                                CartPersistence.updateCart(
                                  dryCleanItems: _dryCleanQuantities,
                                  additionalServices: _additionalServices,
                                  dryCleanTotal: _dryCleanTotal,
                                  additionalTotal: _additionalTotal,
                                );
                              });
                            },
                            onIncrement: () {
                              setState(() {
                                _dryCleanQuantities[entry.key] = entry.value + 1;
                                _dryCleanTotal = _calculateDryCleanTotal();
                                CartPersistence.updateCart(
                                  dryCleanItems: _dryCleanQuantities,
                                  dryCleanTotal: _dryCleanTotal,
                                );
                              });
                            },
                            onRemove: () {
                              setState(() {
                                _dryCleanQuantities.remove(entry.key);
                                _additionalServices.forEach((category, items) {
                                  items.removeWhere((item) => item["name"] == entry.key);
                                  if (items.isEmpty) {
                                    _additionalServices.remove(category);
                                  }
                                });
                                _dryCleanTotal = _calculateDryCleanTotal();
                                _additionalTotal = _calculateAdditionalTotal();
                                CartPersistence.updateCart(
                                  dryCleanItems: _dryCleanQuantities,
                                  additionalServices: _additionalServices,
                                  dryCleanTotal: _dryCleanTotal,
                                  additionalTotal: _additionalTotal,
                                );
                              });
                            },
                          );
                        }),
                      ],
                      if (_ironingQuantities.isNotEmpty) ...[
                        _buildSectionHeader("Ironing"),
                        ..._ironingQuantities.entries.map((entry) {
                          final transformedName = entry.key.replaceAll('/', '-');
                          final item = _ironingPrices.firstWhere(
                                (item) => item["name"] == transformedName,
                            orElse: () => {"price": 0.0, "image": ""},
                          );
                          final price = item["price"] as double;
                          return _buildCartItem(
                            context,
                            leading: item["image"] != ""
                                ? Image.network(
                              item["image"],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.iron, color: Colors.red[700], size: 40),
                            )
                                : Icon(Icons.iron, color: Colors.red[700], size: 40),
                            title: transformedName,
                            subtitle: price > 0 ? "₹${price.toStringAsFixed(2)} each" : "Price not available",
                            quantity: entry.value,
                            onDecrement: () {
                              setState(() {
                                if (entry.value > 1) {
                                  _ironingQuantities[entry.key] = entry.value - 1;
                                } else {
                                  _ironingQuantities.remove(entry.key);
                                }
                                _ironingTotal = _calculateIroningTotal();
                                CartPersistence.updateCart(
                                  ironingItems: _ironingQuantities,
                                );
                              });
                            },
                            onIncrement: () {
                              setState(() {
                                _ironingQuantities[entry.key] = entry.value + 1;
                                _ironingTotal = _calculateIroningTotal();
                                CartPersistence.updateCart(
                                  ironingItems: _ironingQuantities,
                                );
                              });
                            },
                            onRemove: () {
                              setState(() {
                                _ironingQuantities.remove(entry.key);
                                _ironingTotal = _calculateIroningTotal();
                                CartPersistence.updateCart(
                                  ironingItems: _ironingQuantities,
                                );
                              });
                            },
                          );
                        }),
                      ],
                      if (_washAndFoldQuantities.isNotEmpty) ...[
                        _buildSectionHeader("Wash & Fold"),
                        ..._washAndFoldQuantities.entries.map((entry) {
                          final item = _washAndFoldPrices.firstWhere(
                                (item) => item["label"] == entry.key,
                            orElse: () => {"price": 0.0, "unit": ""},
                          );
                          final price = item["price"] as double;
                          final unit = item["unit"] ?? "";
                          final displayName = entry.key.contains(": ") ? entry.key.split(": ")[1] : entry.key;
                          return _buildCartItem(
                            context,
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.local_laundry_service,
                                color: Colors.green[700],
                                size: 30,
                              ),
                            ),
                            title: displayName,
                            subtitle: price > 0 ? "₹${price.toStringAsFixed(2)} $unit" : "Price not available",
                            quantity: entry.value,
                            showQuantityControls: false,
                            showQuantity: false,
                            onRemove: () {
                              setState(() {
                                _washAndFoldQuantities.remove(entry.key);
                                _washAndFoldTotal = _calculateWashAndFoldTotal();
                                _updateRemainingWashes(entry.key, 'washAndFold', 1);
                                CartPersistence.updateCart(
                                  washAndFoldItems: _washAndFoldQuantities,
                                );
                              });
                            },
                          );
                        }),
                      ],
                      if (_washAndIronQuantities.isNotEmpty) ...[
                        _buildSectionHeader("Wash & Iron"),
                        ..._washAndIronQuantities.entries.map((entry) {
                          final item = _washAndIronPrices.firstWhere(
                                (item) => item["label"] == entry.key,
                            orElse: () => {"price": 0.0, "unit": ""},
                          );
                          final price = item["price"] as double;
                          final unit = item["unit"] ?? "";
                          final displayName = entry.key.contains(": ") ? entry.key.split(": ")[1] : entry.key;
                          return _buildCartItem(
                            context,
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.local_laundry_service,
                                color: Colors.blue[700],
                                size: 30,
                              ),
                            ),
                            title: displayName,
                            subtitle: price > 0 ? "₹${price.toStringAsFixed(2)} $unit" : "Price not available",
                            quantity: entry.value,
                            showQuantityControls: false,
                            showQuantity: false,
                            onRemove: () {
                              setState(() {
                                _washAndIronQuantities.remove(entry.key);
                                _washAndIronTotal = _calculateWashAndIronTotal();
                                _updateRemainingWashes(entry.key, 'washAndIron', 1);
                                CartPersistence.updateCart(
                                  washAndIronItems: _washAndIronQuantities,
                                );
                              });
                            },
                          );
                        }),
                      ],
                      if (_washIronStarchQuantities.isNotEmpty) ...[
                        _buildSectionHeader("Wash & Starch"),
                        ..._washIronStarchQuantities.entries.map((entry) {
                          final item = _washIronStarchPrices.firstWhere(
                                (item) => item["label"] == entry.key,
                            orElse: () => {"price": 0.0, "unit": ""},
                          );
                          final price = item["price"] as double;
                          final unit = item["unit"] ?? "";
                          final displayName = entry.key.contains(": ") ? entry.key.split(": ")[1] : entry.key;
                          return _buildCartItem(
                            context,
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.purple[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.local_laundry_service,
                                color: Colors.purple[700],
                                size: 30,
                              ),
                            ),
                            title: displayName,
                            subtitle: price > 0 ? "₹${price.toStringAsFixed(2)} $unit" : "Price not available",
                            quantity: entry.value,
                            showQuantityControls: false,
                            showQuantity: false,
                            onRemove: () {
                              setState(() {
                                _washIronStarchQuantities.remove(entry.key);
                                _washIronStarchTotal = _calculateWashIronStarchTotal();
                                _updateRemainingWashes(entry.key, 'washIronStarch', 1);
                                CartPersistence.updateCart(
                                  washIronStarchItems: _washIronStarchQuantities,
                                );
                              });
                            },
                          );
                        }),
                      ],
                      if (_prePlatedQuantities.isNotEmpty) ...[
                        _buildSectionHeader("Pre-Pleat"),
                        ..._prePlatedQuantities.entries.map((entry) {
                          final quantity = entry.value["quantity"] as int? ?? 0;
                          final pricePerItem = (entry.value["pricePerItem"] as num?)?.toDouble() ?? 0.0;
                          return _buildCartItem(
                            context,
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.pink[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.iron,
                                color: Colors.pink[700],
                                size: 30,
                              ),
                            ),
                            title: entry.key,
                            subtitle: pricePerItem > 0 ? "₹${pricePerItem.toStringAsFixed(2)} each" : "Price not available",
                            quantity: quantity,
                            onDecrement: () {
                              setState(() {
                                if (quantity > 1) {
                                  entry.value["quantity"] = quantity - 1;
                                } else {
                                  _prePlatedQuantities.remove(entry.key);
                                }
                                _prePlatedTotal = _calculatePrePlatedTotal();
                                CartPersistence.updateCart(
                                  prePlatedItems: _prePlatedQuantities,
                                );
                              });
                            },
                            onIncrement: () {
                              setState(() {
                                entry.value["quantity"] = quantity + 1;
                                _prePlatedTotal = _calculatePrePlatedTotal();
                                CartPersistence.updateCart(
                                  prePlatedItems: _prePlatedQuantities,
                                );
                              });
                            },
                            onRemove: () {
                              setState(() {
                                _prePlatedQuantities.remove(entry.key);
                                _prePlatedTotal = _calculatePrePlatedTotal();
                                CartPersistence.updateCart(
                                  prePlatedItems: _prePlatedQuantities,
                                );
                              });
                            },
                          );
                        }),
                      ],
                      if (_additionalServices.isNotEmpty) ...[
                        _buildSectionHeader("Additional Services"),
                        ..._additionalServices.entries.map((entry) {
                          final category = entry.key;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4, top: 8),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                                ...entry.value.map((item) {
                                  final price = (item["price"] as num?)?.toDouble() ?? 0.0;
                                  final quantity = item["quantity"] ?? 0;
                                  final name = item["name"] ?? "";
                                  final maxQuantity = _dryCleanQuantities[name] ?? 0;
                                  return Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.orange[100],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.add_circle,
                                              color: Colors.orange[700],
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  price > 0 ? "₹${price.toStringAsFixed(2)} each" : "Price not available",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[200],
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        padding: const EdgeInsets.all(4),
                                                        child: const Icon(Icons.remove, size: 18, color: Colors.grey),
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          if (quantity > 1) {
                                                            item["quantity"] = quantity - 1;
                                                          } else {
                                                            _additionalServices[category]!.remove(item);
                                                            if (_additionalServices[category]!.isEmpty) {
                                                              _additionalServices.remove(category);
                                                            }
                                                          }
                                                          _additionalTotal = _calculateAdditionalTotal();
                                                          CartPersistence.updateCart(
                                                            additionalServices: _additionalServices,
                                                            additionalTotal: _additionalTotal,
                                                          );
                                                        });
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                                      child: Text(
                                                        "$quantity",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.grey[800],
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.green[100],
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        padding: const EdgeInsets.all(4),
                                                        child: Icon(Icons.add, size: 18, color: Colors.green[700]),
                                                      ),
                                                      onPressed: () {
                                                        if (quantity >= maxQuantity) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text("Cannot exceed Dry Clean quantity ($maxQuantity) for $name"),
                                                              backgroundColor: Colors.orange,
                                                              duration: const Duration(seconds: 2),
                                                            ),
                                                          );
                                                          return;
                                                        }
                                                        setState(() {
                                                          item["quantity"] = quantity + 1;
                                                          _additionalTotal = _calculateAdditionalTotal();
                                                          CartPersistence.updateCart(
                                                            additionalServices: _additionalServices,
                                                            additionalTotal: _additionalTotal,
                                                          );
                                                        });
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: Icon(Icons.delete_outline, size: 22, color: Colors.red[400]),
                                            onPressed: () {
                                              setState(() {
                                                _additionalServices[category]!.remove(item);
                                                if (_additionalServices[category]!.isEmpty) {
                                                  _additionalServices.remove(category);
                                                }
                                                _additionalTotal = _calculateAdditionalTotal();
                                                CartPersistence.updateCart(
                                                  additionalServices: _additionalServices,
                                                  additionalTotal: _additionalTotal,
                                                );
                                              });
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (showPlaceOrderButton)
                Container(
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        if (total > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                "₹${total.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: constants.bgColorPink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (_isOnlyRegularWash()) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Regular Wash Price",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                "₹${_regularWashPrice.toStringAsFixed(2)} /KG",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() => _isOrderLoading = true);
                              await _navigateToCheckout();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: constants.bgColorPink,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Place Order",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // No changes to these helper methods
  Widget _buildSectionHeader(String title) {
    // ...
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context, {
        required Widget leading,
        required String title,
        required String subtitle,
        required int quantity,
        bool showQuantityControls = true,
        bool showQuantity = true,
        VoidCallback? onDecrement,
        VoidCallback? onIncrement,
        VoidCallback? onRemove,
      }) {
    // ...
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (showQuantityControls) ...[
                    Row(
                      children: [
                        IconButton(
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.remove, size: 18, color: Colors.grey),
                          ),
                          onPressed: onDecrement,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "$quantity",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.add, size: 18, color: Colors.green[700]),
                          ),
                          onPressed: onIncrement,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ] else if (showQuantity) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "$quantity",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 22, color: Colors.red[400]),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}