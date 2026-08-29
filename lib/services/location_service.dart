import 'dart:developer';
import 'package:dio/dio.dart';

/// Location suggestion item for city, state, country autocomplete.
class LocationSuggestion {
  final String name;
  final String city;
  final String state;
  final String country;
  final String? postcode;

  LocationSuggestion({
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    this.postcode,
  });

  String get displayName {
    final parts = <String>[];
    if (city.isNotEmpty) {
      parts.add(city);
    } else if (name.isNotEmpty) {
      parts.add(name);
    }
    if (state.isNotEmpty) parts.add(state);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    final p = json['properties'] as Map<String, dynamic>? ?? {};

    final name = p['name']?.toString() ?? '';
    final city = p['city']?.toString() ??
        p['town']?.toString() ??
        p['village']?.toString() ??
        p['county']?.toString() ??
        name;
    final state = p['state']?.toString() ?? p['region']?.toString() ?? '';
    final country = p['country']?.toString() ?? 'India';
    final postcode = p['postcode']?.toString();

    return LocationSuggestion(
      name: name,
      city: city,
      state: state,
      country: country,
      postcode: postcode,
    );
  }
}

/// Service to query location autocomplete API (Photon/OpenStreetMap).
class LocationService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'CargoSetuApp/1.0',
      },
    ),
  );

  /// Search locations/cities matching [query]
  static Future<List<LocationSuggestion>> searchLocations(String query) async {
    if (query.trim().length < 2) return [];

    try {
      final response = await _dio.get(
        'https://photon.komoot.io/api/',
        queryParameters: {
          'q': query.trim(),
          'limit': 8,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final features = data['features'] as List? ?? [];

        return features
            .map((f) =>
                LocationSuggestion.fromJson(f as Map<String, dynamic>))
            .where((item) =>
                item.city.isNotEmpty ||
                item.name.isNotEmpty ||
                item.state.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      log('⚠️ Location autocomplete error: $e');
      return [];
    }
  }
}
