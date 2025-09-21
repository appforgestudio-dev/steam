// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:steam/constant/constant.dart';
// import '../constant/cart_persistence.dart';
//
// class SubscriptionDetailsPage extends StatefulWidget {
//   const SubscriptionDetailsPage({super.key});
//
//   @override
//   _SubscriptionDetailsPageState createState() => _SubscriptionDetailsPageState();
// }
//
// class _SubscriptionDetailsPageState extends State<SubscriptionDetailsPage> {
//   String? _phoneNumber;
//   bool _isLoading = true;
//   String? _errorMessage;
//   bool _useFallbackQuery = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//   }
//
//   Future<void> _fetchUserData() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null && user.phoneNumber != null) {
//       setState(() {
//         _phoneNumber = user.phoneNumber;
//         print("Fetching subscriptions for userId: $_phoneNumber at 06:35 PM IST on June 28, 2025");
//         _isLoading = false;
//       });
//     } else {
//       setState(() {
//         _errorMessage = "User not logged in or phone number not available.";
//         _isLoading = false;
//       });
//       Navigator.pop(context);
//     }
//   }
//
//   Future<void> _useSubscriptionWash(String subscriptionId) async {
//     if (_phoneNumber == null) return;
//
//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Use Wash"),
//         content: const Text("Are you sure you want to use a wash from this subscription? This will be saved as an order."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text("No"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text("Yes", style: TextStyle(color: bgColorPink)),
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
//       final subscriptionDoc = await FirebaseFirestore.instance.collection('subscriptions').doc(subscriptionId).get();
//       if (!subscriptionDoc.exists || subscriptionDoc.data()?['userId'] != _phoneNumber) {
//         throw Exception("Subscription $subscriptionId does not belong to user $_phoneNumber.");
//       }
//
//       final remainingWashes = (subscriptionDoc.data()?['remainingWashes'] as int?) ?? 0;
//       if (remainingWashes <= 0) {
//         throw Exception("No remaining washes for subscription $subscriptionId.");
//       }
//
//       final category = subscriptionDoc.data()?['category'] as String? ?? 'washAndFold';
//       final label = subscriptionDoc.data()?['label'] as String? ?? 'Unknown Subscription';
//
//       // Update remaining washes
//       await FirebaseFirestore.instance.collection('subscriptions').doc(subscriptionId).update({
//         'remainingWashes': FieldValue.increment(-1),
//       });
//
//       // Save directly to orders collection
//       final orderId = await CartPersistence.saveSubscriptionOrder(
//         subscriptionId: subscriptionId,
//         category: category,
//         label: label,
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Order $orderId created from subscription $label. Remaining washes: ${remainingWashes - 1}."),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to use wash: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Active Subscriptions", style: TextStyle(color: Colors.white)),
//         backgroundColor: bgColorPink,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//           onPressed: _isLoading ? null : () => Navigator.pop(context),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _phoneNumber == null
//           ? Center(
//         child: Text(
//           _errorMessage ?? "No user logged in.",
//           style: const TextStyle(fontSize: 16, color: Colors.red),
//         ),
//       )
//           : Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             color: bgColorPink.withOpacity(0.1),
//             child: Row(
//               children: [
//                 Icon(Icons.info_outline, color: bgColorPink, size: 20),
//                 const SizedBox(width: 8),
//                 Flexible(
//                   child: Text(
//                     'Subscription will be activated after payment.',
//                     style: TextStyle(
//                       color: Colors.grey[700],
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _useFallbackQuery
//                   ? FirebaseFirestore.instance
//                   .collection('subscriptions')
//                   .where('userId', isEqualTo: _phoneNumber)
//                   .where('status', isEqualTo: 'Active')
//                   .snapshots()
//                   : FirebaseFirestore.instance
//                   .collection('subscriptions')
//                   .where('userId', isEqualTo: _phoneNumber)
//                   .where('status', isEqualTo: 'Active')
//                   .orderBy('startDate', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   print("Error fetching subscriptions at 06:35 PM IST on June 28, 2025: ${snapshot.error}");
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Failed to load subscriptions. Please try again later.",
//                           style: const TextStyle(fontSize: 16, color: Colors.red),
//                           textAlign: TextAlign.center,
//                         ),
//                         if (snapshot.error.toString().contains('FAILED_PRECONDITION'))
//                           const Padding(
//                             padding: EdgeInsets.all(16.0),
//                             child: Text(
//                               "A required index is being created. Check back in a few minutes.",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                           ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: () => setState(() {
//                             _useFallbackQuery = !_useFallbackQuery;
//                           }),
//                           style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], foregroundColor: Colors.white),
//                           child: const Text("Retry"),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   print("No active subscriptions found for userId: $_phoneNumber at 06:35 PM IST on June 28, 2025");
//                   return const Center(
//                     child: Text(
//                       "No active subscriptions found.",
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     ),
//                   );
//                 }
//
//                 final subscriptions = snapshot.data!.docs;
//
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: subscriptions.length,
//                   itemBuilder: (context, index) {
//                     final subscription = subscriptions[index].data() as Map<String, dynamic>;
//                     final subscriptionId = subscriptions[index].id;
//                     final label = subscription['label'] as String? ?? 'Unknown';
//                     final remainingWashes = subscription['remainingWashes'] as int? ?? 0;
//                     final startDate = (subscription['startDate'] as Timestamp?)?.toDate() ?? DateTime.now();
//                     final validUntil = (subscription['validUntil'] as Timestamp?)?.toDate() ?? DateTime.now();
//                     final formattedStartDate = DateFormat('MMM dd yyyy').format(startDate);
//                     final formattedValidUntil = DateFormat('MMM dd yyyy').format(validUntil);
//
//                     return Card(
//                       elevation: 2,
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               label,
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               "Start Date: $formattedStartDate",
//                               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                             ),
//                             Text(
//                               "Valid Until: $formattedValidUntil",
//                               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                             ),
//                             Text(
//                               "Remaining Washes: $remainingWashes",
//                               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                             ),
//                             const SizedBox(height: 12),
//                             Align(
//                               alignment: Alignment.centerRight,
//                               child: ElevatedButton(
//                                 onPressed: remainingWashes > 0
//                                     ? () => _useSubscriptionWash(subscriptionId)
//                                     : null,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: remainingWashes > 0 ? bgColorPink : Colors.grey,
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                 ),
//                                 child: Text(
//                                   remainingWashes > 0 ? "Use Wash" : "Expired",
//                                   style: const TextStyle(fontWeight: FontWeight.w600),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constant/cart_persistence.dart';
import '../constant/constant.dart';

