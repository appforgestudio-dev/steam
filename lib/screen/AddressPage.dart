// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart' as geocoding;
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/places.dart';
// import '../constant/constant.dart';
// import '../constant/address_persistence.dart';
//
// const double coimbatoreMinLat = 10.9;
// const double coimbatoreMaxLat = 11.2;
// const double coimbatoreMinLng = 76.8;
// const double coimbatoreMaxLng = 77.1;
//
// class AddressPage extends StatefulWidget {
//   const AddressPage({super.key});
//
//   @override
//   State<AddressPage> createState() => _AddressPageState();
// }
//
// class _AddressPageState extends State<AddressPage> {
//   GoogleMapController? _mapController;
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _doorNumberController = TextEditingController();
//   final TextEditingController _streetNameController = TextEditingController();
//   final TextEditingController _customLabelController = TextEditingController();
//
//   String? _selectedLabel;
//   bool _isLoading = true;
//   bool _isGeocoding = false;
//   bool _isOutsideServiceArea = false;
//
//   LatLng? _selectedLatLn;
//   final Set<Marker> _markers = {};
//
//   static const CameraPosition _initialCameraPosition = CameraPosition(
//     target: LatLng(11.0176, 76.9674),
//     zoom: 11,
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     _initializePageData();
//   }
//
//   @override
//   void dispose() {
//     _addressController.dispose();
//     _doorNumberController.dispose();
//     _streetNameController.dispose();
//     _customLabelController.dispose();
//     _mapController?.dispose();
//     super.dispose();
//   }
//
//   Future<void> _initializePageData() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       await _checkLocationAndLoadMap();
//
//       if (_selectedLatLn == null && !_isOutsideServiceArea) {
//         _setMarker(_initialCameraPosition.target);
//         await _getAddressFromLatLng(_initialCameraPosition.target);
//       }
//     } catch (e) {
//       _showSnackBar("Failed to initialize page. Try Again", isError: true);
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _checkLocationAndLoadMap() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     try {
//       serviceEnabled = await Geolocator.isLocationServiceEnabled();
//
//       permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           await _showPermissionDeniedDialog();
//           permission = await Geolocator.checkPermission();
//           if (permission == LocationPermission.denied) {
//             _showSnackBar('Location permissions denied. Using default location.', isError: true);
//             return;
//           }
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         await _showPermissionPermanentlyDeniedDialog();
//         _showSnackBar('Location permissions permanently denied. Using default location.', isError: true);
//         return;
//       }
//
//       if (serviceEnabled && (permission == LocationPermission.whileInUse || permission == LocationPermission.always)) {
//         await _getCurrentLocation();
//       }
//     } catch (e) {
//       _showSnackBar("Error during location check: ${e.toString()}", isError: true);
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//       LatLng currentLatLng = LatLng(position.latitude, position.longitude);
//       if (!_isWithinCoimbatore(currentLatLng)) {
//         setState(() {
//           _isOutsideServiceArea = true;
//         });
//         return;
//       }
//       // ### END: MODIFIED LOCATION CHECK ###
//
//       _setMarker(currentLatLng);
//       if (_mapController != null) {
//         await _mapController!.animateCamera(
//           CameraUpdate.newLatLngZoom(currentLatLng, 15),
//         );
//       }
//       await _getAddressFromLatLng(currentLatLng);
//     } catch (e) {
//       _showSnackBar("Failed to get current location: ${e.toString()}", isError: true);
//     }
//   }
//
//   Future<void> _loadSavedAddress() async {
//     try {
//       final savedAddress = await AddressPersistence.loadCurrentAddress();
//       if (savedAddress != null) {
//         _addressController.text = savedAddress['street'] ?? '';
//         _doorNumberController.text = savedAddress['doorNumber'] ?? '';
//         _streetNameController.text = savedAddress['streetName'] ?? '';
//         _selectedLabel = savedAddress['label'];
//         if (_selectedLabel != 'Home' && _selectedLabel != 'Work') {
//           _customLabelController.text = _selectedLabel ?? '';
//           _selectedLabel = 'Other';
//         }
//         final savedLat = savedAddress['latitude'] as double?;
//         final savedLng = savedAddress['longitude'] as double?;
//         if (savedLat != null && savedLng != null) {
//           final savedLatLng = LatLng(savedLat, savedLng);
//           if (!_isWithinCoimbatore(savedLatLng)) {
//             _showSnackBar("Saved address outside Coimbatore. Defaulting to Coimbatore.", isError: true);
//             _setMarker(_initialCameraPosition.target);
//             await _getAddressFromLatLng(_initialCameraPosition.target);
//           } else {
//             _setMarker(savedLatLng);
//             if (_mapController != null) {
//               await _mapController!.animateCamera(CameraUpdate.newLatLngZoom(savedLatLng, 15));
//             }
//           }
//         }
//       }
//     } catch (e) {
//       _showSnackBar("Error loading saved address: ${e.toString()}", isError: true);
//     }
//   }
//
//   Future<void> _saveAddress() async {
//     if (_addressController.text.trim().isEmpty || _selectedLatLn == null) {
//       _showSnackBar("Please select a location on the map and ensure address is populated.", isError: true);
//       return;
//     }
//
//     if (_doorNumberController.text.trim().isEmpty) {
//       _showSnackBar("Please enter the door number.", isError: true);
//       return;
//     }
//     if (_streetNameController.text.trim().isEmpty) {
//       _showSnackBar("Please enter the street name.", isError: true);
//       return;
//     }
//
//     if (!_isWithinCoimbatore(_selectedLatLn!)) {
//       _showSnackBar("Selected location is outside Coimbatore. Please select a valid location.", isError: true);
//       return;
//     }
//
//     String finalLabel = _selectedLabel ?? 'Custom';
//     if (_selectedLabel == 'Other') {
//       if (_customLabelController.text.trim().isEmpty) {
//         _showSnackBar("Please enter a custom label.", isError: true);
//         return;
//       }
//       finalLabel = _customLabelController.text.trim();
//     }
//
//     final addressData = {
//       'street': _addressController.text.trim(),
//       'doorNumber': _doorNumberController.text.trim(),
//       'streetName': _streetNameController.text.trim(),
//       'label': finalLabel,
//       'latitude': _selectedLatLn!.latitude,
//       'longitude': _selectedLatLn!.longitude,
//     };
//
//     await AddressPersistence.saveOrUpdateAddress(addressData);
//     await AddressPersistence.saveCurrentAddress(addressData);
//
//     _showSnackBar("Address saved successfully!", isError: false);
//     Navigator.pop(context, true);
//
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//     if (_selectedLatLn != null) {
//       _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_selectedLatLn!, 15));
//     }
//   }
//
//   Future<void> _onTapMap(LatLng latLng) async {
//     if (!_isWithinCoimbatore(latLng)) {
//       _showSnackBar("Please select a location within Coimbatore, Tamil Nadu.", isError: true);
//       return;
//     }
//
//     setState(() {
//       _isGeocoding = true;
//     });
//     _setMarker(latLng);
//     if (_mapController != null) {
//       await _mapController!.animateCamera(
//         CameraUpdate.newLatLngZoom(latLng, await _mapController!.getZoomLevel()),
//       );
//     }
//     await _getAddressFromLatLng(latLng);
//     setState(() {
//       _isGeocoding = false;
//     });
//   }
//
//   void _setMarker(LatLng latLng) {
//     setState(() {
//       _selectedLatLn = latLng;
//       _markers.clear();
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('selected_location'),
//           position: latLng,
//           draggable: true,
//           onDragEnd: (newLatLng) async {
//             if (!_isWithinCoimbatore(newLatLng)) {
//               _showSnackBar("Dragging outside Coimbatore is not allowed.", isError: true);
//               _setMarker(_selectedLatLn ?? _initialCameraPosition.target);
//               return;
//             }
//             setState(() { _isGeocoding = true; });
//             _setMarker(newLatLng);
//             await _getAddressFromLatLng(newLatLng);
//             setState(() { _isGeocoding = false; });
//           },
//           infoWindow: const InfoWindow(title: "Selected Location"),
//         ),
//       );
//     });
//   }
//
//   Future<void> _getAddressFromLatLng(LatLng latLng) async {
//     try {
//       List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
//         latLng.latitude,
//         latLng.longitude,
//       );
//
//       if (placemarks.isNotEmpty) {
//         final placemark = placemarks.first;
//         _addressController.text = [
//           placemark.street,
//           placemark.subLocality,
//           placemark.locality,
//           placemark.postalCode,
//           placemark.country,
//         ].whereType<String>().where((s) => s.isNotEmpty).join(', ');
//       } else {
//         _addressController.text = "No address found for this location.";
//       }
//     } catch (e) {
//       _showSnackBar("Failed to get address details: ${e.toString()}", isError: true);
//       _addressController.text = "Error getting address.";
//     }
//   }
//
//   Future<void> _showPermissionDeniedDialog() async {
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text("Location Permission Required"),
//         content: const Text("This app needs location permissions to use your current location. Please grant access."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("No, thanks"),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await Geolocator.requestPermission();
//               _checkLocationAndLoadMap();
//             },
//             child: const Text("Grant"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _showPermissionPermanentlyDeniedDialog() async {
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text("Location Permission Denied"),
//         content: const Text("Location permissions are permanently denied. Please enable them in app settings."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("No, thanks"),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await Geolocator.openAppSettings();
//               _checkLocationAndLoadMap();
//             },
//             child: const Text("Open Settings"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }
//
//   bool _isWithinCoimbatore(LatLng latLng) {
//     return latLng.latitude >= coimbatoreMinLat &&
//         latLng.latitude <= coimbatoreMaxLat &&
//         latLng.longitude >= coimbatoreMinLng &&
//         latLng.longitude <= coimbatoreMaxLng;
//   }
//
//   // ### START: NEW WIDGET FOR "OUTSIDE AREA" MESSAGE ###
//   Widget _buildOutsideAreaWidget() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
//             const SizedBox(height: 24),
//             Text(
//               'Sorry! We are not available in your area.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Our service is only available in Coimbatore.',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   // ### END: NEW WIDGET FOR "OUTSIDE AREA" MESSAGE ###
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Delivery Address", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.3)),
//         centerTitle: true,
//         leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, size: 20)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SearchLocationPage(
//                     onLocationSelected: (latLng) async {
//                       _setMarker(latLng);
//                       if (_mapController != null) {
//                         await _mapController!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
//                       }
//                       await _getAddressFromLatLng(latLng);
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//         elevation: 0,
//         backgroundColor: bgColorPink,
//         foregroundColor: Colors.white,
//         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
//       ),
//       // ### START: MODIFIED BODY LOGIC ###
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.pink, strokeWidth: 2.5))
//           : _isOutsideServiceArea
//           ? _buildOutsideAreaWidget()
//           : Column(
//         children: [
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.43,
//             child: Stack(
//               children: [
//                 GoogleMap(
//                   onMapCreated: _onMapCreated,
//                   initialCameraPosition: _initialCameraPosition,
//                   markers: _markers,
//                   onTap: _onTapMap,
//                   myLocationEnabled: true,
//                   myLocationButtonEnabled: false,
//                   zoomControlsEnabled: false,
//                   mapToolbarEnabled: false,
//                   minMaxZoomPreference: const MinMaxZoomPreference(10, 18),
//                 ),
//                 Positioned(
//                   top: 16,
//                   left: 16,
//                   right: 16,
//                   child: Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                       child: Text(
//                         _addressController.text.isNotEmpty ? _addressController.text : "Tap on map to select location",
//                         style: TextStyle(fontSize: 13, color: Colors.grey[800]),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 16,
//                   right: 16,
//                   child: Column(
//                     children: [
//                       FloatingActionButton.small(
//                         onPressed: _getCurrentLocation,
//                         backgroundColor: Colors.white,
//                         elevation: 2,
//                         child: const Icon(Icons.my_location, color: bgColorPink, size: 20),
//                       ),
//                       const SizedBox(height: 8),
//                       FloatingActionButton.small(
//                         onPressed: () {
//                           if (_selectedLatLn != null) {
//                             _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_selectedLatLn!, 18));
//                           }
//                         },
//                         backgroundColor: Colors.white,
//                         elevation: 2,
//                         child: const Icon(Icons.zoom_in, color: bgColorPink, size: 20),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (_isGeocoding)
//                   const Positioned.fill(
//                     child: Center(child: CircularProgressIndicator(color: Colors.pink, strokeWidth: 2.5)),
//                   ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("ADDRESS DETAILS", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5)),
//                     const SizedBox(height: 16),
//                     Text("Door / Flat Number", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: _doorNumberController,
//                       decoration: InputDecoration(
//                         hintText: "e.g., 12A, Flat 301",
//                         hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                         enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                       style: const TextStyle(fontSize: 14, color: Colors.black87),
//                     ),
//                     const SizedBox(height: 16),
//                     Text("Street Name / Society", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: _streetNameController,
//                       decoration: InputDecoration(
//                         hintText: "e.g., Main Street, Palm Gardens",
//                         hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                         enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                       style: const TextStyle(fontSize: 14, color: Colors.black87),
//                     ),
//                     const SizedBox(height: 20),
//                     Text("SAVE ADDRESS AS", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5)),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(child: _buildLabelChip('Home', Icons.home)),
//                         const SizedBox(width: 8),
//                         Expanded(child: _buildLabelChip('Work', Icons.work)),
//                         const SizedBox(width: 8),
//                         Expanded(child: _buildLabelChip('Other', Icons.category)),
//                       ],
//                     ),
//                     if (_selectedLabel == 'Other') ...[
//                       const SizedBox(height: 12),
//                       TextField(
//                         controller: _customLabelController,
//                         decoration: InputDecoration(
//                           hintText: "Enter custom label",
//                           hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                           enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                           focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
//                           filled: true,
//                           fillColor: Colors.white,
//                           prefixIcon: Icon(Icons.label, size: 20, color: Colors.grey[600]),
//                         ),
//                         style: const TextStyle(fontSize: 14, color: Colors.black87),
//                       ),
//                     ],
//                     const SizedBox(height: 24),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _saveAddress,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: bgColorPink,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           elevation: 0,
//                           shadowColor: Colors.transparent,
//                         ),
//                         child: const Text("SAVE ADDRESS", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       // ### END: MODIFIED BODY LOGIC ###
//     );
//   }
//
//   Widget _buildLabelChip(String label, IconData icon) {
//     final isSelected = _selectedLabel == label;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedLabel = isSelected ? null : label;
//           if (_selectedLabel != 'Other') {
//             _customLabelController.clear();
//           }
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: isSelected ? bgColorPink.withOpacity(0.1) : Colors.grey[50],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: isSelected ? bgColorPink : Colors.grey.shade300,
//             width: isSelected ? 1.5 : 1,
//           ),
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               size: 20,
//               color: isSelected ? bgColorPink : Colors.grey[600],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: isSelected ? bgColorPink : Colors.grey[700],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class SearchLocationPage extends StatefulWidget {
//   final Function(LatLng) onLocationSelected;
//
//   const SearchLocationPage({super.key, required this.onLocationSelected});
//
//   @override
//   State<SearchLocationPage> createState() => _SearchLocationPageState();
// }
//
// class _SearchLocationPageState extends State<SearchLocationPage> {
//   final TextEditingController _searchController = TextEditingController();
//   final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: "AIzaSyBfhmWG0O5LmNO1I9v0P_hsbkA11kyeBXc");
//   List<Prediction> _placePredictions = [];
//   String? _currentSearchInput;
//   bool _isLoading = false;
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _getPlaceSuggestions(String input) async {
//     if (input.isEmpty) {
//       setState(() {
//         _placePredictions = [];
//         _currentSearchInput = null;
//       });
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//       _currentSearchInput = input;
//     });
//
//     final response = await _places.autocomplete(input, components: [Component(Component.country, "in")]);
//
//     if (response.status == "OK" && _currentSearchInput == input) {
//       setState(() {
//         _placePredictions = response.predictions.where((prediction) {
//           return prediction.description!.toLowerCase().contains("coimbatore") &&
//               prediction.description!.toLowerCase().contains("tamil nadu");
//         }).toList();
//       });
//     } else if (response.status == "ZERO_RESULTS" && _currentSearchInput == input) {
//       setState(() {
//         _placePredictions = [];
//       });
//     } else if (response.status != "OK" && _currentSearchInput == input) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error fetching suggestions: ${response.errorMessage}")),
//         );
//       }
//     }
//
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   Future<void> _selectPlaceFromSuggestion(Prediction prediction) async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final detailsResponse = await _places.getDetailsByPlaceId(prediction.placeId!);
//
//       if (detailsResponse.status == "OK") {
//         final location = detailsResponse.result.geometry!.location;
//         final latLng = LatLng(location.lat, location.lng);
//
//         if (latLng.latitude >= coimbatoreMinLat &&
//             latLng.latitude <= coimbatoreMaxLat &&
//             latLng.longitude >= coimbatoreMinLng &&
//             latLng.longitude <= coimbatoreMaxLng) {
//           if (mounted) {
//             widget.onLocationSelected(latLng);
//             Navigator.pop(context);
//           }
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Selected place is outside Coimbatore, Tamil Nadu.")),
//             );
//           }
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Failed to get details: ${detailsResponse.errorMessage}")),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error selecting place: $e")),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(
//             color: Colors.white
//         ),
//         title: const Text("Search Location",
//           style: TextStyle(color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 18,
//             letterSpacing: 0.3,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: bgColorPink,
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(12),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _searchController,
//               autofocus: true,
//               decoration: InputDecoration(
//                 hintText: "Search for a location in Coimbatore...",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: () async {
//                     if (_searchController.text.isNotEmpty) {
//                       setState(() {
//                         _isLoading = true;
//                       });
//                       try {
//                         List<geocoding.Location> locations =
//                         await geocoding.locationFromAddress(_searchController.text);
//                         if (locations.isNotEmpty) {
//                           final location = locations.first;
//                           final latLng = LatLng(location.latitude, location.longitude);
//                           if (latLng.latitude >= coimbatoreMinLat &&
//                               latLng.latitude <= coimbatoreMaxLat &&
//                               latLng.longitude >= coimbatoreMinLng &&
//                               latLng.longitude <= coimbatoreMaxLng) {
//                             if (mounted) {
//                               widget.onLocationSelected(latLng);
//                               Navigator.pop(context);
//                             }
//                           } else {
//                             if (mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text("Search result outside Coimbatore, Tamil Nadu.")),
//                               );
//                             }
//                           }
//                         } else {
//                           if (mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text("No locations found for this address")),
//                             );
//                           }
//                         }
//                       } catch (e) {
//                         if (mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text("Error searching: $e")),
//                           );
//                         }
//                       } finally {
//                         if (mounted) {
//                           setState(() {
//                             _isLoading = false;
//                           });
//                         }
//                       }
//                     }
//                   },
//                 ),
//               ),
//               onChanged: _getPlaceSuggestions,
//             ),
//             if (_isLoading)
//               const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: CircularProgressIndicator(),
//               ),
//             if (_placePredictions.isNotEmpty)
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _placePredictions.length,
//                   itemBuilder: (context, index) {
//                     final prediction = _placePredictions[index];
//                     return ListTile(
//                       leading: const Icon(Icons.location_on),
//                       title: Text(prediction.description!),
//                       onTap: () => _selectPlaceFromSuggestion(prediction),
//                     );
//                   },
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart' as geocoding;
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/places.dart';
// import '../constant/constant.dart';
// import '../constant/address_persistence.dart';
//
// const double coimbatoreMinLat = 10.9;
// const double coimbatoreMaxLat = 11.2;
// const double coimbatoreMinLng = 76.8;
// const double coimbatoreMaxLng = 77.1;
//
// class AddressPage extends StatefulWidget {
//   const AddressPage({super.key});
//
//   @override
//   State<AddressPage> createState() => _AddressPageState();
// }
//
// class _AddressPageState extends State<AddressPage> {
//   GoogleMapController? _mapController;
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _doorNumberController = TextEditingController();
//   final TextEditingController _streetNameController = TextEditingController();
//   final TextEditingController _customLabelController = TextEditingController();
//
//   String? _selectedLabel;
//   bool _isLoading = true;
//   bool _isGeocoding = false;
//   bool _isOutsideServiceArea = false;
//
//   LatLng? _selectedLatLn;
//   final Set<Marker> _markers = {};
//
//   static const CameraPosition _initialCameraPosition = CameraPosition(
//     target: LatLng(11.0176, 76.9674),
//     zoom: 11,
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     _initializePageData();
//   }
//
//   @override
//   void dispose() {
//     _addressController.dispose();
//     _doorNumberController.dispose();
//     _streetNameController.dispose();
//     _customLabelController.dispose();
//     _mapController?.dispose();
//     super.dispose();
//   }
//
//   Future<void> _initializePageData() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       await _checkLocationAndLoadMap();
//
//       if (_selectedLatLn == null && !_isOutsideServiceArea) {
//         _setMarker(_initialCameraPosition.target);
//         await _getAddressFromLatLng(_initialCameraPosition.target);
//       }
//     } catch (e) {
//       _showSnackBar("Failed to initialize page. Try Again", isError: true);
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _checkLocationAndLoadMap() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     try {
//       serviceEnabled = await Geolocator.isLocationServiceEnabled();
//
//       permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           await _showPermissionDeniedDialog();
//           permission = await Geolocator.checkPermission();
//           if (permission == LocationPermission.denied) {
//             _showSnackBar('Location permissions denied. Using default location.', isError: true);
//             return;
//           }
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         await _showPermissionPermanentlyDeniedDialog();
//         _showSnackBar('Location permissions permanently denied. Using default location.', isError: true);
//         return;
//       }
//
//       if (serviceEnabled && (permission == LocationPermission.whileInUse || permission == LocationPermission.always)) {
//         await _getCurrentLocation();
//       }
//     } catch (e) {
//       _showSnackBar("Error during location check: ${e.toString()}", isError: true);
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//       LatLng currentLatLng = LatLng(position.latitude, position.longitude);
//       if (!_isWithinCoimbatore(currentLatLng)) {
//         setState(() {
//           _isOutsideServiceArea = true;
//         });
//         return;
//       }
//
//       _setMarker(currentLatLng);
//       if (_mapController != null) {
//         await _mapController!.animateCamera(
//           CameraUpdate.newLatLngZoom(currentLatLng, 15),
//         );
//       }
//       await _getAddressFromLatLng(currentLatLng);
//     } catch (e) {
//       _showSnackBar("Failed to get current location: ${e.toString()}", isError: true);
//     }
//   }
//
//   Future<void> _loadSavedAddress() async {
//     try {
//       final savedAddress = await AddressPersistence.loadCurrentAddress();
//       if (savedAddress != null) {
//         _addressController.text = savedAddress['street'] ?? '';
//         _doorNumberController.text = savedAddress['doorNumber'] ?? '';
//         _streetNameController.text = savedAddress['streetName'] ?? '';
//         _selectedLabel = savedAddress['label'];
//         if (_selectedLabel != 'Home' && _selectedLabel != 'Work') {
//           _customLabelController.text = _selectedLabel ?? '';
//           _selectedLabel = 'Other';
//         }
//         final savedLat = savedAddress['latitude'] as double?;
//         final savedLng = savedAddress['longitude'] as double?;
//         if (savedLat != null && savedLng != null) {
//           final savedLatLng = LatLng(savedLat, savedLng);
//           if (!_isWithinCoimbatore(savedLatLng)) {
//             _showSnackBar("Saved address outside Coimbatore. Defaulting to Coimbatore.", isError: true);
//             _setMarker(_initialCameraPosition.target);
//             await _getAddressFromLatLng(_initialCameraPosition.target);
//           } else {
//             _setMarker(savedLatLng);
//             if (_mapController != null) {
//               await _mapController!.animateCamera(CameraUpdate.newLatLngZoom(savedLatLng, 15));
//             }
//           }
//         }
//       }
//     } catch (e) {
//       _showSnackBar("Error loading saved address: ${e.toString()}", isError: true);
//     }
//   }
//
//   Future<void> _saveAddress() async {
//     if (_doorNumberController.text.trim().isEmpty) {
//       _showSnackBar("Please enter the door number.", isError: true);
//       return;
//     }
//     if (_streetNameController.text.trim().isEmpty) {
//       _showSnackBar("Please enter the street name.", isError: true);
//       return;
//     }
//
//     String finalLabel = _selectedLabel ?? 'Custom';
//     if (_selectedLabel == 'Other') {
//       if (_customLabelController.text.trim().isEmpty) {
//         _showSnackBar("Please enter a custom label.", isError: true);
//         return;
//       }
//       finalLabel = _customLabelController.text.trim();
//     }
//
//     final addressData = {
//       'street': _streetNameController.text.trim(), // Using streetName instead of addressController for web
//       'doorNumber': _doorNumberController.text.trim(),
//       'streetName': _streetNameController.text.trim(),
//       'label': finalLabel,
//     };
//
//     await AddressPersistence.saveOrUpdateAddress(addressData);
//     await AddressPersistence.saveCurrentAddress(addressData);
//
//     _showSnackBar("Address saved successfully!", isError: false);
//     Navigator.pop(context, true);
//   }
//
//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//     if (_selectedLatLn != null) {
//       _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_selectedLatLn!, 15));
//     }
//   }
//
//   Future<void> _onTapMap(LatLng latLng) async {
//     if (!_isWithinCoimbatore(latLng)) {
//       _showSnackBar("Please select a location within Coimbatore, Tamil Nadu.", isError: true);
//       return;
//     }
//
//     setState(() {
//       _isGeocoding = true;
//     });
//     _setMarker(latLng);
//     if (_mapController != null) {
//       await _mapController!.animateCamera(
//         CameraUpdate.newLatLngZoom(latLng, await _mapController!.getZoomLevel()),
//       );
//     }
//     await _getAddressFromLatLng(latLng);
//     setState(() {
//       _isGeocoding = false;
//     });
//   }
//
//   void _setMarker(LatLng latLng) {
//     setState(() {
//       _selectedLatLn = latLng;
//       _markers.clear();
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('selected_location'),
//           position: latLng,
//           draggable: true,
//           onDragEnd: (newLatLng) async {
//             if (!_isWithinCoimbatore(newLatLng)) {
//               _showSnackBar("Dragging outside Coimbatore is not allowed.", isError: true);
//               _setMarker(_selectedLatLn ?? _initialCameraPosition.target);
//               return;
//             }
//             setState(() { _isGeocoding = true; });
//             _setMarker(newLatLng);
//             await _getAddressFromLatLng(newLatLng);
//             setState(() { _isGeocoding = false; });
//           },
//           infoWindow: const InfoWindow(title: "Selected Location"),
//         ),
//       );
//     });
//   }
//
//   Future<void> _getAddressFromLatLng(LatLng latLng) async {
//     try {
//       List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
//         latLng.latitude,
//         latLng.longitude,
//       );
//
//       if (placemarks.isNotEmpty) {
//         final placemark = placemarks.first;
//         _addressController.text = [
//           placemark.street,
//           placemark.subLocality,
//           placemark.locality,
//           placemark.postalCode,
//           placemark.country,
//         ].whereType<String>().where((s) => s.isNotEmpty).join(', ');
//       } else {
//         _addressController.text = "No address found for this location.";
//       }
//     } catch (e) {
//
//       _addressController.text = "Error getting address.";
//     }
//   }
//
//   Future<void> _showPermissionDeniedDialog() async {
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text("Location Permission Required"),
//         content: const Text("This app needs location permissions to use your current location. Please grant access."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("No, thanks"),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await Geolocator.requestPermission();
//               _checkLocationAndLoadMap();
//             },
//             child: const Text("Grant"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _showPermissionPermanentlyDeniedDialog() async {
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text("Location Permission Denied"),
//         content: const Text("Location permissions are permanently denied. Please enable them in app settings."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("No, thanks"),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await Geolocator.openAppSettings();
//               _checkLocationAndLoadMap();
//             },
//             child: const Text("Open Settings"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }
//
//   bool _isWithinCoimbatore(LatLng latLng) {
//     return latLng.latitude >= coimbatoreMinLat &&
//         latLng.latitude <= coimbatoreMaxLat &&
//         latLng.longitude >= coimbatoreMinLng &&
//         latLng.longitude <= coimbatoreMaxLng;
//   }
//
//   Widget _buildOutsideAreaWidget() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
//             const SizedBox(height: 24),
//             Text(
//               'Sorry! We are not available in your area.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Our service is only available in Coimbatore.',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLabelChip(String label, IconData icon) {
//     final isSelected = _selectedLabel == label;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedLabel = isSelected ? null : label;
//           if (_selectedLabel != 'Other') {
//             _customLabelController.clear();
//           }
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: isSelected ? bgColorPink.withOpacity(0.1) : Colors.grey[50],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: isSelected ? bgColorPink : Colors.grey.shade300,
//             width: isSelected ? 1.5 : 1,
//           ),
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               size: 20,
//               color: isSelected ? bgColorPink : Colors.grey[600],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: isSelected ? bgColorPink : Colors.grey[700],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isWeb = MediaQuery.of(context).size.width >= 1000;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Delivery Address", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.3)),
//         centerTitle: true,
//         leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, size: 20)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SearchLocationPage(
//                     onLocationSelected: (latLng) async {
//                       _setMarker(latLng);
//                       if (_mapController != null) {
//                         await _mapController!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
//                       }
//                       await _getAddressFromLatLng(latLng);
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//         elevation: 0,
//         backgroundColor: bgColorPink,
//         foregroundColor: Colors.white,
//         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           double mapHeight = isWeb ? 0 : screenHeight * 0.43; // No map height on web
//           double maxMapWidth = isWeb ? 0 : screenWidth; // No map width on web
//
//           return _isLoading
//               ? const Center(child: CircularProgressIndicator(color: Colors.pink, strokeWidth: 2.5))
//               : _isOutsideServiceArea
//               ? _buildOutsideAreaWidget()
//               : isWeb
//               ? Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("ADDRESS DETAILS", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5)),
//                   const SizedBox(height: 16),
//                   Text("Door / Flat Number", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: _doorNumberController,
//                     decoration: InputDecoration(
//                       hintText: "e.g., 12A, Flat 301",
//                       hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                       enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                     style: const TextStyle(fontSize: 14, color: Colors.black87),
//                   ),
//                   const SizedBox(height: 16),
//                   Text("Street Name / Society", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: _streetNameController,
//                     decoration: InputDecoration(
//                       hintText: "e.g., Main Street, Palm Gardens",
//                       hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                       enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                     style: const TextStyle(fontSize: 14, color: Colors.black87),
//                   ),
//                   const SizedBox(height: 20),
//                   Text("SAVE ADDRESS AS", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5)),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(child: _buildLabelChip('Home', Icons.home)),
//                       const SizedBox(width: 8),
//                       Expanded(child: _buildLabelChip('Work', Icons.work)),
//                       const SizedBox(width: 8),
//                       Expanded(child: _buildLabelChip('Other', Icons.category)),
//                     ],
//                   ),
//                   if (_selectedLabel == 'Other') ...[
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: _customLabelController,
//                       decoration: InputDecoration(
//                         hintText: "Enter custom label",
//                         hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                         enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
//                         filled: true,
//                         fillColor: Colors.white,
//                         prefixIcon: Icon(Icons.label, size: 20, color: Colors.grey[600]),
//                       ),
//                       style: const TextStyle(fontSize: 14, color: Colors.black87),
//                     ),
//                   ],
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _saveAddress,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: bgColorPink,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         elevation: 0,
//                         shadowColor: Colors.transparent,
//                       ),
//                       child: const Text("SAVE ADDRESS", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                 ],
//               ),
//             ),
//           )
//               : Column(
//             children: [
//               SizedBox(
//                 height: mapHeight,
//                 width: maxMapWidth,
//                 child: Stack(
//                   children: [
//                     GoogleMap(
//                       onMapCreated: _onMapCreated,
//                       initialCameraPosition: _initialCameraPosition,
//                       markers: _markers,
//                       onTap: _onTapMap,
//                       myLocationEnabled: true,
//                       myLocationButtonEnabled: false,
//                       zoomControlsEnabled: false,
//                       mapToolbarEnabled: false,
//                       minMaxZoomPreference: const MinMaxZoomPreference(10, 18),
//                     ),
//                     Positioned(
//                       top: 16,
//                       left: 16,
//                       right: 16,
//                       child: Card(
//                         elevation: 2,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                           child: Text(
//                             _addressController.text.isNotEmpty ? _addressController.text : "Tap on map to select location",
//                             style: TextStyle(fontSize: 13, color: Colors.grey[800]),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 16,
//                       right: 16,
//                       child: Column(
//                         children: [
//                           FloatingActionButton.small(
//                             onPressed: _getCurrentLocation,
//                             backgroundColor: Colors.white,
//                             elevation: 2,
//                             child: const Icon(Icons.my_location, color: bgColorPink, size: 20),
//                           ),
//                           const SizedBox(height: 8),
//                           FloatingActionButton.small(
//                             onPressed: () {
//                               if (_selectedLatLn != null) {
//                                 _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_selectedLatLn!, 18));
//                               }
//                             },
//                             backgroundColor: Colors.white,
//                             elevation: 2,
//                             child: const Icon(Icons.zoom_in, color: bgColorPink, size: 20),
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (_isGeocoding)
//                       const Positioned.fill(
//                         child: Center(child: CircularProgressIndicator(color: Colors.pink, strokeWidth: 2.5)),
//                       ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//                   ),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("ADDRESS DETAILS", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5)),
//                         const SizedBox(height: 16),
//                         Text("Door / Flat Number", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _doorNumberController,
//                           decoration: InputDecoration(
//                             hintText: "e.g., 12A, Flat 301",
//                             hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                             focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
//                             filled: true,
//                             fillColor: Colors.white,
//                           ),
//                           style: const TextStyle(fontSize: 14, color: Colors.black87),
//                         ),
//                         const SizedBox(height: 16),
//                         Text("Street Name / Society", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _streetNameController,
//                           decoration: InputDecoration(
//                             hintText: "e.g., Main Street, Palm Gardens",
//                             hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                             focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
//                             filled: true,
//                             fillColor: Colors.white,
//                           ),
//                           style: const TextStyle(fontSize: 14, color: Colors.black87),
//                         ),
//                         const SizedBox(height: 20),
//                         Text("SAVE ADDRESS AS", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5)),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             Expanded(child: _buildLabelChip('Home', Icons.home)),
//                             const SizedBox(width: 8),
//                             Expanded(child: _buildLabelChip('Work', Icons.work)),
//                             const SizedBox(width: 8),
//                             Expanded(child: _buildLabelChip('Other', Icons.category)),
//                           ],
//                         ),
//                         if (_selectedLabel == 'Other') ...[
//                           const SizedBox(height: 12),
//                           TextField(
//                             controller: _customLabelController,
//                             decoration: InputDecoration(
//                               hintText: "Enter custom label",
//                               hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
//                               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                               enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
//                               focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
//                               filled: true,
//                               fillColor: Colors.white,
//                               prefixIcon: Icon(Icons.label, size: 20, color: Colors.grey[600]),
//                             ),
//                             style: const TextStyle(fontSize: 14, color: Colors.black87),
//                           ),
//                         ],
//                         const SizedBox(height: 24),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: _saveAddress,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: bgColorPink,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               elevation: 0,
//                               shadowColor: Colors.transparent,
//                             ),
//                             child: const Text("SAVE ADDRESS", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
//
// class SearchLocationPage extends StatefulWidget {
//   final Function(LatLng) onLocationSelected;
//
//   const SearchLocationPage({super.key, required this.onLocationSelected});
//
//   @override
//   State<SearchLocationPage> createState() => _SearchLocationPageState();
// }
//
// class _SearchLocationPageState extends State<SearchLocationPage> {
//   final TextEditingController _searchController = TextEditingController();
//   final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: "AIzaSyBfhmWG0O5LmNO1I9v0P_hsbkA11kyeBXc");
//   List<Prediction> _placePredictions = [];
//   String? _currentSearchInput;
//   bool _isLoading = false;
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _getPlaceSuggestions(String input) async {
//     if (input.isEmpty) {
//       setState(() {
//         _placePredictions = [];
//         _currentSearchInput = null;
//       });
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//       _currentSearchInput = input;
//     });
//
//     final response = await _places.autocomplete(input, components: [Component(Component.country, "in")]);
//
//     if (response.status == "OK" && _currentSearchInput == input) {
//       setState(() {
//         _placePredictions = response.predictions.where((prediction) {
//           return prediction.description!.toLowerCase().contains("coimbatore") &&
//               prediction.description!.toLowerCase().contains("tamil nadu");
//         }).toList();
//       });
//     } else if (response.status == "ZERO_RESULTS" && _currentSearchInput == input) {
//       setState(() {
//         _placePredictions = [];
//       });
//     } else if (response.status != "OK" && _currentSearchInput == input) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error fetching suggestions: ${response.errorMessage}")),
//         );
//       }
//     }
//
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   Future<void> _selectPlaceFromSuggestion(Prediction prediction) async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final detailsResponse = await _places.getDetailsByPlaceId(prediction.placeId!);
//
//       if (detailsResponse.status == "OK") {
//         final location = detailsResponse.result.geometry!.location;
//         final latLng = LatLng(location.lat, location.lng);
//
//         if (latLng.latitude >= coimbatoreMinLat &&
//             latLng.latitude <= coimbatoreMaxLat &&
//             latLng.longitude >= coimbatoreMinLng &&
//             latLng.longitude <= coimbatoreMaxLng) {
//           if (mounted) {
//             widget.onLocationSelected(latLng);
//             Navigator.pop(context);
//           }
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Selected place is outside Coimbatore, Tamil Nadu.")),
//             );
//           }
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Failed to get details: ${detailsResponse.errorMessage}")),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error selecting place: $e")),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isWeb = MediaQuery.of(context).size.width >= 1000;
//
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text("Search Location",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.3),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: bgColorPink,
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           double maxWidth = isWeb ? constraints.maxWidth * 0.6 : constraints.maxWidth;
//
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SizedBox(
//               width: maxWidth,
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: _searchController,
//                     autofocus: true,
//                     decoration: InputDecoration(
//                       hintText: "Search for a location in Coimbatore...",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       suffixIcon: IconButton(
//                         icon: const Icon(Icons.search),
//                         onPressed: () async {
//                           if (_searchController.text.isNotEmpty) {
//                             setState(() {
//                               _isLoading = true;
//                             });
//                             try {
//                               List<geocoding.Location> locations =
//                               await geocoding.locationFromAddress(_searchController.text);
//                               if (locations.isNotEmpty) {
//                                 final location = locations.first;
//                                 final latLng = LatLng(location.latitude, location.longitude);
//                                 if (latLng.latitude >= coimbatoreMinLat &&
//                                     latLng.latitude <= coimbatoreMaxLat &&
//                                     latLng.longitude >= coimbatoreMinLng &&
//                                     latLng.longitude <= coimbatoreMaxLng) {
//                                   if (mounted) {
//                                     widget.onLocationSelected(latLng);
//                                     Navigator.pop(context);
//                                   }
//                                 } else {
//                                   if (mounted) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(content: Text("Search result outside Coimbatore, Tamil Nadu.")),
//                                     );
//                                   }
//                                 }
//                               } else {
//                                 if (mounted) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(content: Text("No locations found for this address")),
//                                   );
//                                 }
//                               }
//                             } catch (e) {
//                               if (mounted) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text("Error searching: $e")),
//                                 );
//                               }
//                             } finally {
//                               if (mounted) {
//                                 setState(() {
//                                   _isLoading = false;
//                                 });
//                               }
//                             }
//                           }
//                         },
//                       ),
//                     ),
//                     onChanged: _getPlaceSuggestions,
//                   ),
//                   if (_isLoading)
//                     const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: CircularProgressIndicator(),
//                     ),
//                   if (_placePredictions.isNotEmpty)
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: _placePredictions.length,
//                         itemBuilder: (context, index) {
//                           final prediction = _placePredictions[index];
//                           return ListTile(
//                             leading: const Icon(Icons.location_on),
//                             title: Text(prediction.description!),
//                             onTap: () => _selectPlaceFromSuggestion(prediction),
//                           );
//                         },
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import '../constant/constant.dart';
import '../constant/address_persistence.dart';

const double coimbatoreMinLat = 10.9;
const double coimbatoreMaxLat = 11.2;
const double coimbatoreMinLng = 76.8;
const double coimbatoreMaxLng = 77.1;

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  GoogleMapController? _mapController;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _doorNumberController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();
  final TextEditingController _customLabelController = TextEditingController();

  String? _selectedLabel;
  bool _isLoading = true;
  bool _isGeocoding = false;
  bool _isOutsideServiceArea = false;

  LatLng? _selectedLatLn;
  final Set<Marker> _markers = {};

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(11.0176, 76.9674),
    zoom: 11,
  );

  @override
  void initState() {
    super.initState();
    _initializePageData();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _doorNumberController.dispose();
    _streetNameController.dispose();
    _customLabelController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializePageData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (!kIsWeb) {
        await _checkLocationAndLoadMap();
      }

      if (_selectedLatLn == null && !_isOutsideServiceArea) {
        _setMarker(_initialCameraPosition.target);
        await _getAddressFromLatLng(_initialCameraPosition.target);
      }
    } catch (e) {
      _showSnackBar("Failed to initialize page. Try Again", isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLocationAndLoadMap() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          await _showPermissionDeniedDialog();
          permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            _showSnackBar('Location permissions denied. Using default location.', isError: true);
            return;
          }
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await _showPermissionPermanentlyDeniedDialog();
        _showSnackBar('Location permissions permanently denied. Using default location.', isError: true);
        return;
      }

      if (serviceEnabled && (permission == LocationPermission.whileInUse || permission == LocationPermission.always)) {
        await _getCurrentLocation();
      }
    } catch (e) {
      _showSnackBar("Error during location check: ${e.toString()}", isError: true);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      if (!_isWithinCoimbatore(currentLatLng)) {
        setState(() {
          _isOutsideServiceArea = true;
        });
        return;
      }

      _setMarker(currentLatLng);
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentLatLng, 15),
        );
      }
      await _getAddressFromLatLng(currentLatLng);
    } catch (e) {
      _showSnackBar("Failed to get current location: ${e.toString()}", isError: true);
    }
  }

  Future<void> _loadSavedAddress() async {
    try {
      final savedAddress = await AddressPersistence.loadCurrentAddress();
      if (savedAddress != null) {
        _addressController.text = savedAddress['street'] ?? '';
        _doorNumberController.text = savedAddress['doorNumber'] ?? '';
        _streetNameController.text = savedAddress['streetName'] ?? '';
        _selectedLabel = savedAddress['label'];
        if (_selectedLabel != 'Home' && _selectedLabel != 'Work') {
          _customLabelController.text = _selectedLabel ?? '';
          _selectedLabel = 'Other';
        }
        final savedLat = savedAddress['latitude'] as double?;
        final savedLng = savedAddress['longitude'] as double?;
        if (savedLat != null && savedLng != null) {
          final savedLatLng = LatLng(savedLat, savedLng);
          if (!_isWithinCoimbatore(savedLatLng)) {
            _showSnackBar("Saved address outside Coimbatore. Defaulting to Coimbatore.", isError: true);
            _setMarker(_initialCameraPosition.target);
            await _getAddressFromLatLng(_initialCameraPosition.target);
          } else {
            _setMarker(savedLatLng);
            if (_mapController != null) {
              await _mapController!.animateCamera(CameraUpdate.newLatLngZoom(savedLatLng, 15));
            }
          }
        }
      }
    } catch (e) {
      _showSnackBar("Error loading saved address: ${e.toString()}", isError: true);
    }
  }

  Future<void> _saveAddress() async {
    if (_doorNumberController.text.trim().isEmpty) {
      _showSnackBar("Please enter the door number.", isError: true);
      return;
    }
    if (_streetNameController.text.trim().isEmpty) {
      _showSnackBar("Please enter the street name.", isError: true);
      return;
    }

    String finalLabel = _selectedLabel ?? 'Custom';
    if (_selectedLabel == 'Other') {
      if (_customLabelController.text.trim().isEmpty) {
        _showSnackBar("Please enter a custom label.", isError: true);
        return;
      }
      finalLabel = _customLabelController.text.trim();
    }

    final addressData = {
      'street': _streetNameController.text.trim(),
      'doorNumber': _doorNumberController.text.trim(),
      'streetName': _streetNameController.text.trim(),
      'label': finalLabel,
    };

    await AddressPersistence.saveOrUpdateAddress(addressData);
    await AddressPersistence.saveCurrentAddress(addressData);

    _showSnackBar("Address saved successfully!", isError: false);
    Navigator.pop(context, addressData);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_selectedLatLn != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_selectedLatLn!, 15));
    }
  }

  Future<void> _onTapMap(LatLng latLng) async {
    if (!_isWithinCoimbatore(latLng)) {
      _showSnackBar("Please select a location within Coimbatore, Tamil Nadu.", isError: true);
      return;
    }

    setState(() {
      _isGeocoding = true;
    });
    _setMarker(latLng);
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, await _mapController!.getZoomLevel()),
      );
    }
    await _getAddressFromLatLng(latLng);
    setState(() {
      _isGeocoding = false;
    });
  }

  void _setMarker(LatLng latLng) {
    setState(() {
      _selectedLatLn = latLng;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: latLng,
          draggable: true,
          onDragEnd: (newLatLng) async {
            if (!_isWithinCoimbatore(newLatLng)) {
              _showSnackBar("Dragging outside Coimbatore is not allowed.", isError: true);
              _setMarker(_selectedLatLn ?? _initialCameraPosition.target);
              return;
            }
            setState(() { _isGeocoding = true; });
            _setMarker(newLatLng);
            await _getAddressFromLatLng(newLatLng);
            setState(() { _isGeocoding = false; });
          },
          infoWindow: const InfoWindow(title: "Selected Location"),
        ),
      );
    });
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _addressController.text = [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
          placemark.postalCode,
          placemark.country,
        ].whereType<String>().where((s) => s.isNotEmpty).join(', ');
      } else {
        _addressController.text = "No address found for this location.";
      }
    } catch (e) {
      _addressController.text = "Error getting address.";
    }
  }

  Future<void> _showPermissionDeniedDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Location Permission Required"),
        content: const Text("This app needs location permissions to use your current location. Please grant access."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("No, thanks"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.requestPermission();
              _checkLocationAndLoadMap();
            },
            child: const Text("Grant"),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionPermanentlyDeniedDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Location Permission Denied"),
        content: const Text("Location permissions are permanently denied. Please enable them in app settings."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("No, thanks"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
              _checkLocationAndLoadMap();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  bool _isWithinCoimbatore(LatLng latLng) {
    return latLng.latitude >= coimbatoreMinLat &&
        latLng.latitude <= coimbatoreMaxLat &&
        latLng.longitude >= coimbatoreMinLng &&
        latLng.longitude <= coimbatoreMaxLng;
  }

  Widget _buildOutsideAreaWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Sorry! We are not available in your area.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Our service is only available in Coimbatore.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelChip(String label, IconData icon) {
    final isSelected = _selectedLabel == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLabel = isSelected ? null : label;
          if (_selectedLabel != 'Other') {
            _customLabelController.clear();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? bgColorPink.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? bgColorPink : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? bgColorPink : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? bgColorPink : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width >= 1000 || kIsWeb;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Delivery Address", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.3)),
        centerTitle: true,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, size: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchLocationPage(
                    onLocationSelected: (latLng) async {
                      _setMarker(latLng);
                      if (_mapController != null) {
                        await _mapController!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
                      }
                      await _getAddressFromLatLng(latLng);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
        ],
        elevation: 0,
        backgroundColor: bgColorPink,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double mapHeight = isWeb ? 0 : screenHeight * 0.43;
          double maxMapWidth = isWeb ? 0 : screenWidth;
          String StFa = isWeb ? "Address (Street Name / Society, Area,)" : "Street Name / Society";
          return _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.pink, strokeWidth: 2.5))
              : _isOutsideServiceArea
              ? _buildOutsideAreaWidget()
              : isWeb
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ADDRESS DETAILS", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5)),
                  const SizedBox(height: 16),
                  Text("Door / Flat Number", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _doorNumberController,
                    decoration: InputDecoration(
                      hintText: "e.g., 12A, Flat 301",
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Text(StFa, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _streetNameController,
                    decoration: InputDecoration(
                      hintText: "e.g., Main Street, Palm Gardens",
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  Text("SAVE ADDRESS AS", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildLabelChip('Home', Icons.home)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildLabelChip('Work', Icons.work)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildLabelChip('Other', Icons.category)),
                    ],
                  ),
                  if (_selectedLabel == 'Other') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customLabelController,
                      decoration: InputDecoration(
                        hintText: "Enter custom label",
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.label, size: 20, color: Colors.grey[600]),
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bgColorPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text("SAVE ADDRESS", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          )
              : Column(
            children: [
              SizedBox(
                height: mapHeight,
                width: maxMapWidth,
                child: Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: _initialCameraPosition,
                      markers: _markers,
                      onTap: _onTapMap,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      minMaxZoomPreference: const MinMaxZoomPreference(10, 18),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(
                            _addressController.text.isNotEmpty ? _addressController.text : "Tap on map to select location",
                            style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Column(
                        children: [
                          FloatingActionButton.small(
                            onPressed: _getCurrentLocation,
                            backgroundColor: Colors.white,
                            elevation: 2,
                            child: const Icon(Icons.my_location, color: bgColorPink, size: 20),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            onPressed: () {
                              if (_selectedLatLn != null) {
                                _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_selectedLatLn!, 18));
                              }
                            },
                            backgroundColor: Colors.white,
                            elevation: 2,
                            child: const Icon(Icons.zoom_in, color: bgColorPink, size: 20),
                          ),
                        ],
                      ),
                    ),
                    if (_isGeocoding)
                      const Positioned.fill(
                        child: Center(child: CircularProgressIndicator(color: Colors.pink, strokeWidth: 2.5)),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ADDRESS DETAILS", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5)),
                        const SizedBox(height: 16),
                        Text("Door / Flat Number", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _doorNumberController,
                          decoration: InputDecoration(
                            hintText: "e.g., 12A, Flat 301",
                            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        Text("Street Name / Society", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[800])),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _streetNameController,
                          decoration: InputDecoration(
                            hintText: "e.g., Main Street, Palm Gardens",
                            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 20),
                        Text("SAVE ADDRESS AS", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildLabelChip('Home', Icons.home)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildLabelChip('Work', Icons.work)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildLabelChip('Other', Icons.category)),
                          ],
                        ),
                        if (_selectedLabel == 'Other') ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _customLabelController,
                            decoration: InputDecoration(
                              hintText: "Enter custom label",
                              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bgColorPink, width: 1.5)),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.label, size: 20, color: Colors.grey[600]),
                            ),
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveAddress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bgColorPink,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text("SAVE ADDRESS", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SearchLocationPage extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const SearchLocationPage({super.key, required this.onLocationSelected});

  @override
  State<SearchLocationPage> createState() => _SearchLocationPageState();
}

class _SearchLocationPageState extends State<SearchLocationPage> {
  final TextEditingController _searchController = TextEditingController();
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: "AIzaSyBfhmWG0O5LmNO1I9v0P_hsbkA11kyeBXc");
  List<Prediction> _placePredictions = [];
  String? _currentSearchInput;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getPlaceSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _placePredictions = [];
        _currentSearchInput = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _currentSearchInput = input;
    });

    final response = await _places.autocomplete(input, components: [Component(Component.country, "in")]);

    if (response.status == "OK" && _currentSearchInput == input) {
      setState(() {
        _placePredictions = response.predictions.where((prediction) {
          return prediction.description!.toLowerCase().contains("coimbatore") &&
              prediction.description!.toLowerCase().contains("tamil nadu");
        }).toList();
      });
    } else if (response.status == "ZERO_RESULTS" && _currentSearchInput == input) {
      setState(() {
        _placePredictions = [];
      });
    } else if (response.status != "OK" && _currentSearchInput == input) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching suggestions: ${response.errorMessage}")),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectPlaceFromSuggestion(Prediction prediction) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final detailsResponse = await _places.getDetailsByPlaceId(prediction.placeId!);

      if (detailsResponse.status == "OK") {
        final location = detailsResponse.result.geometry!.location;
        final latLng = LatLng(location.lat, location.lng);

        if (latLng.latitude >= coimbatoreMinLat &&
            latLng.latitude <= coimbatoreMaxLat &&
            latLng.longitude >= coimbatoreMinLng &&
            latLng.longitude <= coimbatoreMaxLng) {
          if (mounted) {
            widget.onLocationSelected(latLng);
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Selected place is outside Coimbatore, Tamil Nadu.")),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to get details: ${detailsResponse.errorMessage}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error selecting place: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Search Location",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.3),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: bgColorPink,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = isWeb ? constraints.maxWidth * 0.6 : constraints.maxWidth;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: maxWidth,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Search for a location in Coimbatore...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () async {
                          if (_searchController.text.isNotEmpty) {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              List<geocoding.Location> locations =
                              await geocoding.locationFromAddress(_searchController.text);
                              if (locations.isNotEmpty) {
                                final location = locations.first;
                                final latLng = LatLng(location.latitude, location.longitude);
                                if (latLng.latitude >= coimbatoreMinLat &&
                                    latLng.latitude <= coimbatoreMaxLat &&
                                    latLng.longitude >= coimbatoreMinLng &&
                                    latLng.longitude <= coimbatoreMaxLng) {
                                  if (mounted) {
                                    widget.onLocationSelected(latLng);
                                    Navigator.pop(context);
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Search result outside Coimbatore, Tamil Nadu.")),
                                    );
                                  }
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("No locations found for this address")),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error searching: $e")),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          }
                        },
                      ),
                    ),
                    onChanged: _getPlaceSuggestions,
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  if (_placePredictions.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _placePredictions.length,
                        itemBuilder: (context, index) {
                          final prediction = _placePredictions[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(prediction.description!),
                            onTap: () => _selectPlaceFromSuggestion(prediction),
                          );
                        },
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
}