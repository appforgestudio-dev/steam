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
    for (var itemData in prePlatedItemsFromCart.values) {
      totalItems += (itemData?["quantity"] as int? ?? 0);
    }
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

  String _normalize(String input) {
    return input.toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('/', '');
  }

  void _fetchDryCleanPrices() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection("Dry Clean").get();

      setState(() {
        dryCleanPrices = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          String name = doc.id;
          if (name.toLowerCase() != "t-shirt" && name.contains('-')) {
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

        if (_searchController.text.isNotEmpty) {
          String normalizedQuery = _normalize(_searchController.text);
          filteredPrices = dryCleanPrices.where((item) {
            return _normalize(item["name"]).contains(normalizedQuery);
          }).toList();
        } else {
          filteredPrices = dryCleanPrices;
        }
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

    String normalizedQuery = _normalize(query);
    setState(() {
      filteredPrices = dryCleanPrices.where((item) {
        return _normalize(item["name"]).contains(normalizedQuery);
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: item["image"].isEmpty ? Colors.grey[100] : null,
                image: item["image"].isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(item["image"]),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item["image"].isEmpty
                  ? Icon(Icons.image_not_supported, color: Colors.grey[400], size: 28)
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
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${item["dry_clean"]}",
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
                      onTap: () {
                        setState(() {
                          if (quantity > 1) {
                            itemQuantities[item["name"]] = quantity - 1;
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
                      onTap: () {
                        setState(() {
                          itemQuantities[item["name"]] = quantity + 1;
                          _dryCleanTotal = _calculateDryCleanTotal();
                          _additionalTotal = _calculateAdditionalTotal();
                        });
                        _saveCart();
                      },
                      child: const Icon(Icons.add, size: 16, color: bgColorPink),
                    ),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: () {
                  setState(() {
                    itemQuantities[item["name"]] = 1;
                    _dryCleanTotal = _calculateDryCleanTotal();
                    _additionalTotal = _calculateAdditionalTotal();
                  });
                  _saveCart();
                },
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
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: bgColorPink, size: 20),
            hintText: "Search items...",
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                    onPressed: () {
                      _searchController.clear();
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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
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
            "Available Items",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          if (isItemSelected())
            Text(
              "${itemQuantities.length} plan${itemQuantities.length > 1 ? 's' : ''} selected",
              style: const TextStyle(color: bgColorPink, fontWeight: FontWeight.w600, fontSize: 13),
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
            width: 150,
            height: 150,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.search_off_outlined, size: 64, color: Colors.grey[300]);
            },
          ),
          const SizedBox(height: 16),
          Text(
            "No items found",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _searchController.clear(),
            style: TextButton.styleFrom(foregroundColor: bgColorPink),
            child: const Text("Clear search", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildSearchField(),
        _buildHeaderRow(),
        Expanded(
          child: filteredPrices.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  itemCount: filteredPrices.length,
                  itemBuilder: (context, index) {
                    return _buildItemCard(context, filteredPrices[index]);
                  },
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
                    "Dry Clean Total",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "₹${_dryCleanTotal.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: bgColorPink),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _navigateToAdditionalServices,
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
              child: Column(
                children: [
                  _buildSearchField(),
                  _buildHeaderRow(),
                  Expanded(
                    child: filteredPrices.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
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
                  "Selected Items (${itemQuantities.length})",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Dry Clean Total",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              "₹${_dryCleanTotal.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: bgColorPink),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _navigateToAdditionalServices,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColorPink,
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
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Dry Cleaning",
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
              onPressed: _navigateToCartPage,
            ),
          ),
        ],
      ),
      body: _isLoading
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