import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/location_model.dart';
import '../../../../config/env.dart';

class MapLocationPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapLocationPicker({
    super.key,
    this.initialLatitude = 30.0444, // Default to Cairo
    this.initialLongitude = 31.2357,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  Set<Marker> _markers = {};
  bool _isLoading = false;
  final bool _locationPermissionDenied = false;
  
  // Search variables
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  final String _apiKey = AppConfig.googleMapsApiKey;
  
  // Focus node to handle keyboard interactions
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _selectedPosition = LatLng(
      widget.initialLatitude ?? 30.0444, // Default to Cairo
      widget.initialLongitude ?? 31.2357,
    );
    _setMarker(_selectedPosition!);
    
    _searchFocusNode.addListener(() {
      setState(() {
        _showSearchResults = _searchFocusNode.hasFocus && _searchResults.isNotEmpty;
      });
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
          onDragEnd: (newPosition) {
            setState(() {
              _selectedPosition = newPosition;
            });
          },
        ),
      };
    });
  }

  // Clean region name to match dropdown options
  String _normalizeRegionName(String? regionName) {
    if (regionName == null) return '';
    
    // List of mappings for region names
    final Map<String, String> regionMappings = {
      'cairo governorate': 'Cairo',
      'giza governorate': 'Giza',
      'alexandria governorate': 'Alexandria',
    };
    
    // Normalize by removing "Governorate" and matching to known regions
    String normalized = regionName.toLowerCase();
    
    // Try direct mapping first
    if (regionMappings.containsKey(normalized)) {
      return regionMappings[normalized]!;
    }
    
    // Try to match substring of known regions
    for (var entry in regionMappings.entries) {
      if (normalized.contains(entry.key.split(' ')[0])) { // Match first word
        return entry.value;
      }
    }
    
    // If Cairo/Giza/Alexandria is in the string, use that
    if (normalized.contains('cairo')) return 'Cairo';
    if (normalized.contains('giza')) return 'Giza';
    if (normalized.contains('alexandria') || normalized.contains('alex')) return 'Alexandria';
    
    // Return original if no match found
    return regionName;
  }

  // Search for places using Google Places API
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
          'input=$query&key=$_apiKey&language=en'
          '&components=country:eg' // Limit to Egypt
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['predictions'];
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
          
          // Update selected position and move camera
          setState(() {
            _selectedPosition = latLng;
            _setMarker(latLng);
          });
          
          _mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 15),
          ));
          
          // Update search box with formatted address if available
          if (data['result']['formatted_address'] != null) {
            _searchController.text = data['result']['formatted_address'];
          }
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
        
        // Extract location details
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

        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          formattedAddress: formattedAddress,
          country: country,
          city: city,
          region: region, // Use normalized region name
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent keyboard from pushing up content
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition ?? const LatLng(30.0444, 31.2357),
              zoom: 14,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (position) {
              setState(() {
                _selectedPosition = position;
                _setMarker(position);
                _showSearchResults = false;
                _searchFocusNode.unfocus();
              });
            },
            // Disable myLocationEnabled to prevent errors about missing permissions
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: true,
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            
          // Location permission message if needed
          if (_locationPermissionDenied)
            Positioned(
              top: 16, 
              left: 16, 
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Location permissions not granted. You can still select a location manually.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          // Custom map search bar
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search for a location',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    onChanged: (value) {
                      if (value.length > 2) { // Start search after 2 characters
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
                    margin: const EdgeInsets.only(top: 4),
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _isSearching
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _searchResults.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No results found'),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final result = _searchResults[index];
                                  return ListTile(
                                    dense: true,
                                    title: Text(result['description'] ?? 'Unknown location'),
                                    onTap: () {
                                      _getPlaceDetails(result['place_id']);
                                    },
                                  );
                                },
                              ),
                  ),
              ],
            ),
          ),
          
          // Confirm button at the bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              child: const Text(
                'Confirm Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}