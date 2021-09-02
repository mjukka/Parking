import 'dart:async';
import 'dart:typed_data';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:geocoder/geocoder.dart' as geoCo;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mPark/methods/isInsideCircle.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mPark/models/Parkings.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mPark/screens/newParking.dart';
import 'package:mPark/services/places_service.dart';
import 'package:mPark/services/marker_service.dart';
import 'package:mPark/models/place.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class Parking extends StatefulWidget {
  Parking({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _ParkingState createState() => _ParkingState();
}

class _ParkingState extends State<Parking> {
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  GoogleMapController _controller;
  bool toggleMarkers = true;
  bool togglePOI = true;
  bool toggleCamLock = true;
  Marker marker = Marker(markerId: MarkerId("car"));
  Circle circle = Circle(circleId: CircleId("loc"));
  var markers = [];
  List<Marker> myMarker = [];
  List<Circle> circles = [];
  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  bool isInside = false;
  List<Parkings> parkings = [];
  LatLng pressedPointStorage;

  //ALERT FOUND PARKING
  Future<void> foundParkingAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Did you park?'),
          actions: <Widget>[
            MaterialButton(
              elevation: 5.0,
              child: Text('Yes'),
              onPressed: () {
                parkings.add(Parkings(
                    user: "testUser",
                    parkVicinity: pressedPointStorage,
                    parkLocation: marker.position,
                    successParking: true));
                Navigator.of(context).pop();
              },
            ),
            MaterialButton(
              child: Text('No'),
              onPressed: () {
                parkings.add(Parkings(
                    user: "testUser",
                    parkVicinity: pressedPointStorage,
                    parkLocation: marker.position,
                    successParking: false));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void initState() {
    super.initState();
    getCurrentLocation();
  }

  _createPolylines(double startLatitude, double startLongitude,
      double destinationLatitude, double destinationLongitude) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyCYYXHG1_Dw1HABNRjyDihnbOq-Z1EJ0YE",
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 10,
      zIndex: 0,
    );
    polylines[id] = polyline;
  }

  handlePress(LatLng pressedPoint) {
    setState(() {
      myMarker = [];
      circles = [];
      polylineCoordinates = [];

      myMarker.add(Marker(
        markerId: MarkerId(pressedPoint.toString()),
        position: pressedPoint,
      ));

      circles.add(Circle(
          circleId: CircleId("diam"),
          radius: 200,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: pressedPoint,
          fillColor: Colors.blue.withAlpha(70)));
    });

    pressedPointStorage = pressedPoint;
    polylineCoordinates = [];
    polylines = {};
    print(pressedPoint);
    print(marker.position);

    setState(() {
      isInside = isInsideCircle(
          marker.position.latitude,
          marker.position.longitude,
          pressedPoint.latitude,
          pressedPoint.longitude);
    });
    print(isInsideCircle(circle.center.latitude, circle.center.longitude,
        pressedPoint.latitude, pressedPoint.longitude));
  }

  _clearMarkers(LatLng foo) {
    myMarker = [];
    circles = [];
    polylineCoordinates = [];
    polylines = {};
  }

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(40.3011, 21.7882),
    zoom: 14.70,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/images/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("car"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("loc"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          if (toggleCamLock) {
            _controller.animateCamera(CameraUpdate.newCameraPosition(
                new CameraPosition(
                    bearing: 0,
                    target:
                        LatLng(newLocalData.latitude, newLocalData.longitude),
                    tilt: 0,
                    zoom: 17.60)));
            toggleCamLock = false;
          }
          updateMarkerAndCircle(newLocalData, imageData);
        }
        isInside = isInsideCircle(
            marker.position.latitude,
            marker.position.longitude,
            pressedPointStorage.latitude,
            pressedPointStorage.longitude);
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placesProvider = Provider.of<Future<List<Place>>>(context);
    final currentPosition = Provider.of<Position>(context);
    final markerService = MarkerService();

    return FutureProvider(
      create: (context) => placesProvider,
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
            OutlinedButton(
              child: Text('Where did I park?'),
              onPressed: () {
                if (parkings.length != 0) {
                  myMarker.add(Marker(
                    markerId: MarkerId("mycar"),
                    position: parkings.last.parkLocation,
                  ));
                  Navigator.pop(context);
                }
              },
            ),
          ]),
        ),
        appBar: AppBar(
          title: Text('Available Parking'),
          actions: [
            PopupMenuButton(
              tooltip: 'Filters',
                icon: Icon(Icons.filter_alt_rounded),
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      PopupMenuItem(
                        child: TextButton.icon(
                          icon: Icon(Icons.garage_rounded),
                          label: Text('Toggle parking icons On/Off'),
                          onPressed: () {
                            toggleMarkers = !toggleMarkers;
                          }
                        ),
                      ),
                      PopupMenuItem(
                        child: TextButton.icon(
                            icon: Icon(Icons.location_off),
                            label: Text('Toggle location icons On/Off'),
                            onPressed: () {
                              togglePOI
                                  ? _controller.setMapStyle(
                                      '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]')
                                  : _controller.setMapStyle(
                                      '[{"featureType": "poi","stylers": [{"visibility": "on"}]}]');
                              togglePOI = !togglePOI;
                            }
                          ),
                      ),
                    ]),
          ],
        ),
        body: (currentPosition != null)
            ? Consumer<List<Place>>(builder: (_, places, __) {
                markers = (places != null)
                    ? markerService.getMarkers(places)
                    : List<Marker>();
                return (places != null)
                    ? Container(
                        child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: initialLocation,
                          markers: toggleMarkers
                              ? Set<Marker>.of(
                                  [...myMarker, ...markers, marker])
                              : Set<Marker>.of([...myMarker, marker]),
                          circles: Set<Circle>.of([...circles, circle]),
                          polylines: Set<Polyline>.of(polylines.values),
                          onMapCreated: (GoogleMapController controller) {
                            getCurrentLocation();
                            _controller = controller;
                          },
                          onLongPress: handlePress,
                          onTap: _clearMarkers,
                          trafficEnabled: true,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                        ),
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      );
              })
            : null,
        floatingActionButton: isInside
            ? FloatingActionButton(
              heroTag: 'parkbutton',
                elevation: 8.0,
                child: Icon(Icons.local_parking_rounded),
                onPressed: () {
                  foundParkingAlert(context);
                })
            : FloatingActionButton.extended(
                heroTag: 'parkbutton',
                elevation: 8.0,
                label: Text('Navigate'),
                icon: Icon(Icons.local_parking_rounded),
                onPressed: () {
                  if (pressedPointStorage != null) {
                    //meta to clearmarkers an patisw navigate bgazei pali directions
                    polylineCoordinates = [];
                    polylines = {};
                    _createPolylines(
                        marker.position.latitude,
                        marker.position.longitude,
                        pressedPointStorage.latitude,
                        pressedPointStorage.longitude);
                  } else {
                    Fluttertoast.showToast(
                        msg: "Please select an area",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 18.0);
                  }
                }),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
