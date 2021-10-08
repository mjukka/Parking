import 'package:google_maps_flutter/google_maps_flutter.dart';

class LastParking {
  String user;
  LatLng parkVicinity;
  LatLng parkLocation;
  bool successParking;
  LastParking({this.user, this.parkVicinity, this.parkLocation, this.successParking});
}
