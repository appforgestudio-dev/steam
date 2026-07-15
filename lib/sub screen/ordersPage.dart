import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../constant/constant.dart';

class UserOrdersPage extends StatefulWidget {
  const UserOrdersPage({super.key});

  @override
  State<UserOrdersPage> createState() => _UserOrdersPageState();
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_outlined, color: Colors.red, size: 40),
              ),
              const SizedBox(height: 18),
              const Text(
                "Cancel Order",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Text(
                "Are you sure you want to cancel order #$orderId?",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.3),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("No", style: TextStyle(color: Colors.black54, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text("Yes", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _onItemTapped(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedIndex == 0 ? bgColorPink : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Active Orders",
                    style: TextStyle(
                      color: _selectedIndex == 0 ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _onItemTapped(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1 ? bgColorPink : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Past Orders",
                    style: TextStyle(
                      color: _selectedIndex == 1 ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt_long_rounded, color: Colors.grey.shade400, size: 64),
                ),
                const SizedBox(height: 20),
                const Text(
                  "No orders placed yet.",
                  style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your orders will appear here.",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
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
                  _selectedIndex == 0 ? "No active orders found." : "No delivered or cancelled orders found.",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
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
                  _selectedIndex == 0 ? "No active orders found." : "No delivered or cancelled orders found.",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              );
            }

            return _buildOrderList(orders);
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Awaiting Pickup':
        return Colors.orange;
      case 'Laundry Collected':
      case 'Processing':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderList(List<DocumentSnapshot> orders) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        final statusColor = _getStatusColor(orderStatus);

        if (order['phoneNumber'] != _phoneNumber) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: bgColorPink.withValues(alpha: 0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColorPink.withValues(alpha: 0.04),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order #$orderId",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          orderStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subscriptionStatus.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: subscriptionStatus.contains("Awaiting Payment") ? Colors.orange.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: subscriptionStatus.contains("Awaiting Payment") ? Colors.orange : Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  subscriptionStatus,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: subscriptionStatus.contains("Awaiting Payment") ? Colors.orange.shade800 : Colors.green.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (orderStatus == 'Awaiting Pickup' ||
                          orderStatus == 'Laundry Collected' ||
                          orderStatus == 'Delivered')
                        Container(
                          height: 130,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Lottie.asset(
                              orderStatus == 'Awaiting Pickup'
                                  ? 'assets/animations/delivered.json'
                                  : orderStatus == 'Laundry Collected'
                                      ? 'assets/animations/Animation.json'
                                      : 'assets/animations/pickup.json',
                              height: 110,
                              fit: BoxFit.contain,
                              repeat: orderStatus != 'Delivered',
                              animate: true,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, color: Colors.grey.shade400, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMM dd, yyyy - hh:mm a').format(orderDate.toLocal()),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 12),
                      // List of items
                      _buildItemsSection("Dry Clean Items", dryCleanItems, (itemName, quantity) {
                        final item = _dryCleanPrices.firstWhere(
                          (item) => item['name'] == itemName,
                          orElse: () => {"dry_clean": 0.0},
                        );
                        final price = (item['dry_clean'] as num?)?.toDouble() ?? 0.0;
                        return price * quantity;
                      }),
                      _buildItemsSection("Pre-Plated Items", prePlatedItems, (itemName, quantity) {
                        final dynamic value = prePlatedItems[itemName] ?? prePlatedItems['prePlated_$itemName'];
                        if (value is Map) {
                          final price = (value['pricePerItem'] as num?)?.toDouble() ?? 0.0;
                          return price * quantity;
                        }
                        return 0.0;
                      }, isPreplated: true),
                      _buildItemsSection("Wash and Fold Items", washAndFoldItems, (itemLabel, quantity) {
                        final item = _washAndFoldPrices.firstWhere(
                          (item) => item['label'] == itemLabel,
                          orElse: () => {"price": 0.0},
                        );
                        double price = (item['price'] as num?)?.toDouble() ?? 0.0;
                        if (itemLabel.contains('Regular Wash') && totalItemTypes > 1) price = 0.0;
                        return price * quantity;
                      }),
                      _buildItemsSection("Wash and Iron Items", washAndIronItems, (itemLabel, quantity) {
                        final item = _washAndIronPrices.firstWhere(
                          (item) => item['label'] == itemLabel,
                          orElse: () => {"price": 0.0},
                        );
                        double price = (item['price'] as num?)?.toDouble() ?? 0.0;
                        if (itemLabel.contains('Regular Wash') && totalItemTypes > 1) price = 0.0;
                        return price * quantity;
                      }),
                      _buildItemsSection("Wash, Iron & Starch Items", washIronStarchItems, (itemLabel, quantity) {
                        final item = _washIronStarchPrices.firstWhere(
                          (item) => item['label'] == itemLabel,
                          orElse: () => {"price": 0.0},
                        );
                        double price = (item['price'] as num?)?.toDouble() ?? 0.0;
                        if (itemLabel.contains('Regular Wash') && totalItemTypes > 1) price = 0.0;
                        return price * quantity;
                      }),
                      if (ironingItems.isNotEmpty) ...[
                        _buildItemsSection("Ironing Items", ironingItems, (itemName, quantity) {
                          final item = _ironingPrices.firstWhere(
                            (item) => item['name'] == itemName,
                            orElse: () => {"price": 0.0},
                          );
                          final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                          return price * quantity;
                        }),
                      ],
                      if (additionalServices.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          "Additional Services",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        ...additionalServices.entries.expand((entry) {
                          final category = entry.key;
                          final items = (entry.value as List<dynamic>? ?? []).map((item) {
                            if (item is Map) return Map<String, dynamic>.from(item);
                            return <String, dynamic>{};
                          }).toList();
                          return items.map((item) {
                            if (item.isEmpty) return const SizedBox.shrink();
                            final name = item['name'] as String? ?? 'Unknown';
                            final quantity = item['quantity'] as int? ?? 0;
                            final price = item['price'] as double? ?? 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "$category: $name (x$quantity)",
                                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                                    ),
                                  ),
                                  Text(
                                    "₹${(price * quantity).toStringAsFixed(2)}",
                                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          });
                        }),
                      ],
                      const SizedBox(height: 12),
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 12),
                      // Total & Action Button row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (subscriptionStatus != "Active Subscription - Placed Order")
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Total Amount", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(
                                  "₹${total.toStringAsFixed(2)}",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ],
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Subscription Placed",
                                style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (orderStatus != 'Delivered' &&
                              orderStatus != 'Cancelled' &&
                              orderStatus != 'Laundry Collected' &&
                              _selectedIndex != 1)
                            OutlinedButton(
                              onPressed: () => _cancelOrder(orderId),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red.shade200),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              child: const Text(
                                "Cancel Order",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemsSection(
    String sectionTitle,
    Map<String, dynamic> items,
    double Function(String key, int quantity) getSubtotal, {
    bool isPreplated = false,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          sectionTitle,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        ...items.entries.map((entry) {
          final rawKey = entry.key;
          final cleanKey = rawKey
              .replaceFirst('dryClean_', '')
              .replaceFirst('ironing_', '')
              .replaceFirst('washAndFold_', '')
              .replaceFirst('washAndIron_', '')
              .replaceFirst('washIronStarch_', '')
              .replaceFirst('prePlated_', '');
          final quantity = isPreplated
              ? (entry.value['quantity'] as num?)?.toInt() ?? 0
              : (entry.value as num?)?.toInt() ?? 0;
          final subtotal = getSubtotal(rawKey, quantity);
          final displayName = cleanKey.contains(": ") ? cleanKey.split(": ")[1] : cleanKey;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "$displayName (x$quantity)",
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ),
                Text(
                  "₹${subtotal.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            _buildTabSelector(),
            Expanded(
              child: _buildOrderContent(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: bgColorPink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: isMobile ? Column(
          children: [
            _buildTabSelector(),
            Expanded(
              child: _buildOrderContent(),
            ),
          ],
        ) : _buildWebLayout(context),
      ),
    );
  }
}