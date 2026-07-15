import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constant/cart_persistence.dart';
import '../price list/DryCleanPriceList.dart';
import '../price list/starch.dart';
import '../price list/wash_iron.dart' show WashAndIronPage;
import '../price list/iron.dart';
import '../price list/pre_plate.dart';
import '../price list/wash_fold.dart';
import 'package:flutter/services.dart';
import '../constant/address_persistence.dart';
import '../sub screen/contact.dart';
import '../sub screen/feedback.dart';
import '../sub screen/settings.dart';
import '../sub screen/subscription.dart';
import 'AddressPage.dart';
import '../sub screen/ordersPage.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'cart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// â”€â”€â”€ Design tokens â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const Color _primary = Color(0xFFFF4081);
const Color _primaryDark = Color(0xFFE91E63);
const Color _surface = Color(0xFFF8F9FF);

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static bool hasShownInitialAddressPrompt = false;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String _userName = "Guest";
  String? _userPhoneNumber;
  final TextEditingController _nameController = TextEditingController();
  Map<String, dynamic>? _currentAddress;
  bool _isPremiumBooked = false;
  int _cartItemCount = 0;
  StreamSubscription<User?>? _authSubscription;

  late AnimationController _heroController;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  final List<Map<String, dynamic>> standardServices = const [
    {
      "name": "Wash & Fold",
      "icon": Icons.local_laundry_service,
      "image": "assets/images/wash-fold.png",
      "price": "View Prices",
      "gradient": [Color(0xFF6A11CB), Color(0xFF2575FC)],
    },
    {
      "name": "Wash & Iron",
      "icon": Icons.iron,
      "image": "assets/images/wash-iron.png",
      "price": "View Prices",
      "gradient": [Color(0xFFFF4081), Color(0xFFFF6E40)],
    },
    {
      "name": "Dry Clean",
      "icon": Icons.dry_cleaning,
      "image": "assets/images/dry-cleaning.png",
      "price": "View Prices",
      "gradient": [Color(0xFF11998E), Color(0xFF38EF7D)],
    },
    {
      "name": "Steam Press Iron",
      "icon": Icons.stream,
      "image": "assets/images/ironing.png",
      "price": "View Prices",
      "gradient": [Color(0xFFF7971E), Color(0xFFFFD200)],
    },
    {
      "name": "Saree Pre-Pleat",
      "icon": Icons.style,
      "image": "assets/images/saree.png",
      "price": "View Prices",
      "gradient": [Color(0xFFDA22FF), Color(0xFF9733EE)],
    },
    {
      "name": "Wash & Starch",
      "icon": Icons.water_drop,
      "image": "assets/images/starch.png",
      "price": "View Prices",
      "gradient": [Color(0xFF1FA2FF), Color(0xFF12D8FA)],
    },
  ];

  final List<Map<String, dynamic>> premiumServices = const [
    {
      "name": "Premium Laundry",
      "image": "assets/images/premium.png",
      "price": "\u20b9159/KG",
      "description": "Wash \u00b7 Iron \u00b7 Fragrance \u00b7 Fold \u00b7 Special Packing",
    },
  ];

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOut));
    _heroController.forward();

    _requestNotificationPermission();
    _initializePage();
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) _setupAndSaveFCMToken(user);
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _nameController.dispose();
    _authSubscription?.cancel();
    super.dispose();
  }

  // â”€â”€â”€ Business logic â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    } catch (e) {
      debugPrint("Error requesting location permission: $e");
    }
  }

  Future<void> _initializePage() async {
    await _fetchUserName();
    await _loadCurrentAddress();
    if (!kIsWeb) _requestLocationPermission();
    if (mounted) {
      await Future.wait([
        _checkPremiumBookedStatus(),
        if (!kIsWeb) _checkForUpdate(),
        _updateCartItemCount(),
      ]);
    }
    if (_currentAddress == null && !HomePage.hasShownInitialAddressPrompt && mounted) {
      HomePage.hasShownInitialAddressPrompt = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final route = ModalRoute.of(context);
        if (route != null) {
          if (route.isCurrent) {
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted && route.isCurrent) {
                _showAddressSelectionSheet(onAddressChanged: _loadCurrentAddress);
              }
            });
          } else {
            late final void Function(AnimationStatus) listener;
            listener = (status) {
              if (status == AnimationStatus.dismissed) {
                route.secondaryAnimation?.removeStatusListener(listener);
                if (route.isCurrent && mounted) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted && route.isCurrent) {
                      _showAddressSelectionSheet(onAddressChanged: _loadCurrentAddress);
                    }
                  });
                }
              }
            };
            route.secondaryAnimation?.addStatusListener(listener);
          }
        } else {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) _showAddressSelectionSheet(onAddressChanged: _loadCurrentAddress);
          });
        }
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (kIsWeb) return;
    await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> _setupAndSaveFCMToken(User user) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken(
        vapidKey: kIsWeb
            ? "BAEu6_xp-409KcIzsYi7LmiOAMqMDeL20885I1kILS2zN19IxJFoEraUxgbsTGJsPtiHhK3cG3j3HfPfRXhRkCc"
            : null,
      );
      if (fcmToken != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.phoneNumber)
            .set(
              {'fcmToken': fcmToken, 'phoneNumber': user.phoneNumber, 'updatedAt': FieldValue.serverTimestamp()},
              SetOptions(merge: true),
            );
      }
    } catch (_) {}
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.phoneNumber != null) {
      _userPhoneNumber = user.phoneNumber;
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userPhoneNumber)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data()!;
          setState(() {
            _userName = (data['name'] ?? data['Name'] ?? data['userName'] ?? data['username']) as String? ?? "User";
          });
          _nameController.text = _userName;
        } else {
          setState(() => _userName = "New User");
          _nameController.text = "";
        }
      } catch (e) {
        _showSnackBar("Failed to load user name: ${e.toString()}", isError: true);
        setState(() => _userName = "Error User");
      }
    } else {
      setState(() => _userName = "Guest");
    }
  }

  Future<void> _loadCurrentAddress() async {
    try {
      final savedAddress = await AddressPersistence.loadCurrentAddress();
      if (mounted) setState(() => _currentAddress = savedAddress);
    } catch (e) {
      _showSnackBar("Failed to load address: ${e.toString()}", isError: true);
      if (mounted) setState(() => _currentAddress = null);
    }
  }

  Future<void> _handleDeleteAddress(Map<String, dynamic> addressToDelete) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await AddressPersistence.deleteAddress(addressToDelete);
      setState(() => _currentAddress = null);
      if (!mounted) return;
      Navigator.pop(context);
      await _loadCurrentAddress();
    }
  }

  Future<void> _showAddressSelectionSheet({required VoidCallback onAddressChanged}) async {
    final List<Map<String, dynamic>> savedAddresses = await AddressPersistence.loadAllAddresses();
    final Map<String, dynamic>? currentAddress = await AddressPersistence.loadCurrentAddress();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext context) {
        final sw = MediaQuery.of(context).size.width;
        final sh = MediaQuery.of(context).size.height;
        return Container(
          padding: EdgeInsets.only(
            top: sh * 0.025,
            left: sw * 0.05,
            right: sw * 0.05,
            bottom: sh * 0.025 + MediaQuery.of(context).viewPadding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text("Select Pickup Address", style: TextStyle(fontSize: sw * 0.05, fontWeight: FontWeight.bold)),
              SizedBox(height: sh * 0.018),
              if (savedAddresses.isEmpty)
                Center(child: Padding(padding: EdgeInsets.symmetric(vertical: sh * 0.025), child: const Text("No saved addresses found.")))
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
                      final bool isSelected = currentAddress != null &&
                          currentAddress['label'] == address['label'] &&
                          currentAddress['street'] == address['street'];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: sh * 0.006),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isSelected ? _primary : Colors.transparent, width: 1.5),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.location_on_outlined, color: _primary),
                          title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("$door, $street"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) const Icon(Icons.check_circle, color: _primary),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.grey[400]),
                                onPressed: () => _handleDeleteAddress(address),
                                tooltip: 'Delete Address',
                              ),
                            ],
                          ),
                          onTap: () async {
                            await AddressPersistence.saveCurrentAddress(address);
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            onAddressChanged();
                          },
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: sh * 0.018),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
                  label: const Text("Add New Address", style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    Navigator.pop(context);
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressPage()));
                    onAddressChanged();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.025)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _checkPremiumBookedStatus() async {
    try {
      final savedCart = await CartPersistence.loadCart() ?? {};
      final washAndFoldItems = (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {});
      setState(() {
        _isPremiumBooked = washAndFoldItems.containsKey('Premium Laundry') &&
            (washAndFoldItems['Premium Laundry'] as int? ?? 0) > 0;
      });
    } catch (e) {
      _showSnackBar("Error checking cart status: ${e.toString()}", isError: true);
    }
  }

  Future<void> _updateCartItemCount() async {
    try {
      final savedCart = await CartPersistence.loadCart() ?? {};
      int count = 0;
      count += (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).values.fold(0, (s, v) => s + (v is int ? v : int.tryParse(v.toString()) ?? 0));
      count += (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).values.fold(0, (s, v) => s + (v is int ? v : int.tryParse(v.toString()) ?? 0));
      count += (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).values.fold(0, (s, v) => s + (v is int ? v : int.tryParse(v.toString()) ?? 0));
      count += (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).values.fold(0, (s, v) => s + (v is int ? v : int.tryParse(v.toString()) ?? 0));
      count += (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).values.fold(0, (s, v) => s + (v is int ? v : int.tryParse(v.toString()) ?? 0));
      count += (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).values.fold(0, (s, v) => s + (v['quantity'] as int? ?? 0));
      count += (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).values.fold(0, (s, v) => s + (v as List).fold(0, (ss, item) => ss + (item['quantity'] as int? ?? 0)));
      setState(() => _cartItemCount = count);
    } catch (e) {
      _showSnackBar("Error loading cart item count: ${e.toString()}", isError: true);
      setState(() => _cartItemCount = 0);
    }
  }

  Future<void> _updateUserName() async {
    if (_userPhoneNumber == null || _nameController.text.trim().isEmpty) {
      _showSnackBar("Please enter a valid name.", isError: true);
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('users').doc(_userPhoneNumber).set({'name': _nameController.text.trim()}, SetOptions(merge: true));
      setState(() => _userName = _nameController.text.trim());
      _showSnackBar("Name updated successfully!", isError: false);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Failed to update name: ${e.toString()}", isError: true);
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      HomePage.hasShownInitialAddressPrompt = false;
      await AddressPersistence.clearCurrentAddress();
      await AddressPersistence.clearAllAddresses();
      await CartPersistence.clearCart();
      _showSnackBar("Logged out successfully!", isError: false);
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      _showSnackBar("Error during logout: ${e.toString()}", isError: true);
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      AppUpdateInfo appUpdateInfo = await InAppUpdate.checkForUpdate();
      if (appUpdateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (appUpdateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (appUpdateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
        }
      }
    } catch (_) {}
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

  // â”€â”€â”€ Cart navigation helper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Map<String, int> _parseIntMap(Map<String, dynamic>? raw) {
    return (raw ?? {}).map((k, v) => MapEntry(k, v is int ? v : int.tryParse(v.toString()) ?? 0));
  }

  Future<void> _navigateToCart() async {
    try {
      final savedCart = await CartPersistence.loadCart() ?? {};
      final dci = _parseIntMap(savedCart['dryCleanItems'] as Map<String, dynamic>?);
      final ii  = _parseIntMap(savedCart['ironingItems'] as Map<String, dynamic>?);
      final wfi = _parseIntMap(savedCart['washAndFoldItems'] as Map<String, dynamic>?);
      final wii = _parseIntMap(savedCart['washAndIronItems'] as Map<String, dynamic>?);
      final wisi = _parseIntMap(savedCart['washIronStarchItems'] as Map<String, dynamic>?);
      final ppi = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).map((k, v) => MapEntry(k, Map<String, dynamic>.from(v)));
      final aS  = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).map((k, v) => MapEntry(k, (v as List<dynamic>).cast<Map<String, dynamic>>()));
      final dct = savedCart['dryCleanTotal'] as double? ?? 0.0;
      final at  = savedCart['additionalTotal'] as double? ?? 0.0;

      if (!mounted) return;
      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: CartPage(
        dryCleanItems: dci, ironingItems: ii, washAndFoldItems: wfi,
        washAndIronItems: wii, washIronStarchItems: wisi,
        prePlatedItems: ppi, additionalServices: aS,
        dryCleanTotal: dct, additionalTotal: at,
      ))).then((_) { _checkPremiumBookedStatus(); _updateCartItemCount(); });
    } catch (e) {
      _showSnackBar("Error loading cart: ${e.toString()}", isError: true);
    }
  }

  void _navigateToService(String name) {
    Widget dest;
    if (name == "Dry Clean") {
      dest = DryCleanPriceListPage();
    } else if (name == "Wash & Fold") {
      dest = WashAndFoldPage();
    } else if (name == "Wash & Iron") {
      dest = WashAndIronPage();
    } else if (name == "Steam Press Iron") {
      dest = IroningPriceListPage();
    } else if (name == "Saree Pre-Pleat") {
      dest = PrePlatedPage();
    } else {
      dest = WashAndStarchPage();
    }
    Navigator.of(context).push(PageTransition(type: PageTransitionType.rightToLeft, child: dest)).then((_) {
      _updateCartItemCount();
      _checkPremiumBookedStatus();
    });
  }

  // â”€â”€â”€ Profile sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _showProfileSheet() {
    final bool isWeb = MediaQuery.of(context).size.width >= 1000;

    Widget profileContent() => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [_primary, Color(0xFFFF6E40)]),
            boxShadow: [BoxShadow(color: _primary.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)],
          ),
          child: const CircleAvatar(backgroundColor: Colors.transparent, child: Icon(Icons.person_rounded, size: 48, color: Colors.white)),
        ),
        const SizedBox(height: 12),
        Text(_userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(_userPhoneNumber ?? "Phone: N/A", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: "Change Name",
            prefixIcon: const Icon(Icons.edit, color: _primary),
            labelStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _primary, width: 2)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _updateUserName,
            style: ElevatedButton.styleFrom(backgroundColor: _primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: const Text("Save Name", style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () { Navigator.pop(context); _logout(); },
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text("Logout", style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );

    if (isWeb) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
            child: Padding(padding: const EdgeInsets.all(28), child: SingleChildScrollView(child: profileContent())),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24 + MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(child: profileContent()),
        ),
      );
    }
  }

  // â”€â”€â”€ Service card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    final List<Color> gradient = (service['gradient'] as List).cast<Color>();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 80),
      curve: Curves.easeOut,
      builder: (context, val, child) => Opacity(opacity: val, child: Transform.translate(offset: Offset(0, 20 * (1 - val)), child: child)),
      child: GestureDetector(
        onTap: () => _navigateToService(service['name'] as String),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [BoxShadow(color: gradient.first.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned(
                  top: -20, left: -20,
                  child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.4))),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)),
                        child: Icon(service['icon'] as IconData, color: Colors.white, size: 24),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, height: 1.2)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(20)),
                            child: const Text("View Prices \u2192", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // â”€â”€â”€ Premium card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildPremiumCard(Map<String, dynamic> service) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (context, val, child) => Opacity(opacity: val, child: child),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.pinkAccent.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              SizedBox(
                height: 140, width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(service['image'] as String, fit: BoxFit.cover),
                    Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withValues(alpha: 0.4), Colors.black.withValues(alpha: 0.4)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
                    Positioned(
                      top: 12, right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.4), blurRadius: 8)],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text("PREMIUM", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(service['name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(service['price'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(service['description'] as String, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPremiumBooked ? null : () async {
                          try {
                            final savedCart = await CartPersistence.loadCart() ?? {};
                            final dci  = _parseIntMap(savedCart['dryCleanItems'] as Map<String, dynamic>?);
                            final ii   = _parseIntMap(savedCart['ironingItems'] as Map<String, dynamic>?);
                            final wfi  = _parseIntMap(savedCart['washAndFoldItems'] as Map<String, dynamic>?);
                            final wii  = _parseIntMap(savedCart['washAndIronItems'] as Map<String, dynamic>?);
                            final wisi = _parseIntMap(savedCart['washIronStarchItems'] as Map<String, dynamic>?);
                            final ppi  = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).map((k, v) => MapEntry(k, Map<String, dynamic>.from(v)));
                            final aS   = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).map((k, v) => MapEntry(k, (v as List<dynamic>).cast<Map<String, dynamic>>()));
                            final dct  = savedCart['dryCleanTotal'] as double? ?? 0.0;
                            final at   = savedCart['additionalTotal'] as double? ?? 0.0;

                            wfi['Premium Laundry'] = (wfi['Premium Laundry'] ?? 0) + 1;

                            await CartPersistence.saveCart(dryCleanItems: dci, ironingItems: ii, washAndFoldItems: wfi, washAndIronItems: wii, washIronStarchItems: wisi, prePlatedItems: ppi, additionalServices: aS, dryCleanTotal: dct, additionalTotal: at);
                            setState(() => _isPremiumBooked = true);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Premium Laundry added to cart"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                            Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: CartPage(dryCleanItems: dci, ironingItems: ii, washAndFoldItems: wfi, washAndIronItems: wii, washIronStarchItems: wisi, prePlatedItems: ppi, additionalServices: aS, dryCleanTotal: dct, additionalTotal: at)))
                              .then((_) { _checkPremiumBookedStatus(); _updateCartItemCount(); });
                          } catch (e) {
                            _showSnackBar("Error adding to cart: ${e.toString()}", isError: true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPremiumBooked ? Colors.grey.shade300 : Colors.pinkAccent,
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: _isPremiumBooked ? Colors.grey.shade600 : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: _isPremiumBooked ? 0 : 2,
                        ),
                        child: Text(_isPremiumBooked ? "\u2713 Already in Cart" : "Book Now \u2192", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _isPremiumBooked ? Colors.grey.shade600 : Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€â”€ Drawer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildDrawerMenu() {
    String fullAddressString = "No address selected";
    if (_currentAddress != null) {
      final door  = _currentAddress!['doorNumber'] ?? '';
      final street = _currentAddress!['street'] ?? '';
      final label = _currentAddress!['label'] ?? 'Address';
      fullAddressString = "$label: $door, $street";
    }

    return Drawer(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [_primaryDark, _primary], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            width: double.infinity,
            padding: const EdgeInsets.only(top: 56, bottom: 28, left: 16, right: 16),
            child: Column(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.4), border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.person_rounded, size: 42, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                Text(fullAddressString, style: const TextStyle(fontSize: 13, color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerTile(Icons.receipt_long_rounded, "Orders", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserOrdersPage()))),
                _drawerTile(Icons.local_laundry_service, "Active Subscriptions", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionDetailsPage()))),
                _drawerTile(Icons.phone_rounded, "Contact", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactPage()))),
                _drawerTile(Icons.settings_rounded, "Settings", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))),
                _drawerTile(Icons.feedback_rounded, "Feedback", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackPage()))),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10),
            child: _drawerTile(Icons.logout_rounded, "Logout", () async {
              await FirebaseAuth.instance.signOut();
              HomePage.hasShownInitialAddressPrompt = false;
              if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
            }, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String label, VoidCallback onTap, {Color color = _primary}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  // â”€â”€â”€ Hero banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildHeroBanner() {
    return SlideTransition(
      position: _heroSlide,
      child: FadeTransition(
        opacity: _heroFade,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Color(0xFFFF80AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(top: -30, right: -30, child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2)))),
              Positioned(bottom: -20, left: 80, child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: Text("\u{1F44B}  Hello, $_userName", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 16),
                    const Text("Fresh clothes,\ndelivered to you.", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.5)),
                    const SizedBox(height: 10),
                    Text("Pick up \u00b7 Clean \u00b7 Deliver", style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15)),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _statChip(Icons.bolt_rounded, "Fast Delivery"),
                        _statChip(Icons.eco_rounded, "Eco-Friendly"),
                        _statChip(Icons.verified_rounded, "Trusted"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: -0.3)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
      ],
    );
  }

  // â”€â”€â”€ Layouts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeroBanner()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          sliver: SliverToBoxAdapter(child: _sectionHeader("Our Services", "Tap a service to see pricing")),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _buildServiceCard(standardServices[i], i),
              childCount: standardServices.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.9,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          sliver: SliverToBoxAdapter(child: _sectionHeader("Premium Services", "Elite care for your finest garments")),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          sliver: SliverList(delegate: SliverChildBuilderDelegate(
            (context, i) => _buildPremiumCard(premiumServices[i]),
            childCount: premiumServices.length,
          )),
        ),
      ],
    );
  }

  Widget _buildWebLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pinkAccent, Color(0xFFFF80AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: Text("\u{1F44B}  Welcome back, $_userName", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 20),
                      const Text("Fresh clothes,\ndelivered to you.", style: TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -1)),
                      const SizedBox(height: 16),
                      Text("We'll pick up, clean, and deliver your clothes.", style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 18)),
                      const SizedBox(height: 28),
                      Wrap(spacing: 12, children: [
                        _statChip(Icons.bolt_rounded, "Fast Delivery"),
                        _statChip(Icons.eco_rounded, "Eco-Friendly"),
                        _statChip(Icons.verified_rounded, "Trusted"),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader("Our Services", "Tap a service to see pricing"),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.1, crossAxisSpacing: 20, mainAxisSpacing: 20),
                      itemCount: standardServices.length,
                      itemBuilder: (_, i) => _buildServiceCard(standardServices[i], i),
                    ),
                    const SizedBox(height: 40),
                    _sectionHeader("Premium Services", "Elite care for your finest garments"),
                    const SizedBox(height: 20),
                    SizedBox(width: 520, child: _buildPremiumCard(premiumServices[0])),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primary,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const SizedBox.shrink(),
      actions: [
        GestureDetector(
          onTap: () => _showAddressSelectionSheet(onAddressChanged: _loadCurrentAddress),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _currentAddress != null ? (_currentAddress!['label'] as String? ?? 'Select') : 'Select Address',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        Stack(
          children: [
            IconButton(icon: const Icon(Icons.shopping_bag_rounded, color: Colors.white), onPressed: _navigateToCart),
            if (_cartItemCount > 0)
              Positioned(
                right: 6, top: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text('$_cartItemCount', style: const TextStyle(color: _primaryDark, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: _showProfileSheet,
            child: Container(
              width: 36, height: 36,
              margin: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, spreadRadius: 1)],
              ),
              child: const Icon(Icons.person_rounded, color: _primaryDark, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  // â”€â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 1000;
    return Title(
      title: 'V12 Laundry | Home',
      color: _primary,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) SystemNavigator.pop();
        },
        child: Scaffold(
          backgroundColor: _surface,
          drawer: _buildDrawerMenu(),
          appBar: _buildAppBar(),
          body: isMobile ? _buildMobileLayout() : _buildWebLayout(),
        ),
      ),
    );
  }
}




