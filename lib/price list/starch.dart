import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../constant/cart_persistence.dart';
import '../constant/constant.dart';
import '../screen/cart.dart';

class WashAndStarchPage extends StatefulWidget {
  const WashAndStarchPage({super.key});

  @override
  _WashAndStarchPageState createState() => _WashAndStarchPageState();
}

class _WashAndStarchPageState extends State<WashAndStarchPage> {
  // State variables
  Map<String, int> itemQuantities = {};
  bool _isLoading = true;
  double _total = 0;
  int _totalCartItems = 0;

  Map<String, dynamic>? byWeightPricing;
  List<Map<String, dynamic>> additionalPrices = [];
  List<Map<String, dynamic>> oneTimePrices = [];
  List<Map<String, dynamic>> subscriptionPrices = [];
  List<Map<String, dynamic>> subscriptionThreePrices = [];

  final Color primaryColor = bgColorPink;
  final Color secondaryColor = Colors.pinkAccent.shade100;
  final double cardRadius = 12.0;
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
        if (savedCart != null && savedCart['washIronStarchItems'] != null) {
          final loadedItems = savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {};
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
        // Calculate total items for badge
        if (savedCart != null) {
          int totalItems = 0;
          totalItems += (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).length;
          totalItems += (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).length;
          totalItems += (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).length;
          totalItems += (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).length;
          totalItems += (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).length;
          totalItems += itemQuantities.length;
          _totalCartItems = totalItems;
        }
      });
      _fetchPricingData();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load saved cart at 12:04 AM IST on June 07, 2025: $e"),
          backgroundColor: Colors.red,
        ),
      );
      _fetchPricingData();
    }
  }

  Future<void> _fetchPricingData() async {
    try {
      final futures = [
        FirebaseFirestore.instance.collection("Wash-Starch").doc("By Weight").get(),
        FirebaseFirestore.instance.collection("Wash-Starch").doc("1 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Starch").doc("7 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Starch").doc("15 Time").get(),
        FirebaseFirestore.instance.collection("Wash-Starch").doc("30 Time").get(),
      ];

      final results = await Future.wait(futures);

      setState(() {
        additionalPrices = [];
        oneTimePrices = [];
        subscriptionPrices = [];
        subscriptionThreePrices = [];

        if (results[0].exists) {
          final data = results[0].data() as Map<String, dynamic>;
          byWeightPricing = {
            "name": "By Weight",
            "price": data["price"] ?? 0,
            "month": 0,
            "unit": "/KG",
          };
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
                "label": "Subscription: $times White (5kg)",
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
                "label": "Subscription: $times White (3kg)",
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
        SnackBar(
          content: Text("Error loading prices at 12:04 AM IST on June 07, 2025: ${e.toString()}"),
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
        washAndFoldItems: savedCart?['washAndFoldItems'] ?? {},
        washAndIronItems: savedCart?['washAndIronItems'] ?? {},
        washIronStarchItems: itemQuantities,
        prePlatedItems: savedPrePlatedItems,
        additionalServices: savedCart?['additionalServices'] ?? {},
        dryCleanTotal: savedCart?['dryCleanTotal'] ?? 0,
        additionalTotal: savedCart?['additionalTotal'] ?? 0,
      );

      // Update total cart items for badge
      final updatedCart = await CartPersistence.loadCart();
      int totalItems = 0;
      totalItems += (updatedCart?['dryCleanItems'] as Map<String, dynamic>? ?? {}).length;
      totalItems += (updatedCart?['ironingItems'] as Map<String, dynamic>? ?? {}).length;
      totalItems += (updatedCart?['washAndFoldItems'] as Map<String, dynamic>? ?? {}).length;
      totalItems += (updatedCart?['washAndIronItems'] as Map<String, dynamic>? ?? {}).length;
      totalItems += (updatedCart?['prePlatedItems'] as Map<String, dynamic>? ?? {}).length;
      totalItems += itemQuantities.length;
      setState(() {
        _totalCartItems = totalItems;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving selections at 12:04 AM IST on June 07, 2025: ${e.toString()}"),
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

      Map<String, int> washAndFoldItems = (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).map((key, value) {
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

      Map<String, Map<String, dynamic>> savedPrePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));

      Map<String, List<Map<String, dynamic>>> additionalServices =
      (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).map(
            (key, value) => MapEntry(
          key,
          (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList(),
        ),
      );

      await CartPersistence.saveCart(
        dryCleanItems: dryCleanItems,
        ironingItems: ironingItems,
        washAndFoldItems: washAndFoldItems,
        washAndIronItems: washAndIronItems,
        washIronStarchItems: itemQuantities,
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
            washAndFoldItems: washAndFoldItems,
            washAndIronItems: washAndIronItems,
            washIronStarchItems: itemQuantities,
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
        SnackBar(
          content: Text("Error saving cart at 12:04 AM IST on June 07, 2025: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildItemCard(Map<String, dynamic> priceItem, bool isSelected, bool isSubscription) {
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    priceItem["label"].split(": ")[1].replaceAll(" (3kg)", "").replaceAll(" (5kg)", ""),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        priceItem["unit"],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (isSubscription) ...[
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          "${priceItem["month"]} Month Validity • ${priceItem["times"]} Washes",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "₹${priceItem["price"]}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: bgColorPink,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? bgColorPink : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? bgColorPink : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
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
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
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
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final priceItem = items[index];
            final isSelected = itemQuantities.containsKey(priceItem["label"]);
            final isSubscription = (priceItem["label"] as String).contains("Subscription");
            return _buildItemCard(priceItem, isSelected, isSubscription);
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
        title: const Text("Wash & Starch", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: bgColorPink,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final priceItem = items[index];
            final isSelected = itemQuantities.containsKey(priceItem["label"]);
            final isSubscription = (priceItem["label"] as String).contains("Subscription");
            return _buildItemCard(priceItem, isSelected, isSubscription);
          },
        ),
      ],
    );
  }

  Widget _buildWebFooter() {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Selected Plans (${itemQuantities.length})",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Wash & Starch Total",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              "₹${_total.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: primaryColor),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _navigateToHomePage,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: const Text(
                "Continue",
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
    final isWeb = MediaQuery.of(context).size.width > 800;
    final allItems = [...additionalPrices, ...oneTimePrices, ...subscriptionPrices, ...subscriptionThreePrices];

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/loading.json',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const CircularProgressIndicator(color: bgColorPink, strokeWidth: 3);
                },
              ),
            ],
          ),
        ),
      );
    }

    if (allItems.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/empty.json',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]);
                },
              ),
              const SizedBox(height: 16),
              Text(
                "No services available",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _fetchPricingData,
                style: TextButton.styleFrom(foregroundColor: bgColorPink),
                child: const Text("Retry", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    if (isWeb) {
      return _buildWebLayout();
    } else {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "Wash & Starch",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.3),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
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
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, size: 26),
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
                onPressed: _saveAndNavigateToCart,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                      child: Row(
                        children: [
                          const Text(
                            "Available Plans",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87),
                          ),
                          const Spacer(),
                          if (isItemSelected())
                            Text(
                              "${itemQuantities.length} plan${itemQuantities.length > 1 ? 's' : ''} selected",
                              style: const TextStyle(color: bgColorPink, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                    _buildSection("By Weight Pricing", additionalPrices, 1.5),
                    _buildSection("One-Time Wash", oneTimePrices, 1.5),
                    _buildSection("Subscription Based (2.75 To 3 KG)", subscriptionThreePrices, 1.3),
                    _buildSection("Subscription Based (5 to 5.5 KG)", subscriptionPrices, 1.3),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (isItemSelected())
              Container(
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
                              "Wash & Starch Total",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "₹${_total.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: bgColorPink),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _navigateToHomePage,
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
                                "Continue",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
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
              ),
          ],
        ),
      );
    }
  }

  void _navigateToHomePage() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}