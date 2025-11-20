import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/location_model.dart';

// Theme colors
const Color _primaryOrange = Color(0xfff29620);
const Color _white = Colors.white;
const Color _lightGrey = Color(0xFFF5F5F5);
const Color _darkGrey = Color(0xFF757575);

class MapLocationPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapLocationPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  Set<Marker> _markers = {};
  bool _isLoading = false;
  String? _mapError;
  String? _currentAddress;
  
  // Search variables
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  final String _apiKey = 'AIzaSyBg4oV-yrhIkatEh2fVvzOXmFaDmJ-h7Aw';
  
  // Focus node to handle keyboard interactions
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchResults = false;

  // Default location: Cairo, Egypt
  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357);
  static const double _defaultZoom = 14.0;

  @override
  void initState() {
    super.initState();
    // Set initial position - use provided coordinates or default to Cairo, Egypt
    _selectedPosition = widget.initialLatitude != null && widget.initialLongitude != null
        ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
        : _defaultLocation;
    
    _setMarker(_selectedPosition!);
    _loadAddressForPosition(_selectedPosition!);
    
    _searchFocusNode.addListener(() {
      setState(() {
        _showSearchResults = _searchFocusNode.hasFocus && _searchResults.isNotEmpty;
      });
    });
    
    _searchController.addListener(() {
      setState(() {}); // Rebuild to show/hide clear button
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _setMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selectedLocation'),
          position: position,
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onDragEnd: (newPosition) {
            setState(() {
              _selectedPosition = newPosition;
              _setMarker(newPosition);
            });
            _loadAddressForPosition(newPosition);
          },
        ),
      };
    });
  }

  // Load address for a given position
  Future<void> _loadAddressForPosition(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String formattedAddress = [
          place.thoroughfare,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((component) => component != null && component.isNotEmpty).join(', ');
        
        setState(() {
          _currentAddress = formattedAddress;
        });
      }
    } catch (e) {
      debugPrint('Error loading address: $e');
    }
  }

  // Normalize region name to match dropdown options
  String _normalizeRegionName(String? regionName) {
    if (regionName == null) return '';
    
    final Map<String, String> regionMappings = {
      'cairo governorate': 'Cairo',
      'giza governorate': 'Giza',
      'alexandria governorate': 'Alexandria',
    };
    
    String normalized = regionName.toLowerCase();
    
    if (regionMappings.containsKey(normalized)) {
      return regionMappings[normalized]!;
    }
    
    for (var entry in regionMappings.entries) {
      if (normalized.contains(entry.key.split(' ')[0])) {
        return entry.value;
      }
    }
    
    if (normalized.contains('cairo')) return 'Cairo';
    if (normalized.contains('giza')) return 'Giza';
    if (normalized.contains('alexandria') || normalized.contains('alex')) return 'Alexandria';
    
    return regionName;
  }

  // Get current GPS location
  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Permission.location.request();
      if (permission.isDenied || permission.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission is required'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      bool serviceEnabled = false;
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } catch (e) {
        debugPrint('Geolocator not available: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services not available. Please restart the app.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable location services'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _isLoading = true;
      });

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _selectedPosition = latLng;
        _setMarker(latLng);
      });
      
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 16),
        ),
      );
      
      await _loadAddressForPosition(latLng);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location updated'),
            backgroundColor: _primaryOrange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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

  // Search for places using Google Places API (limited to Egypt)
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
          'input=${Uri.encodeComponent(query)}&key=$_apiKey&language=en'
          '&components=country:eg' // Limit to Egypt
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['predictions'] ?? [];
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('Error searching places: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  // Get details for a selected place
  Future<void> _getPlaceDetails(String placeId) async {
    setState(() {
      _isLoading = true;
      _showSearchResults = false;
      _searchFocusNode.unfocus();
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?'
          'place_id=$placeId&key=$_apiKey&language=en&fields=geometry,formatted_address'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] != null && data['result']['geometry'] != null) {
          final location = data['result']['geometry']['location'];
          final latLng = LatLng(location['lat'], location['lng']);
          
          setState(() {
            _selectedPosition = latLng;
            _setMarker(latLng);
            if (data['result']['formatted_address'] != null) {
              _currentAddress = data['result']['formatted_address'];
              _searchController.text = data['result']['formatted_address'];
            }
          });
          
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: latLng, zoom: 16),
            ),
          );
          
          await _loadAddressForPosition(latLng);
        }
      }
    } catch (e) {
      debugPrint('Error getting place details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get address from coordinates
  Future<LocationData?> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        String? country = place.country;
        String? rawRegion = place.administrativeArea;
        String region = _normalizeRegionName(rawRegion);
        
        String? zone = place.subAdministrativeArea;
        String? city = place.locality;
        String? district = place.subLocality;
        String? street = place.thoroughfare;
        
        // Format a readable address
        String formattedAddress = [
          street,
          district,
          city,
          rawRegion,
          country,
        ].where((component) => component != null && component.isNotEmpty).join(', ');

        // Format address details (street-level address for the form)
        String addressDetails = [
          street,
          district,
          city,
        ].where((component) => component != null && component.isNotEmpty).join(', ');
        
        // If no street-level details, use formatted address as fallback
        if (addressDetails.isEmpty) {
          addressDetails = formattedAddress.isNotEmpty ? formattedAddress : 'Selected location';
        }

        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          formattedAddress: formattedAddress,
          addressDetails: addressDetails,
          country: country,
          city: city,
          region: region,
          zone: zone ?? district,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting address: $e');
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Move camera to default location
  void _moveToDefaultLocation() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _defaultLocation,
            zoom: _defaultZoom,
          ),
        ),
      );
      setState(() {
        _selectedPosition = _defaultLocation;
        _setMarker(_defaultLocation);
      });
      _loadAddressForPosition(_defaultLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _white,
      appBar: AppBar(
        title: const Text(
          'Select Location',
          style: TextStyle(
            color: _white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _primaryOrange,
        elevation: 0,
        iconTheme: const IconThemeData(color: _white),
        actions: [
          // Current location button
          IconButton(
            icon: const Icon(Icons.my_location, color: _white),
            tooltip: 'Get Current Location',
            onPressed: _isLoading ? null : _getCurrentLocation,
          ),
          // Reset to default location
          IconButton(
            icon: const Icon(Icons.home, color: _white),
            tooltip: 'Center on Cairo',
            onPressed: _isLoading ? null : _moveToDefaultLocation,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          debugPrint('🗺️ MapLocationPicker building with size: ${constraints.maxWidth}x${constraints.maxHeight}');
          return Stack(
            fit: StackFit.expand,
        children: [
              // Google Map - fills entire screen - MUST be first in stack (bottom layer)
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                color: _lightGrey, // Background color while map loads
                child: RepaintBoundary(
                  child: GoogleMap(
                    key: const ValueKey('google_map_widget'),
            initialCameraPosition: CameraPosition(
                      target: _defaultLocation,
                      zoom: _defaultZoom,
            ),
            markers: _markers,
                    onMapCreated: (controller) async {
                debugPrint('🗺️ GoogleMap onMapCreated called');
              _mapController = controller;
                setState(() {
                  _mapError = null;
                });
                
                // Move to initial position if provided
                if (widget.initialLatitude != null && widget.initialLongitude != null) {
                  final initialPos = LatLng(widget.initialLatitude!, widget.initialLongitude!);
                  await controller.animateCamera(
                    CameraUpdate.newLatLngZoom(initialPos, _defaultZoom),
                  );
                  setState(() {
                    _selectedPosition = initialPos;
                    _setMarker(initialPos);
                  });
                  _loadAddressForPosition(initialPos);
                } else {
                  setState(() {
                    _selectedPosition = _defaultLocation;
                    _setMarker(_defaultLocation);
                  });
                  _loadAddressForPosition(_defaultLocation);
                }
                
                debugPrint('✅ Google Map initialized successfully');
            },
            onTap: (position) {
                debugPrint('🗺️ Map tapped at: $position');
              setState(() {
                _selectedPosition = position;
                _setMarker(position);
                _showSearchResults = false;
                _searchFocusNode.unfocus();
              });
                _loadAddressForPosition(position);
            },
              myLocationEnabled: true,
            myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              mapType: MapType.normal,
              compassEnabled: true,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: true,
              zoomGesturesEnabled: true,
                  minMaxZoomPreference: const MinMaxZoomPreference(5, 20),
                  buildingsEnabled: true,
                  trafficEnabled: false,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                ),
              ),
            ),
            
            // Error message overlay
          if (_mapError != null)
            Positioned.fill(
              child: Container(
                color: _white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Map failed to load',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _darkGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                          _mapError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: _darkGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _mapError = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryOrange,
                          foregroundColor: _white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryOrange),
                      ),
                ),
              ),
            ),
            
          // Search bar at the top
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search for a location...',
                      hintStyle: const TextStyle(color: _darkGrey),
                      prefixIcon: const Icon(Icons.search, color: _primaryOrange),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20, color: _darkGrey),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchResults = [];
                                  _showSearchResults = false;
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Rebuild to show/hide clear button
                      if (value.length > 2) {
                        _searchPlaces(value);
                      } else if (value.isEmpty) {
                        setState(() {
                          _searchResults = [];
                          _showSearchResults = false;
                        });
                      }
                    },
                  ),
                ),
                
                // Search results dropdown
                if (_showSearchResults)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: _white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isSearching
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(_primaryOrange),
                              ),
                            ),
                          )
                        : _searchResults.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No results found',
                                  style: TextStyle(color: _darkGrey),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final result = _searchResults[index];
                                  return InkWell(
                                    onTap: () => _getPlaceDetails(result['place_id']),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: _lightGrey,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.place, size: 20, color: _primaryOrange),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              result['description'] ?? 'Unknown location',
                                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
              ],
            ),
          ),
          
          // Address display card
          if (_currentAddress != null && !_showSearchResults)
          Positioned(
              top: 100,
            left: 16,
            right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: _primaryOrange, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentAddress!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Confirm button at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: _white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryOrange,
                    foregroundColor: _white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
              ),
              onPressed: _selectedPosition == null || _isLoading
                  ? null
                  : () async {
                      if (_selectedPosition != null) {
                        LocationData? locationData = await _getAddressFromLatLng(_selectedPosition!);
                        if (!mounted) return;
                        Navigator.pop(context, locationData);
                      }
                    },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                'Confirm Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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

