import 'dart:math' show cos, sqrt, asin;


bool isInsideCircle(
    double lat, double lon, double circleLat, double circleLon) {
  var radius = 0.3;
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((circleLat - lat) * p) / 2 +
      c(lat * p) * c(circleLat * p) * (1 - c((circleLon - lon) * p)) / 2;
      print(12742 * asin(sqrt(a)));
  return (12742 * asin(sqrt(a)) <= radius);
}

