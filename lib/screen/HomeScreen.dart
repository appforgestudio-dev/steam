// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:steam/price%20list/DryCleanPriceList.dart';
// import 'package:steam/price%20list/starch.dart';
// import 'package:steam/price%20list/wash_iron.dart';
// import 'package:steam/screen/MainPage.dart';
// import 'package:steam/screen/cart.dart';
// import '../constant/constant.dart';
// import '../constant/cart_persistence.dart';
// import '../price%20list/iron.dart';
// import '../price%20list/pre_plate.dart';
// import '../price%20list/wash_fold.dart';
// import 'package:flutter/services.dart';
// import '../constant/address_persistence.dart';
// import '../sub screen/contact.dart';
// import '../sub screen/feedback.dart';
// import '../sub screen/settings.dart';
// import '../sub screen/subscription.dart';
// import 'AddressPage.dart';
// import '../sub screen/ordersPage.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   String _userName = "Guest";
//   String? _userPhoneNumber;
//   final TextEditingController _nameController = TextEditingController();
//   Map<String, dynamic>? _currentAddress;
//   bool _isPremiumBooked = false;
//   String? _currentVersion;
//   bool _isCheckingUpdate = false;
//   bool _isUpdateAvailable = false;
//   int _cartItemCount = 0;
//
//   final List<Map<String, dynamic>> standardServices = const [
//     {"name": "Wash & Fold", "color": Colors.white, "image": "assets/images/wash-fold.png", "price": "View Prices"},
//     {"name": "Wash & Iron", "color": Colors.white, "image": "assets/images/wash-iron.png", "price": "View Prices"},
//     {"name": "Dry Clean", "color": Colors.white, "image": "assets/images/dry-cleaning.png", "price": "View Prices"},
//     {"name": "Steam Press Iron", "color": Colors.white, "image": "assets/images/ironing.png", "price": "View Prices"},
//     {"name": "Saree Pre-Pleat", "color": Colors.white, "image": "assets/images/saree.png", "price": "View Prices"},
//     {"name": "Wash & Starch", "color": Colors.white, "image": "assets/images/starch.png", "price": "View Prices"},
//   ];
//
//   final List<Map<String, dynamic>> premiumServices = const [
//     {"name": "Premium Laundry", "color": Colors.white, "image": "assets/images/premium.png", "price": "₹159/KG", "description": "Wash, Iron, Fragrance, Fold, Special Packing"},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _initializePage();
//   }
//
//   Future<void> _initializePage() async {
//     await _fetchUserName();
//     await _loadCurrentAddress();
//     _checkPremiumBookedStatus();
//     _checkForUpdate();
//     _updateCartItemCount();
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchUserName() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null && user.phoneNumber != null) {
//       _userPhoneNumber = user.phoneNumber;
//       try {
//         final userDoc = await FirebaseFirestore.instance.collection('users').doc(_userPhoneNumber).get();
//         if (userDoc.exists && userDoc.data() != null) {
//           setState(() {
//             _userName = userDoc.data()!['name'] as String? ?? "User";
//           });
//           _nameController.text = _userName;
//         } else {
//           setState(() => _userName = "New User");
//           _nameController.text = "";
//         }
//       } catch (e) {
//         _showSnackBar("Failed to load user name: ${e.toString()}", isError: true);
//         setState(() => _userName = "Error User");
//       }
//     } else {
//       setState(() => _userName = "Guest");
//     }
//   }
//
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
//
//   Future<void> _showAddressSelectionSheet() async {
//
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
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? bgColorPink : Colors.transparent, width: 1.5)),
//                         child: ListTile(
//                           leading: const Icon(Icons.location_on_outlined, color: bgColorPink),
//                           title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//                           subtitle: Text("$door, $street"),
//                           // ### START: MODIFIED TRAILING WIDGET ###
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               if (isSelected)
//                                 const Icon(Icons.check_circle, color: bgColorPink),
//                               IconButton(
//                                 icon: Icon(Icons.close, color: Colors.grey[400]),
//                                 onPressed: () => _handleDeleteAddress(address),
//                                 tooltip: 'Delete Address',
//                               ),
//                             ],
//                           ),
//                           // ### END: MODIFIED TRAILING WIDGET ###
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
//                   style: ElevatedButton.styleFrom(backgroundColor: bgColorPink, padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025))),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//
//   Future<void> _checkPremiumBookedStatus() async {
//     try {
//       final savedCart = await CartPersistence.loadCart() ?? {};
//       final washAndFoldItems = (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {});
//       setState(() {
//         _isPremiumBooked = washAndFoldItems.containsKey('Premium Laundry') && (washAndFoldItems['Premium Laundry'] as int? ?? 0) > 0;
//       });
//     } catch (e) {
//       _showSnackBar("Error checking cart status: ${e.toString()}", isError: true);
//     }
//   }
//
//   Future<void> _updateCartItemCount() async {
//     try {
//       final savedCart = await CartPersistence.loadCart() ?? {};
//       int count = 0;
//       count += (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).values.fold(0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).values.fold(0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).values.fold(0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).values.fold(0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).values.fold(0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).values.fold(0, (sum, value) => sum + (value['quantity'] as int? ?? 0));
//       count += (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).values.fold(0, (sum, value) => sum + (value as List).fold(0, (subSum, item) => subSum + (item['quantity'] as int? ?? 0)));
//       setState(() => _cartItemCount = count);
//     } catch (e) {
//       _showSnackBar("Error loading cart item count: ${e.toString()}", isError: true);
//       setState(() => _cartItemCount = 0);
//     }
//   }
//
//   Future<void> _updateUserName() async {
//     if (_userPhoneNumber == null || _nameController.text.trim().isEmpty) {
//       _showSnackBar("Please enter a valid name.", isError: true);
//       return;
//     }
//     try {
//       await FirebaseFirestore.instance.collection('users').doc(_userPhoneNumber).set({'name': _nameController.text.trim()}, SetOptions(merge: true));
//       setState(() => _userName = _nameController.text.trim());
//       _showSnackBar("Name updated successfully!", isError: false);
//       Navigator.pop(context);
//     } catch (e) {
//       _showSnackBar("Failed to update name: ${e.toString()}", isError: true);
//     }
//   }
//
//   Future<void> _logout() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       await AddressPersistence.clearCurrentAddress();
//       await AddressPersistence.clearAllAddresses();
//       await CartPersistence.clearCart();
//       _showSnackBar("Logged out successfully!", isError: false);
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainPage()));
//     } catch (e) {
//       _showSnackBar("Error during logout: ${e.toString()}", isError: true);
//     }
//   }
//
//   void _showProfileSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         final screenWidth = MediaQuery.of(context).size.width;
//         final screenHeight = MediaQuery.of(context).size.height;
//         return SingleChildScrollView(
//           child: Container(
//             padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + screenHeight * 0.025, top: screenHeight * 0.025, left: screenWidth * 0.05, right: screenWidth * 0.05),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircleAvatar(radius: screenWidth * 0.1, backgroundColor: bgColorPink, child: Icon(Icons.person, size: screenWidth * 0.1, color: Colors.white)),
//                 SizedBox(height: screenHeight * 0.012),
//                 Text(_userName, style: TextStyle(fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold, color: Colors.black87)),
//                 Text(_userPhoneNumber ?? "Phone: N/A", style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey[600])),
//                 SizedBox(height: screenHeight * 0.025),
//                 TextField(controller: _nameController, decoration: InputDecoration(labelText: "Change Name", labelStyle: TextStyle(color: Colors.grey[700]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025), borderSide: BorderSide(color: Colors.grey.shade400)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025), borderSide: const BorderSide(color: bgColorPink, width: 2))), style: const TextStyle(color: Colors.black87)),
//                 SizedBox(height: screenHeight * 0.018),
//                 SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _updateUserName, style: ElevatedButton.styleFrom(backgroundColor: bgColorPink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025)), padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018)), child: Text("Save Name", style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white)))),
//                 SizedBox(height: screenHeight * 0.012),
//                 SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _logout, style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025)), padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018)), child: Text("Logout", style: TextStyle(fontSize: screenWidth * 0.04)))),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green));
//   }
//
//   Widget _buildServiceCard(Map<String, dynamic> service, BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Widget destinationPage;
//         if (service["name"] == "Dry Clean") destinationPage = const DryCleanPriceListPage();
//         else if (service["name"] == "Wash & Fold") destinationPage = const WashAndFoldPage();
//         else if (service["name"] == "Wash & Iron") destinationPage = const WashAndIronPage();
//         else if (service["name"] == "Steam Press Iron") destinationPage = const IroningPriceListPage();
//         else if (service["name"] == "Saree Pre-Pleat") destinationPage = const PrePlatedPage();
//         else destinationPage = const WashAndStarchPage();
//         Navigator.of(context).push(PageTransition(type: PageTransitionType.rightToLeft, child: destinationPage)).then((_) {
//           _updateCartItemCount();
//           _checkPremiumBookedStatus();
//         });
//       },
//       borderRadius: BorderRadius.circular(15),
//       child: Container(
//         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)]),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 100, width: double.infinity, child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: Image.asset(service["image"], fit: BoxFit.contain))),
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(service["name"], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
//                   const SizedBox(height: 5),
//                   Text(service["price"], style: const TextStyle(fontSize: 13, color: bgColorPink, fontWeight: FontWeight.w600)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPremiumCard(Map<String, dynamic> service, BuildContext context) {
//     return InkWell(
//       onTap: () {},
//       borderRadius: BorderRadius.circular(15),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//               child: Stack(
//                 children: [
//                   Image.asset(
//                     service["image"],
//                     height: 120,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                   Positioned(
//                     top: 10,
//                     right: 10,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.amber.shade700,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Text(
//                         "PREMIUM",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(15),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         service["name"],
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       Text(
//                         service["price"],
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: bgColorPink,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     service["description"],
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isPremiumBooked
//                           ? null
//                           : () async {
//                         try {
//                           final savedCart = await CartPersistence.loadCart() ?? {};
//
//                           final dryCleanItems = (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {})
//                               .map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                           final ironingItems = (savedCart['ironingItems'] as Map<String, dynamic>? ?? {})
//                               .map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                           final washAndFoldItems = (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {})
//                               .map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                           final washAndIronItems = (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {})
//                               .map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                           final washIronStarchItems = (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {})
//                               .map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                           final prePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {})
//                               .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
//                           final additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {})
//                               .map((key, value) => MapEntry(key, (value as List<dynamic>).cast<Map<String, dynamic>>()));
//                           final dryCleanTotal = savedCart['dryCleanTotal'] as double? ?? 0.0;
//                           final additionalTotal = savedCart['additionalTotal'] as double? ?? 0.0;
//
//                           washAndFoldItems['Premium Laundry'] = (washAndFoldItems['Premium Laundry'] ?? 0) + 1;
//
//                           await CartPersistence.saveCart(
//                             dryCleanItems: dryCleanItems,
//                             ironingItems: ironingItems,
//                             washAndFoldItems: washAndFoldItems,
//                             washAndIronItems: washAndIronItems,
//                             washIronStarchItems: washIronStarchItems,
//                             prePlatedItems: prePlatedItems,
//                             additionalServices: additionalServices,
//                             dryCleanTotal: dryCleanTotal,
//                             additionalTotal: additionalTotal,
//                           );
//
//                           setState(() {
//                             _isPremiumBooked = true;
//                           });
//
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text("Premium Laundry added to cart"),
//                               backgroundColor: Colors.green,
//                               duration: Duration(seconds: 2),
//                             ),
//                           );
//
//                           Navigator.push(
//                             context,
//                             PageTransition(
//                               type: PageTransitionType.rightToLeft,
//                               child: CartPage(
//                                 dryCleanItems: dryCleanItems,
//                                 ironingItems: ironingItems,
//                                 washAndFoldItems: washAndFoldItems,
//                                 washAndIronItems: washAndIronItems,
//                                 washIronStarchItems: washIronStarchItems,
//                                 prePlatedItems: prePlatedItems,
//                                 additionalServices: additionalServices,
//                                 dryCleanTotal: dryCleanTotal,
//                                 additionalTotal: additionalTotal,
//                               ),
//                             ),
//                           ).then((_) {
//                             _checkPremiumBookedStatus();
//                             _updateCartItemCount(); // Update cart item count after navigation
//                           });
//                         } catch (e) {
//                           _showSnackBar("Error adding to cart: ${e.toString()}", isError: true);
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _isPremiumBooked ? Colors.grey : bgColorPink,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       child: Text(
//                         _isPremiumBooked ? "Already in Cart" : "Book Now",
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDrawerMenu() {
//     String fullAddressString = "No address selected";
//     if (_currentAddress != null) {
//       final door = _currentAddress!['doorNumber'] ?? '';
//       final street = _currentAddress!['street'] ?? '';
//       final label = _currentAddress!['label'] ?? 'Address';
//       fullAddressString = "$label: $door, $street";
//     }
//
//     return Drawer(
//       child: Column(
//         children: [
//           Container(
//             color: bgColorPink,
//             width: double.infinity,
//             padding: const EdgeInsets.only(top: 40, bottom: 24),
//             child: Column(
//               children: [
//                 const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: bgColorPink)),
//                 const SizedBox(height: 12),
//                 Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
//                 const SizedBox(height: 8),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     fullAddressString,
//                     style: const TextStyle(fontSize: 14, color: Colors.white70),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Divider(color: Colors.grey, thickness: 1, indent: 16, endIndent: 16),
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 ListTile(leading: const Icon(Icons.receipt_long, color: bgColorPink), title: const Text("Orders", style: TextStyle(fontSize: 16, color: Colors.black87)), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserOrdersPage()))),
//                 ListTile(leading: const Icon(Icons.local_laundry_service, color: bgColorPink), title: const Text("Active Subscriptions", style: TextStyle(fontSize: 16, color: Colors.black87)), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionDetailsPage()))),
//                 ListTile(leading: const Icon(Icons.phone, color: bgColorPink), title: const Text("Contact", style: TextStyle(fontSize: 16, color: Colors.black87)), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactPage()))),
//                 ListTile(leading: const Icon(Icons.settings, color: bgColorPink), title: const Text("Settings", style: TextStyle(fontSize: 16, color: Colors.black87)), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()))),
//                 ListTile(leading: const Icon(Icons.feedback, color: bgColorPink), title: const Text("Feedback", style: TextStyle(fontSize: 16, color: Colors.black87)), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackPage()))),
//               ],
//             ),
//           ),
//           const Divider(thickness: 1),
//           Padding(
//             padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10),
//             child: ListTile(leading: const Icon(Icons.logout, color: bgColorPink), title: const Text("Logout", style: TextStyle(fontSize: 16, color: Colors.black87)), onTap: () async { await FirebaseAuth.instance.signOut(); Navigator.of(context).popUntil((route) => route.isFirst); }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _checkForUpdate() async {
//     setState(() => _isCheckingUpdate = true);
//     try {
//       PackageInfo packageInfo = await PackageInfo.fromPlatform();
//       _currentVersion = packageInfo.version;
//       const String packageName = "com.laundry.steam";
//       final response = await http.get(Uri.parse('https://play.google.com/store/apps/details?id=$packageName&hl=en'));
//       if (response.statusCode == 200) {
//         final document = RegExp(r'Current Version</div><span class="htlgb"><div class="IQ1z0d"><span class="htlgb">([0-9]+(\.[0-9]+)+)</span>').firstMatch(response.body);
//         if (document != null && document.groupCount > 0) {
//           final latestVersion = document.group(1)!;
//           final current = _currentVersion!.split('.');
//           final latest = latestVersion.split('.');
//           bool isUpdateAvailable = false;
//           for (int i = 0; i < current.length; i++) {
//             if (i >= latest.length || int.parse(latest[i]) > int.parse(current[i])) { isUpdateAvailable = true; break; }
//             else if (int.parse(latest[i]) < int.parse(current[i])) { break; }
//           }
//           if (isUpdateAvailable) {
//             setState(() => _isUpdateAvailable = true);
//             _showUpdateDialog(latestVersion);
//           }
//         }
//       }
//     } catch (e) { print("Error checking for update: $e"); }
//     finally { setState(() => _isCheckingUpdate = false); }
//   }
//
//   void _showUpdateDialog(String latestVersion) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Update Available"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text("A new version of the app is available."),
//               const SizedBox(height: 10),
//               Text("Current Version: $_currentVersion"),
//               Text("Latest Version: $latestVersion"),
//               const SizedBox(height: 10),
//               const Text("Please update to enjoy the latest features and improvements."),
//             ],
//           ),
//           actions: [
//             TextButton(child: const Text("Update Now"), onPressed: () { _launchPlayStore(); Navigator.of(context).pop(); }),
//             TextButton(child: const Text("Later"), onPressed: () => Navigator.of(context).pop()),
//           ],
//         );
//       },
//     );
//   }
//
//   void _launchPlayStore() async {
//     const String packageName = "com.laundry.steam";
//     final Uri uri = Uri.parse("market://details?id=$packageName");
//     if (await canLaunchUrl(uri)) await launchUrl(uri);
//     else {
//       final Uri webUri = Uri.parse("https://play.google.com/store/apps/details?id=$packageName");
//       if (await canLaunchUrl(webUri)) await launchUrl(webUri);
//       else _showSnackBar("Could not open Play Store.", isError: true);
//     }
//   }
//
//   Widget _buildBody() {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Container(
//             color: bgColorPink,
//             padding: const EdgeInsets.only(top: 30, left: 25, bottom: 40, right: 25),
//             width: double.infinity,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text("Book pickups and\nservices with ease", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2)),
//                 SizedBox(height: 15),
//                 Text("We'll pick up, clean, and deliver your clothes", style: TextStyle(color: Colors.white70, fontSize: 16)),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Standard Services", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
//                 const SizedBox(height: 10),
//                 GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 15, mainAxisSpacing: 15), itemCount: standardServices.length, itemBuilder: (context, index) => _buildServiceCard(standardServices[index], context)),
//                 const SizedBox(height: 30),
//                 Text("Premium Services", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
//                 const SizedBox(height: 10),
//                 ...premiumServices.map((service) => _buildPremiumCard(service, context)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         SystemNavigator.pop();
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: bgColorPink,
//           elevation: 0,
//           title: const Text(''),
//           iconTheme: const IconThemeData(color: Colors.white),
//           actions: [
//             InkWell(
//               onTap: _showAddressSelectionSheet,
//               borderRadius: BorderRadius.circular(20),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.location_on, color: Colors.white, size: 18),
//                     const SizedBox(width: 1),
//                     Flexible(
//                       child: Text(
//                         _currentAddress != null ? (_currentAddress!['label'] as String? ?? 'Select Address') : 'Select Address',
//                         style: const TextStyle(color: Colors.white, fontSize: 14),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(width: 4),
//             Stack(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.shopping_cart, color: Colors.white),
//                   onPressed: () async {
//                     try {
//                       final savedCart = await CartPersistence.loadCart() ?? {};
//                       final dryCleanItems = (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                       final ironingItems = (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                       final washAndFoldItems = (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                       final washAndIronItems = (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                       final washIronStarchItems = (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                       final prePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
//                       final additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, (value as List<dynamic>).cast<Map<String, dynamic>>()));
//                       final dryCleanTotal = savedCart['dryCleanTotal'] as double? ?? 0.0;
//                       final additionalTotal = savedCart['additionalTotal'] as double? ?? 0.0;
//                       Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: CartPage(dryCleanItems: dryCleanItems, ironingItems: ironingItems, washAndFoldItems: washAndFoldItems, washAndIronItems: washAndIronItems, washIronStarchItems: washIronStarchItems, prePlatedItems: prePlatedItems, additionalServices: additionalServices, dryCleanTotal: dryCleanTotal, additionalTotal: additionalTotal))).then((_) {
//                         _checkPremiumBookedStatus();
//                         _updateCartItemCount();
//                       });
//                     } catch (e) {
//                       _showSnackBar("Error loading cart: ${e.toString()}", isError: true);
//                     }
//                   },
//                 ),
//                 if (_cartItemCount > 0)
//                   Positioned(
//                     right: 8,
//                     top: 8,
//                     child: Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
//                       constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
//                       child: Text(_cartItemCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
//                     ),
//                   ),
//               ],
//             ),
//             IconButton(icon: const Icon(Icons.account_circle, color: Colors.white), onPressed: _showProfileSheet),
//           ],
//         ),
//         drawer: _buildDrawerMenu(),
//         body: _buildBody(),
//       ),
//     );
//   }
// }


// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:steam/price%20list/DryCleanPriceList.dart';
// import 'package:steam/price%20list/starch.dart';
// import 'package:steam/price%20list/wash_iron.dart';
// import 'package:steam/screen/MainPage.dart';
// import 'package:steam/screen/cart.dart';
// import '../constant/constant.dart';
// import '../constant/cart_persistence.dart';
// import '../price%20list/iron.dart';
// import '../price%20list/pre_plate.dart';
// import '../price%20list/wash_fold.dart';
// import 'package:flutter/services.dart';
// import '../constant/address_persistence.dart';
// import '../sub%20screen/contact.dart';
// import '../sub%20screen/feedback.dart';
// import '../sub%20screen/settings.dart';
// import '../sub%20screen/subscription.dart';
// import 'AddressPage.dart';
// import '../sub%20screen/ordersPage.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:in_app_update/in_app_update.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   String _userName = "Guest";
//   String? _userPhoneNumber;
//   final TextEditingController _nameController = TextEditingController();
//   Map<String, dynamic>? _currentAddress;
//   bool _isPremiumBooked = false;
//   String? _currentVersion;
//   bool _isCheckingUpdate = false;
//   bool _isUpdateAvailable = false;
//   int _cartItemCount = 0;
//   bool _isAddressSheetBeingShown = false;
//   bool _hasCheckedAddress = false;
//
//   final List<Map<String, dynamic>> standardServices = const [
//     {
//       "name": "Wash & Fold",
//       "color": Colors.white,
//       "image": "assets/images/wash-fold.png",
//       "price": "View Prices"
//     },
//     {
//       "name": "Wash & Iron",
//       "color": Colors.white,
//       "image": "assets/images/wash-iron.png",
//       "price": "View Prices"
//     },
//     {
//       "name": "Dry Clean",
//       "color": Colors.white,
//       "image": "assets/images/dry-cleaning.png",
//       "price": "View Prices"
//     },
//     {
//       "name": "Steam Press Iron",
//       "color": Colors.white,
//       "image": "assets/images/ironing.png",
//       "price": "View Prices"
//     },
//     {
//       "name": "Saree Pre-Pleat",
//       "color": Colors.white,
//       "image": "assets/images/saree.png",
//       "price": "View Prices"
//     },
//     {
//       "name": "Wash & Starch",
//       "color": Colors.white,
//       "image": "assets/images/starch.png",
//       "price": "View Prices"
//     },
//   ];
//
//   final List<Map<String, dynamic>> premiumServices = const [
//     {
//       "name": "Premium Laundry",
//       "color": Colors.white,
//       "image": "assets/images/premium.png",
//       "price": "₹159/KG",
//       "description": "Wash, Iron, Fragrance, Fold, Special Packing"
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _initializePage();
//   }
//
//   Future<void> _initializePage() async {
//     await _fetchUserName();
//     await _loadCurrentAddress();
//     _checkPremiumBookedStatus();
//     _checkForUpdate();
//     _updateCartItemCount();
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchUserName() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null && user.phoneNumber != null) {
//       _userPhoneNumber = user.phoneNumber;
//       try {
//         final userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(_userPhoneNumber)
//             .get();
//         if (userDoc.exists && userDoc.data() != null) {
//           setState(() {
//             _userName = userDoc.data()!['name'] as String? ?? "User";
//           });
//           _nameController.text = _userName;
//         } else {
//           setState(() => _userName = "New User");
//           _nameController.text = "";
//         }
//       } catch (e) {
//         _showSnackBar("Failed to load user name: ${e.toString()}", isError: true);
//         setState(() => _userName = "Error User");
//       }
//     } else {
//       setState(() => _userName = "Guest");
//     }
//   }
//
//   Future<void> _loadCurrentAddress() async {
//     try {
//       final savedAddress = await AddressPersistence.loadCurrentAddress();
//       setState(() {
//         _currentAddress = savedAddress;
//         if (_currentAddress == null) {
//           _hasCheckedAddress = false;
//         }
//       });
//       if (_currentAddress == null && mounted) {
//         _showAddressSelectionSheet();
//       }
//     } catch (e) {
//       _showSnackBar("Failed to load address: ${e.toString()}", isError: true);
//       setState(() {
//         _currentAddress = null;
//         _hasCheckedAddress = false;
//       });
//       if (mounted) {
//         _showAddressSelectionSheet();
//       }
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
//       await _loadCurrentAddress(); // This will trigger _showAddressSelectionSheet if needed
//       if (mounted) {
//         Navigator.pop(context); // Close the current sheet
//       }
//     }
//   }
//
//   Future<void> _showAddressSelectionSheet() async {
//     if (_isAddressSheetBeingShown || (_currentAddress != null && _hasCheckedAddress)) {
//       return;
//     }
//
//     try {
//       if (mounted) setState(() => _isAddressSheetBeingShown = true);
//
//       final List<Map<String, dynamic>> savedAddresses =
//       await AddressPersistence.loadAllAddresses();
//       final Map<String, dynamic>? currentAddress =
//       await AddressPersistence.loadCurrentAddress();
//       if (!mounted) return;
//
//       await showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         isDismissible: false,
//         enableDrag: false,
//         builder: (BuildContext context) {
//           final screenWidth = MediaQuery.of(context).size.width;
//           final screenHeight = MediaQuery.of(context).size.height;
//           return Container(
//             padding: EdgeInsets.only(
//               top: screenHeight * 0.025,
//               left: screenWidth * 0.05,
//               right: screenWidth * 0.05,
//               bottom: screenHeight * 0.025 + MediaQuery.of(context).viewPadding.bottom,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Select Pickup Address",
//                   style: TextStyle(
//                       fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: screenHeight * 0.018),
//                 if (savedAddresses.isEmpty)
//                   Center(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025),
//                       child: const Text("No saved addresses found."),
//                     ),
//                   )
//                 else
//                   Flexible(
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: savedAddresses.length,
//                       itemBuilder: (context, index) {
//                         final address = savedAddresses[index];
//                         final label = address['label'] ?? 'Address';
//                         final street = address['street'] ?? '';
//                         final door = address['doorNumber'] ?? '';
//                         final bool isSelected = currentAddress != null &&
//                             currentAddress['label'] == address['label'] &&
//                             currentAddress['street'] == address['street'];
//                         return Card(
//                           margin: EdgeInsets.symmetric(vertical: screenHeight * 0.006),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             side: BorderSide(
//                               color: isSelected ? bgColorPink : Colors.transparent,
//                               width: 1.5,
//                             ),
//                           ),
//                           child: ListTile(
//                             leading: const Icon(Icons.location_on_outlined,
//                                 color: bgColorPink),
//                             title: Text(label,
//                                 style: const TextStyle(fontWeight: FontWeight.bold)),
//                             subtitle: Text("$door, $street"),
//                             trailing: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 if (isSelected)
//                                   const Icon(Icons.check_circle, color: bgColorPink),
//                                 IconButton(
//                                   icon: Icon(Icons.close, color: Colors.grey[400]),
//                                   onPressed: () => _handleDeleteAddress(address),
//                                   tooltip: 'Delete Address',
//                                 ),
//                               ],
//                             ),
//                             onTap: () async {
//                               await AddressPersistence.saveCurrentAddress(address);
//                               await _loadCurrentAddress();
//                               Navigator.pop(context);
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 SizedBox(height: screenHeight * 0.018),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.add_location_alt_outlined,
//                         color: Colors.white),
//                     label: const Text("Add New Address",
//                         style: TextStyle(color: Colors.white)),
//                     onPressed: () async {
//                       Navigator.pop(context); // Pop the current sheet
//                       await Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => const AddressPage()),
//                       );
//                       await _loadCurrentAddress(); // Trigger sheet if no address selected
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: bgColorPink,
//                       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(screenWidth * 0.025),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isAddressSheetBeingShown = false;
//           _hasCheckedAddress = true;
//         });
//       }
//     }
//   }
//
//   Future<void> _checkPremiumBookedStatus() async {
//     try {
//       final savedCart = await CartPersistence.loadCart() ?? {};
//       final washAndFoldItems =
//       (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {});
//       setState(() {
//         _isPremiumBooked = washAndFoldItems.containsKey('Premium Laundry') &&
//             (washAndFoldItems['Premium Laundry'] as int? ?? 0) > 0;
//       });
//     } catch (e) {
//       _showSnackBar("Error checking cart status: ${e.toString()}", isError: true);
//     }
//   }
//
//   Future<void> _updateCartItemCount() async {
//     try {
//       final savedCart = await CartPersistence.loadCart() ?? {};
//       int count = 0;
//       count += (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {})
//           .values
//           .fold(
//           0,
//               (sum, value) =>
//           sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['ironingItems'] as Map<String, dynamic>? ?? {})
//           .values
//           .fold(
//           0,
//               (sum, value) =>
//           sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {})
//           .values
//           .fold(
//           0,
//               (sum, value) =>
//           sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {})
//           .values
//           .fold(
//           0,
//               (sum, value) =>
//           sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {})
//           .values
//           .fold(
//           0,
//               (sum, value) =>
//           sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {})
//           .values
//           .fold(0, (sum, value) => sum + (value['quantity'] as int? ?? 0));
//       count += (savedCart['additionalServices'] as Map<String, dynamic>? ?? {})
//           .values
//           .fold(
//           0,
//               (sum, value) => sum +
//               (value as List)
//                   .fold(0, (subSum, item) => subSum + (item['quantity'] as int? ?? 0)));
//       setState(() => _cartItemCount = count);
//     } catch (e) {
//       _showSnackBar("Error loading cart item count: ${e.toString()}", isError: true);
//       setState(() => _cartItemCount = 0);
//     }
//   }
//
//   Future<void> _updateUserName() async {
//     if (_userPhoneNumber == null || _nameController.text.trim().isEmpty) {
//       _showSnackBar("Please enter a valid name.", isError: true);
//       return;
//     }
//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(_userPhoneNumber)
//           .set({'name': _nameController.text.trim()}, SetOptions(merge: true));
//       setState(() => _userName = _nameController.text.trim());
//       _showSnackBar("Name updated successfully!", isError: false);
//       Navigator.pop(context);
//     } catch (e) {
//       _showSnackBar("Failed to update name: ${e.toString()}", isError: true);
//     }
//   }
//
//   Future<void> _logout() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       await AddressPersistence.clearCurrentAddress();
//       await AddressPersistence.clearAllAddresses();
//       await CartPersistence.clearCart();
//       _showSnackBar("Logged out successfully!", isError: false);
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => const MainPage()));
//     } catch (e) {
//       _showSnackBar("Error during logout: ${e.toString()}", isError: true);
//     }
//   }
//
//   void _showProfileSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         final screenWidth = MediaQuery.of(context).size.width;
//         final screenHeight = MediaQuery.of(context).size.height;
//         return SingleChildScrollView(
//           child: Container(
//             padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom +
//                     MediaQuery.of(context).viewPadding.bottom +
//                     screenHeight * 0.025,
//                 top: screenHeight * 0.025,
//                 left: screenWidth * 0.05,
//                 right: screenWidth * 0.05),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircleAvatar(
//                     radius: screenWidth * 0.1,
//                     backgroundColor: bgColorPink,
//                     child: Icon(Icons.person,
//                         size: screenWidth * 0.1, color: Colors.white)),
//                 SizedBox(height: screenHeight * 0.012),
//                 Text(_userName,
//                     style: TextStyle(
//                         fontSize: screenWidth * 0.055,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87)),
//                 Text(_userPhoneNumber ?? "Phone: N/A",
//                     style: TextStyle(
//                         fontSize: screenWidth * 0.035, color: Colors.grey[600])),
//                 SizedBox(height: screenHeight * 0.025),
//                 TextField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                         labelText: "Change Name",
//                         labelStyle: TextStyle(color: Colors.grey[700]),
//                         border: OutlineInputBorder(
//                             borderRadius:
//                             BorderRadius.circular(screenWidth * 0.025),
//                             borderSide: BorderSide(color: Colors.grey.shade400)),
//                         focusedBorder: OutlineInputBorder(
//                             borderRadius:
//                             BorderRadius.circular(screenWidth * 0.025),
//                             borderSide:
//                             const BorderSide(color: bgColorPink, width: 2))),
//                     style: const TextStyle(color: Colors.black87)),
//                 SizedBox(height: screenHeight * 0.018),
//                 SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                         onPressed: _updateUserName,
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: bgColorPink,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius:
//                                 BorderRadius.circular(screenWidth * 0.025)),
//                             padding: EdgeInsets.symmetric(
//                                 vertical: screenHeight * 0.018)),
//                         child: Text("Save Name",
//                             style: TextStyle(
//                                 fontSize: screenWidth * 0.04,
//                                 color: Colors.white)))),
//                 SizedBox(height: screenHeight * 0.012),
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       _logout();
//                     },
//                     style: OutlinedButton.styleFrom(
//                         foregroundColor: Colors.red,
//                         side: const BorderSide(color: Colors.red),
//                         shape: RoundedRectangleBorder(
//                             borderRadius:
//                             BorderRadius.circular(screenWidth * 0.025)),
//                         padding:
//                         EdgeInsets.symmetric(vertical: screenHeight * 0.018)),
//                     child: Text(
//                       "Logout",
//                       style: TextStyle(fontSize: screenWidth * 0.04),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green));
//   }
//
//   Widget _buildServiceCard(Map<String, dynamic> service, BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Widget destinationPage;
//         if (service["name"] == "Dry Clean")
//           destinationPage = const DryCleanPriceListPage();
//         else if (service["name"] == "Wash & Fold")
//           destinationPage = const WashAndFoldPage();
//         else if (service["name"] == "Wash & Iron")
//           destinationPage = const WashAndIronPage();
//         else if (service["name"] == "Steam Press Iron")
//           destinationPage = const IroningPriceListPage();
//         else if (service["name"] == "Saree Pre-Pleat")
//           destinationPage = const PrePlatedPage();
//         else
//           destinationPage = const WashAndStarchPage();
//         Navigator.of(context)
//             .push(PageTransition(
//             type: PageTransitionType.rightToLeft, child: destinationPage))
//             .then((_) {
//           _updateCartItemCount();
//           _checkPremiumBookedStatus();
//         });
//       },
//       borderRadius: BorderRadius.circular(15),
//       child: Container(
//         decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   spreadRadius: 2)
//             ]),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//                 height: 100,
//                 width: double.infinity,
//                 child: ClipRRect(
//                     borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(15)),
//                     child: Image.asset(service["image"], fit: BoxFit.contain))),
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(service["name"],
//                       style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87)),
//                   const SizedBox(height: 5),
//                   Text(service["price"],
//                       style: const TextStyle(
//                           fontSize: 13,
//                           color: bgColorPink,
//                           fontWeight: FontWeight.w600)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPremiumCard(Map<String, dynamic> service, BuildContext context) {
//     return InkWell(
//       onTap: () {},
//       borderRadius: BorderRadius.circular(15),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//               child: Stack(
//                 children: [
//                   Image.asset(
//                     service["image"],
//                     height: 120,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                   Positioned(
//                     top: 10,
//                     right: 10,
//                     child: Container(
//                       padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.amber.shade700,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Text(
//                         "PREMIUM",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(15),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         service["name"],
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       Text(
//                         service["price"],
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: bgColorPink,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     service["description"],
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isPremiumBooked
//                           ? null
//                           : () async {
//                         try {
//                           final savedCart =
//                               await CartPersistence.loadCart() ?? {};
//
//                           final dryCleanItems = (savedCart['dryCleanItems']
//                           as Map<String, dynamic>? ??
//                               {}).map((key, value) => MapEntry(
//                               key,
//                               value is int
//                                   ? value
//                                   : int.tryParse(value.toString()) ?? 0));
//                           final ironingItems = (savedCart['ironingItems']
//                           as Map<String, dynamic>? ??
//                               {}).map((key, value) => MapEntry(
//                               key,
//                               value is int
//                                   ? value
//                                   : int.tryParse(value.toString()) ?? 0));
//                           final washAndFoldItems = (savedCart[
//                           'washAndFoldItems'] as Map<String, dynamic>? ??
//                               {}).map((key, value) => MapEntry(
//                               key,
//                               value is int
//                                   ? value
//                                   : int.tryParse(value.toString()) ?? 0));
//                           final washAndIronItems = (savedCart[
//                           'washAndIronItems'] as Map<String, dynamic>? ??
//                               {}).map((key, value) => MapEntry(
//                               key,
//                               value is int
//                                   ? value
//                                   : int.tryParse(value.toString()) ?? 0));
//                           final washIronStarchItems = (savedCart[
//                           'washIronStarchItems'] as Map<String, dynamic>? ??
//                               {}).map((key, value) => MapEntry(
//                               key,
//                               value is int
//                                   ? value
//                                   : int.tryParse(value.toString()) ?? 0));
//                           final prePlatedItems = (savedCart['prePlatedItems']
//                           as Map<String, dynamic>? ??
//                               {}).map((key, value) =>
//                               MapEntry(key, Map<String, dynamic>.from(value)));
//                           final additionalServices = (savedCart[
//                           'additionalServices'] as Map<String, dynamic>? ??
//                               {}).map((key, value) => MapEntry(
//                               key,
//                               (value as List<dynamic>)
//                                   .cast<Map<String, dynamic>>()));
//                           final dryCleanTotal =
//                               savedCart['dryCleanTotal'] as double? ?? 0.0;
//                           final additionalTotal =
//                               savedCart['additionalTotal'] as double? ?? 0.0;
//
//                           washAndFoldItems['Premium Laundry'] =
//                               (washAndFoldItems['Premium Laundry'] ?? 0) + 1;
//
//                           await CartPersistence.saveCart(
//                             dryCleanItems: dryCleanItems,
//                             ironingItems: ironingItems,
//                             washAndFoldItems: washAndFoldItems,
//                             washAndIronItems: washAndIronItems,
//                             washIronStarchItems: washIronStarchItems,
//                             prePlatedItems: prePlatedItems,
//                             additionalServices: additionalServices,
//                             dryCleanTotal: dryCleanTotal,
//                             additionalTotal: additionalTotal,
//                           );
//
//                           setState(() {
//                             _isPremiumBooked = true;
//                           });
//
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text("Premium Laundry added to cart"),
//                               backgroundColor: Colors.green,
//                               duration: Duration(seconds: 2),
//                             ),
//                           );
//
//                           Navigator.push(
//                             context,
//                             PageTransition(
//                               type: PageTransitionType.rightToLeft,
//                               child: CartPage(
//                                 dryCleanItems: dryCleanItems,
//                                 ironingItems: ironingItems,
//                                 washAndFoldItems: washAndFoldItems,
//                                 washAndIronItems: washAndIronItems,
//                                 washIronStarchItems: washIronStarchItems,
//                                 prePlatedItems: prePlatedItems,
//                                 additionalServices: additionalServices,
//                                 dryCleanTotal: dryCleanTotal,
//                                 additionalTotal: additionalTotal,
//                               ),
//                             ),
//                           ).then((_) {
//                             _checkPremiumBookedStatus();
//                             _updateCartItemCount();
//                           });
//                         } catch (e) {
//                           _showSnackBar(
//                               "Error adding to cart: ${e.toString()}",
//                               isError: true);
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                         _isPremiumBooked ? Colors.grey : bgColorPink,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       child: Text(
//                         _isPremiumBooked ? "Already in Cart" : "Book Now",
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDrawerMenu() {
//     String fullAddressString = "No address selected";
//     if (_currentAddress != null) {
//       final door = _currentAddress!['doorNumber'] ?? '';
//       final street = _currentAddress!['street'] ?? '';
//       final label = _currentAddress!['label'] ?? 'Address';
//       fullAddressString = "$label: $door, $street";
//     }
//
//     return Drawer(
//       child: Column(
//         children: [
//           Container(
//             color: bgColorPink,
//             width: double.infinity,
//             padding: const EdgeInsets.only(top: 40, bottom: 24),
//             child: Column(
//               children: [
//                 const CircleAvatar(
//                     radius: 40,
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.person, size: 40, color: bgColorPink)),
//                 const SizedBox(height: 12),
//                 Text(_userName,
//                     style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white)),
//                 const SizedBox(height: 8),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     fullAddressString,
//                     style: const TextStyle(fontSize: 14, color: Colors.white70),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Divider(color: Colors.grey, thickness: 1, indent: 16, endIndent: 16),
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 ListTile(
//                     leading: const Icon(Icons.receipt_long, color: bgColorPink),
//                     title: const Text("Orders",
//                         style: TextStyle(fontSize: 16, color: Colors.black87)),
//                     trailing:
//                     const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                     onTap: () => Navigator.push(context,
//                         MaterialPageRoute(builder: (context) => const UserOrdersPage()))),
//                 ListTile(
//                     leading:
//                     const Icon(Icons.local_laundry_service, color: bgColorPink),
//                     title: const Text("Active Subscriptions",
//                         style: TextStyle(fontSize: 16, color: Colors.black87)),
//                     trailing:
//                     const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                     onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const SubscriptionDetailsPage()))),
//                 ListTile(
//                     leading: const Icon(Icons.phone, color: bgColorPink),
//                     title: const Text("Contact",
//                         style: TextStyle(fontSize: 16, color: Colors.black87)),
//                     trailing:
//                     const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                     onTap: () => Navigator.push(context,
//                         MaterialPageRoute(builder: (context) => const ContactPage()))),
//                 ListTile(
//                     leading: const Icon(Icons.settings, color: bgColorPink),
//                     title: const Text("Settings",
//                         style: TextStyle(fontSize: 16, color: Colors.black87)),
//                     trailing:
//                     const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                     onTap: () => Navigator.push(context,
//                         MaterialPageRoute(builder: (context) => const SettingsPage()))),
//                 ListTile(
//                     leading: const Icon(Icons.feedback, color: bgColorPink),
//                     title: const Text("Feedback",
//                         style: TextStyle(fontSize: 16, color: Colors.black87)),
//                     trailing:
//                     const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                     onTap: () => Navigator.push(context,
//                         MaterialPageRoute(builder: (context) => const FeedbackPage()))),
//               ],
//             ),
//           ),
//           const Divider(thickness: 1),
//           Padding(
//             padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10),
//             child: ListTile(
//                 leading: const Icon(Icons.logout, color: bgColorPink),
//                 title: const Text("Logout",
//                     style: TextStyle(fontSize: 16, color: Colors.black87)),
//                 onTap: () async {
//                   await FirebaseAuth.instance.signOut();
//                   Navigator.of(context).popUntil((route) => route.isFirst);
//                 }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _checkForUpdate() async {
//     setState(() => _isCheckingUpdate = true);
//     try {
//       // Fetch current app version
//       PackageInfo packageInfo = await PackageInfo.fromPlatform();
//       _currentVersion = packageInfo.version;
//       print("Current app version: $_currentVersion");
//
//       // Check for update using official Play Store API
//       AppUpdateInfo appUpdateInfo = await InAppUpdate.checkForUpdate();
//       print("Update availability: ${appUpdateInfo.updateAvailability}");
//
//       if (appUpdateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
//         setState(() => _isUpdateAvailable = true);
//         print("Update available. Update type: ${appUpdateInfo.updatePriority}");
//
//         // Trigger the official Google Play update dialog
//         if (appUpdateInfo.immediateUpdateAllowed) {
//           print("Starting immediate update...");
//           await InAppUpdate.performImmediateUpdate();
//         } else if (appUpdateInfo.flexibleUpdateAllowed) {
//           print("Starting flexible update...");
//           await InAppUpdate.startFlexibleUpdate();
//         }
//       } else {
//         print("No update available.");
//       }
//     } catch (e) {
//       print("Error checking for update via API: $e");
//       _showSnackBar("Failed to check for updates. Ensure the app is installed from Play Store.", isError: true);
//     } finally {
//       setState(() => _isCheckingUpdate = false);
//     }
//   }
//
//   bool _isVersionNewer(String latest, String current) {
//     List<int> parseVersion(String v) {
//       return v.split('.').map(int.parse).toList();
//     }
//     List<int> currentParts = parseVersion(current);
//     List<int> latestParts = parseVersion(latest);
//     int maxLength = currentParts.length > latestParts.length ? currentParts.length : latestParts.length;
//     currentParts.addAll(List.filled(maxLength - currentParts.length, 0));
//     latestParts.addAll(List.filled(maxLength - latestParts.length, 0));
//     for (int i = 0; i < maxLength; i++) {
//       if (latestParts[i] > currentParts[i]) return true;
//       if (latestParts[i] < currentParts[i]) return false;
//     }
//     return false;
//   }
//
//   void _showUpdateDialog(String latestVersion) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Update Available"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text("A new version of the app is available."),
//               const SizedBox(height: 10),
//               Text("Current Version: $_currentVersion"),
//               Text("Latest Version: $latestVersion"),
//               const SizedBox(height: 10),
//               const Text("Please update to enjoy the latest features and improvements."),
//             ],
//           ),
//           actions: [
//             TextButton(
//               child: const Text("Update Now"),
//               onPressed: () {
//                 _launchPlayStore();
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text("Later"),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _launchPlayStore() async {
//     const String packageName = "com.laundry.steam";
//     final Uri uri = Uri.parse("market://details?id=$packageName");
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       final Uri webUri = Uri.parse("https://play.google.com/store/apps/details?id=$packageName");
//       if (await canLaunchUrl(webUri)) {
//         await launchUrl(webUri);
//       } else {
//         _showSnackBar("Could not open Play Store.", isError: true);
//       }
//     }
//   }
//
//   Widget _buildBody() {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Container(
//             color: bgColorPink,
//             padding: const EdgeInsets.only(top: 30, left: 25, bottom: 40, right: 25),
//             width: double.infinity,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text("Book pickups and\nservices with ease",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         height: 1.2)),
//                 SizedBox(height: 15),
//                 Text("We'll pick up, clean, and deliver your clothes",
//                     style: TextStyle(color: Colors.white70, fontSize: 16)),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Standard Services",
//                     style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey.shade800)),
//                 const SizedBox(height: 10),
//                 GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         childAspectRatio: 0.85,
//                         crossAxisSpacing: 15,
//                         mainAxisSpacing: 15),
//                     itemCount: standardServices.length,
//                     itemBuilder: (context, index) =>
//                         _buildServiceCard(standardServices[index], context)),
//                 const SizedBox(height: 30),
//                 Text("Premium Services",
//                     style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey.shade800)),
//                 const SizedBox(height: 10),
//                 ...premiumServices
//                     .map((service) => _buildPremiumCard(service, context)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         SystemNavigator.pop();
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: bgColorPink,
//           elevation: 0,
//           title: const Text(''),
//           iconTheme: const IconThemeData(color: Colors.white),
//           actions: [
//             InkWell(
//               onTap: _showAddressSelectionSheet,
//               borderRadius: BorderRadius.circular(20),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.location_on, color: Colors.white, size: 18),
//                     const SizedBox(width: 8),
//                     Flexible(
//                       child: Text(
//                         _currentAddress != null
//                             ? (_currentAddress!['label'] as String? ??
//                             'Select Address')
//                             : 'Select Address',
//                         style: const TextStyle(color: Colors.white, fontSize: 14),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(width: 4),
//             Stack(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.shopping_cart, color: Colors.white),
//                   onPressed: () async {
//                     try {
//                       final savedCart = await CartPersistence.loadCart() ?? {};
//                       final dryCleanItems = (savedCart['dryCleanItems']
//                       as Map<String, dynamic>? ??
//                           {}).map((key, value) => MapEntry(
//                           key,
//                           value is int
//                               ? value
//                               : int.tryParse(value.toString()) ?? 0));
//                       final ironingItems = (savedCart['ironingItems']
//                       as Map<String, dynamic>? ??
//                           {}).map((key, value) => MapEntry(
//                           key,
//                           value is int
//                               ? value
//                               : int.tryParse(value.toString()) ?? 0));
//                       final washAndFoldItems = (savedCart['washAndFoldItems']
//                       as Map<String, dynamic>? ??
//                           {}).map((key, value) => MapEntry(
//                           key,
//                           value is int
//                               ? value
//                               : int.tryParse(value.toString()) ?? 0));
//                       final washAndIronItems = (savedCart['washAndIronItems']
//                       as Map<String, dynamic>? ??
//                           {}).map((key, value) => MapEntry(
//                           key,
//                           value is int
//                               ? value
//                               : int.tryParse(value.toString()) ?? 0));
//                       final washIronStarchItems = (savedCart['washIronStarchItems']
//                       as Map<String, dynamic>? ??
//                           {}).map((key, value) => MapEntry(
//                           key,
//                           value is int
//                               ? value
//                               : int.tryParse(value.toString()) ?? 0));
//                       final prePlatedItems = (savedCart['prePlatedItems']
//                       as Map<String, dynamic>? ??
//                           {})
//                           .map((key, value) =>
//                           MapEntry(key, Map<String, dynamic>.from(value)));
//                       final additionalServices = (savedCart['additionalServices']
//                       as Map<String, dynamic>? ??
//                           {}).map((key, value) => MapEntry(
//                           key, (value as List<dynamic>).cast<Map<String, dynamic>>()));
//                       final dryCleanTotal =
//                           savedCart['dryCleanTotal'] as double? ?? 0.0;
//                       final additionalTotal =
//                           savedCart['additionalTotal'] as double? ?? 0.0;
//                       Navigator.push(
//                           context,
//                           PageTransition(
//                               type: PageTransitionType.rightToLeft,
//                               child: CartPage(
//                                 dryCleanItems: dryCleanItems,
//                                 ironingItems: ironingItems,
//                                 washAndFoldItems: washAndFoldItems,
//                                 washAndIronItems: washAndIronItems,
//                                 washIronStarchItems: washIronStarchItems,
//                                 prePlatedItems: prePlatedItems,
//                                 additionalServices: additionalServices,
//                                 dryCleanTotal: dryCleanTotal,
//                                 additionalTotal: additionalTotal,
//                               ))).then((_) {
//                         _checkPremiumBookedStatus();
//                         _updateCartItemCount();
//                       });
//                     } catch (e) {
//                       _showSnackBar("Error loading cart: ${e.toString()}",
//                           isError: true);
//                     }
//                   },
//                 ),
//                 if (_cartItemCount > 0)
//                   Positioned(
//                     right: 8,
//                     top: 8,
//                     child: Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: const BoxDecoration(
//                           color: Colors.red, shape: BoxShape.circle),
//                       constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
//                       child: Text(_cartItemCount.toString(),
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold),
//                           textAlign: TextAlign.center),
//                     ),
//                   ),
//               ],
//             ),
//             IconButton(
//                 icon: const Icon(Icons.account_circle, color: Colors.white),
//                 onPressed: _showProfileSheet),
//           ],
//         ),
//         drawer: _buildDrawerMenu(),
//         body: _buildBody(),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../constant/constant.dart';
// import '../constant/cart_persistence.dart';
// import '../constant/constant.dart' as constants;
// import '../price list/DryCleanPriceList.dart';
// import '../price list/starch.dart';
// import '../price list/wash_iron.dart' show WashAndIronPage;
// import '../price list/iron.dart';
// import '../price list/pre_plate.dart';
// import '../price list/wash_fold.dart';
// import 'package:flutter/services.dart';
// import '../constant/address_persistence.dart';
// import '../sub screen/contact.dart';
// import '../sub screen/feedback.dart';
// import '../sub screen/settings.dart';
// import '../sub screen/subscription.dart';
// import 'AddressPage.dart';
// import '../sub screen/ordersPage.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:in_app_update/in_app_update.dart';
// import 'MainPage.dart';
// import 'cart.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//   static bool hasShownInitialAddressPrompt = false;
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   String _userName = "Guest";
//   String? _userPhoneNumber;
//   final TextEditingController _nameController = TextEditingController();
//   Map<String, dynamic>? _currentAddress;
//   bool _isPremiumBooked = false;
//   String? _currentVersion;
//   bool _isCheckingUpdate = false;
//   bool _isUpdateAvailable = false;
//   int _cartItemCount = 0;
//   bool _isAddressSheetBeingShown = false;
//   bool _isInitialAddressCheckDone = false;
//   bool _isAddressLoading = false;
//
//   final List<Map<String, dynamic>> standardServices = const [
//     {
//       "name": "Wash & Fold",
//       "color": Colors.white,
//       "image": "assets/images/wash-fold.png",
//       "price": "View Prices"
//     },
//     {
//       "name": "Wash & Iron",
//       "color": Colors.white,
//       "image": "assets/images/wash-iron.png",
//       "price": "View Prices"
//     },
//     {
//       "name": "Dry Clean",
//       "color": Colors.white,
//       "image": "assets/images/dry-cleaning.png",
//       "price": "View Prices"
//     },
//     {
//       "name": "Steam Press Iron",
//       "color": Colors.white,
//       "image": "assets/images/ironing.png",
//       "price": "View Prices"
//     },
//     {
//       "name": "Saree Pre-Pleat",
//       "color": Colors.white,
//       "image": "assets/images/saree.png",
//       "price": "View Prices"
//     },
//     {
//       "name": "Wash & Starch",
//       "color": Colors.white,
//       "image": "assets/images/starch.png",
//       "price": "View Prices"
//     },
//   ];
//
//   final List<Map<String, dynamic>> premiumServices = const [
//     {
//       "name": "Premium Laundry",
//       "color": Colors.white,
//       "image": "assets/images/premium.png",
//       "price": "₹159/KG",
//       "description": "Wash, Iron, Fragrance, Fold, Special Packing"
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _initializePage();
//
//   }
//
//   Future<void> _initializePage() async {
//     await _fetchUserName();
//     await _loadCurrentAddress();
//     if (mounted) {
//       await Future.wait([
//         _checkPremiumBookedStatus(),
//         _checkForUpdate(),
//         _updateCartItemCount(),
//       ]);
//     }
//
//     if (_currentAddress == null && !HomePage.hasShownInitialAddressPrompt && mounted) {
//       HomePage.hasShownInitialAddressPrompt = true;
//       _showAddressSelectionSheet();
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }
//
//
//   Future<void> _fetchUserName() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null && user.phoneNumber != null) {
//       _userPhoneNumber = user.phoneNumber;
//       try {
//         final userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(_userPhoneNumber)
//             .get();
//
//         if (userDoc.exists && userDoc.data() != null) {
//           setState(() {
//             _userName = userDoc.data()!['name'] as String? ?? "User";
//           });
//           _nameController.text = _userName;
//         } else {
//           setState(() {
//             _userName = "New User";
//           });
//           _nameController.text = "";
//         }
//       } catch (e) {
//         _showSnackBar("Failed to load user name: ${e.toString()}", isError: true);
//         setState(() {
//           _userName = "Error User";
//         });
//       }
//     } else {
//       setState(() {
//         _userName = "Guest";
//       });
//     }
//   }
//
//   Future<void> _loadCurrentAddress() async {
//     try {
//       final savedAddress = await AddressPersistence.loadCurrentAddress();
//       if (mounted) {
//         setState(() {
//           _currentAddress = savedAddress;
//         });
//       }
//     } catch (e) {
//       _showSnackBar("Failed to load address: ${e.toString()}", isError: true);
//       if (mounted) {
//         setState(() {
//           _currentAddress = null;
//         });
//       }
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
//     if (confirm == true && mounted) {
//       await AddressPersistence.deleteAddress(addressToDelete);
//       setState(() {
//         _currentAddress = null;
//       });
//       Navigator.pop(context);
//       await _loadCurrentAddress();
//     }
//   }
//
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
//                           leading: const Icon(Icons.location_on_outlined, color: bgColorPink),
//                           title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//                           subtitle: Text("$door, $street"),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               if (isSelected)
//                                 const Icon(Icons.check_circle, color: bgColorPink),
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
//                     final result =await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressPage()));
//                     if (result !=null && result is Map<String, dynamic> && mounted){
//                       await AddressPersistence.saveCurrentAddress(result);
//                       await _loadCurrentAddress();
//                       Navigator.pop(context);
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(backgroundColor: bgColorPink, padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025))),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _checkPremiumBookedStatus() async {
//     try {
//       final savedCart = await CartPersistence.loadCart() ?? {};
//       final washAndFoldItems = (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {});
//       setState(() {
//         _isPremiumBooked = washAndFoldItems.containsKey('Premium Laundry') &&
//             (washAndFoldItems['Premium Laundry'] as int? ?? 0) > 0;
//       });
//     } catch (e) {
//       _showSnackBar("Error checking cart status: ${e.toString()}", isError: true);
//     }
//   }
//
//   Future<void> _updateCartItemCount() async {
//     try {
//       final savedCart = await CartPersistence.loadCart() ?? {};
//       int count = 0;
//       count += (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).values.fold(
//           0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).values.fold(
//           0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).values.fold(
//           0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).values.fold(
//           0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).values.fold(
//           0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
//       count += (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {})
//           .values
//           .fold(0, (sum, value) => sum + (value['quantity'] as int? ?? 0));
//       count += (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).values.fold(
//           0,
//               (sum, value) => sum +
//               (value as List).fold(0, (subSum, item) => subSum + (item['quantity'] as int? ?? 0)));
//       setState(() {
//         _cartItemCount = count;
//       });
//     } catch (e) {
//       _showSnackBar("Error loading cart item count: ${e.toString()}", isError: true);
//       setState(() {
//         _cartItemCount = 0;
//       });
//     }
//   }
//
//   Future<void> _updateUserName() async {
//     if (_userPhoneNumber == null || _nameController.text.trim().isEmpty) {
//       _showSnackBar("Please enter a valid name.", isError: true);
//       return;
//     }
//
//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(_userPhoneNumber)
//           .set({'name': _nameController.text.trim()}, SetOptions(merge: true));
//
//       setState(() {
//         _userName = _nameController.text.trim();
//       });
//       _showSnackBar("Name updated successfully!", isError: false);
//       Navigator.pop(context);
//     } catch (e) {
//       _showSnackBar("Failed to update name: ${e.toString()}", isError: true);
//     }
//   }
//
//   Future<void> _logout() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       HomePage.hasShownInitialAddressPrompt = false;
//       await AddressPersistence.clearCurrentAddress();
//       await AddressPersistence.clearAllAddresses();
//       await CartPersistence.clearCart();
//
//       _showSnackBar("Logged out successfully!", isError: false);
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const MainPage()),
//       );
//     } catch (e) {
//       _showSnackBar("Error during logout: ${e.toString()}", isError: true);
//     }
//   }
//
//
//
//   void _showProfileSheet() {
//     final bool isWeb = MediaQuery.of(context).size.width >= 1000;
//
//     if (isWeb) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return Dialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(
//                 maxWidth: 400, // Fixed max width for web
//                 maxHeight: 500, // Fixed max height to prevent overflow
//               ),
//               child: SingleChildScrollView(
//                 child: Container(
//                   padding: const EdgeInsets.all(20), // Fixed padding for consistency
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       CircleAvatar(
//                         radius: 40, // Fixed radius for web
//                         backgroundColor: bgColorPink,
//                         child: Icon(Icons.person, size: 40, color: Colors.white),
//                       ),
//                       SizedBox(height: 12),
//                       Text(
//                         _userName,
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       Text(
//                         _userPhoneNumber ?? "Phone: N/A",
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       TextField(
//                         controller: _nameController,
//                         decoration: InputDecoration(
//                           labelText: "Change Name",
//                           labelStyle: TextStyle(color: Colors.grey[700]),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide(color: Colors.grey.shade400),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: const BorderSide(color: bgColorPink, width: 2),
//                           ),
//                         ),
//                         style: const TextStyle(color: Colors.black87),
//                       ),
//                       SizedBox(height: 16),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _updateUserName,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: bgColorPink,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                           ),
//                           child: const Text(
//                             "Save Name",
//                             style: TextStyle(fontSize: 16, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 12),
//                       SizedBox(
//                         width: double.infinity,
//                         child: OutlinedButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                             _logout();
//                           },
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: Colors.red,
//                             side: const BorderSide(color: Colors.red),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                           ),
//                           child: const Text(
//                             "Logout",
//                             style: TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     } else {
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         builder: (BuildContext context) {
//           final screenWidth = MediaQuery.of(context).size.width;
//           final screenHeight = MediaQuery.of(context).size.height;
//           return SingleChildScrollView(
//             child: Container(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom +
//                     MediaQuery.of(context).viewPadding.bottom +
//                     screenHeight * 0.025,
//                 top: screenHeight * 0.025,
//                 left: screenWidth * 0.05,
//                 right: screenWidth * 0.05,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircleAvatar(
//                     radius: screenWidth * 0.1,
//                     backgroundColor: bgColorPink,
//                     child: Icon(Icons.person, size: screenWidth * 0.1, color: Colors.white),
//                   ),
//                   SizedBox(height: screenHeight * 0.012),
//                   Text(
//                     _userName,
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.055,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   Text(
//                     _userPhoneNumber ?? "Phone: N/A",
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.035,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   SizedBox(height: screenHeight * 0.025),
//                   TextField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       labelText: "Change Name",
//                       labelStyle: TextStyle(color: Colors.grey[700]),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(screenWidth * 0.025),
//                         borderSide: BorderSide(color: Colors.grey.shade400),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(screenWidth * 0.025),
//                         borderSide: const BorderSide(color: bgColorPink, width: 2),
//                       ),
//                     ),
//                     style: const TextStyle(color: Colors.black87),
//                   ),
//                   SizedBox(height: screenHeight * 0.018),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _updateUserName,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: bgColorPink,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(screenWidth * 0.025),
//                         ),
//                         padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
//                       ),
//                       child: Text(
//                         "Save Name",
//                         style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: screenHeight * 0.012),
//                   SizedBox(
//                     width: double.infinity,
//                     child: OutlinedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         _logout();
//                       },
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Colors.red,
//                         side: const BorderSide(color: Colors.red),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(screenWidth * 0.025),
//                         ),
//                         padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
//                       ),
//                       child: Text(
//                         "Logout",
//                         style: TextStyle(fontSize: screenWidth * 0.04),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
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
//
//   Widget _buildServiceCard(Map<String, dynamic> service, BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Widget destinationPage;
//         if (service["name"] == "Dry Clean") {
//           destinationPage = DryCleanPriceListPage();
//         } else if (service["name"] == "Wash & Fold") {
//           destinationPage = WashAndFoldPage();
//         } else if (service["name"] == "Wash & Iron") {
//           destinationPage = WashAndIronPage();
//         } else if (service["name"] == "Steam Press Iron") {
//           destinationPage = IroningPriceListPage();
//         } else if (service["name"] == "Saree Pre-Pleat") {
//           destinationPage = PrePlatedPage();
//         } else {
//           destinationPage = WashAndStarchPage();
//         }
//         Navigator.of(context)
//             .push(
//           PageTransition(
//             type: PageTransitionType.rightToLeft,
//             child: destinationPage,
//           ),
//         )
//             .then((_) {
//           _updateCartItemCount();
//           _checkPremiumBookedStatus();
//         });
//       },
//       borderRadius: BorderRadius.circular(15),
//       child: Container(
//         height: 180, // Fixed height to eliminate extra space
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               height: 100,
//               width: double.infinity,
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//                 child: Image.asset(
//                   service["image"],
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10), // Consistent padding
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     service["name"],
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     service["price"],
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: bgColorPink,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPremiumCard(Map<String, dynamic> service, BuildContext context) {
//     return InkWell(
//       onTap: () {},
//       borderRadius: BorderRadius.circular(15),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//               child: Stack(
//                 children: [
//                   Image.asset(
//                     service["image"],
//                     height: 120,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                   Positioned(
//                     top: 10,
//                     right: 10,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.amber.shade700,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Text(
//                         "PREMIUM",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(15),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         service["name"],
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       Text(
//                         service["price"],
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: bgColorPink,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     service["description"],
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isPremiumBooked
//                           ? null
//                           : () async {
//                         try {
//                           final savedCart = await CartPersistence.loadCart() ?? {};
//                           final dryCleanItems = (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {})
//                               .map((key, value) => MapEntry(
//                               key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                           final ironingItems = (savedCart['ironingItems'] as Map<String, dynamic>? ?? {})
//                               .map((key, value) => MapEntry(
//                               key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                           final washAndFoldItems = (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {})
//                               .map((key, value) => MapEntry(
//                               key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                           final washAndIronItems = (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {})
//                               .map((key, value) => MapEntry(
//                               key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                           final washIronStarchItems = (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {})
//                               .map((key, value) => MapEntry(
//                               key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                           final prePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {})
//                               .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
//                           final additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {})
//                               .map((key, value) => MapEntry(key, (value as List<dynamic>).cast<Map<String, dynamic>>()));
//                           final dryCleanTotal = savedCart['dryCleanTotal'] as double? ?? 0.0;
//                           final additionalTotal = savedCart['additionalTotal'] as double? ?? 0.0;
//
//                           washAndFoldItems['Premium Laundry'] = (washAndFoldItems['Premium Laundry'] ?? 0) + 1;
//
//                           await CartPersistence.saveCart(
//                             dryCleanItems: dryCleanItems,
//                             ironingItems: ironingItems,
//                             washAndFoldItems: washAndFoldItems,
//                             washAndIronItems: washAndIronItems,
//                             washIronStarchItems: washIronStarchItems,
//                             prePlatedItems: prePlatedItems,
//                             additionalServices: additionalServices,
//                             dryCleanTotal: dryCleanTotal,
//                             additionalTotal: additionalTotal,
//                           );
//
//                           setState(() {
//                             _isPremiumBooked = true;
//                           });
//
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text("Premium Laundry added to cart"),
//                               backgroundColor: Colors.green,
//                               duration: Duration(seconds: 2),
//                             ),
//                           );
//
//                           Navigator.push(
//                             context,
//                             PageTransition(
//                               type: PageTransitionType.rightToLeft,
//                               child: CartPage(
//                                 dryCleanItems: dryCleanItems,
//                                 ironingItems: ironingItems,
//                                 washAndFoldItems: washAndFoldItems,
//                                 washAndIronItems: washAndIronItems,
//                                 washIronStarchItems: washIronStarchItems,
//                                 prePlatedItems: prePlatedItems,
//                                 additionalServices: additionalServices,
//                                 dryCleanTotal: dryCleanTotal,
//                                 additionalTotal: additionalTotal,
//                               ),
//                             ),
//                           ).then((_) {
//                             _checkPremiumBookedStatus();
//                             _updateCartItemCount();
//                           });
//                         } catch (e) {
//                           _showSnackBar("Error adding to cart: ${e.toString()}", isError: true);
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _isPremiumBooked ? Colors.grey : bgColorPink,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       child: Text(
//                         _isPremiumBooked ? "Already in Cart" : "Book Now",
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDrawerMenu() {
//     String fullAddressString = "No address selected";
//     if (_currentAddress != null) {
//       final door = _currentAddress!['doorNumber'] ?? '';
//       final street = _currentAddress!['street'] ?? '';
//       final label = _currentAddress!['label'] ?? 'Address';
//       fullAddressString = "$label: $door, $street";
//     }
//
//     return Drawer(
//       child: Column(
//         children: [
//           Container(
//             color: bgColorPink,
//             width: double.infinity,
//             padding: const EdgeInsets.only(top: 40, bottom: 24),
//             child: Column(
//               children: [
//                 const CircleAvatar(
//                   radius: 40,
//                   backgroundColor: Colors.white,
//                   child: Icon(Icons.person, size: 40, color: bgColorPink),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   _userName,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     fullAddressString,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.white70,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Divider(
//             color: Colors.grey,
//             thickness: 1,
//             indent: 16,
//             endIndent: 16,
//           ),
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.receipt_long, color: bgColorPink),
//                   title: const Text("Orders", style: TextStyle(fontSize: 16, color: Colors.black87)),
//                   trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                   onTap: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => const UserOrdersPage()));
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.local_laundry_service, color: bgColorPink),
//                   title: const Text("Active Subscriptions", style: TextStyle(fontSize: 16, color: Colors.black87)),
//                   trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                   onTap: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionDetailsPage()));
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.phone, color: bgColorPink),
//                   title: const Text("Contact", style: TextStyle(fontSize: 16, color: Colors.black87)),
//                   trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                   onTap: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactPage()));
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.settings, color: bgColorPink),
//                   title: const Text("Settings", style: TextStyle(fontSize: 16, color: Colors.black87)),
//                   trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                   onTap: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.feedback, color: bgColorPink),
//                   title: const Text("Feedback", style: TextStyle(fontSize: 16, color: Colors.black87)),
//                   trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                   onTap: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackPage()));
//                   },
//                 ),
//               ],
//             ),
//           ),
//           const Divider(thickness: 1),
//           Padding(
//             padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10),
//             child: ListTile(
//               leading: const Icon(Icons.logout, color: bgColorPink),
//               title: const Text("Logout", style: TextStyle(fontSize: 16, color: Colors.black87)),
//               onTap: () async {
//                 await FirebaseAuth.instance.signOut();
//                 HomePage.hasShownInitialAddressPrompt = false;
//                 Navigator.of(context).popUntil((route) => route.isFirst);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _checkForUpdate() async {
//     setState(() => _isCheckingUpdate = true);
//     try {
//       PackageInfo packageInfo = await PackageInfo.fromPlatform();
//       _currentVersion = packageInfo.version;
//       print("Current app version: $_currentVersion");
//
//       AppUpdateInfo appUpdateInfo = await InAppUpdate.checkForUpdate();
//       print("Update availability: ${appUpdateInfo.updateAvailability}");
//
//       if (appUpdateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
//         setState(() => _isUpdateAvailable = true);
//         print("Update available. Update type: ${appUpdateInfo.updatePriority}");
//
//         if (appUpdateInfo.immediateUpdateAllowed) {
//           print("Starting immediate update...");
//           await InAppUpdate.performImmediateUpdate();
//         } else if (appUpdateInfo.flexibleUpdateAllowed) {
//           print("Starting flexible update...");
//           await InAppUpdate.startFlexibleUpdate();
//         }
//       } else {
//         print("No update available.");
//       }
//     } catch (e) {
//       print("Error checking for update via API: $e");
//     } finally {
//       setState(() => _isCheckingUpdate = false);
//     }
//   }
//
//   void _launchPlayStore() async {
//     const String packageName = "com.laundry.steam";
//     final Uri uri = Uri.parse("market://details?id=$packageName");
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       final Uri webUri = Uri.parse("https://play.google.com/store/apps/details?id=$packageName");
//       if (await canLaunchUrl(webUri)) {
//         await launchUrl(webUri);
//       } else {
//         _showSnackBar("Could not open Play Store.", isError: true);
//       }
//     }
//   }
//
//   Widget _buildMobileLayout() {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Container(
//             color: bgColorPink,
//             padding: const EdgeInsets.only(top: 30, left: 25, bottom: 40, right: 25),
//             width: double.infinity,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text(
//                   "Book pickups and\nservices with ease",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     height: 1.2,
//                   ),
//                 ),
//                 SizedBox(height: 15),
//                 Text(
//                   "We'll pick up, clean, and deliver your clothes",
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Standard Services",
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade800,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 LayoutBuilder(
//                   builder: (context, constraints) {
//                     final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
//                     final itemWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 15)) / crossAxisCount; // 15 is crossAxisSpacing
//                     final aspectRatio = itemWidth / 180; // 180 is the fixed height from _buildServiceCard
//
//                     return GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: crossAxisCount,
//                         childAspectRatio: aspectRatio,
//                         crossAxisSpacing: 15,
//                         mainAxisSpacing: 15,
//                       ),
//                       itemCount: standardServices.length,
//                       itemBuilder: (context, index) {
//                         return _buildServiceCard(standardServices[index], context);
//                       },
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 30),
//                 Text(
//                   "Premium Services",
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade800,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 ...premiumServices.map((service) => _buildPremiumCard(service, context)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Widget _buildMobileLayout() {
//   //   return SingleChildScrollView(
//   //     child: Column(
//   //       children: [
//   //         Container(
//   //           color: bgColorPink,
//   //           padding: const EdgeInsets.only(top: 30, left: 25, bottom: 40, right: 25),
//   //           width: double.infinity,
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: const [
//   //               Text(
//   //                 "Book pickups and\nservices with ease",
//   //                 style: TextStyle(
//   //                   color: Colors.white,
//   //                   fontSize: 28,
//   //                   fontWeight: FontWeight.bold,
//   //                   height: 1.2,
//   //                 ),
//   //               ),
//   //               SizedBox(height: 15),
//   //               Text(
//   //                 "We'll pick up, clean, and deliver your clothes",
//   //                 style: TextStyle(
//   //                   color: Colors.white70,
//   //                   fontSize: 16,
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //         Padding(
//   //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Text(
//   //                 "Standard Services",
//   //                 style: TextStyle(
//   //                   fontSize: 20,
//   //                   fontWeight: FontWeight.bold,
//   //                   color: Colors.grey.shade800,
//   //                 ),
//   //               ),
//   //               const SizedBox(height: 10),
//   //               GridView.builder(
//   //                 shrinkWrap: true,
//   //                 physics: const NeverScrollableScrollPhysics(),
//   //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//   //                   crossAxisCount: 2,
//   //                   childAspectRatio: 0.85,
//   //                   crossAxisSpacing: 15,
//   //                   mainAxisSpacing: 15,
//   //                 ),
//   //                 itemCount: standardServices.length,
//   //                 itemBuilder: (context, index) {
//   //                   return _buildServiceCard(standardServices[index], context);
//   //                 },
//   //               ),
//   //               const SizedBox(height: 30),
//   //               Text(
//   //                 "Premium Services",
//   //                 style: TextStyle(
//   //                   fontSize: 20,
//   //                   fontWeight: FontWeight.bold,
//   //                   color: Colors.grey.shade800,
//   //                 ),
//   //               ),
//   //               const SizedBox(height: 10),
//   //               ...premiumServices.map((service) => _buildPremiumCard(service, context)),
//   //             ],
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   // Widget _buildWebLayout() {
//   //   return SingleChildScrollView(
//   //     child: Center(
//   //       child: Container(
//   //         constraints: const BoxConstraints(maxWidth: 1200),
//   //         padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
//   //         child: Row(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             Expanded(
//   //               flex: 1,
//   //               child: Padding(
//   //                 padding: const EdgeInsets.only(right: 30),
//   //                 child: Column(
//   //                   crossAxisAlignment: CrossAxisAlignment.start,
//   //                   children: [
//   //                     const Text(
//   //                       "Book pickups and\nservices with ease",
//   //                       style: TextStyle(
//   //                         fontSize: 48,
//   //                         fontWeight: FontWeight.bold,
//   //                         color: bgColorPink,
//   //                         height: 1.2,
//   //                       ),
//   //                     ),
//   //                     const SizedBox(height: 20),
//   //                     Text(
//   //                       "We'll pick up, clean, and deliver your clothes",
//   //                       style: TextStyle(
//   //                         color: Colors.grey.shade600,
//   //                         fontSize: 20,
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //             ),
//   //             Expanded(
//   //               flex: 2,
//   //               child: Column(
//   //                 crossAxisAlignment: CrossAxisAlignment.start,
//   //                 children: [
//   //                   Text(
//   //                     "Standard Services",
//   //                     style: TextStyle(
//   //                       fontSize: 24,
//   //                       fontWeight: FontWeight.bold,
//   //                       color: Colors.grey.shade800,
//   //                     ),
//   //                   ),
//   //                   const SizedBox(height: 20),
//   //                   GridView.builder(
//   //                     shrinkWrap: true,
//   //                     physics: const NeverScrollableScrollPhysics(),
//   //                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//   //                       crossAxisCount: 3,
//   //                       childAspectRatio: 0.8,
//   //                       crossAxisSpacing: 25,
//   //                       mainAxisSpacing: 25,
//   //                     ),
//   //                     itemCount: standardServices.length,
//   //                     itemBuilder: (context, index) {
//   //                       return _buildServiceCard(standardServices[index], context);
//   //                     },
//   //                   ),
//   //                   const SizedBox(height: 40),
//   //                   Text(
//   //                     "Premium Services",
//   //                     style: TextStyle(
//   //                       fontSize: 24,
//   //                       fontWeight: FontWeight.bold,
//   //                       color: Colors.grey.shade800,
//   //                     ),
//   //                   ),
//   //                   const SizedBox(height: 20),
//   //                   ...premiumServices.map((service) => Container(
//   //                     width: 500,
//   //                     child: _buildPremiumCard(service, context),
//   //                   )),
//   //                 ],
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   Widget _buildWebLayout() {
//     return SingleChildScrollView(
//       child: Center(
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 1200),
//           padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 flex: 1,
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 30),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Book pickups and\nservices with ease",
//                         style: TextStyle(
//                           fontSize: 48,
//                           fontWeight: FontWeight.bold,
//                           color: bgColorPink,
//                           height: 1.2,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         "We'll pick up, clean, and deliver your clothes",
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 20,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Expanded(
//                 flex: 2,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Standard Services",
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey.shade800,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3, // Fixed to 3 columns
//                         childAspectRatio: 1.3, // Adjusted for fixed height of 180px
//                         crossAxisSpacing: 25,
//                         mainAxisSpacing: 25,
//                       ),
//                       itemCount: standardServices.length,
//                       itemBuilder: (context, index) {
//                         return _buildServiceCard(standardServices[index], context);
//                       },
//                     ),
//                     const SizedBox(height: 40),
//                     Text(
//                       "Premium Services",
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey.shade800,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ...premiumServices.map((service) => Container(
//                       width: 500,
//                       child: _buildPremiumCard(service, context),
//                     )),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isMobile = MediaQuery.of(context).size.width < 1000;
//
//     return WillPopScope(
//       onWillPop: () async {
//         SystemNavigator.pop();
//         return false;
//       },
//       child: Scaffold(
//         drawer: _buildDrawerMenu(),
//         appBar: AppBar(
//           backgroundColor: bgColorPink,
//           elevation: 0,
//           title: const Text(''),
//           iconTheme: const IconThemeData(color: Colors.white),
//           actions: [
//             InkWell(
//               onTap:_showAddressSelectionSheet,
//               borderRadius: BorderRadius.circular(20),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.location_on, color: Colors.white, size: 18),
//                     const SizedBox(width: 8),
//                     Flexible(
//                       child: Text(
//                         _currentAddress != null
//                             ? (_currentAddress!['label'] as String? ?? 'Select Address')
//                             : 'Select Address',
//                         style: const TextStyle(color: Colors.white, fontSize: 14),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(width: 4),
//             Stack(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.shopping_cart, color: Colors.white),
//                   onPressed: () async {
//                     try {
//                       final savedCart = await CartPersistence.loadCart() ?? {};
//                       final dryCleanItems = (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {})
//                           .map((key, value) => MapEntry(
//                           key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                       final ironingItems = (savedCart['ironingItems'] as Map<String, dynamic>? ?? {})
//                           .map((key, value) => MapEntry(
//                           key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                       final washAndFoldItems = (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {})
//                           .map((key, value) => MapEntry(
//                           key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                       final washAndIronItems = (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {})
//                           .map((key, value) => MapEntry(
//                           key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                       final washIronStarchItems = (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {})
//                           .map((key, value) => MapEntry(
//                           key, value is int ? value : int.tryParse(value.toString()) ?? 0));
//                       final prePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {})
//                           .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
//                       final additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {})
//                           .map((key, value) => MapEntry(key, (value as List<dynamic>).cast<Map<String, dynamic>>()));
//                       final dryCleanTotal = savedCart['dryCleanTotal'] as double? ?? 0.0;
//                       final additionalTotal = savedCart['additionalTotal'] as double? ?? 0.0;
//
//                       Navigator.push(
//                         context,
//                         PageTransition(
//                           type: PageTransitionType.rightToLeft,
//                           child: CartPage(
//                             dryCleanItems: dryCleanItems,
//                             ironingItems: ironingItems,
//                             washAndFoldItems: washAndFoldItems,
//                             washAndIronItems: washAndIronItems,
//                             washIronStarchItems: washIronStarchItems,
//                             prePlatedItems: prePlatedItems,
//                             additionalServices: additionalServices,
//                             dryCleanTotal: dryCleanTotal,
//                             additionalTotal: additionalTotal,
//                           ),
//                         ),
//                       ).then((_) {
//                         _checkPremiumBookedStatus();
//                         _updateCartItemCount();
//                       });
//                     } catch (e) {
//                       _showSnackBar("Error loading cart: ${e.toString()}", isError: true);
//                     }
//                   },
//                 ),
//                 if (_cartItemCount > 0)
//                   Positioned(
//                     right: 8,
//                     top: 8,
//                     child: Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: const BoxDecoration(
//                         color: Colors.red,
//                         shape: BoxShape.circle,
//                       ),
//                       constraints: const BoxConstraints(
//                         minWidth: 16,
//                         minHeight: 16,
//                       ),
//                       child: Text(
//                         _cartItemCount.toString(),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             IconButton(
//               icon: const Icon(Icons.account_circle, color: Colors.white),
//               onPressed: _showProfileSheet,
//             ),
//           ],
//         ),
//         body: isMobile ? _buildMobileLayout() : _buildWebLayout(),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constant/constant.dart';
import '../constant/cart_persistence.dart';
import '../constant/constant.dart' as constants;
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
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:in_app_update/in_app_update.dart';
import 'MainPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'cart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static bool hasShownInitialAddressPrompt = false;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = "Guest";
  String? _userPhoneNumber;
  final TextEditingController _nameController = TextEditingController();
  Map<String, dynamic>? _currentAddress;
  bool _isPremiumBooked = false;
  String? _currentVersion;
  bool _isCheckingUpdate = false;
  bool _isUpdateAvailable = false;
  int _cartItemCount = 0;
  StreamSubscription<User?>? _authSubscription;


  final List<Map<String, dynamic>> standardServices = const [
    {
      "name": "Wash & Fold",
      "color": Colors.white,
      "image": "assets/images/wash-fold.png",
      "price": "View Prices"
    },
    {
      "name": "Wash & Iron",
      "color": Colors.white,
      "image": "assets/images/wash-iron.png",
      "price": "View Prices"
    },
    {
      "name": "Dry Clean",
      "color": Colors.white,
      "image": "assets/images/dry-cleaning.png",
      "price": "View Prices"
    },
    {
      "name": "Steam Press Iron",
      "color": Colors.white,
      "image": "assets/images/ironing.png",
      "price": "View Prices"
    },
    {
      "name": "Saree Pre-Pleat",
      "color": Colors.white,
      "image": "assets/images/saree.png",
      "price": "View Prices"
    },
    {
      "name": "Wash & Starch",
      "color": Colors.white,
      "image": "assets/images/starch.png",
      "price": "View Prices"
    },
  ];

  final List<Map<String, dynamic>> premiumServices = const [
    {
      "name": "Premium Laundry",
      "color": Colors.white,
      "image": "assets/images/premium.png",
      "price": "₹159/KG",
      "description": "Wash, Iron, Fragrance, Fold, Special Packing"
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializePage();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // A user is logged in, so we can get their FCM token
        print("User is logged in, setting up FCM token...");
        _setupAndSaveFCMToken(user);
      } else {
        print("No user logged in.");
      }
    });

  }

  Future<void> _initializePage() async {
    await _fetchUserName();
    await _loadCurrentAddress();
    if (mounted) {
      await Future.wait([
        _checkPremiumBookedStatus(),
        if (!kIsWeb) _checkForUpdate(),
        _updateCartItemCount(),
      ]);
    }

    if (_currentAddress == null && !HomePage.hasShownInitialAddressPrompt && mounted) {
      HomePage.hasShownInitialAddressPrompt = true;
      _showAddressSelectionSheet(onAddressChanged: _loadCurrentAddress);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setupAndSaveFCMToken(User user) async {
    try {
      // For web, we need a VAPID key. For mobile, this is not needed.
      final fcmToken = await FirebaseMessaging.instance.getToken(
        vapidKey: kIsWeb ? "BAEu6_xp-409KcIzsYi7LmiOAMqMDeL20885I1kILS2zN19IxJFoEraUxgbsTGJsPtiHhK3cG3j3HfPfRXhRkCc" : null,
      );

      if (fcmToken != null) {
        print("✅ FCM Token: $fcmToken");

        // Use the user's UID for the document ID - THIS IS THE FIX
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.phoneNumber);

        await userDocRef.set(
          {
            'fcmToken': fcmToken,
            'phoneNumber': user.phoneNumber, // Still save the phone number as a field
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        print("✅ FCM Token saved for user: ${user.uid}");
      } else {
        print("❌ FCM TOKEN IS NULL. Check your VAPID key and Firebase setup.");
      }
    } catch (e) {
      print("❌ ERROR getting FCM token: $e");
    }
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
          setState(() {
            _userName = userDoc.data()!['name'] as String? ?? "User";
          });
          _nameController.text = _userName;
        } else {
          setState(() {
            _userName = "New User";
          });
          _nameController.text = "";
        }
      } catch (e) {
        _showSnackBar("Failed to load user name: ${e.toString()}", isError: true);
        setState(() {
          _userName = "Error User";
        });
      }
    } else {
      setState(() {
        _userName = "Guest";
      });
    }
  }

  Future<void> _loadCurrentAddress() async {
    try {
      final savedAddress = await AddressPersistence.loadCurrentAddress();
      if (mounted) {
        setState(() {
          _currentAddress = savedAddress;
        });
      }
    } catch (e) {
      _showSnackBar("Failed to load address: ${e.toString()}", isError: true);
      if (mounted) {
        setState(() {
          _currentAddress = null;
        });
      }
    }
  }

  Future<void> _handleDeleteAddress(Map<String, dynamic> addressToDelete) async {
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

    if (confirm == true && mounted) {
      await AddressPersistence.deleteAddress(addressToDelete);
      setState(() {
        _currentAddress = null;
      });
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
                          leading: const Icon(Icons.location_on_outlined, color: bgColorPink),
                          title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("$door, $street"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                const Icon(Icons.check_circle, color: bgColorPink),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.grey[400]),
                                onPressed: () => _handleDeleteAddress(address),
                                tooltip: 'Delete Address',
                              ),
                            ],
                          ),
                          onTap: () async {
                            await AddressPersistence.saveCurrentAddress(address);
                            Navigator.pop(context);
                            onAddressChanged();
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
                    Navigator.pop(context); // Close the sheet
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddressPage()),
                    );
                    onAddressChanged(); // <-- Tell HomePage to refresh
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: bgColorPink, padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025))),
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
      count += (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {}).values.fold(
          0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
      count += (savedCart['ironingItems'] as Map<String, dynamic>? ?? {}).values.fold(
          0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
      count += (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {}).values.fold(
          0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
      count += (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {}).values.fold(
          0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
      count += (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {}).values.fold(
          0, (sum, value) => sum + (value is int ? value : int.tryParse(value.toString()) ?? 0));
      count += (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {})
          .values
          .fold(0, (sum, value) => sum + (value['quantity'] as int? ?? 0));
      count += (savedCart['additionalServices'] as Map<String, dynamic>? ?? {}).values.fold(
          0,
              (sum, value) => sum +
              (value as List).fold(0, (subSum, item) => subSum + (item['quantity'] as int? ?? 0)));
      setState(() {
        _cartItemCount = count;
      });
    } catch (e) {
      _showSnackBar("Error loading cart item count: ${e.toString()}", isError: true);
      setState(() {
        _cartItemCount = 0;
      });
    }
  }

  Future<void> _updateUserName() async {
    if (_userPhoneNumber == null || _nameController.text.trim().isEmpty) {
      _showSnackBar("Please enter a valid name.", isError: true);
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userPhoneNumber)
          .set({'name': _nameController.text.trim()}, SetOptions(merge: true));

      setState(() {
        _userName = _nameController.text.trim();
      });
      _showSnackBar("Name updated successfully!", isError: false);
      Navigator.pop(context);
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } catch (e) {
      _showSnackBar("Error during logout: ${e.toString()}", isError: true);
    }
  }



  void _showProfileSheet() {
    final bool isWeb = MediaQuery.of(context).size.width >= 1000;

    if (isWeb) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400, // Fixed max width for web
                maxHeight: 500, // Fixed max height to prevent overflow
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20), // Fixed padding for consistency
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 40, // Fixed radius for web
                        backgroundColor: bgColorPink,
                        child: Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      SizedBox(height: 12),
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _userPhoneNumber ?? "Phone: N/A",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Change Name",
                          labelStyle: TextStyle(color: Colors.grey[700]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: bgColorPink, width: 2),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black87),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateUserName,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bgColorPink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Save Name",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _logout();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Logout",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    MediaQuery.of(context).viewPadding.bottom +
                    screenHeight * 0.025,
                top: screenHeight * 0.025,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.1,
                    backgroundColor: bgColorPink,
                    child: Icon(Icons.person, size: screenWidth * 0.1, color: Colors.white),
                  ),
                  SizedBox(height: screenHeight * 0.012),
                  Text(
                    _userName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _userPhoneNumber ?? "Phone: N/A",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Change Name",
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.025),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.025),
                        borderSide: const BorderSide(color: bgColorPink, width: 2),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black87),
                  ),
                  SizedBox(height: screenHeight * 0.018),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateUserName,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bgColorPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.025),
                        ),
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                      ),
                      child: Text(
                        "Save Name",
                        style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.012),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.025),
                        ),
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                      ),
                      child: Text(
                        "Logout",
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
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


  Widget _buildServiceCard(Map<String, dynamic> service, BuildContext context) {
    return InkWell(
      onTap: () {
        Widget destinationPage;
        if (service["name"] == "Dry Clean") {
          destinationPage = DryCleanPriceListPage();
        } else if (service["name"] == "Wash & Fold") {
          destinationPage = WashAndFoldPage();
        } else if (service["name"] == "Wash & Iron") {
          destinationPage = WashAndIronPage();
        } else if (service["name"] == "Steam Press Iron") {
          destinationPage = IroningPriceListPage();
        } else if (service["name"] == "Saree Pre-Pleat") {
          destinationPage = PrePlatedPage();
        } else {
          destinationPage = WashAndStarchPage();
        }
        Navigator.of(context)
            .push(
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: destinationPage,
          ),
        )
            .then((_) {
          _updateCartItemCount();
          _checkPremiumBookedStatus();
        });
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 180, // Fixed height to eliminate extra space
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  service["image"],
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10), // Consistent padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service["name"],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    service["price"],
                    style: TextStyle(
                      fontSize: 13,
                      color: bgColorPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard(Map<String, dynamic> service, BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Stack(
                children: [
                  Image.asset(
                    service["image"],
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "PREMIUM",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        service["name"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        service["price"],
                        style: TextStyle(
                          fontSize: 15,
                          color: bgColorPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    service["description"],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isPremiumBooked
                          ? null
                          : () async {
                        try {
                          final savedCart = await CartPersistence.loadCart() ?? {};
                          final dryCleanItems = (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {})
                              .map((key, value) => MapEntry(
                              key, value is int ? value : int.tryParse(value.toString()) ?? 0));
                          final ironingItems = (savedCart['ironingItems'] as Map<String, dynamic>? ?? {})
                              .map((key, value) => MapEntry(
                              key, value is int ? value : int.tryParse(value.toString()) ?? 0));
                          final washAndFoldItems = (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {})
                              .map((key, value) => MapEntry(
                              key, value is int ? value : int.tryParse(value.toString()) ?? 0));
                          final washAndIronItems = (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {})
                              .map((key, value) => MapEntry(
                              key, value is int ? value : int.tryParse(value.toString()) ?? 0));
                          final washIronStarchItems = (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {})
                              .map((key, value) => MapEntry(
                              key, value is int ? value : int.tryParse(value.toString()) ?? 0));
                          final prePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {})
                              .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
                          final additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {})
                              .map((key, value) => MapEntry(key, (value as List<dynamic>).cast<Map<String, dynamic>>()));
                          final dryCleanTotal = savedCart['dryCleanTotal'] as double? ?? 0.0;
                          final additionalTotal = savedCart['additionalTotal'] as double? ?? 0.0;

                          washAndFoldItems['Premium Laundry'] = (washAndFoldItems['Premium Laundry'] ?? 0) + 1;

                          await CartPersistence.saveCart(
                            dryCleanItems: dryCleanItems,
                            ironingItems: ironingItems,
                            washAndFoldItems: washAndFoldItems,
                            washAndIronItems: washAndIronItems,
                            washIronStarchItems: washIronStarchItems,
                            prePlatedItems: prePlatedItems,
                            additionalServices: additionalServices,
                            dryCleanTotal: dryCleanTotal,
                            additionalTotal: additionalTotal,
                          );

                          setState(() {
                            _isPremiumBooked = true;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Premium Laundry added to cart"),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );

                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: CartPage(
                                dryCleanItems: dryCleanItems,
                                ironingItems: ironingItems,
                                washAndFoldItems: washAndFoldItems,
                                washAndIronItems: washAndIronItems,
                                washIronStarchItems: washIronStarchItems,
                                prePlatedItems: prePlatedItems,
                                additionalServices: additionalServices,
                                dryCleanTotal: dryCleanTotal,
                                additionalTotal: additionalTotal,
                              ),
                            ),
                          ).then((_) {
                            _checkPremiumBookedStatus();
                            _updateCartItemCount();
                          });
                        } catch (e) {
                          _showSnackBar("Error adding to cart: ${e.toString()}", isError: true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPremiumBooked ? Colors.grey : bgColorPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        _isPremiumBooked ? "Already in Cart" : "Book Now",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
  }

  Widget _buildDrawerMenu() {
    String fullAddressString = "No address selected";
    if (_currentAddress != null) {
      final door = _currentAddress!['doorNumber'] ?? '';
      final street = _currentAddress!['street'] ?? '';
      final label = _currentAddress!['label'] ?? 'Address';
      fullAddressString = "$label: $door, $street";
    }

    return Drawer(
      child: Column(
        children: [
          Container(
            color: bgColorPink,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, bottom: 24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: bgColorPink),
                ),
                const SizedBox(height: 12),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    fullAddressString,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.receipt_long, color: bgColorPink),
                  title: const Text("Orders", style: TextStyle(fontSize: 16, color: Colors.black87)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UserOrdersPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_laundry_service, color: bgColorPink),
                  title: const Text("Active Subscriptions", style: TextStyle(fontSize: 16, color: Colors.black87)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionDetailsPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: bgColorPink),
                  title: const Text("Contact", style: TextStyle(fontSize: 16, color: Colors.black87)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: bgColorPink),
                  title: const Text("Settings", style: TextStyle(fontSize: 16, color: Colors.black87)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.feedback, color: bgColorPink),
                  title: const Text("Feedback", style: TextStyle(fontSize: 16, color: Colors.black87)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackPage()));
                  },
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10),
            child: ListTile(
              leading: const Icon(Icons.logout, color: bgColorPink),
              title: const Text("Logout", style: TextStyle(fontSize: 16, color: Colors.black87)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                HomePage.hasShownInitialAddressPrompt = false;
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdate() async {
    setState(() => _isCheckingUpdate = true);
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = packageInfo.version;
      print("Current app version: $_currentVersion");

      AppUpdateInfo appUpdateInfo = await InAppUpdate.checkForUpdate();
      print("Update availability: ${appUpdateInfo.updateAvailability}");

      if (appUpdateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        setState(() => _isUpdateAvailable = true);
        print("Update available. Update type: ${appUpdateInfo.updatePriority}");

        if (appUpdateInfo.immediateUpdateAllowed) {
          print("Starting immediate update...");
          await InAppUpdate.performImmediateUpdate();
        } else if (appUpdateInfo.flexibleUpdateAllowed) {
          print("Starting flexible update...");
          await InAppUpdate.startFlexibleUpdate();
        }
      } else {
        print("No update available.");
      }
    } catch (e) {
      print("Error checking for update via API: $e");
    } finally {
      setState(() => _isCheckingUpdate = false);
    }
  }

  void _launchPlayStore() async {
    const String packageName = "com.laundry.steam";
    final Uri uri = Uri.parse("market://details?id=$packageName");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final Uri webUri = Uri.parse("https://play.google.com/store/apps/details?id=$packageName");
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri);
      } else {
        _showSnackBar("Could not open Play Store.", isError: true);
      }
    }
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: bgColorPink,
            padding: const EdgeInsets.only(top: 30, left: 25, bottom: 40, right: 25),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Book pickups and\nservices with ease",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "We'll pick up, clean, and deliver your clothes",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Standard Services",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                    final itemWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 15)) / crossAxisCount; // 15 is crossAxisSpacing
                    final aspectRatio = itemWidth / 180; // 180 is the fixed height from _buildServiceCard

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: standardServices.length,
                      itemBuilder: (context, index) {
                        return _buildServiceCard(standardServices[index], context);
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),
                Text(
                  "Premium Services",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                ...premiumServices.map((service) => _buildPremiumCard(service, context)),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildWebLayout() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Book pickups and\nservices with ease",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: bgColorPink,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "We'll pick up, clean, and deliver your clothes",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Standard Services",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Fixed to 3 columns
                        childAspectRatio: 1.3, // Adjusted for fixed height of 180px
                        crossAxisSpacing: 25,
                        mainAxisSpacing: 25,
                      ),
                      itemCount: standardServices.length,
                      itemBuilder: (context, index) {
                        return _buildServiceCard(standardServices[index], context);
                      },
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Premium Services",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...premiumServices.map((service) => Container(
                      width: 500,
                      child: _buildPremiumCard(service, context),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 1000;

    return Title(
      title:'V12 Laundry | Home',
      color: bgColorPink,
      child: WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
        child: Scaffold(
          drawer: _buildDrawerMenu(),
          appBar: AppBar(
            backgroundColor: bgColorPink,
            elevation: 0,
            title: const Text(''),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              InkWell(
                onTap: (){_showAddressSelectionSheet(onAddressChanged: _loadCurrentAddress);},
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
                          _currentAddress != null
                              ? (_currentAddress!['label'] as String? ?? 'Select Address')
                              : 'Select Address',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () async {
                      try {
                        final savedCart = await CartPersistence.loadCart() ?? {};
                        final dryCleanItems = (savedCart['dryCleanItems'] as Map<String, dynamic>? ?? {})
                            .map((key, value) => MapEntry(
                            key, value is int ? value : int.tryParse(value.toString()) ?? 0));
                        final ironingItems = (savedCart['ironingItems'] as Map<String, dynamic>? ?? {})
                            .map((key, value) => MapEntry(
                            key, value is int ? value : int.tryParse(value.toString()) ?? 0));
                        final washAndFoldItems = (savedCart['washAndFoldItems'] as Map<String, dynamic>? ?? {})
                            .map((key, value) => MapEntry(
                            key, value is int ? value : int.tryParse(value.toString()) ?? 0));
                        final washAndIronItems = (savedCart['washAndIronItems'] as Map<String, dynamic>? ?? {})
                            .map((key, value) => MapEntry(
                            key, value is int ? value : int.tryParse(value.toString()) ?? 0));
                        final washIronStarchItems = (savedCart['washIronStarchItems'] as Map<String, dynamic>? ?? {})
                            .map((key, value) => MapEntry(
                            key, value is int ? value : int.tryParse(value.toString()) ?? 0));
                        final prePlatedItems = (savedCart['prePlatedItems'] as Map<String, dynamic>? ?? {})
                            .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
                        final additionalServices = (savedCart['additionalServices'] as Map<String, dynamic>? ?? {})
                            .map((key, value) => MapEntry(key, (value as List<dynamic>).cast<Map<String, dynamic>>()));
                        final dryCleanTotal = savedCart['dryCleanTotal'] as double? ?? 0.0;
                        final additionalTotal = savedCart['additionalTotal'] as double? ?? 0.0;
      
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: CartPage(
                              dryCleanItems: dryCleanItems,
                              ironingItems: ironingItems,
                              washAndFoldItems: washAndFoldItems,
                              washAndIronItems: washAndIronItems,
                              washIronStarchItems: washIronStarchItems,
                              prePlatedItems: prePlatedItems,
                              additionalServices: additionalServices,
                              dryCleanTotal: dryCleanTotal,
                              additionalTotal: additionalTotal,
                            ),
                          ),
                        ).then((_) {
                          _checkPremiumBookedStatus();
                          _updateCartItemCount();
                        });
                      } catch (e) {
                        _showSnackBar("Error loading cart: ${e.toString()}", isError: true);
                      }
                    },
                  ),
                  if (_cartItemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          _cartItemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.account_circle, color: Colors.white),
                onPressed: _showProfileSheet,
              ),
            ],
          ),
          body: isMobile ? _buildMobileLayout() : _buildWebLayout(),
        ),
      ),
    );
  }
}