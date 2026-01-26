import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/barber.dart';
import '../models/user.dart';

class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  Future<List<Shop>> searchShops({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    final radiusMeters = (radiusKm * 1000).toInt();
    final url = '$_baseUrl/nearbysearch/json'
        '?location=$latitude,$longitude'
        '&radius=$radiusMeters'
        '&type=hair_care'
        '&keyword=barber'
        '&key=${AppConstants.googleMapsApiKey}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((place) {
          return Shop(
            id: place['place_id'],
            name: place['name'],
            address: place['vicinity'],
            latitude: place['geometry']['location']['lat'],
            longitude: place['geometry']['location']['lng'],
            avatarUrl: _getPhotoUrl(place['photos']?.first['photo_reference']),
            phone: null, // Detail search needed for phone
            website: null,
          );
        }).toList();
      }
    } catch (e) {
      // print('Error fetching places: $e');
    }
    return [];
  }

  String? _getPhotoUrl(String? reference) {
    if (reference == null) return null;
    return '$_baseUrl/photo?maxwidth=400&photo_reference=$reference&key=${AppConstants.googleMapsApiKey}';
  }
}