class SubscriptionDetailsPage extends StatefulWidget {
  const SubscriptionDetailsPage({super.key});

  @override
  _SubscriptionDetailsPageState createState() => _SubscriptionDetailsPageState();
}

class _SubscriptionDetailsPageState extends State<SubscriptionDetailsPage> {
  String? _phoneNumber;
  bool _isLoading = true;
  String? _errorMessage;
  bool _useFallbackQuery = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.phoneNumber != null) {
      setState(() {
        _phoneNumber = user.phoneNumber;
        print("Fetching subscriptions for userId: $_phoneNumber at 06:35 PM IST on June 28, 2025");
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = "User not logged in or phone number not available.";
        _isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  Future<void> _useSubscriptionWash(String subscriptionId) async {
    if (_phoneNumber == null) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Use Wash"),
        content: const Text("Are you sure you want to use a wash from this subscription? This will be saved as an order."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes", style: TextStyle(color: bgColorPink)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final subscriptionDoc = await FirebaseFirestore.instance.collection('subscriptions').doc(subscriptionId).get();
      if (!subscriptionDoc.exists || subscriptionDoc.data()?['userId'] != _phoneNumber) {
        throw Exception("Subscription $subscriptionId does not belong to user $_phoneNumber.");
      }

      final remainingWashes = (subscriptionDoc.data()?['remainingWashes'] as int?) ?? 0;
      if (remainingWashes <= 0) {
        throw Exception("No remaining washes for subscription $subscriptionId.");
      }

      final category = subscriptionDoc.data()?['category'] as String? ?? 'washAndFold';
      final label = subscriptionDoc.data()?['label'] as String? ?? 'Unknown Subscription';

      // Update remaining washes
      await FirebaseFirestore.instance.collection('subscriptions').doc(subscriptionId).update({
        'remainingWashes': FieldValue.increment(-1),
      });

      // Save directly to orders collection
      final orderId = await CartPersistence.saveSubscriptionOrder(
        subscriptionId: subscriptionId,
        category: category,
        label: label,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order $orderId created from subscription $label. Remaining washes: ${remainingWashes - 1}."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to use wash: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Common widget to build the subscription list
  Widget _buildSubscriptionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_phoneNumber == null) {
      return Center(
        child: Text(
          _errorMessage ?? "No user logged in.",
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _useFallbackQuery
          ? FirebaseFirestore.instance
          .collection('subscriptions')
          .where('userId', isEqualTo: _phoneNumber)
          .where('status', isEqualTo: 'Active')
          .snapshots()
          : FirebaseFirestore.instance
          .collection('subscriptions')
          .where('userId', isEqualTo: _phoneNumber)
          .where('status', isEqualTo: 'Active')
          .orderBy('startDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print("Error fetching subscriptions at 06:35 PM IST on June 28, 2025: ${snapshot.error}");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Failed to load subscriptions. Please try again later.",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                if (snapshot.error.toString().contains('FAILED_PRECONDITION'))
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "A required index is being created. Check back in a few minutes.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _useFallbackQuery = !_useFallbackQuery;
                  }),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], foregroundColor: Colors.white),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print("No active subscriptions found for userId: $_phoneNumber at 06:35 PM IST on June 28, 2025");
          return const Center(
            child: Text(
              "No active subscriptions found.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final subscriptions = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: subscriptions.length,
          itemBuilder: (context, index) {
            final subscription = subscriptions[index].data() as Map<String, dynamic>;
            final subscriptionId = subscriptions[index].id;
            final label = subscription['label'] as String? ?? 'Unknown';
            final remainingWashes = subscription['remainingWashes'] as int? ?? 0;
            final startDate = (subscription['startDate'] as Timestamp?)?.toDate() ?? DateTime.now();
            final validUntil = (subscription['validUntil'] as Timestamp?)?.toDate() ?? DateTime.now();
            final formattedStartDate = DateFormat('MMM dd yyyy').format(startDate);
            final formattedValidUntil = DateFormat('MMM dd yyyy').format(validUntil);

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Start Date: $formattedStartDate",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      "Valid Until: $formattedValidUntil",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      "Remaining Washes: $remainingWashes",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: remainingWashes > 0
                            ? () => _useSubscriptionWash(subscriptionId)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: remainingWashes > 0 ? bgColorPink : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          remainingWashes > 0 ? "Use Wash" : "Expired",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Mobile-specific layout
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: bgColorPink.withOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: bgColorPink, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Subscription will be activated after payment.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildSubscriptionList(),
        ),
      ],
    );
  }

  // Web-specific layout
  Widget _buildWebLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              color: bgColorPink.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: bgColorPink, size: 24),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Subscription will be activated after payment.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildSubscriptionList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const mobileBreakpoint = 600.0;
    final bool isMobile = screenWidth < mobileBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Active Subscriptions", style: TextStyle(color: Colors.white)),
        backgroundColor: bgColorPink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: isMobile ? _buildMobileLayout(context) : _buildWebLayout(context),
      ),
    );
  }
}
