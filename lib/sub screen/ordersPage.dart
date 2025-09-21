// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import '../constant/constant.dart';
//
// class UserOrdersPage extends StatefulWidget {
//   const UserOrdersPage({super.key});
//
//   @override
//   _UserOrdersPageState createState() => _UserOrdersPageState();
// }
//
// class _UserOrdersPageState extends State<UserOrdersPage> {
//   String? _phoneNumber;
//   bool _isLoading = true;
//   bool _useFallbackQuery = true;
//   List<Map<String, dynamic>> _dryCleanPrices = [];
//   List<Map<String, dynamic>> _ironingPrices = [];
//   List<Map<String, dynamic>> _washAndFoldPrices = [];
//   List<Map<String, dynamic>> _washAndIronPrices = [];
//   List<Map<String, dynamic>> _washIronStarchPrices = [];
//   String? _errorMessage;
//   final Map<String, String> _subscriptionStatuses = {};
//   int _selectedIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//     _fetchPrices();
//     _fetchSubscriptionStatuses();
//   }
//
//   Future<void> _fetchUserData() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null && user.phoneNumber != null) {
//       setState(() {
//         _phoneNumber = user.phoneNumber;
//         _isLoading = false;
//       });
//     } else {
//       _showSnackBar("User not logged in.", isError: true);
//       Navigator.pop(context);
//     }
//   }
//
//   Future<void> _fetchPrices() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     try {
//       QuerySnapshot dryCleanSnapshot = await FirebaseFirestore.instance.collection("Dry Clean").get();
//       QuerySnapshot ironingSnapshot = await FirebaseFirestore.instance.collection("Iron").get();
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
//           return {
//             "name": doc.id,
//             "dry_clean": data["dry_clean"] ?? 0,
//           };
//         }).toList();
//
//         _ironingPrices = ironingSnapshot.docs.map((doc) {
//           var data = doc.data() as Map<String, dynamic>;
//           return {
//             "name": doc.id,
//             "price": data["price"] ?? 0,
//           };
//         }).toList();
//
//         _washAndFoldPrices = [];
//         if (washFoldResults.isNotEmpty && washFoldResults[0].exists) {
//           final data = washFoldResults[0].data() as Map<String, dynamic>? ?? {};
//           _washAndFoldPrices.add({
//             "label": "By Weight: Regular Wash",
//             "price": data["price"] ?? 0,
//             "unit": "/KG",
//           });
//           _washAndFoldPrices.add({
//             "label": "Premium Laundry",
//             "price": data["premium_price"] ?? 159,
//             "unit": "/KG",
//           });
//         }
//         if (washFoldResults.length > 1 && washFoldResults[1].exists) {
//           final data = washFoldResults[1].data() as Map<String, dynamic>? ?? {};
//           _washAndFoldPrices.addAll([
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
//               "unit": "/5 To 5.5 KG",
//             },
//             {
//               "label": "One-Time: 5kg White Clothes",
//               "price": data["white"] ?? 0,
//               "unit": "/5 To 5.5 KG",
//             },
//           ]);
//         }
//         final subscriptionTimes = {2: 7, 3: 15, 4: 30};
//         for (int i = 2; i < washFoldResults.length; i++) {
//           if (washFoldResults[i].exists) {
//             final data = washFoldResults[i].data() as Map<String, dynamic>? ?? {};
//             final times = subscriptionTimes[i] ?? 0;
//             if (times > 0) {
//               _washAndFoldPrices.addAll([
//                 {
//                   "label": "Subscription: $times Washes (5kg)",
//                   "price": data["price"] ?? 0,
//                   "unit": "/5 To 5.5 KG",
//                   "month": data["month"] ?? 1,
//                   "times": times,
//                 },
//                 {
//                   "label": "Subscription: $times White Washes (5kg)",
//                   "price": data["white"] ?? 0,
//                   "unit": "/5 To 5.5 KG",
//                   "month": data["month"] ?? 1,
//                   "times": times,
//                 },
//                 {
//                   "label": "Subscription: $times Washes (3kg)",
//                   "price": data["three"] ?? 0,
//                   "unit": "/2.75 To 3 KG",
//                   "month": data["month"] ?? 1,
//                   "times": times,
//                 },
//                 {
//                   "label": "Subscription: $times White Washes (3kg)",
//                   "price": data["white3"] ?? 0,
//                   "unit": "/2.75 To 3 KG",
//                   "month": data["month"] ?? 1,
//                   "times": times,
//                 },
//               ]);
//             }
//           }
//         }
//
//         _washAndIronPrices = [];
//         if (washIronResults.isNotEmpty && washIronResults[0].exists) {
//           final data = washIronResults[0].data() as Map<String, dynamic>? ?? {};
//           _washAndIronPrices.add({
//             "label": "By Weight: Regular Wash",
//             "price": data["price"] ?? 0,
//             "unit": "/KG",
//           });
//           _washAndIronPrices.add({
//             "label": "Premium Laundry",
//             "price": data["premium_price"] ?? 159,
//             "unit": "/KG",
//           });
//         }
//         if (washIronResults.length > 1 && washIronResults[1].exists) {
//           final data = washIronResults[1].data() as Map<String, dynamic>? ?? {};
//           _washAndIronPrices.addAll([
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
//               "unit": "/5 To 5.5 KG",
//             },
//             {
//               "label": "One-Time: 5kg White Clothes",
//               "price": data["white"] ?? 0,
//               "unit": "/5 To 5.5 KG",
//             },
//           ]);
//         }
//         for (int i = 2; i < washIronResults.length; i++) {
//           if (washIronResults[i].exists) {
//             final data = washIronResults[i].data() as Map<String, dynamic>? ?? {};
//             final times = subscriptionTimes[i] ?? 0;
//             if (times > 0) {
//               _washAndIronPrices.addAll([
//                 {
//                   "label": "Subscription: $times Washes (5kg)",
//                   "price": data["price"] ?? 0,
//                   "unit": "/5 To 5.5 KG",
//                   "month": data["month"] ?? 1,
//                   "times": times,
//                 },
//                 {
//                   "label": "Subscription: $times White Washes (5kg)",
//                   "price": data["white"] ?? 0,
//                   "unit": "/5 To 5.5 KG",
//                   "month": data["month"] ?? 1,
//                   "times": times,
//                 },
//                 {
//                   "label": "Subscription: $times Washes (3kg)",
//                   "price": data["three"] ?? 0,
//                   "unit": "/2.75 To 3 KG",
//                   "month": data["month"] ?? 1,
//                   "times": times,
//                 },
//                 {
//                   "label": "Subscription: $times White Washes (3kg)",
//                   "price": data["white3"] ?? 0,
//                   "unit": "/2.75 To 3 KG",
//                   "month": data["month"] ?? 1,
//                   "times": times,
//                 },
//               ]);
//             }
//           }
//         }
//
//         _washIronStarchPrices = [];
//         if (washStarchResults.isNotEmpty && washStarchResults[0].exists) {
//           final data = washStarchResults[0].data() as Map<String, dynamic>? ?? {};
//           _washIronStarchPrices.add({
//             "label": "By Weight: Regular Wash",
//             "price": data["price"] ?? 0,
//             "unit": "/KG",
//           });
//         }
//         if (washStarchResults.length > 1 && washStarchResults[1].exists) {
//           final data = washStarchResults[1].data() as Map<String, dynamic>? ?? {};
//           _washIronStarchPrices.addAll([
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
//               "unit": "/5 To 5.5 KG",
//             },
//             {
//               "label": "One-Time: 5kg White Clothes",
//               "price": data["white"] ?? 0,
//               "unit": "/5 To 5.5 KG",
//             },
//           ]);
//         }
//         for (int i = 2; i < washStarchResults.length; i++) {
//           if (washStarchResults[i].exists) {
//             final data = washStarchResults[i].data() as Map<String, dynamic>? ?? {};
//             final times = subscriptionTimes[i] ?? 0;
//             if (times > 0) {
//               _washIronStarchPrices.addAll([
//                 {
//                   "label": "Subscription: $times Washes (5kg)",
//                   "price": data["price"] ?? 0,
//                   "unit": "/5 To 5.5 KG",
//                   "month": data["month"] ?? 1,
//                   "times": times,
//                 },
//                 {
//                   "label": "Subscription: $times White (5kg)",
//                   "price": data["white"] ?? 0,
//                   "unit": "/5 To 5.5 KG",
//                   "month": data["month"] ?? 1,
//                   "times": times,
//                 },
//                 {
//                   "label": "Subscription: $times Washes (3kg)",
//                   "price": data["three"] ?? 0,
//                   "unit": "/2.75 To 3 KG",
//                   "month": data["month"] ?? 1,
//                   "times": times,
//                 },
//                 {
//                   "label": "Subscription: $times White (3kg)",
//                   "price": data["white3"] ?? 0,
//                   "unit": "/2.75 To 3 KG",
//                   "month": data["month"] ?? 1,
//                   "times": times,
//                 },
//               ]);
//             }
//           }
//         }
//
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = "Failed to load prices. Please try again.";
//         print("Error fetching prices: $e");
//       });
//     }
//   }
//
//   Future<void> _fetchSubscriptionStatuses() async {
//     try {
//       final activeSubscriptions = await FirebaseFirestore.instance
//           .collection('subscriptions')
//           .where('userId', isEqualTo: _phoneNumber)
//           .where('status', isEqualTo: 'Active')
//           .get();
//       setState(() {
//         _subscriptionStatuses.clear();
//         for (var doc in activeSubscriptions.docs) {
//           final data = doc.data() as Map<String, dynamic>;
//           final subscriptionId = data['subscriptionId'] as String? ?? doc.id;
//           _subscriptionStatuses[subscriptionId] = "Active Subscription - Placed Order";
//         }
//       });
//     } catch (e) {
//       print("Error fetching subscription statuses: $e");
//     }
//   }
//
//   Future<void> _cancelOrder(String orderId) async {
//     if (_phoneNumber == null) return;
//
//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Cancel Order"),
//         content: Text("Are you sure you want to cancel order $orderId?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text("No"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text("Yes", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm != true) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final orderDoc = await FirebaseFirestore.instance.collection('orders').doc(orderId).get();
//       if (!orderDoc.exists || orderDoc.data()?['phoneNumber'] != _phoneNumber) {
//         throw Exception("Order does not belong to user.");
//       }
//
//       final orderData = orderDoc.data() as Map<String, dynamic>;
//       final subscriptionId = orderData['subscriptionId'] as String?;
//
//       if (subscriptionId != null) {
//         final subscriptionDoc = await FirebaseFirestore.instance
//             .collection('subscriptions')
//             .doc(subscriptionId)
//             .get();
//         if (subscriptionDoc.exists) {
//           final subscriptionData = subscriptionDoc.data() as Map<String, dynamic>;
//           int remainingWashes = (subscriptionData['remainingWashes'] as int?) ?? 0;
//           await FirebaseFirestore.instance.collection('subscriptions').doc(subscriptionId).update({
//             'remainingWashes': remainingWashes + 1,
//           });
//         }
//       }
//
//       await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
//         'orderStatus': 'Cancelled',
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//
//       _showSnackBar("Order $orderId cancelled successfully.");
//     } catch (e) {
//       _showSnackBar("Failed to cancel order: $e", isError: true);
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "My Orders",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
//         ),
//         backgroundColor: bgColorPink,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//           onPressed: _isLoading ? null : () => Navigator.pop(context),
//         ),
//         elevation: 4,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: bgColorPink))
//           : _errorMessage != null
//           ? Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 _errorMessage!,
//                 style: const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.w500),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _fetchPrices,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: bgColorPink,
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//                 child: const Text("Retry", style: TextStyle(color: Colors.white, fontSize: 16)),
//               ),
//             ],
//           ),
//         ),
//       )
//           : _phoneNumber == null
//           ? const Center(
//         child: Text(
//           "No user logged in.",
//           style: TextStyle(fontSize: 18, color: Colors.grey),
//         ),
//       )
//           : StreamBuilder<DocumentSnapshot>(
//         stream: FirebaseFirestore.instance.collection('users').doc(_phoneNumber).snapshots(),
//         builder: (context, userSnapshot) {
//           if (userSnapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator(color: bgColorPink));
//           }
//           if (userSnapshot.hasError) {
//             return const Center(
//               child: Text(
//                 "Error loading user data.",
//                 style: TextStyle(fontSize: 18, color: Colors.red),
//               ),
//             );
//           }
//           if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
//             return const Center(
//               child: Text(
//                 "No user data found.",
//                 style: TextStyle(fontSize: 18, color: Colors.grey),
//               ),
//             );
//           }
//
//           final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
//           final orderIds = userData?['orderIds'] as List<dynamic>? ?? [];
//
//           if (orderIds.isEmpty) {
//             return const Center(
//               child: Text(
//                 "No orders placed yet.",
//                 style: TextStyle(fontSize: 18, color: Colors.grey),
//               ),
//             );
//           }
//
//           List<List<dynamic>> orderIdChunks = [];
//           for (int i = 0; i < orderIds.length; i += 10) {
//             orderIdChunks.add(orderIds.sublist(i, i + 10 > orderIds.length ? orderIds.length : i + 10));
//           }
//
//           return StreamBuilder<QuerySnapshot>(
//             stream: _useFallbackQuery
//                 ? Stream.fromIterable(orderIdChunks)
//                 .asyncMap((chunk) => FirebaseFirestore.instance
//                 .collection('orders')
//                 .where('orderId', whereIn: chunk)
//                 .get())
//                 .asyncExpand((querySnapshot) => Stream.value(querySnapshot))
//                 .map((event) => event)
//                 : FirebaseFirestore.instance
//                 .collection('orders')
//                 .where('orderId', whereIn: orderIds)
//                 .where('phoneNumber', isEqualTo: _phoneNumber)
//                 .orderBy('orderDate', descending: true)
//                 .snapshots(),
//             builder: (context, orderSnapshot) {
//               if (orderSnapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator(color: bgColorPink));
//               }
//               if (orderSnapshot.hasError) {
//                 return Center(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           "Failed to load orders. Please try again later.",
//                           style: TextStyle(fontSize: 18, color: Colors.red),
//                           textAlign: TextAlign.center,
//                         ),
//                         if (orderSnapshot.error.toString().contains('FAILED_PRECONDITION'))
//                           const Padding(
//                             padding: EdgeInsets.all(16.0),
//                             child: Text(
//                               "A required index is being created. Check back in a few minutes.",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(color: Colors.grey, fontSize: 14),
//                             ),
//                           ),
//                         const SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: () => setState(() {
//                             _useFallbackQuery = !_useFallbackQuery;
//                           }),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: bgColorPink,
//                             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                           ),
//                           child: const Text("Retry", style: TextStyle(color: Colors.white, fontSize: 16)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }
//               if (!orderSnapshot.hasData || orderSnapshot.data!.docs.isEmpty) {
//                 return const Center(
//                   child: Text(
//                     "No orders found.",
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                 );
//               }
//
//               final orders = orderSnapshot.data!.docs.where((doc) {
//                 final order = doc.data() as Map<String, dynamic>;
//                 final orderStatus = order['orderStatus'] as String? ?? 'Unknown';
//                 return _selectedIndex == 0
//                     ? orderStatus != 'Delivered' && orderStatus != 'Cancelled'
//                     : orderStatus == 'Delivered' || orderStatus == 'Cancelled';
//               }).toList();
//
//               if (orders.isEmpty) {
//                 return Center(
//                   child: Text(
//                     _selectedIndex == 0 ? "No placed orders found." : "No delivered or cancelled orders found.",
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
//                   ),
//                 );
//               }
//
//               return Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: ListView.builder(
//                   itemCount: orders.length,
//                   itemBuilder: (context, index) {
//                     final order = orders[index].data() as Map<String, dynamic>;
//                     final orderId = order['orderId'] as String? ?? 'Unknown';
//                     final orderStatus = order['orderStatus'] as String? ?? 'Unknown';
//                     final orderDate = (order['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now();
//                     final dryCleanItems = order['dryCleanItems'] as Map<String, dynamic>? ?? {};
//                     final ironingItems = order['ironingItems'] as Map<String, dynamic>? ?? {};
//                     final washAndFoldItems = order['washAndFoldItems'] as Map<String, dynamic>? ?? {};
//                     final washAndIronItems = order['washAndIronItems'] as Map<String, dynamic>? ?? {};
//                     final washIronStarchItems = order['washIronStarchItems'] as Map<String, dynamic>? ?? {};
//                     final prePlatedItems = order['prePlatedItems'] as Map<String, dynamic>? ?? {};
//                     final additionalServices = order['additionalServices'] as Map<String, dynamic>? ?? {};
//                     final subscriptionId = order['subscriptionId'] as String?;
//
//                     // ### START: LOGIC FOR REGULAR WASH PRICING ###
//                     int totalItemTypes = dryCleanItems.length +
//                         ironingItems.length +
//                         washAndFoldItems.length +
//                         washAndIronItems.length +
//                         washIronStarchItems.length +
//                         prePlatedItems.length +
//                         additionalServices.length;
//
//                     bool hasRegularWash =
//                         washAndFoldItems.keys.any((k) => k.contains('Regular Wash')) ||
//                             washAndIronItems.keys.any((k) => k.contains('Regular Wash')) ||
//                             washIronStarchItems.keys.any((k) => k.contains('Regular Wash'));
//                     // ### END: LOGIC FOR REGULAR WASH PRICING ###
//
//
//                     double dryCleanTotal = 0.0;
//                     double ironingTotal = 0.0;
//                     double washAndFoldTotal = 0.0;
//                     double washAndIronTotal = 0.0;
//                     double washIronStarchTotal = 0.0;
//                     double prePlatedTotal = 0.0;
//                     double additionalTotal = 0.0;
//
//                     dryCleanItems.forEach((key, value) {
//                       final itemName = key.replaceFirst('dryClean_', '');
//                       final quantity = (value as num?)?.toInt() ?? 0;
//                       final item = _dryCleanPrices.firstWhere(
//                             (item) => item['name'] == itemName,
//                         orElse: () => {"dry_clean": 0.0},
//                       );
//                       final price = (item['dry_clean'] as num?)?.toDouble() ?? 0.0;
//                       dryCleanTotal += price * quantity;
//                     });
//
//                     ironingItems.forEach((key, value) {
//                       final itemName = key.replaceFirst('ironing_', '');
//                       final quantity = (value as num?)?.toInt() ?? 0;
//                       final item = _ironingPrices.firstWhere(
//                             (item) => item['name'] == itemName,
//                         orElse: () => {"price": 0.0},
//                       );
//                       final price = (item['price'] as num?)?.toDouble() ?? 0.0;
//                       ironingTotal += price * quantity;
//                     });
//
//                     washAndFoldItems.forEach((key, value) {
//                       final itemLabel = key.replaceFirst('washAndFold_', '');
//                       final quantity = (value as num?)?.toInt() ?? 0;
//                       final item = _washAndFoldPrices.firstWhere(
//                             (item) => item['label'] == itemLabel,
//                         orElse: () => {"price": 0.0},
//                       );
//                       double price = (item['price'] as num?)?.toDouble() ?? 0.0;
//
//                       // ### LOGIC APPLIED HERE ###
//                       bool isRegularWashItem = itemLabel.contains('Regular Wash');
//                       if (isRegularWashItem && totalItemTypes > 1) {
//                         price = 0.0; // Don't add price if other items exist
//                       }
//                       washAndFoldTotal += price * quantity;
//                     });
//
//                     washAndIronItems.forEach((key, value) {
//                       final itemLabel = key.replaceFirst('washAndIron_', '');
//                       final quantity = (value as num?)?.toInt() ?? 0;
//                       final item = _washAndIronPrices.firstWhere(
//                             (item) => item['label'] == itemLabel,
//                         orElse: () => {"price": 0.0},
//                       );
//                       double price = (item['price'] as num?)?.toDouble() ?? 0.0;
//
//                       // ### LOGIC APPLIED HERE ###
//                       bool isRegularWashItem = itemLabel.contains('Regular Wash');
//                       if (isRegularWashItem && totalItemTypes > 1) {
//                         price = 0.0; // Don't add price if other items exist
//                       }
//                       washAndIronTotal += price * quantity;
//                     });
//
//                     washIronStarchItems.forEach((key, value) {
//                       final itemLabel = key.replaceFirst('washIronStarch_', '');
//                       final quantity = (value as num?)?.toInt() ?? 0;
//                       final item = _washIronStarchPrices.firstWhere(
//                             (item) => item['label'] == itemLabel,
//                         orElse: () => {"price": 0.0},
//                       );
//                       double price = (item['price'] as num?)?.toDouble() ?? 0.0;
//
//                       // ### LOGIC APPLIED HERE ###
//                       bool isRegularWashItem = itemLabel.contains('Regular Wash');
//                       if (isRegularWashItem && totalItemTypes > 1) {
//                         price = 0.0; // Don't add price if other items exist
//                       }
//                       washIronStarchTotal += price * quantity;
//                     });
//
//                     prePlatedItems.forEach((key, value) {
//                       final quantity = (value['quantity'] as num?)?.toInt() ?? 0;
//                       final price = (value['pricePerItem'] as num?)?.toDouble() ?? 0.0;
//                       prePlatedTotal += price * quantity;
//                     });
//
//                     additionalServices.forEach((category, items) {
//                       for (var item in (items as List<dynamic>)) {
//                         final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
//                         final price = (item['price'] as num?)?.toDouble() ?? 0.0;
//                         additionalTotal += price * quantity;
//                       }
//                     });
//
//                     final total = dryCleanTotal + ironingTotal + washAndFoldTotal + washAndIronTotal + washIronStarchTotal + prePlatedTotal + additionalTotal;
//                     final subscriptionStatus = subscriptionId != null ? _subscriptionStatuses[subscriptionId] ?? "New Subscription - Awaiting Payment" : "";
//
//                     if (order['phoneNumber'] != _phoneNumber) {
//                       return const SizedBox.shrink();
//                     }
//
//                     return Card(
//                       elevation: 6,
//                       margin: const EdgeInsets.only(bottom: 15),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                       color: Colors.white,
//                       child: Padding(
//                         padding: const EdgeInsets.all(15),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "Order #$orderId",
//                                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
//                                 ),
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       orderStatus == 'Awaiting Pickup'
//                                           ? Icons.local_shipping
//                                           : orderStatus == 'Laundry Collected'
//                                           ? Icons.check_circle_outline
//                                           : orderStatus == 'Delivered'
//                                           ? Icons.done_all
//                                           : Icons.info_outline,
//                                       color: orderStatus == 'Awaiting Pickup'
//                                           ? Colors.green
//                                           : orderStatus == 'Cancelled'
//                                           ? Colors.red
//                                           : Colors.grey,
//                                       size: 20,
//                                     ),
//                                     const SizedBox(width: 5),
//                                     Text(
//                                       orderStatus,
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: orderStatus == 'Awaiting Pickup'
//                                             ? Colors.green
//                                             : orderStatus == 'Cancelled'
//                                             ? Colors.red
//                                             : Colors.grey,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             if (subscriptionStatus.isNotEmpty) ...[
//                               const SizedBox(height: 8),
//                               Text(
//                                 subscriptionStatus,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: subscriptionStatus.contains("Awaiting Payment") ? Colors.orange : Colors.green,
//                                 ),
//                               ),
//                             ],
//                             if (orderStatus == 'Awaiting Pickup' ||
//                                 orderStatus == 'Laundry Collected' ||
//                                 orderStatus == 'Delivered')
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(vertical: 10),
//                                 child: Center(
//                                   child: Lottie.asset(
//                                     orderStatus == 'Awaiting Pickup'
//                                         ? 'assets/animations/delivered.json'
//                                         : orderStatus == 'Laundry Collected'
//                                         ? 'assets/animations/Animation.json'
//                                         : 'assets/animations/pickup.json',
//                                     height: 120,
//                                     fit: BoxFit.contain,
//                                     repeat: orderStatus != 'Delivered',
//                                     animate: true,
//                                   ),
//                                 ),
//                               ),
//                             const SizedBox(height: 10),
//                             Text(
//                               "Date: ${orderDate.toLocal().toString().split('.')[0]}",
//                               style: const TextStyle(fontSize: 14, color: Colors.grey),
//                             ),
//                             const Divider(height: 20, thickness: 1),
//                             if (dryCleanItems.isNotEmpty) ...[
//                               const Text(
//                                 "Dry Clean Items",
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
//                               ),
//                               ...dryCleanItems.entries.map((entry) {
//                                 final itemName = entry.key.replaceFirst('dryClean_', '');
//                                 final quantity = entry.value as int;
//                                 final item = _dryCleanPrices.firstWhere(
//                                       (item) => item['name'] == itemName,
//                                   orElse: () => {"dry_clean": 0.0},
//                                 );
//                                 final price = (item['dry_clean'] as num?)?.toDouble() ?? 0.0;
//                                 return ListTile(
//                                   contentPadding: EdgeInsets.zero,
//                                   title: Text(
//                                     "$itemName (x$quantity)",
//                                     style: const TextStyle(color: Colors.black54),
//                                   ),
//                                   trailing: Text(
//                                     "₹${(price * quantity).toStringAsFixed(2)}",
//                                     style: const TextStyle(color: Colors.black54),
//                                   ),
//                                 );
//                               }),
//                             ],
//                             if (prePlatedItems.isNotEmpty) ...[
//                               const SizedBox(height: 10),
//                               const Text(
//                                 "Pre-Plated Items",
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
//                               ),
//                               ...prePlatedItems.entries.map((entry) {
//                                 final itemName = entry.key.replaceFirst('prePlated_', '');
//                                 final quantity = (entry.value['quantity'] as num?)?.toInt() ?? 0;
//                                 final price = (entry.value['pricePerItem'] as num?)?.toDouble() ?? 0.0;
//                                 return ListTile(
//                                   contentPadding: EdgeInsets.zero,
//                                   title: Text(
//                                     "$itemName (x$quantity)",
//                                     style: const TextStyle(color: Colors.black54),
//                                   ),
//                                   trailing: Text(
//                                     "₹${(price * quantity).toStringAsFixed(2)}",
//                                     style: const TextStyle(color: Colors.black54),
//                                   ),
//                                 );
//                               }),
//                             ],
//                             if (washAndFoldItems.isNotEmpty) ...[
//                               const SizedBox(height: 10),
//                               const Text(
//                                 "Wash and Fold Items",
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
//                               ),
//                               ...washAndFoldItems.entries.map((entry) {
//                                 final itemLabel = entry.key.replaceFirst('washAndFold_', '');
//                                 final quantity = entry.value as int;
//                                 final item = _washAndFoldPrices.firstWhere(
//                                       (item) => item['label'] == itemLabel,
//                                   orElse: () => {"price": 0.0},
//                                 );
//                                 final price = (item['price'] as num?)?.toDouble() ?? 0.0;
//                                 final displayName = itemLabel.contains(": ") ? itemLabel.split(": ")[1] : itemLabel;
//                                 return ListTile(
//                                   contentPadding: EdgeInsets.zero,
//                                   title: Text(
//                                     "$displayName (x$quantity)",
//                                     style: const TextStyle(color: Colors.black54),
//                                   ),
//                                   trailing: Text(
//                                     "₹${(price * quantity).toStringAsFixed(2)}",
//                                     style: const TextStyle(color: Colors.black54),
//                                   ),
//                                 );
//                               }),
//                             ],
//                             if (washAndIronItems.isNotEmpty) ...[
//                               const SizedBox(height: 10),
//                               const Text(
//                                 "Wash and Iron Items",
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
//                               ),
//                               ...washAndIronItems.entries.map((entry) {
//                                 final itemLabel = entry.key.replaceFirst('washAndIron_', '');
//                                 final quantity = entry.value as int;
//                                 final item = _washAndIronPrices.firstWhere(
//                                       (item) => item['label'] == itemLabel,
//                                   orElse: () => {"price": 0.0},
//                                 );
//                                 final price = (item['price'] as num?)?.toDouble() ?? 0.0;
//                                 final displayName = itemLabel.contains(": ") ? itemLabel.split(": ")[1] : itemLabel;
//                                 return ListTile(
//                                   contentPadding: EdgeInsets.zero,
//                                   title: Text(
//                                     "$displayName (x$quantity)",
//                                     style: const TextStyle(color: Colors.black54),
//                                   ),
//                                   trailing: Text(
//                                     "₹${(price * quantity).toStringAsFixed(2)}",
//                                     style: const TextStyle(color: Colors.black54),
//                                   ),
//                                 );
//                               }),
//                             ],
//                             if (washIronStarchItems.isNotEmpty) ...[
//                               const SizedBox(height: 10),
//                               const Text(
//                                 "Wash, Iron & Starch Items",
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
//                               ),
//                               ...washIronStarchItems.entries.map((entry) {
//                                 final itemLabel = entry.key.replaceFirst('washIronStarch_', '');
//                                 final quantity = entry.value as int;
//                                 final item = _washIronStarchPrices.firstWhere(
//                                       (item) => item['label'] == itemLabel,
//                                   orElse: () => {"price": 0.0},
//                                 );
//                                 final price = (item['price'] as num?)?.toDouble() ?? 0.0;
//                                 final displayName = itemLabel.contains(": ") ? itemLabel.split(": ")[1] : itemLabel;
//                                 return ListTile(
//                                   contentPadding: EdgeInsets.zero,
//                                   title: Text(
//                                     "$displayName (x$quantity)",
//                                     style: const TextStyle(color: Colors.black54),
//                                   ),
//                                   trailing: Text(
//                                     "₹${(price * quantity).toStringAsFixed(2)}",
//                                     style: const TextStyle(color: Colors.black54),
//                                   ),
//                                 );
//                               }),
//                             ],
//                             if (ironingItems.isNotEmpty) ...[
//                               const SizedBox(height: 10),
//                               const Text(
//                                 "Ironing Items",
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
//                               ),
//                               ...ironingItems.entries.map((entry) {
//                                 final itemName = entry.key.replaceFirst('ironing_', '');
//                                 final quantity = entry.value as int;
//                                 final item = _ironingPrices.firstWhere(
//                                       (item) => item['name'] == itemName,
//                                   orElse: () => {"price": 0.0},
//                                 );
//                                 final price = (item['price'] as num?)?.toDouble() ?? 0.0;
//                                 return ListTile(
//                                   contentPadding: EdgeInsets.zero,
//                                   title: Text(
//                                     "$itemName (x$quantity)",
//                                     style: const TextStyle(color: Colors.black54),
//                                   ),
//                                   trailing: Text(
//                                     "₹${(price * quantity).toStringAsFixed(2)}",
//                                     style: const TextStyle(color: Colors.black54),
//                                   ),
//                                 );
//                               }),
//                             ],
//                             if (additionalServices.isNotEmpty) ...[
//                               const SizedBox(height: 10),
//                               const Text(
//                                 "Additional Services",
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
//                               ),
//                               ...additionalServices.entries.expand((entry) {
//                                 final category = entry.key;
//                                 final items = (entry.value as List<dynamic>? ?? []).map((item) {
//                                   if (item is Map) {
//                                     return Map<String, dynamic>.from(item);
//                                   }
//                                   return <String, dynamic>{};
//                                 }).toList();
//                                 return items.map((item) {
//                                   if (item.isEmpty) return const SizedBox.shrink();
//                                   final name = item['name'] as String? ?? 'Unknown';
//                                   final quantity = item['quantity'] as int? ?? 0;
//                                   final price = item['price'] as double? ?? 0.0;
//                                   return ListTile(
//                                     contentPadding: EdgeInsets.zero,
//                                     title: Text(
//                                       "$category: $name (x$quantity)",
//                                       style: const TextStyle(color: Colors.black54),
//                                     ),
//                                     trailing: Text(
//                                       "₹${(price * quantity).toStringAsFixed(2)}",
//                                       style: const TextStyle(color: Colors.black54),
//                                     ),
//                                   );
//                                 });
//                               }),
//                             ],
//                             if (subscriptionStatus != "Active Subscription - Placed Order") ...[
//                               const SizedBox(height: 10),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: [
//                                   // ### LOGIC APPLIED HERE FOR FINAL TOTAL DISPLAY ###
//                                   if (hasRegularWash && totalItemTypes == 1)
//                                     const Text(
//                                       "Service Booked",
//                                       style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.green),
//                                     )
//                                   else
//                                     Text(
//                                       "Total: ₹${total.toStringAsFixed(2)}",
//                                       style: const TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                           color: bgColorPink),
//                                     ),
//                                 ],
//                               ),
//                             ],
//                             const SizedBox(height: 10),
//                             if (orderStatus != 'Delivered' &&
//                                 orderStatus != 'Cancelled' &&
//                                 orderStatus != 'Laundry Collected' &&
//                                 _selectedIndex != 1)
//                               Align(
//                                 alignment: Alignment.centerRight,
//                                 child: ElevatedButton(
//                                   onPressed: () => _cancelOrder(orderId),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.red,
//                                     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                   ),
//                                   child: const Text(
//                                     "Cancel",
//                                     style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.local_shipping),
//             label: 'Placed',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.check_circle),
//             label: 'Delivered',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: bgColorPink,
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//         backgroundColor: Colors.white,
//         elevation: 8,
//         selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
//         unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constant/constant.dart';

