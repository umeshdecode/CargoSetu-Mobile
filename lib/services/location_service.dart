import 'dart:developer';
import 'dart:math' as math;
import 'package:dio/dio.dart';

/// Location suggestion item for city, state, country autocomplete with coordinates.
class LocationSuggestion {
  final String name;
  final String city;
  final String state;
  final String country;
  final String? postcode;
  final double? latitude;
  final double? longitude;
  final String? _customDisplayName;

  const LocationSuggestion({
    String? name,
    required this.city,
    required this.state,
    required this.country,
    this.postcode,
    this.latitude,
    this.longitude,
    String? displayName,
  }) : name = name ?? city,
       _customDisplayName = displayName;

  String get canonicalCity =>
      city.trim().isNotEmpty ? city.trim() : name.trim();

  String get displayName {
    if (_customDisplayName != null && _customDisplayName.trim().isNotEmpty) {
      return _customDisplayName;
    }
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

  String get cityStateDisplay {
    final c = canonicalCity;
    if (state.trim().isNotEmpty &&
        c.toLowerCase() != state.trim().toLowerCase()) {
      return '$c, ${state.trim()}';
    }
    return c;
  }

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    final p = json['properties'] as Map<String, dynamic>? ?? {};
    final geom = json['geometry'] as Map<String, dynamic>?;
    final coords = geom?['coordinates'] as List?;

    double? lon;
    double? lat;
    if (coords != null && coords.length >= 2) {
      lon = (coords[0] as num?)?.toDouble();
      lat = (coords[1] as num?)?.toDouble();
    }

    final name = p['name']?.toString() ?? '';
    final city =
        p['city']?.toString() ??
        p['town']?.toString() ??
        p['village']?.toString() ??
        p['county']?.toString() ??
        name;
    final state = p['state']?.toString() ?? p['region']?.toString() ?? '';
    final country = p['country']?.toString() ?? 'India';
    final postcode = p['postcode']?.toString();

    final fallback = (lat == null || lon == null)
        ? LocationService.resolveCityCoordinates(city.isNotEmpty ? city : name)
        : null;

    return LocationSuggestion(
      name: name,
      city: city,
      state: state,
      country: country,
      postcode: postcode,
      latitude: lat ?? fallback?.$1,
      longitude: lon ?? fallback?.$2,
    );
  }
}

