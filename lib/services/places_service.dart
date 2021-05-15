import 'dart:io';

import 'package:mPark/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class PlacesService {
  final key = 'AIzaSyClCJ99QJFz8RdhAHXSo8fXUw2ZvG-xrlA';

  Future<List<Place>> getPlaces(double lat, double lng, BitmapDescriptor icon) async {
    var response = await http.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&type=parking&rankby=distance&key=$key');
    stderr.writeln(response);
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['results'] as List;
    return jsonResults.map((place) => Place.fromJson(place,icon)).toList();
  }

}