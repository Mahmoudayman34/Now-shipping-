import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';

class RegionData {
  final String governorate;
  final String area;

  RegionData({
    required this.governorate,
    required this.area,
  });

  factory RegionData.fromJson(Map<String, dynamic> json) {
    return RegionData(
      governorate: json['governorate'] as String,
      area: json['area'] as String,
    );
  }
}

class RegionsService {
  static List<RegionData>? _cachedRegions;
  static String? _cachedLocale;

  /// Load regions from JSON file based on locale
  static Future<List<RegionData>> loadRegions(String locale) async {
    // Return cached data if locale hasn't changed
    if (_cachedRegions != null && _cachedLocale == locale) {
      return _cachedRegions!;
    }

    try {
      final String jsonString;
      if (locale == 'ar') {
        jsonString = await rootBundle.loadString('assets/regions/bosta_regionsAR.json');
      } else {
        jsonString = await rootBundle.loadString('assets/regions/bosta_regionsENG.json');
      }

      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final regions = jsonList
          .map((json) => RegionData.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache the data
      _cachedRegions = regions;
      _cachedLocale = locale;

      return regions;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading regions: $e');
      }
      return [];
    }
  }

  /// Get zones (areas) for a specific governorate
  static Future<List<String>> getZonesForGovernorate(String governorate, String locale) async {
    final regions = await loadRegions(locale);
    
    // Normalize governorate name for matching
    final normalizedGovernorate = governorate.trim();
    
    final zones = regions
        .where((region) => 
            region.governorate.trim().toLowerCase() == normalizedGovernorate.toLowerCase())
        .map((region) => region.area)
        .toSet() // Remove duplicates
        .toList();
    
    // Sort alphabetically
    zones.sort();
    
    return zones;
  }

  /// Get all available governorates
  static Future<List<String>> getGovernorates(String locale) async {
    final regions = await loadRegions(locale);
    
    final governorates = regions
        .map((region) => region.governorate)
        .toSet() // Remove duplicates
        .toList();
    
    // Sort alphabetically
    governorates.sort();
    
    return governorates;
  }

  /// Clear cache (useful when locale changes)
  static void clearCache() {
    _cachedRegions = null;
    _cachedLocale = null;
  }
}

/// Provider to get zones for a governorate based on current locale
final zonesForGovernorateProvider = FutureProvider.family<List<String>, String>((ref, governorate) async {
  final locale = ref.watch(localeProvider);
  return RegionsService.getZonesForGovernorate(governorate, locale.languageCode);
});

/// Provider to get all governorates based on current locale
final governoratesProvider = FutureProvider<List<String>>((ref) async {
  final locale = ref.watch(localeProvider);
  return RegionsService.getGovernorates(locale.languageCode);
});

