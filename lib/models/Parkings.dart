import 'package:google_maps_flutter/google_maps_flutter.dart';

class Parkings {
  String user;
  LatLng parkVicinity;
  LatLng parkLocation;
  bool successParking;
  Parkings({this.user, this.parkVicinity, this.parkLocation, this.successParking});
}
