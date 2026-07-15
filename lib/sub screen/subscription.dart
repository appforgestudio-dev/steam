import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constant/cart_persistence.dart';
import '../constant/constant.dart';

class SubscriptionDetailsPage extends StatefulWidget {
  const SubscriptionDetailsPage({super.key});

  @override
  State<SubscriptionDetailsPage> createState() => _SubscriptionDetailsPageState();
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
                  color: bgColorPink.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_laundry_service_rounded, color: bgColorPink, size: 40),
              ),
              const SizedBox(height: 18),
              const Text(
                "Use Wash?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              const Text(
                "Are you sure you want to use a wash from this subscription? This will be saved as an order.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.3),
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
                        backgroundColor: bgColorPink,
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order $orderId created from subscription $label. Remaining washes: ${remainingWashes - 1}."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to use wash: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'washAndFold':
        return Icons.local_laundry_service_outlined;
      case 'washAndIron':
        return Icons.iron_outlined;
      case 'dryClean':
        return Icons.dry_cleaning_outlined;
      default:
        return Icons.star_outline_rounded;
    }
  }

  Widget _buildSubscriptionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: bgColorPink));
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
          return const Center(child: CircularProgressIndicator(color: bgColorPink));
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    "Failed to load subscriptions. Please try again later.",
                    style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  if (snapshot.error.toString().contains('FAILED_PRECONDITION'))
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "A required index is being created. Check back in a few minutes.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    onPressed: () => setState(() {
                      _useFallbackQuery = !_useFallbackQuery;
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bgColorPink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    label: const Text("Retry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                  child: Icon(Icons.card_membership_rounded, color: Colors.grey.shade400, size: 64),
                ),
                const SizedBox(height: 20),
                const Text(
                  "No active subscriptions found.",
                  style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your active plans will appear here.",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        final subscriptions = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: subscriptions.length,
          itemBuilder: (context, index) {
            final subscription = subscriptions[index].data() as Map<String, dynamic>;
            final subscriptionId = subscriptions[index].id;
            final label = subscription['label'] as String? ?? 'Subscription Plan';
            final remainingWashes = subscription['remainingWashes'] as int? ?? 0;
            final category = subscription['category'] as String?;
            final startDate = (subscription['startDate'] as Timestamp?)?.toDate() ?? DateTime.now();
            final validUntil = (subscription['validUntil'] as Timestamp?)?.toDate() ?? DateTime.now();
            final formattedStartDate = DateFormat('MMM dd, yyyy').format(startDate);
            final formattedValidUntil = DateFormat('MMM dd, yyyy').format(validUntil);

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
                    // Top Accent bar with Title
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColorPink.withValues(alpha: 0.05),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getCategoryIcon(category), color: bgColorPink, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: remainingWashes > 0 ? bgColorPink : Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              remainingWashes > 0 ? "$remainingWashes Washes" : "No Washes",
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
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
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateItem(
                                  Icons.calendar_today_rounded,
                                  "Start Date",
                                  formattedStartDate,
                                ),
                              ),
                              Container(height: 32, width: 1, color: Colors.grey.shade200),
                              Expanded(
                                child: _buildDateItem(
                                  Icons.event_available_rounded,
                                  "Valid Until",
                                  formattedValidUntil,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: remainingWashes > 0
                                  ? () => _useSubscriptionWash(subscriptionId)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bgColorPink,
                                disabledBackgroundColor: Colors.grey.shade200,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: Text(
                                remainingWashes > 0 ? "Use Wash \u2192" : "Expired / Empty",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: remainingWashes > 0 ? Colors.white : Colors.grey.shade500,
                                ),
                              ),
                            ),
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
      },
    );
  }

  Widget _buildDateItem(IconData icon, String title, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black38, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(date, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bgColorPink.withValues(alpha: 0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColorPink.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline_rounded, color: bgColorPink, size: 20),
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Text(
                  'Subscription will be activated after payment.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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

  Widget _buildWebLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: bgColorPink.withValues(alpha: 0.15), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bgColorPink.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: bgColorPink, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Flexible(
                    child: Text(
                      'Subscription will be activated after payment.',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
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
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text(
          "Active Subscriptions",
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
        child: isMobile ? _buildMobileLayout(context) : _buildWebLayout(context),
      ),
    );
  }
}
