import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/user_service.dart' show PickUpAddressItem, userDataProvider;
import '../providers/order_providers.dart';
import '../../../../core/widgets/toast_.dart' show ToastService, ToastType;

class PickupAddressSelectorWidget extends ConsumerWidget {
  const PickupAddressSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(userDataProvider);
    final order = ref.watch(orderModelProvider);
    final selectedAddressId = order.selectedPickupAddressId;

    return userDataAsync.when(
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        // Get pickup addresses - prefer pickUpAddresses array, fallback to single pickUpAddress
        List<PickUpAddressItem> addresses = [];
        
        if (user.pickUpAddresses != null && user.pickUpAddresses!.isNotEmpty) {
          addresses = user.pickUpAddresses!;
        } else {
          // Convert single pickUpAddress to PickUpAddressItem format
          addresses = [
            PickUpAddressItem(
              addressId: 'default',
              addressName: 'Main Address',
              isDefault: true,
              country: user.pickUpAddress.country,
              city: user.pickUpAddress.city,
              adressDetails: user.pickUpAddress.addressDetails,
              nearbyLandmark: user.pickUpAddress.nearbyLandmark,
              pickupPhone: user.pickUpAddress.pickupPhone,
              pickUpPointInMaps: user.pickUpAddress.pickUpPointInMaps,
              coordinates: user.pickUpAddress.coordinates,
            ),
          ];
        }

        if (addresses.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No pickup addresses found. Please add an address in your profile.',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Auto-select default address if none selected
        String? addressIdToSelect = selectedAddressId;
        if (addressIdToSelect == null && addresses.isNotEmpty) {
          final defaultAddress = addresses.firstWhere(
            (addr) => addr.isDefault == true,
            orElse: () => addresses.first,
          );
          addressIdToSelect = defaultAddress.addressId;
          // Set it in the order model
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(orderModelProvider.notifier).updatePickupAddress(addressIdToSelect);
          });
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.orange.shade300, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Select Pickup Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...addresses.map((address) {
                final isSelected = address.addressId == addressIdToSelect;
                return _buildAddressCard(
                  context,
                  address,
                  isSelected,
                  () {
                    ref.read(orderModelProvider.notifier).updatePickupAddress(address.addressId);
                  },
                );
              }),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error loading pickup addresses: $error',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    PickUpAddressItem address,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.orange.shade300 : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: isSelected ? Colors.orange.shade700 : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address.addressName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.orange.shade900 : Colors.grey.shade800,
                            ),
                          ),
                        ),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                address.adressDetails,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              if (address.zone != null && address.zone!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '${address.city}, ${address.zone}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              if (address.nearbyLandmark != null && address.nearbyLandmark!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.place, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      address.nearbyLandmark!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    address.pickupPhone,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (address.pickUpPointInMaps.isNotEmpty) ...[
                    const Spacer(),
                    InkWell(
                      onTap: () async {
                        try {
                          // Extract coordinates
                          final coords = address.coordinates;
                          double? lat;
                          double? lng;
                          
                          if (coords != null && coords['lat'] != null && coords['lng'] != null) {
                            lat = coords['lat'] is double ? coords['lat'] : (coords['lat'] as num).toDouble();
                            lng = coords['lng'] is double ? coords['lng'] : (coords['lng'] as num).toDouble();
                          }
                          
                          // Build Google Maps URL
                          String mapsUrl;
                          if (lat != null && lng != null) {
                            // Use Google Maps URL format that specifically opens Google Maps app
                            if (Platform.isAndroid) {
                              // Android: Try Google Maps app first with geo: scheme
                              // If that fails, fallback to https URL
                              try {
                                final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
                                if (await canLaunchUrl(geoUrl)) {
                                  await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
                                  return; // Successfully opened, exit early
                                }
                              } catch (e) {
                                // Fallback to https URL
                              }
                              // Use Google Maps search URL for Android
                              mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                            } else if (Platform.isIOS) {
                              // iOS: Use Google Maps URL scheme
                              mapsUrl = 'https://maps.google.com/?q=$lat,$lng';
                            } else {
                              // Web/Other: Use standard Google Maps URL
                              mapsUrl = 'https://www.google.com/maps?q=$lat,$lng';
                            }
                          } else {
                            // Fallback to the stored URL
                            mapsUrl = address.pickUpPointInMaps;
                            // Ensure it's a proper Google Maps URL
                            if (!mapsUrl.contains('google.com/maps') && !mapsUrl.contains('maps.google.com')) {
                              mapsUrl = 'https://www.google.com/maps?q=$mapsUrl';
                            }
                          }
                          
                          final url = Uri.parse(mapsUrl);
                          
                          // Launch URL - use externalApplication to open in browser/app
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            ToastService.show(
                              context,
                              'Could not open Google Maps',
                              type: ToastType.error,
                            );
                          }
                        } catch (e) {
                          ToastService.show(
                            context,
                            'Could not open map: ${e.toString()}',
                            type: ToastType.error,
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.map, size: 14, color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'View on Map',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