/// Service to query location autocomplete API (Photon/OpenStreetMap) and compute route distances.
class LocationService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Accept': 'application/json', 'User-Agent': 'CargoSetuApp/1.0'},
    ),
  );

  static final Map<String, List<LocationSuggestion>> _searchCache = {};

  static const Map<String, (double, double, String)> _knownIndianCities = {
    'mumbai': (19.0760, 72.8777, 'Maharashtra'),
    'navi mumbai': (19.0330, 73.0297, 'Maharashtra'),
    'thane': (19.2183, 72.9781, 'Maharashtra'),
    'bhiwandi': (19.2813, 73.0483, 'Maharashtra'),
    'pune': (18.5204, 73.8567, 'Maharashtra'),
    'nagpur': (21.1458, 79.0882, 'Maharashtra'),
    'nashik': (19.9975, 73.7898, 'Maharashtra'),
    'aurangabad': (19.8762, 75.3433, 'Maharashtra'),
    'solapur': (17.6599, 75.9064, 'Maharashtra'),
    'kolhapur': (16.7050, 74.2433, 'Maharashtra'),
    'delhi': (28.6139, 77.2090, 'Delhi'),
    'new delhi': (28.6139, 77.2090, 'Delhi'),
    'gurgaon': (28.4595, 77.0266, 'Haryana'),
    'gurugram': (28.4595, 77.0266, 'Haryana'),
    'noida': (28.5355, 77.3910, 'Uttar Pradesh'),
    'faridabad': (28.4089, 77.3178, 'Haryana'),
    'ghaziabad': (28.6692, 77.4538, 'Uttar Pradesh'),
    'ahmedabad': (23.0225, 72.5714, 'Gujarat'),
    'surat': (21.1702, 72.8311, 'Gujarat'),
    'vadodara': (22.3072, 73.1812, 'Gujarat'),
    'rajkot': (22.3039, 70.8022, 'Gujarat'),
    'vapi': (20.3893, 72.9106, 'Gujarat'),
    'bharuch': (21.7051, 72.9959, 'Gujarat'),
    'gandhidham': (23.0753, 70.1337, 'Gujarat'),
    'mundra': (22.8394, 69.7213, 'Gujarat'),
    'bengaluru': (12.9716, 77.5946, 'Karnataka'),
    'bangalore': (12.9716, 77.5946, 'Karnataka'),
    'mysuru': (12.2958, 76.6394, 'Karnataka'),
    'hubballi': (15.3647, 75.1240, 'Karnataka'),
    'mangaluru': (12.9141, 74.8560, 'Karnataka'),
    'hyderabad': (17.3850, 78.4867, 'Telangana'),
    'warangal': (17.9689, 79.5941, 'Telangana'),
    'chennai': (13.0827, 80.2707, 'Tamil Nadu'),
    'coimbatore': (11.0168, 76.9558, 'Tamil Nadu'),
    'madurai': (9.9252, 78.1198, 'Tamil Nadu'),
    'salem': (11.6643, 78.1460, 'Tamil Nadu'),
    'hosur': (12.7409, 77.8253, 'Tamil Nadu'),
    'kolkata': (22.5726, 88.3639, 'West Bengal'),
    'howrah': (22.5958, 88.2636, 'West Bengal'),
    'siliguri': (26.7271, 88.3953, 'West Bengal'),
    'jaipur': (26.9124, 75.7873, 'Rajasthan'),
    'udaipur': (24.5854, 73.7125, 'Rajasthan'),
    'jodhpur': (26.2389, 73.0243, 'Rajasthan'),
    'kota': (25.2138, 75.8648, 'Rajasthan'),
    'ajmer': (26.4499, 74.6399, 'Rajasthan'),
    'indore': (22.7196, 75.8577, 'Madhya Pradesh'),
    'bhopal': (23.2599, 77.4126, 'Madhya Pradesh'),
    'gwalior': (26.2183, 78.1828, 'Madhya Pradesh'),
    'jabalpur': (23.1815, 79.9864, 'Madhya Pradesh'),
    'lucknow': (26.8467, 80.9462, 'Uttar Pradesh'),
    'kanpur': (26.4499, 80.3319, 'Uttar Pradesh'),
    'agra': (27.1767, 78.0081, 'Uttar Pradesh'),
    'varanasi': (25.3176, 82.9739, 'Uttar Pradesh'),
    'prayagraj': (25.4358, 81.8463, 'Uttar Pradesh'),
    'meerut': (28.9845, 77.7064, 'Uttar Pradesh'),
    'chandigarh': (30.7333, 76.7794, 'Chandigarh'),
    'ludhiana': (30.9010, 75.8573, 'Punjab'),
    'amritsar': (31.6340, 74.8723, 'Punjab'),
    'jalandhar': (31.3260, 75.5762, 'Punjab'),
    'ambala': (30.3782, 76.7767, 'Haryana'),
    'panipat': (29.3909, 76.9635, 'Haryana'),
    'karnal': (29.6857, 76.9905, 'Haryana'),
    'hisar': (29.1492, 75.7217, 'Haryana'),
    'rohtak': (28.8955, 76.6066, 'Haryana'),
    'patna': (25.5941, 85.1376, 'Bihar'),
    'ranchi': (23.3441, 85.3096, 'Jharkhand'),
    'jamshedpur': (22.8046, 86.2029, 'Jharkhand'),
    'bhubaneswar': (20.2961, 85.8245, 'Odisha'),
    'cuttack': (20.4625, 85.8830, 'Odisha'),
    'raipur': (21.2514, 81.6296, 'Chhattisgarh'),
    'bilaspur': (22.0797, 82.1409, 'Chhattisgarh'),
    'visakhapatnam': (17.6868, 83.2185, 'Andhra Pradesh'),
    'vijayawada': (16.5062, 80.6480, 'Andhra Pradesh'),
    'guntur': (16.3067, 80.4365, 'Andhra Pradesh'),
    'nellore': (14.4426, 79.9865, 'Andhra Pradesh'),
    'tirupati': (13.6288, 79.4192, 'Andhra Pradesh'),
    'kochi': (9.9312, 76.2673, 'Kerala'),
    'thiruvananthapuram': (8.5241, 76.9366, 'Kerala'),
    'kozhikode': (11.2588, 75.7804, 'Kerala'),
    'guwahati': (26.1445, 91.7362, 'Assam'),
    'dehradun': (30.3165, 78.0322, 'Uttarakhand'),
    'haridwar': (29.9457, 78.1642, 'Uttarakhand'),
    'rudrapur': (28.9875, 79.4141, 'Uttarakhand'),
    'jammu': (32.7266, 74.8570, 'Jammu and Kashmir'),
    'srinagar': (34.0837, 74.7973, 'Jammu and Kashmir'),
    'goa': (15.2993, 74.1240, 'Goa'),
    'panaji': (15.4909, 73.8278, 'Goa'),
  };

  /// Resolve known city coordinates (lat, lng) if available.
  static (double, double)? resolveCityCoordinates(String? city) {
    if (city == null || city.trim().isEmpty) return null;
    final clean = city.trim().toLowerCase().split(',').first.trim();
    final exact = _knownIndianCities[clean];
    if (exact != null) return (exact.$1, exact.$2);
    for (final entry in _knownIndianCities.entries) {
      if (clean.contains(entry.key) || entry.key.contains(clean)) {
        return (entry.value.$1, entry.value.$2);
      }
    }
    return null;
  }

  /// Alias for [resolveCityCoordinates].
  static (double, double)? lookupCityCoordinates(String? city) =>
      resolveCityCoordinates(city);

  /// Offline fallback suggestions from built-in Indian cities.
  static List<LocationSuggestion> fallbackSuggestions(String query) {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return [];
    final results = <LocationSuggestion>[];
    for (final entry in _knownIndianCities.entries) {
      if (entry.key.contains(q) || entry.value.$3.toLowerCase().contains(q)) {
        final displayCity = entry.key
            .split(' ')
            .map(
              (w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}',
            )
            .join(' ');
        results.add(
          LocationSuggestion(
            name: displayCity,
            city: displayCity,
            state: entry.value.$3,
            country: 'India',
            latitude: entry.value.$1,
            longitude: entry.value.$2,
          ),
        );
        if (results.length >= 8) break;
      }
    }
    return results;
  }

  /// Search locations/cities matching [query] with in-memory caching and fallback.
  static Future<List<LocationSuggestion>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final cacheKey = trimmed.toLowerCase();
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    try {
      final response = await _dio.get(
        'https://photon.komoot.io/api/',
        queryParameters: {'q': trimmed, 'limit': 8},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final features = data['features'] as List? ?? [];

        final parsed = features
            .map((f) => LocationSuggestion.fromJson(f as Map<String, dynamic>))
            .where(
              (item) =>
                  item.city.isNotEmpty ||
                  item.name.isNotEmpty ||
                  item.state.isNotEmpty,
            )
            .toList();

        if (parsed.isNotEmpty) {
          _searchCache[cacheKey] = parsed;
          return parsed;
        }
      }
      final fallback = fallbackSuggestions(trimmed);
      if (fallback.isNotEmpty) {
        _searchCache[cacheKey] = fallback;
      }
      return fallback;
    } catch (e) {
      log('⚠️ Location autocomplete error: $e');
      return fallbackSuggestions(trimmed);
    }
  }

  /// Compute straight-line Haversine distance in kilometres between two points.
  static double? calculateDistanceKm(
    double? lat1,
    double? lng1,
    double? lat2,
    double? lng2,
  ) {
    if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) {
      return null;
    }
    const double earthRadiusKm = 6371.0088;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(math.max(0.0, 1.0 - a)));
    return ((earthRadiusKm * c) * 10).round() / 10.0;
  }

  /// Estimate distance in km using explicit coordinates or fallback city lookup.
  static double? estimateCityDistanceKm({
    double? originLat,
    double? originLng,
    String? originCity,
    double? destLat,
    double? destLng,
    String? destCity,
  }) {
    double? oLat = originLat;
    double? oLng = originLng;
    if (oLat == null || oLng == null) {
      final resolved = resolveCityCoordinates(originCity);
      if (resolved != null) {
        oLat = resolved.$1;
        oLng = resolved.$2;
      }
    }

    double? dLat = destLat;
    double? dLng = destLng;
    if (dLat == null || dLng == null) {
      final resolved = resolveCityCoordinates(destCity);
      if (resolved != null) {
        dLat = resolved.$1;
        dLng = resolved.$2;
      }
    }

    return calculateDistanceKm(oLat, oLng, dLat, dLng);
  }

  /// Format distance in km for user-facing display.
  static String formatDistanceKm(double km, {bool includeMethodLabel = false}) {
    final rounded = km.round();
    if (includeMethodLabel) {
      return 'Approx. $rounded km (straight-line distance)';
    }
    return 'Approx. $rounded km';
  }

  static double _toRadians(double deg) => deg * (math.pi / 180.0);
}
