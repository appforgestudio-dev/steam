import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../constant/cart_persistence.dart';
import '../constant/constant.dart';
import '../screen/cart.dart';

class AdditionalService extends StatefulWidget {
  final Map<String, int> selectedItems;
  final double initialTotal;
  final List<Map<String, dynamic>> dryCleanPrices;

  const AdditionalService({
    required this.selectedItems,
    required this.initialTotal,
    required this.dryCleanPrices,
    super.key,
  });

  @override
  _AdditionalServiceState createState() => _AdditionalServiceState();
}

class _AdditionalServiceState extends State<AdditionalService> {
  Set<String> selectedServices = {};
  final List<String> services = [
    "Starch",
    "Saree Pre-Pleat",
  ];
  List<Map<String, dynamic>> starchingItems = [];
  List<Map<String, dynamic>> prePlatedItems = [];
  bool isStarchingExpanded = false;
  bool isPrePlatedExpanded = false;
  bool isLoading = true;
  int _totalCartItems = 0;

  @override
  void initState() {
    super.initState();
    _loadCartAndFetchPrices();
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

  Future<void> _loadCartAndFetchPrices() async {
    setState(() => isLoading = true);
    try {
      final savedCart = await CartPersistence.loadCart();
      Map<String, List<Map<String, dynamic>>> additionalServicesFromCart = {};
      if (savedCart != null) {
        additionalServicesFromCart = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).map(
                (key, value) => MapEntry(key, (value as List<dynamic>).map((item) => Map<String, dynamic>.from(item)).toList()));
        setState(() {
          _totalCartItems = _calculateTotalCartItems(savedCart);
        });
      }
      await _fetchServicePrices();
      setState(() {
        selectedServices.clear();
        isStarchingExpanded = false;
        isPrePlatedExpanded = false;
        additionalServicesFromCart.forEach((service, items) {
          bool hasQuantifiedItems = items.any((item) => (item["quantity"] ?? 0) > 0);
          if (hasQuantifiedItems) {
            selectedServices.add(service);
            if (service == "Starch") {
              isStarchingExpanded = true;
            } else if (service == "Saree Pre-Pleat") {
              isPrePlatedExpanded = true;
            }
          }
          List<Map<String, dynamic>> targetList;
          if (service == "Starch") {
            targetList = starchingItems;
          } else if (service == "Saree Pre-Pleat") {
            targetList = prePlatedItems;
          } else {
            return;
          }
          for (var cartItem in items) {
            var itemIndex = targetList.indexWhere((item) => item["name"] == cartItem["name"]);
            if (itemIndex != -1) {
              targetList[itemIndex]["quantity"] = cartItem["quantity"] ?? 0;
            } else {
              targetList.add(Map<String, dynamic>.from(cartItem));
            }
          }
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading cart or fetching prices. Please check your internet or try again later"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _toggleServiceSelection(String service) {
    setState(() {
      if (selectedServices.contains(service)) {
        selectedServices.remove(service);
        List<Map<String, dynamic>> targetList;
        if (service == "Starch") {
          isStarchingExpanded = false;
          targetList = starchingItems;
        } else if (service == "Saree Pre-Pleat") {
          isPrePlatedExpanded = false;
          targetList = prePlatedItems;
        } else {
          return;
        }
        for (var item in targetList) {
          item["quantity"] = 0;
        }
      } else {
        selectedServices.add(service);
        List<Map<String, dynamic>> targetList;
        if (service == "Starch") {
          isStarchingExpanded = true;
          targetList = starchingItems;
        } else if (service == "Saree Pre-Pleat") {
          isPrePlatedExpanded = true;
          targetList = prePlatedItems;
        } else {
          return;
        }
        for (var item in targetList) {
          if (widget.selectedItems.containsKey(item["name"])) {
            if (service == "Saree Pre-Pleat" && !item["name"].toLowerCase().contains("saree")) {
              continue;
            }
            if ((item["quantity"] ?? 0) == 0) {
              item["quantity"] = widget.selectedItems[item["name"]] ?? 0;
            }
          }
        }
      }
    });
    _saveSelections();
  }

  Future<void> _fetchServicePrices() async {
    try {
      QuerySnapshot dryCleanSnapshot = await FirebaseFirestore.instance.collection("Dry Clean").get();
      DocumentSnapshot washPreDoc = await FirebaseFirestore.instance.collection("Pre-Plate").doc("Wash Pre").get();
      double washPrice = 0.0;
      if (washPreDoc.exists) {
        final data = washPreDoc.data() as Map<String, dynamic>? ?? {};
        washPrice = (data["wash_price"] as num?)?.toDouble() ?? 0.0;
      }
      if (mounted) {
        setState(() {
          starchingItems = _filterItems(dryCleanSnapshot, "starch");
          prePlatedItems = _filterItems(dryCleanSnapshot, "pleat", onlySaree: true);
        });
      }
    } catch (e) {
      // Error handling
    }
  }

  List<Map<String, dynamic>> _filterItems(QuerySnapshot snapshot, String priceKey, {bool onlySaree = false}) {
    var filteredItems = snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;
      var price = (data[priceKey] as num?)?.toDouble();
      return {"name": doc.id, "price": price ?? 0.0, "quantity": 0,};
    }).whereType<Map<String, dynamic>>().where((item) {
      bool nameIsValid = item["name"] != null && item["name"].isNotEmpty;
      bool isPreviouslySelected = widget.selectedItems.containsKey(item["name"]);
      bool isAdditionalServicePriceValid = true;
      if (priceKey == "starch") {
        isAdditionalServicePriceValid = (item["price"] as double) > 0;
      }
      bool isSareeItem = true;
      if (onlySaree && priceKey == "pleat") {
        isSareeItem = item["name"].toLowerCase().contains("saree");
      }
      return nameIsValid && isPreviouslySelected && isAdditionalServicePriceValid && isSareeItem;
    }).toList();
    return filteredItems;
  }

  void _removeItem(String itemName, String service) {
    setState(() {
      List<Map<String, dynamic>>? targetList;
      if (service == "Starch") {
        targetList = starchingItems;
      } else if (service == "Saree Pre-Pleat") targetList = prePlatedItems;

      if (targetList != null) {
        var itemIndex = targetList.indexWhere((item) => item["name"] == itemName);
        if (itemIndex != -1) {
          targetList[itemIndex]["quantity"] = 0;
        }
      }
    });
    _saveSelections();
  }

  void _updateItemQuantity(String itemName, String service, int newQuantity) {
    setState(() {
      int maxQuantity = widget.selectedItems[itemName] ?? 0;
      if (maxQuantity == 0) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$itemName was not selected in Dry Clean service."), backgroundColor: Colors.orange, duration: const Duration(seconds: 2),));
        return;
      }
      if (newQuantity > maxQuantity) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("This cloth is selected $maxQuantity times in Dry Clean"), backgroundColor: Colors.orange, duration: const Duration(seconds: 2),));
        return;
      }
      List<Map<String, dynamic>>? targetList;
      if (service == "Starch") {
        targetList = starchingItems;
      } else if (service == "Saree Pre-Pleat") targetList = prePlatedItems;
      else return;

      var itemIndex = targetList.indexWhere((item) => item["name"] == itemName);
      if (itemIndex != -1) {
        targetList[itemIndex]["quantity"] = newQuantity.clamp(0, maxQuantity);
      }
        });
    _saveSelections();
  }

  double _calculateAdditionalTotal() {
    double total = 0;
    total += starchingItems.fold(0.0, (sum, item) => sum + ((item["price"] as num? ?? 0.0) * (item["quantity"] ?? 0)));
    total += prePlatedItems.fold(0.0, (sum, item) => sum + ((item["price"] as num? ?? 0.0) * (item["quantity"] ?? 0)));
    return total;
  }

  double _calculateGrandTotal() {
    return widget.initialTotal + _calculateAdditionalTotal();
  }

  Future<void> _saveSelections() async {
    try {
      Map<String, List<Map<String, dynamic>>> allAdditionalServices = {};
      if (starchingItems.any((item) => (item["quantity"] ?? 0) > 0)) {
        allAdditionalServices["Starch"] = starchingItems.where((item) => (item["quantity"] ?? 0) > 0).toList();
      }
      if (prePlatedItems.any((item) => (item["quantity"] ?? 0) > 0)) {
        allAdditionalServices["Saree Pre-Pleat"] = prePlatedItems.where((item) => (item["quantity"] ?? 0) > 0).toList();
      }
      final savedCart = await CartPersistence.loadCart();
      Map<String, int> dryCleanItems = (savedCart?['dryCleanItems'] as Map<String, dynamic>? ?? {}).cast<String, int>();
      Map<String, int> ironingItems = (savedCart?['ironingItems'] as Map<String, dynamic>? ?? {}).cast<String, int>();
      Map<String, int> washAndFoldItems = (savedCart?['washAndFoldItems'] as Map<String, dynamic>? ?? {}).cast<String, int>();
      Map<String, int> washAndIronItems = (savedCart?['washAndIronItems'] as Map<String, dynamic>? ?? {}).cast<String, int>();
      Map<String, int> washIronStarchItems = (savedCart?['washIronStarchItems'] as Map<String, dynamic>? ?? {}).cast<String, int>();
      Map<String, Map<String, dynamic>> savedPrePlatedItems = (savedCart?['prePlatedItems'] as Map<String, dynamic>? ?? {}).cast<String, Map<String, dynamic>>();
      Map<String, Map<String, dynamic>> prePlatedItemsToSave = {};
      if (allAdditionalServices.containsKey("Saree Pre-Pleat") && allAdditionalServices["Saree Pre-Pleat"] != null) {
        for (var item in allAdditionalServices["Saree Pre-Pleat"]!) {
          final name = item["name"] as String? ?? "";
          final quantity = item["quantity"] as int? ?? 0;
          final price = item["price"] as double? ?? 0.0;
          if (quantity > 0 && name.isNotEmpty) {
            prePlatedItemsToSave[name] = {"quantity": quantity, "pricePerItem": price,};
          }
        }
      }
      Map<String, Map<String, dynamic>> finalPrePlatedItems = {};
      savedPrePlatedItems.forEach((key, value) {
        if (!prePlatedItemsToSave.containsKey(key) && (value['quantity'] ?? 0) > 0) {
          finalPrePlatedItems[key] = value;
        }
      });
      finalPrePlatedItems.addAll(prePlatedItemsToSave);
      allAdditionalServices.remove("Saree Pre-Pleat");
      await CartPersistence.saveCart(
        dryCleanItems: dryCleanItems,
        ironingItems: ironingItems,
        washAndFoldItems: washAndFoldItems,
        washAndIronItems: washAndIronItems,
        washIronStarchItems: washIronStarchItems,
        prePlatedItems: finalPrePlatedItems,
        additionalServices: allAdditionalServices,
        dryCleanTotal: savedCart?['dryCleanTotal'] as double? ?? 0,
        additionalTotal: _calculateAdditionalTotal(),
      );
      final newCart = await CartPersistence.loadCart();
      if(mounted && newCart != null){
        setState(() { _totalCartItems = _calculateTotalCartItems(newCart); });
      }
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _saveCartAndNavigateToCartPage() async {
    await _saveSelections();
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
          additionalTotal: _calculateAdditionalTotal(),
        ),),).then((_) => _loadCartAndFetchPrices());
      }
    } catch (e) {
      // Error handling
    }
  }

  void _navigateToHomePage() {
    if(mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Widget _buildMobileLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    bool hasSaree = widget.selectedItems.keys.any((item) => item.toLowerCase().contains("saree"));
    List<String> availableServices = hasSaree ? services : services.where((service) => service != "Saree Pre-Pleat").toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(screenWidth * 0.04, screenHeight * 0.02, screenWidth * 0.04, screenHeight * 0.02),
            children: [
              Text("Enhance your laundry with premium services", style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey[600], fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
              SizedBox(height: screenHeight * 0.01),
              ...availableServices.map((service) {
                bool isSelected = selectedServices.contains(service);
                bool isStarching = service == "Starch";
                bool isSareePrePleat = service == "Saree Pre-Pleat";
                bool isExpanded = (isStarching && isStarchingExpanded) || (isSareePrePleat && isPrePlatedExpanded);
                return Column(
                  children: [
                    Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () => _toggleServiceSelection(service),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _toggleServiceSelection(service),
                                    child: Container(
                                      width: screenWidth * 0.06,
                                      height: screenWidth * 0.06,
                                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? bgColorPink : Colors.grey[400]!, width: 2,), color: isSelected ? bgColorPink : Colors.transparent,),
                                      child: isSelected ? Icon(Icons.check, size: screenWidth * 0.04, color: Colors.white) : null,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.04),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _toggleServiceSelection(service),
                                      child: Text(service, style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w600, color: Colors.grey[800]),),
                                    ),
                                  ),
                                  if (isStarching || isSareePrePleat)
                                    if (selectedServices.contains(service))
                                      IconButton(
                                        icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey[600],),
                                        onPressed: () {
                                          setState(() {
                                            if (isStarching) {
                                              isStarchingExpanded = !isStarchingExpanded;
                                            } else if (isSareePrePleat) isPrePlatedExpanded = !isPrePlatedExpanded;
                                          });
                                        },
                                      ),
                                ],
                              ),
                              if (isExpanded && (isStarching || isSareePrePleat))
                                Padding(
                                  padding: EdgeInsets.only(top: screenHeight * 0.015),
                                  child: _buildDropdownItems(isStarching ? starchingItems : prePlatedItems, service,),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        _buildFooter(),
      ],
    );
  }

  Widget _buildWebLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    bool hasSaree = widget.selectedItems.keys.any((item) => item.toLowerCase().contains("saree"));
    List<String> availableServices = hasSaree ? services : services.where((service) => service != "Saree Pre-Pleat").toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(screenWidth * 0.04, screenHeight * 0.02, screenWidth * 0.04, screenHeight * 0.02),
                children: [
                  Text("Enhance your laundry with premium services", style: TextStyle(fontSize: screenWidth * 0.02, color: Colors.grey[600], fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                  SizedBox(height: screenHeight * 0.02),
                  ...availableServices.map((service) {
                    bool isSelected = selectedServices.contains(service);
                    bool isStarching = service == "Starch";
                    bool isSareePrePleat = service == "Saree Pre-Pleat";
                    bool isExpanded = (isStarching && isStarchingExpanded) || (isSareePrePleat && isPrePlatedExpanded);
                    return Column(
                      children: [
                        Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: screenHeight * 0.01),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            onTap: () => _toggleServiceSelection(service),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.02),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _toggleServiceSelection(service),
                                        child: Container(
                                          width: screenWidth * 0.02,
                                          height: screenWidth * 0.02,
                                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? bgColorPink : Colors.grey[400]!, width: 2,), color: isSelected ? bgColorPink : Colors.transparent,),
                                          child: isSelected ? Icon(Icons.check, size: screenWidth * 0.015, color: Colors.white) : null,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _toggleServiceSelection(service),
                                          child: Text(service, style: TextStyle(fontSize: screenWidth * 0.02, fontWeight: FontWeight.w600, color: Colors.grey[800]),),
                                        ),
                                      ),
                                      if (isStarching || isSareePrePleat)
                                        if (selectedServices.contains(service))
                                          IconButton(
                                            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey[600],),
                                            onPressed: () {
                                              setState(() {
                                                if (isStarching) {
                                                  isStarchingExpanded = !isStarchingExpanded;
                                                } else if (isSareePrePleat) isPrePlatedExpanded = !isPrePlatedExpanded;
                                              });
                                            },
                                          ),
                                    ],
                                  ),
                                  if (isExpanded && (isStarching || isSareePrePleat))
                                    Padding(
                                      padding: EdgeInsets.only(top: screenHeight * 0.015),
                                      child: _buildDropdownItems(isStarching ? starchingItems : prePlatedItems, service,),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 800;

    return Container(
      padding: EdgeInsets.all(isMobile ? screenWidth * 0.04 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isMobile ? screenWidth * 0.025 : 10,
            offset: Offset(0, -screenHeight * 0.01),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(isMobile ? screenWidth * 0.04 : 16)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_calculateAdditionalTotal() > 0)
                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.005),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Additional:",
                            style: TextStyle(fontSize: isMobile ? screenWidth * 0.035 : 16, color: Colors.grey[600]),
                          ),
                          Text(
                            "₹${_calculateAdditionalTotal().toStringAsFixed(2)}",
                            style: TextStyle(
                                fontSize: isMobile ? screenWidth * 0.035 : 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    "Grand Total",
                    style: TextStyle(
                      fontSize: isMobile ? screenWidth * 0.04 : 20,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "₹${_calculateGrandTotal().toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: isMobile ? screenWidth * 0.05 : 24,
                      fontWeight: FontWeight.bold,
                      color: bgColorPink,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isMobile ? 16 : 24),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await _saveSelections();
                  _navigateToHomePage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColorPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isMobile ? screenWidth * 0.03 : 12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: isMobile ? screenHeight * 0.02 : 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Continue",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? screenWidth * 0.04 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? screenWidth * 0.02 : 10),
                    Icon(Icons.arrow_forward, size: isMobile ? screenWidth * 0.05 : 24, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageLoader() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Lottie.asset(
        'assets/animations/loading.json',
        width: screenWidth * 0.2,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildDropdownItems(List<Map<String, dynamic>> items, String service) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 800;
    List<Map<String, dynamic>> displayedItems = items.where((item) {
      return (item["quantity"] ?? 0) > 0 || widget.selectedItems.containsKey(item["name"]);
    }).toList();

    if (displayedItems.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        child: Text("No items available for this service based on your selections", style: TextStyle(color: Colors.grey[600])),
      );
    }
    return Column(
      children: displayedItems.map((item) {
        if (item["name"] == null || item["name"].isEmpty) return const SizedBox.shrink();
        int currentQuantity = item["quantity"] ?? 0;
        double itemPrice = (item["price"] as num?)?.toDouble() ?? 0.0;
        return Card(
          elevation: 1,
          margin: EdgeInsets.only(bottom: screenHeight * 0.01),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey[200]!),),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? screenWidth * 0.03 : 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item["name"], style: TextStyle(fontSize: isMobile ? screenWidth * 0.038 : 16, fontWeight: FontWeight.bold),),
                      SizedBox(height: screenHeight * 0.005),
                      Row(
                        children: [
                          Text("Qty: ", style: TextStyle(fontSize: isMobile ? screenWidth * 0.033 : 14, color: Colors.grey[600])),
                          IconButton(icon: Icon(Icons.remove, size: isMobile ? screenWidth * 0.05 : 20, color: Colors.grey[600]), onPressed: currentQuantity > 0 ? () => _updateItemQuantity(item["name"], service, currentQuantity - 1) : null, padding: EdgeInsets.zero, constraints: const BoxConstraints(),),
                          Text("$currentQuantity", style: TextStyle(fontSize: isMobile ? screenWidth * 0.033 : 14, color: Colors.grey[600], fontWeight: FontWeight.bold),),
                          IconButton(icon: Icon(Icons.add, size: isMobile ? screenWidth * 0.05 : 20, color: Colors.grey[600]), onPressed: () => _updateItemQuantity(item["name"], service, currentQuantity + 1), padding: EdgeInsets.zero, constraints: const BoxConstraints(),),
                        ],
                      ),
                    ],
                  ),
                ),
                Text("₹${(itemPrice * currentQuantity).toStringAsFixed(2)}", style: TextStyle(fontSize: isMobile ? screenWidth * 0.04 : 18, fontWeight: FontWeight.bold, color: bgColorPink),),
                IconButton(icon: Icon(Icons.close, size: isMobile ? screenWidth * 0.05 : 20, color: Colors.grey[600]), onPressed: () => _removeItem(item["name"], service),),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const mobileBreakpoint = 800.0;
    final bool isMobile = screenWidth < mobileBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: Text("Additional Services", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? screenWidth * 0.05 : 20, letterSpacing: 0.5),),
        centerTitle: true,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_ios, size: isMobile ? screenWidth * 0.05 : 24),),
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(12),),),
        backgroundColor: bgColorPink,
        foregroundColor: bgColorWhite,
        actions: [
          Padding(padding: EdgeInsets.only(right: isMobile ? screenWidth * 0.04 : 16),
            child: IconButton(icon: Stack(alignment: Alignment.center,
              children: [
                Icon(Icons.shopping_cart, size: isMobile ? screenWidth * 0.07 : 28),
                if (_totalCartItems > 0)
                  Positioned(right: 0, top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1),),
                      constraints: BoxConstraints(minWidth: isMobile ? screenWidth * 0.05 : 18, minHeight: isMobile ? screenWidth * 0.05 : 18,),
                      child: Center(child: Text('$_totalCartItems', style: TextStyle(color: Colors.white, fontSize: isMobile ? screenWidth * 0.03 : 10, fontWeight: FontWeight.bold),),),
                    ),
                  ),
              ],
            ),
              onPressed: () { _saveCartAndNavigateToCartPage(); },
            ),
          ),
        ],
      ),
      body: isLoading ? _buildPageLoader() : (isMobile ? _buildMobileLayout() : _buildWebLayout()),
    );
  }
}