class UserOrdersPage extends StatefulWidget {
  const UserOrdersPage({super.key});

  @override
  _UserOrdersPageState createState() => _UserOrdersPageState();
}

class _UserOrdersPageState extends State<UserOrdersPage> {
  String? _phoneNumber;
  bool _isLoading = true;
  bool _useFallbackQuery = true;
  List<Map<String, dynamic>> _dryCleanPrices = [];
  List<Map<String, dynamic>> _ironingPrices = [];
  List<Map<String, dynamic>> _washAndFoldPrices = [];
  List<Map<String, dynamic>> _washAndIronPrices = [];
  List<Map<String, dynamic>> _washIronStarchPrices = [];
  String? _errorMessage;
  final Map<String, String> _subscriptionStatuses = {};
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchPrices();
    _fetchSubscriptionStatuses();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.phoneNumber != null) {
      setState(() {
        _phoneNumber = user.phoneNumber;
        _isLoading = false;
      });
    } else {
      _showSnackBar("User not logged in.", isError: true);
      Navigator.pop(context);
    }
  }

  Future<void> _fetchPrices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
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
            "name": doc.id,
            "dry_clean": data["dry_clean"] ?? 0,
          };
        }).toList();

        _ironingPrices = ironingSnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            "name": doc.id,
            "price": data["price"] ?? 0,
          };
        }).toList();

        _washAndFoldPrices = [];
        if (washFoldResults.isNotEmpty && washFoldResults[0].exists) {
          final data = washFoldResults[0].data() as Map<String, dynamic>? ?? {};
          _washAndFoldPrices.add({
            "label": "By Weight: Regular Wash",
            "price": data["price"] ?? 0,
            "unit": "/KG",
          });
          _washAndFoldPrices.add({
            "label": "Premium Laundry",
            "price": data["premium_price"] ?? 159,
            "unit": "/KG",
          });
        }
        if (washFoldResults.length > 1 && washFoldResults[1].exists) {
          final data = washFoldResults[1].data() as Map<String, dynamic>? ?? {};
          _washAndFoldPrices.addAll([
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
              "unit": "/5 To 5.5 KG",
            },
            {
              "label": "One-Time: 5kg White Clothes",
              "price": data["white"] ?? 0,
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
                  "price": data["price"] ?? 0,
                  "unit": "/5 To 5.5 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
                {
                  "label": "Subscription: $times White Washes (5kg)",
                  "price": data["white"] ?? 0,
                  "unit": "/5 To 5.5 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
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
        }

        _washAndIronPrices = [];
        if (washIronResults.isNotEmpty && washIronResults[0].exists) {
          final data = washIronResults[0].data() as Map<String, dynamic>? ?? {};
          _washAndIronPrices.add({
            "label": "By Weight: Regular Wash",
            "price": data["price"] ?? 0,
            "unit": "/KG",
          });
          _washAndIronPrices.add({
            "label": "Premium Laundry",
            "price": data["premium_price"] ?? 159,
            "unit": "/KG",
          });
        }
        if (washIronResults.length > 1 && washIronResults[1].exists) {
          final data = washIronResults[1].data() as Map<String, dynamic>? ?? {};
          _washAndIronPrices.addAll([
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
              "unit": "/5 To 5.5 KG",
            },
            {
              "label": "One-Time: 5kg White Clothes",
              "price": data["white"] ?? 0,
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
                  "price": data["price"] ?? 0,
                  "unit": "/5 To 5.5 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
                {
                  "label": "Subscription: $times White Washes (5kg)",
                  "price": data["white"] ?? 0,
                  "unit": "/5 To 5.5 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
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
        }

        _washIronStarchPrices = [];
        if (washStarchResults.isNotEmpty && washStarchResults[0].exists) {
          final data = washStarchResults[0].data() as Map<String, dynamic>? ?? {};
          _washIronStarchPrices.add({
            "label": "By Weight: Regular Wash",
            "price": data["price"] ?? 0,
            "unit": "/KG",
          });
        }
        if (washStarchResults.length > 1 && washStarchResults[1].exists) {
          final data = washStarchResults[1].data() as Map<String, dynamic>? ?? {};
          _washIronStarchPrices.addAll([
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
              "unit": "/5 To 5.5 KG",
            },
            {
              "label": "One-Time: 5kg White Clothes",
              "price": data["white"] ?? 0,
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
                  "price": data["price"] ?? 0,
                  "unit": "/5 To 5.5 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
                {
                  "label": "Subscription: $times White (5kg)",
                  "price": data["white"] ?? 0,
                  "unit": "/5 To 5.5 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
                {
                  "label": "Subscription: $times Washes (3kg)",
                  "price": data["three"] ?? 0,
                  "unit": "/2.75 To 3 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
                {
                  "label": "Subscription: $times White (3kg)",
                  "price": data["white3"] ?? 0,
                  "unit": "/2.75 To 3 KG",
                  "month": data["month"] ?? 1,
                  "times": times,
                },
              ]);
            }
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load prices. Please try again.";
        print("Error fetching prices: $e");
      });
    }
  }

  Future<void> _fetchSubscriptionStatuses() async {
    try {
      final activeSubscriptions = await FirebaseFirestore.instance
          .collection('subscriptions')
          .where('userId', isEqualTo: _phoneNumber)
          .where('status', isEqualTo: 'Active')
          .get();
      setState(() {
        _subscriptionStatuses.clear();
        for (var doc in activeSubscriptions.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final subscriptionId = data['subscriptionId'] as String? ?? doc.id;
          _subscriptionStatuses[subscriptionId] = "Active Subscription - Placed Order";
        }
      });
    } catch (e) {
      print("Error fetching subscription statuses: $e");
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    if (_phoneNumber == null) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order"),
        content: Text("Are you sure you want to cancel order $orderId?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final orderDoc = await FirebaseFirestore.instance.collection('orders').doc(orderId).get();
      if (!orderDoc.exists || orderDoc.data()?['phoneNumber'] != _phoneNumber) {
        throw Exception("Order does not belong to user.");
      }

      final orderData = orderDoc.data() as Map<String, dynamic>;
      final subscriptionId = orderData['subscriptionId'] as String?;

      if (subscriptionId != null) {
        final subscriptionDoc = await FirebaseFirestore.instance
            .collection('subscriptions')
            .doc(subscriptionId)
            .get();
        if (subscriptionDoc.exists) {
          final subscriptionData = subscriptionDoc.data() as Map<String, dynamic>;
          int remainingWashes = (subscriptionData['remainingWashes'] as int?) ?? 0;
          await FirebaseFirestore.instance.collection('subscriptions').doc(subscriptionId).update({
            'remainingWashes': remainingWashes + 1,
          });
        }
      }

      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'orderStatus': 'Cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar("Order $orderId cancelled successfully.");
    } catch (e) {
      _showSnackBar("Failed to cancel order: $e", isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildWebLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _onItemTapped(0),
                      icon: const Icon(Icons.local_shipping),
                      label: const Text('Placed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedIndex == 0 ? bgColorPink : Colors.white,
                        foregroundColor: _selectedIndex == 0 ? Colors.white : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _onItemTapped(1),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Delivered'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedIndex == 1 ? bgColorPink : Colors.white,
                        foregroundColor: _selectedIndex == 1 ? Colors.white : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildOrderContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: bgColorPink));
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchPrices,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColorPink,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Retry", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      );
    }
    if (_phoneNumber == null) {
      return const Center(
        child: Text(
          "No user logged in.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_phoneNumber).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: bgColorPink));
        }
        if (userSnapshot.hasError) {
          return const Center(
            child: Text(
              "Error loading user data.",
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          );
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(
            child: Text(
              "No user data found.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        final orderIds = userData?['orderIds'] as List<dynamic>? ?? [];

        if (orderIds.isEmpty) {
          return const Center(
            child: Text(
              "No orders placed yet.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        List<List<dynamic>> orderIdChunks = [];
        for (int i = 0; i < orderIds.length; i += 10) {
          orderIdChunks.add(orderIds.sublist(i, i + 10 > orderIds.length ? orderIds.length : i + 10));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _useFallbackQuery
              ? Stream.fromIterable(orderIdChunks)
              .asyncMap((chunk) => FirebaseFirestore.instance
              .collection('orders')
              .where('orderId', whereIn: chunk)
              .get())
              .asyncExpand((querySnapshot) => Stream.value(querySnapshot))
              .map((event) => event)
              : FirebaseFirestore.instance
              .collection('orders')
              .where('orderId', whereIn: orderIds)
              .where('phoneNumber', isEqualTo: _phoneNumber)
              .orderBy('orderDate', descending: true)
              .snapshots(),
          builder: (context, orderSnapshot) {
            if (orderSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: bgColorPink));
            }
            if (orderSnapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Failed to load orders. Please try again later.",
                        style: TextStyle(fontSize: 18, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      if (orderSnapshot.error.toString().contains('FAILED_PRECONDITION'))
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "A required index is being created. Check back in a few minutes.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _useFallbackQuery = !_useFallbackQuery;
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgColorPink,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Retry", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (!orderSnapshot.hasData || orderSnapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  _selectedIndex == 0 ? "No placed orders found." : "No delivered or cancelled orders found.",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              );
            }

            final orders = orderSnapshot.data!.docs.where((doc) {
              final order = doc.data() as Map<String, dynamic>;
              final orderStatus = order['orderStatus'] as String? ?? 'Unknown';
              return _selectedIndex == 0
                  ? orderStatus != 'Delivered' && orderStatus != 'Cancelled'
                  : orderStatus == 'Delivered' || orderStatus == 'Cancelled';
            }).toList();

            if (orders.isEmpty) {
              return Center(
                child: Text(
                  _selectedIndex == 0 ? "No placed orders found." : "No delivered or cancelled orders found.",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              );
            }

            return _buildOrderList(orders);
          },
        );
      },
    );
  }

  Widget _buildOrderList(List<DocumentSnapshot> orders) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index].data() as Map<String, dynamic>;
          final orderId = order['orderId'] as String? ?? 'Unknown';
          final orderStatus = order['orderStatus'] as String? ?? 'Unknown';
          final orderDate = (order['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now();
          final dryCleanItems = order['dryCleanItems'] as Map<String, dynamic>? ?? {};
          final ironingItems = order['ironingItems'] as Map<String, dynamic>? ?? {};
          final washAndFoldItems = order['washAndFoldItems'] as Map<String, dynamic>? ?? {};
          final washAndIronItems = order['washAndIronItems'] as Map<String, dynamic>? ?? {};
          final washIronStarchItems = order['washIronStarchItems'] as Map<String, dynamic>? ?? {};
          final prePlatedItems = order['prePlatedItems'] as Map<String, dynamic>? ?? {};
          final additionalServices = order['additionalServices'] as Map<String, dynamic>? ?? {};
          final subscriptionId = order['subscriptionId'] as String?;

          int totalItemTypes = dryCleanItems.length +
              ironingItems.length +
              washAndFoldItems.length +
              washAndIronItems.length +
              washIronStarchItems.length +
              prePlatedItems.length +
              additionalServices.length;

          bool hasRegularWash =
              washAndFoldItems.keys.any((k) => k.contains('Regular Wash')) ||
                  washAndIronItems.keys.any((k) => k.contains('Regular Wash')) ||
                  washIronStarchItems.keys.any((k) => k.contains('Regular Wash'));

          double dryCleanTotal = 0.0;
          double ironingTotal = 0.0;
          double washAndFoldTotal = 0.0;
          double washAndIronTotal = 0.0;
          double washIronStarchTotal = 0.0;
          double prePlatedTotal = 0.0;
          double additionalTotal = 0.0;

          dryCleanItems.forEach((key, value) {
            final itemName = key.replaceFirst('dryClean_', '');
            final quantity = (value as num?)?.toInt() ?? 0;
            final item = _dryCleanPrices.firstWhere(
                  (item) => item['name'] == itemName,
              orElse: () => {"dry_clean": 0.0},
            );
            final price = (item['dry_clean'] as num?)?.toDouble() ?? 0.0;
            dryCleanTotal += price * quantity;
          });

          ironingItems.forEach((key, value) {
            final itemName = key.replaceFirst('ironing_', '');
            final quantity = (value as num?)?.toInt() ?? 0;
            final item = _ironingPrices.firstWhere(
                  (item) => item['name'] == itemName,
              orElse: () => {"price": 0.0},
            );
            final price = (item['price'] as num?)?.toDouble() ?? 0.0;
            ironingTotal += price * quantity;
          });

          washAndFoldItems.forEach((key, value) {
            final itemLabel = key.replaceFirst('washAndFold_', '');
            final quantity = (value as num?)?.toInt() ?? 0;
            final item = _washAndFoldPrices.firstWhere(
                  (item) => item['label'] == itemLabel,
              orElse: () => {"price": 0.0},
            );
            double price = (item['price'] as num?)?.toDouble() ?? 0.0;
            bool isRegularWashItem = itemLabel.contains('Regular Wash');
            if (isRegularWashItem && totalItemTypes > 1) {
              price = 0.0;
            }
            washAndFoldTotal += price * quantity;
          });

          washAndIronItems.forEach((key, value) {
            final itemLabel = key.replaceFirst('washAndIron_', '');
            final quantity = (value as num?)?.toInt() ?? 0;
            final item = _washAndIronPrices.firstWhere(
                  (item) => item['label'] == itemLabel,
              orElse: () => {"price": 0.0},
            );
            double price = (item['price'] as num?)?.toDouble() ?? 0.0;
            bool isRegularWashItem = itemLabel.contains('Regular Wash');
            if (isRegularWashItem && totalItemTypes > 1) {
              price = 0.0;
            }
            washAndIronTotal += price * quantity;
          });

          washIronStarchItems.forEach((key, value) {
            final itemLabel = key.replaceFirst('washIronStarch_', '');
            final quantity = (value as num?)?.toInt() ?? 0;
            final item = _washIronStarchPrices.firstWhere(
                  (item) => item['label'] == itemLabel,
              orElse: () => {"price": 0.0},
            );
            double price = (item['price'] as num?)?.toDouble() ?? 0.0;
            bool isRegularWashItem = itemLabel.contains('Regular Wash');
            if (isRegularWashItem && totalItemTypes > 1) {
              price = 0.0;
            }
            washIronStarchTotal += price * quantity;
          });

          prePlatedItems.forEach((key, value) {
            final quantity = (value['quantity'] as num?)?.toInt() ?? 0;
            final price = (value['pricePerItem'] as num?)?.toDouble() ?? 0.0;
            prePlatedTotal += price * quantity;
          });

          additionalServices.forEach((category, items) {
            for (var item in (items as List<dynamic>)) {
              final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
              final price = (item['price'] as num?)?.toDouble() ?? 0.0;
              additionalTotal += price * quantity;
            }
          });

          final total = dryCleanTotal + ironingTotal + washAndFoldTotal + washAndIronTotal + washIronStarchTotal + prePlatedTotal + additionalTotal;
          final subscriptionStatus = subscriptionId != null ? _subscriptionStatuses[subscriptionId] ?? "New Subscription - Awaiting Payment" : "";

          if (order['phoneNumber'] != _phoneNumber) {
            return const SizedBox.shrink();
          }

          return Card(
            elevation: 6,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order #$orderId",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Row(
                        children: [
                          Icon(
                            orderStatus == 'Awaiting Pickup'
                                ? Icons.local_shipping
                                : orderStatus == 'Laundry Collected'
                                ? Icons.check_circle_outline
                                : orderStatus == 'Delivered'
                                ? Icons.done_all
                                : Icons.info_outline,
                            color: orderStatus == 'Awaiting Pickup'
                                ? Colors.green
                                : orderStatus == 'Cancelled'
                                ? Colors.red
                                : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            orderStatus,
                            style: TextStyle(
                              fontSize: 16,
                              color: orderStatus == 'Awaiting Pickup'
                                  ? Colors.green
                                  : orderStatus == 'Cancelled'
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (subscriptionStatus.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      subscriptionStatus,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: subscriptionStatus.contains("Awaiting Payment") ? Colors.orange : Colors.green,
                      ),
                    ),
                  ],
                  if (orderStatus == 'Awaiting Pickup' ||
                      orderStatus == 'Laundry Collected' ||
                      orderStatus == 'Delivered')
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Lottie.asset(
                          orderStatus == 'Awaiting Pickup'
                              ? 'assets/animations/delivered.json'
                              : orderStatus == 'Laundry Collected'
                              ? 'assets/animations/Animation.json'
                              : 'assets/animations/pickup.json',
                          height: 120,
                          fit: BoxFit.contain,
                          repeat: orderStatus != 'Delivered',
                          animate: true,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    "Date: ${orderDate.toLocal().toString().split('.')[0]}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const Divider(height: 20, thickness: 1),
                  if (dryCleanItems.isNotEmpty) ...[
                    const Text(
                      "Dry Clean Items",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    ...dryCleanItems.entries.map((entry) {
                      final itemName = entry.key.replaceFirst('dryClean_', '');
                      final quantity = entry.value as int;
                      final item = _dryCleanPrices.firstWhere(
                            (item) => item['name'] == itemName,
                        orElse: () => {"dry_clean": 0.0},
                      );
                      final price = (item['dry_clean'] as num?)?.toDouble() ?? 0.0;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "$itemName (x$quantity)",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: Text(
                          "₹${(price * quantity).toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      );
                    }),
                  ],
                  if (prePlatedItems.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      "Pre-Plated Items",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    ...prePlatedItems.entries.map((entry) {
                      final itemName = entry.key.replaceFirst('prePlated_', '');
                      final quantity = (entry.value['quantity'] as num?)?.toInt() ?? 0;
                      final price = (entry.value['pricePerItem'] as num?)?.toDouble() ?? 0.0;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "$itemName (x$quantity)",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: Text(
                          "₹${(price * quantity).toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      );
                    }),
                  ],
                  if (washAndFoldItems.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      "Wash and Fold Items",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    ...washAndFoldItems.entries.map((entry) {
                      final itemLabel = entry.key.replaceFirst('washAndFold_', '');
                      final quantity = entry.value as int;
                      final item = _washAndFoldPrices.firstWhere(
                            (item) => item['label'] == itemLabel,
                        orElse: () => {"price": 0.0},
                      );
                      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                      final displayName = itemLabel.contains(": ") ? itemLabel.split(": ")[1] : itemLabel;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "$displayName (x$quantity)",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: Text(
                          "₹${(price * quantity).toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      );
                    }),
                  ],
                  if (washAndIronItems.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      "Wash and Iron Items",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    ...washAndIronItems.entries.map((entry) {
                      final itemLabel = entry.key.replaceFirst('washAndIron_', '');
                      final quantity = entry.value as int;
                      final item = _washAndIronPrices.firstWhere(
                            (item) => item['label'] == itemLabel,
                        orElse: () => {"price": 0.0},
                      );
                      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                      final displayName = itemLabel.contains(": ") ? itemLabel.split(": ")[1] : itemLabel;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "$displayName (x$quantity)",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: Text(
                          "₹${(price * quantity).toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      );
                    }),
                  ],
                  if (washIronStarchItems.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      "Wash, Iron & Starch Items",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    ...washIronStarchItems.entries.map((entry) {
                      final itemLabel = entry.key.replaceFirst('washIronStarch_', '');
                      final quantity = entry.value as int;
                      final item = _washIronStarchPrices.firstWhere(
                            (item) => item['label'] == itemLabel,
                        orElse: () => {"price": 0.0},
                      );
                      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                      final displayName = itemLabel.contains(": ") ? itemLabel.split(": ")[1] : itemLabel;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "$displayName (x$quantity)",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: Text(
                          "₹${(price * quantity).toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      );
                    }),
                  ],
                  if (ironingItems.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      "Ironing Items",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    ...ironingItems.entries.map((entry) {
                      final itemName = entry.key.replaceFirst('ironing_', '');
                      final quantity = entry.value as int;
                      final item = _ironingPrices.firstWhere(
                            (item) => item['name'] == itemName,
                        orElse: () => {"price": 0.0},
                      );
                      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "$itemName (x$quantity)",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: Text(
                          "₹${(price * quantity).toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      );
                    }),
                  ],
                  if (additionalServices.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      "Additional Services",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    ...additionalServices.entries.expand((entry) {
                      final category = entry.key;
                      final items = (entry.value as List<dynamic>? ?? []).map((item) {
                        if (item is Map) {
                          return Map<String, dynamic>.from(item);
                        }
                        return <String, dynamic>{};
                      }).toList();
                      return items.map((item) {
                        if (item.isEmpty) return const SizedBox.shrink();
                        final name = item['name'] as String? ?? 'Unknown';
                        final quantity = item['quantity'] as int? ?? 0;
                        final price = item['price'] as double? ?? 0.0;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            "$category: $name (x$quantity)",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          trailing: Text(
                            "₹${(price * quantity).toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.black54),
                          ),
                        );
                      });
                    }),
                  ],
                  if (subscriptionStatus != "Active Subscription - Placed Order") ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (hasRegularWash && totalItemTypes == 1)
                          const Text(
                            "Service Booked",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          )
                        else
                          Text(
                            "Total: ₹${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: bgColorPink),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (orderStatus != 'Delivered' &&
                      orderStatus != 'Cancelled' &&
                      orderStatus != 'Laundry Collected' &&
                      _selectedIndex != 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => _cancelOrder(orderId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWeb = constraints.maxWidth > 800;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "My Orders",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
            ),
            backgroundColor: bgColorPink,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: _isLoading ? null : () => Navigator.pop(context),
            ),
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          body: isWeb ? _buildWebLayout(context) : Padding(
            padding: const EdgeInsets.all(10),
            child: ListView.builder(
              itemCount: 1, // Placeholder for mobile layout
              itemBuilder: (context, index) {
                return Container(); // Placeholder, to be replaced with actual mobile content
              },
            ),
          ),
          bottomNavigationBar: isWeb
              ? null
              : BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping),
                label: 'Placed',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle),
                label: 'Delivered',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: bgColorPink,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            elevation: 8,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          ),
        );
      },
    );
  }
}