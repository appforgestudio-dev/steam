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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final modalRoute = ModalRoute.of(context);
      if (modalRoute != null && modalRoute.animation != null) {
        if (modalRoute.animation!.isCompleted) {
          _initializePageData();
        } else {
          modalRoute.animation!.addStatusListener((status) {
            if (status == AnimationStatus.completed && mounted) {
              _initializePageData();
            }
          });
        }
      } else {
        _initializePageData();
      }
    });
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
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          await _getCurrentLocation();
        }
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

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      if (!_isWithinCoimbatore(currentLatLng)) {
        _showSnackBar("Current location is outside Coimbatore. Defaulting to Coimbatore.", isError: true);
        _setMarker(_initialCameraPosition.target);
        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_initialCameraPosition.target, 15),
          );
        }
        await _getAddressFromLatLng(_initialCameraPosition.target);
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
      'latitude': _selectedLatLn!.latitude,
      'longitude': _selectedLatLn!.longitude,
      'label': finalLabel,
      'latitude':     _selectedLatLn!.latitude,
      'longitude':    _selectedLatLn!.longitude,
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? bgColorPink.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? bgColorPink : Colors.grey.shade200,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: bgColorPink.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? bgColorPink : Colors.grey[500],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? bgColorPink : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText, IconData prefixIcon) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      prefixIcon: Icon(prefixIcon, color: Colors.grey[400], size: 20),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: bgColorPink, width: 1.5),
      ),
    );
  }

  Widget _buildAddressHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColorPink.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: bgColorPink, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selected Location",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[500], letterSpacing: 0.6),
                ),
                const SizedBox(height: 4),
                Text(
                  _addressController.text.isNotEmpty ? _addressController.text : "Tap on map to select location",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingMapControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'my_location_btn',
          onPressed: _getCurrentLocation,
          backgroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.my_location, color: bgColorPink, size: 22),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'zoom_in_btn',
          onPressed: () {
            if (_selectedLatLn != null) {
              _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_selectedLatLn!, 18));
            }
          },
          backgroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.zoom_in, color: bgColorPink, size: 22),
        ),
      ],
    );
  }

  Widget _buildForm(String streetHint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "DELIVERY ADDRESS DETAILS",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey[600],
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 20),
        
        Text(
          "Door / Flat Number",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _doorNumberController,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: _buildInputDecoration("e.g., 12A, Flat 301", Icons.meeting_room_outlined),
        ),
        const SizedBox(height: 20),

        Text(
          "Street Name / Society",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _streetNameController,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: _buildInputDecoration(streetHint, Icons.add_location_outlined),
        ),
        const SizedBox(height: 24),

        Text(
          "SAVE ADDRESS AS",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey[600],
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildLabelChip('Home', Icons.home_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _buildLabelChip('Work', Icons.work_outline)),
            const SizedBox(width: 10),
            Expanded(child: _buildLabelChip('Other', Icons.category_outlined)),
          ],
        ),
        if (_selectedLabel == 'Other') ...[
          const SizedBox(height: 16),
          TextField(
            controller: _customLabelController,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: _buildInputDecoration("Enter custom label", Icons.label_outline),
          ),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColorPink,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              shadowColor: Colors.transparent,
            ),
            child: const Text(
              "SAVE ADDRESS",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width >= 1000 || kIsWeb;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Title(
      title: 'V12 Laundry | Add Delivery Address',
      color: bgColorPink,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "Add Delivery Address",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.3),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, size: 20),
          ),
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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            String StFa = isWeb ? "Address (Street Name / Society, Area,)" : "Street Name / Society";
            return _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.pink, strokeWidth: 2.5))
                : _isOutsideServiceArea
                    ? _buildOutsideAreaWidget()
                    : isWeb
                        ? Row(
                            children: [
                              Expanded(
                                flex: 11,
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
                                      top: 24,
                                      left: 24,
                                      right: 24,
                                      child: _buildAddressHeaderCard(),
                                    ),
                                    Positioned(
                                      bottom: 24,
                                      right: 24,
                                      child: _buildFloatingMapControls(),
                                    ),
                                    if (_isGeocoding)
                                      const Positioned.fill(
                                        child: Center(child: CircularProgressIndicator(color: Colors.pink, strokeWidth: 2.5)),
                                      ),
                                  ],
                                ),
                              ),
                              Container(width: 1, color: Colors.grey.shade200),
                              Expanded(
                                flex: 9,
                                child: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: _buildForm(StFa),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                flex: 9,
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
                                      child: _buildAddressHeaderCard(),
                                    ),
                                    Positioned(
                                      bottom: 16,
                                      right: 16,
                                      child: _buildFloatingMapControls(),
                                    ),
                                    if (_isGeocoding)
                                      const Positioned.fill(
                                        child: Center(child: CircularProgressIndicator(color: Colors.pink, strokeWidth: 2.5)),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 11,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 16,
                                        offset: const Offset(0, -4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                                      child: _buildForm(StFa),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
          },
        ),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Search Location",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 0.3),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        elevation: 0,
        backgroundColor: bgColorPink,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = isWeb ? 600 : constraints.maxWidth;

          return Center(
            child: Container(
              width: maxWidth,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Search for location in Coimbatore...",
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: bgColorPink, size: 22),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey[400], size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _getPlaceSuggestions("");
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      ),
                      onChanged: _getPlaceSuggestions,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(color: bgColorPink, strokeWidth: 2.5),
                      ),
                    ),
                  if (_placePredictions.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _placePredictions.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final prediction = _placePredictions[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: bgColorPink.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.location_on_outlined, color: bgColorPink, size: 20),
                              ),
                              title: Text(
                                prediction.description!,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                              ),
                              onTap: () => _selectPlaceFromSuggestion(prediction),
                            ),
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
