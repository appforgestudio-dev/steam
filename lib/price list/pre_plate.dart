import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
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
          "Saree Fancy": (sareeFancyDoc.data())?["dry_clean"]?.toDouble() ?? 0.0,
          "Saree Medium": (sareeMediumDoc.data())?["dry_clean"]?.toDouble() ?? 0.0,
          "Saree Heavy": (sareeHeavyDoc.data())?["dry_clean"]?.toDouble() ?? 0.0,
          "Saree Plain": (sareePlainDoc.data())?["dry_clean"]?.toDouble() ?? 0.0,
        };
        commonDryCleanStarchPrice = (dryCleanPrePlateDoc.data())?["starch"]?.toDouble() ?? 0.0;
        dryCleanCalculatedTotals = {
          "Saree Fancy": (dryCleanPrePlateDoc.data())?["fancy"]?.toDouble() ?? 0.0,
          "Saree Medium": (dryCleanPrePlateDoc.data())?["medium"]?.toDouble() ?? 0.0,
          "Saree Heavy": (dryCleanPrePlateDoc.data())?["heavy"]?.toDouble() ?? 0.0,
          "Saree Plain": (dryCleanPrePlateDoc.data())?["plain"]?.toDouble() ?? 0.0,
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

  // --- Premium UI Widgets ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: bgColorPink,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrePlateItemCard({
    required String title,
    required double totalPrice,
    required int quantity,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    List<Map<String, dynamic>>? priceComponents,
  }) {
    final isSelected = quantity > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? bgColorPink.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? bgColorPink : Colors.grey.shade200,
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? bgColorPink.withOpacity(0.06)
                : Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: bgColorPink.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dry_cleaning_outlined,
                  color: bgColorPink,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${totalPrice.toStringAsFixed(2)} /Piece",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: bgColorPink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isSelected)
                Container(
                  width: 96,
                  height: 32,
                  decoration: BoxDecoration(
                    color: bgColorPink.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: bgColorPink.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: onDecrement,
                        child: const Icon(Icons.remove, size: 16, color: bgColorPink),
                      ),
                      Text(
                        "$quantity",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Colors.grey[800],
                        ),
                      ),
                      GestureDetector(
                        onTap: onIncrement,
                        child: const Icon(Icons.add, size: 16, color: bgColorPink),
                      ),
                    ],
                  ),
                )
              else
                GestureDetector(
                  onTap: onIncrement,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: bgColorPink, width: 1.5),
                    ),
                    child: const Icon(Icons.add, color: bgColorPink, size: 18),
                  ),
                ),
            ],
          ),
          if (priceComponents != null && priceComponents.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: priceComponents.map((component) {
                  final isSubTotal = component["isTotal"] == true;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          component["label"],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSubTotal ? FontWeight.w700 : FontWeight.w500,
                            color: isSubTotal ? Colors.grey[800] : Colors.grey[500],
                          ),
                        ),
                        Text(
                          "₹${(component["value"] as num).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSubTotal ? FontWeight.w700 : FontWeight.w600,
                            color: isSubTotal ? bgColorPink : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            children: [
              _buildSectionHeader("Pre-Pleat Saree"),
              _buildPrePlateItemCard(
                title: "Saree Pleating Only",
                totalPrice: prePlatedPrice,
                quantity: sareeQuantity,
                onDecrement: () => _updateQuantity(-1),
                onIncrement: () => _updateQuantity(1),
              ),
              const SizedBox(height: 8),
              _buildSectionHeader("Wash & Pre-Pleat Saree"),
              _buildPrePlateItemCard(
                title: "Wash & Pre-Pleat Saree",
                totalPrice: totalWashPrePlatedPrice,
                quantity: washPrePlatedQuantity,
                onDecrement: () => _updateQuantity(-1, isWashPrePlated: true),
                onIncrement: () => _updateQuantity(1, isWashPrePlated: true),
                priceComponents: [
                  {"label": "Wash Price", "value": washPrice},
                  {"label": "Pleating Price", "value": prePlatedPrice},
                  {"label": "Total Cost", "value": totalWashPrePlatedPrice, "isTotal": true},
                ],
              ),
              const SizedBox(height: 8),
              _buildSectionHeader("Wash & Starch & Pre-Pleat"),
              _buildPrePlateItemCard(
                title: "Wash & Starch & Pre-Pleat Saree",
                totalPrice: totalWashStarchPrePlatedPrice,
                quantity: washStarchPrePlatedQuantity,
                onDecrement: () => _updateQuantity(-1, isWashStarchPrePlated: true),
                onIncrement: () => _updateQuantity(1, isWashStarchPrePlated: true),
                priceComponents: [
                  {"label": "Wash Price", "value": washPrice},
                  {"label": "Starch Price", "value": starchPrice},
                  {"label": "Pleating Price", "value": prePlatedPrice},
                  {"label": "Total Cost", "value": totalWashStarchPrePlatedPrice, "isTotal": true},
                ],
              ),
              const SizedBox(height: 8),
              _buildSectionHeader("Dry Clean & Pre-Pleat"),
              ...dryCleanQuantities.keys.map((key) {
                final basePrice = dryCleanItemPrices[key] ?? 0.0;
                final starch = commonDryCleanStarchPrice;
                final pleat = prePlatedPrice;
                final total = dryCleanCalculatedTotals[key] ?? 0.0;
                return _buildPrePlateItemCard(
                  title: key,
                  totalPrice: total,
                  quantity: dryCleanQuantities[key] ?? 0,
                  onDecrement: () => _updateQuantity(-1, dryCleanItem: key),
                  onIncrement: () => _updateQuantity(1, dryCleanItem: key),
                  priceComponents: [
                    {"label": "Dry Clean Price", "value": basePrice},
                    {"label": "Starch Price", "value": starch},
                    {"label": "Pleating Price", "value": pleat},
                    {"label": "Total Cost", "value": total, "isTotal": true},
                  ],
                );
              }),
            ],
          ),
        ),
        if (isItemSelected()) _buildMobileFooter(),
      ],
    );
  }

  Widget _buildMobileFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "₹${_calculateTotal().toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: bgColorPink),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await _saveSelections();
                  _navigateToMeasure();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColorPink,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Add Measurement",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 16, color: Colors.white),
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                children: [
                  _buildSectionHeader("Pre-Pleat Saree"),
                  _buildPrePlateItemCard(
                    title: "Saree Pleating Only",
                    totalPrice: prePlatedPrice,
                    quantity: sareeQuantity,
                    onDecrement: () => _updateQuantity(-1),
                    onIncrement: () => _updateQuantity(1),
                  ),
                  const SizedBox(height: 8),
                  _buildSectionHeader("Wash & Pre-Pleat Saree"),
                  _buildPrePlateItemCard(
                    title: "Wash & Pre-Pleat Saree",
                    totalPrice: totalWashPrePlatedPrice,
                    quantity: washPrePlatedQuantity,
                    onDecrement: () => _updateQuantity(-1, isWashPrePlated: true),
                    onIncrement: () => _updateQuantity(1, isWashPrePlated: true),
                    priceComponents: [
                      {"label": "Wash Price", "value": washPrice},
                      {"label": "Pleating Price", "value": prePlatedPrice},
                      {"label": "Total Cost", "value": totalWashPrePlatedPrice, "isTotal": true},
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSectionHeader("Wash & Starch & Pre-Pleat"),
                  _buildPrePlateItemCard(
                    title: "Wash & Starch & Pre-Pleat Saree",
                    totalPrice: totalWashStarchPrePlatedPrice,
                    quantity: washStarchPrePlatedQuantity,
                    onDecrement: () => _updateQuantity(-1, isWashStarchPrePlated: true),
                    onIncrement: () => _updateQuantity(1, isWashStarchPrePlated: true),
                    priceComponents: [
                      {"label": "Wash Price", "value": washPrice},
                      {"label": "Starch Price", "value": starchPrice},
                      {"label": "Pleating Price", "value": prePlatedPrice},
                      {"label": "Total Cost", "value": totalWashStarchPrePlatedPrice, "isTotal": true},
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildSectionHeader("Dry Clean & Pre-Pleat"),
                  ...dryCleanQuantities.keys.map((key) {
                    final basePrice = dryCleanItemPrices[key] ?? 0.0;
                    final starch = commonDryCleanStarchPrice;
                    final pleat = prePlatedPrice;
                    final total = dryCleanCalculatedTotals[key] ?? 0.0;
                    return _buildPrePlateItemCard(
                      title: key,
                      totalPrice: total,
                      quantity: dryCleanQuantities[key] ?? 0,
                      onDecrement: () => _updateQuantity(-1, dryCleanItem: key),
                      onIncrement: () => _updateQuantity(1, dryCleanItem: key),
                      priceComponents: [
                        {"label": "Dry Clean Price", "value": basePrice},
                        {"label": "Starch Price", "value": starch},
                        {"label": "Pleating Price", "value": pleat},
                        {"label": "Total Cost", "value": total, "isTotal": true},
                      ],
                    );
                  }),
                ],
              ),
            ),
            if (isItemSelected())
              Expanded(
                flex: 2,
                child: _buildWebFooter(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebFooter() {
    final total = _calculateTotal();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 24),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            const Divider(height: 36, thickness: 1),
            const Text(
              "Pre-Pleat Total",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              "₹${total.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: bgColorPink),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () async {
                await _saveSelections();
                _navigateToMeasure();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColorPink,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: const Text(
                "Add Measurement",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
              ),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Saree Pre-Pleat",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.3),
        ),
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shopping_cart, size: 26, color: Colors.white),
                  if (_totalCartItems > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Center(
                          child: Text(
                            '$_totalCartItems',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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
      body: isLoading
          ? Center(
              child: Lottie.asset(
                'assets/animations/loading.json',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const CircularProgressIndicator(color: bgColorPink, strokeWidth: 3);
                },
              ),
            )
          : isMobile
              ? _buildMobileLayout()
              : _buildWebLayout(),
    );
  }
}