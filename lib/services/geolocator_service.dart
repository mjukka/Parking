import 'package:geolocator/geolocator.dart';

class GeoLocatorService{

  Future<Position> getLocation() async {
    try{
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }
    on Exception catch (e) {
      return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest);
    }
    
  }

  Future<double> getDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) async {
   return Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
  }


}