import 'dart:async';
import 'dart:typed_data';
import 'package:geocoder/geocoder.dart' as geoCo;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mPark/methods/isInsideCircle.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mPark/models/Parkings.dart';
import 'package:mPark/pages/LoginPage.dart';
import 'package:mPark/resources/ConstantMethods.dart';
import 'package:mPark/resources/Resources.dart';
import 'package:provider/provider.dart';
import 'package:mPark/services/places_service.dart';
import 'package:mPark/services/marker_service.dart';
import 'package:mPark/models/place.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class Parking extends StatefulWidget {
  final Function() notifyParent;

  Parking({Key key, this.title, this.notifyParent}) : super(key: key);
  final String title;
  @override
  _ParkingState createState() => _ParkingState();
}

class _ParkingState extends State<Parking> {
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  GoogleMapController _controller;
  int percent = 500;
  bool toggleMarkers = true;
  bool togglePOI = true;
  bool toggleTraffic = true;
  bool toggleCamLock = false;
  bool parkedSuccessfully = false;
  Marker carMarker = Marker(markerId: MarkerId("car"));
  Circle circle = Circle(circleId: CircleId("loc"));
  var markers = [];
  List<Marker> myMarker = [];
  List<Circle> circles = [];
  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  bool isInside = false;
  bool permissions = false;
  List<LastParking> lastparking = [];
  LatLng pressedPointStorage;
  int counterSucc = 0;
  int counter = 0;
  double prob = 0;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference parkingsFB =
      FirebaseFirestore.instance.collection('parkings');

  int calculateProb() {
    percent = 0;
    prob = 0.0;
    parkingsFB.get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        if (isInsideCircle(
            result.get("parkLocation")[0],
            result.get("parkLocation")[1],
            pressedPointStorage.latitude,
            pressedPointStorage.longitude)) {
          if (result.get("successParking")) {
            counterSucc = counterSucc + 1;
          }
          counter++;
        }
      });
    });

    setState(() {
      if (counter < 1) {
        prob = 0.0;
      } else {
        prob = counterSucc / counter * 100;
      }
      percent = prob.toInt();
    });

    print(prob.toString());
    print("---------calculateProb--------------");

    return prob.toInt();
  }

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
                parkingsFB
                    .add({
                      'user': "testUser",
                      'parkVicinity': pressedPointStorage.toJson(),
                      'parkLocation': carMarker.position.toJson(),
                      'successParking': true
                    })
                    .then((value) => print("User Added"))
                    .catchError((error) => print("Failed to add user: $error"));

                lastparking.add(LastParking(
                  user: 'testUser',
                  parkVicinity: pressedPointStorage,
                  parkLocation: carMarker.position,
                ));
                parkedSuccessfully = true;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    children: [
                      //Icon(Icons.add_location, size: 28),
                      //SizedBox(width: 5),
                      Text('Do you want to save this location?',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  backgroundColor: Colors.yellowAccent,
                  duration: Duration(seconds: 10),
                  action: SnackBarAction(
                    label: 'Yes',
                    textColor: Colors.black,
                    onPressed: () {},
                  ),
                ));
                Navigator.of(context).pop();
              },
            ),
            MaterialButton(
              child: Text('No'),
              onPressed: () {
                parkingsFB
                    .add({
                      'user': "testUser",
                      'parkVicinity': pressedPointStorage.toJson(),
                      'parkLocation': carMarker.position.toJson(),
                      'successParking': false
                    })
                    .then((value) => print("User Added"))
                    .catchError((error) => print("Failed to add user: $error"));
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
      zIndex: 999,
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
        //infoWindow: InfoWindow.
      ));

      circles.add(Circle(
          circleId: CircleId("diam"),
          radius: 300,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: pressedPoint,
          fillColor: Colors.blue.withAlpha(70)));
    });

    pressedPointStorage = pressedPoint;
    polylineCoordinates = [];
    polylines = {};
    parkedSuccessfully = false;
    calculateProb();
    print(pressedPoint);
    print(carMarker.position);

    setState(() {
      isInside = isInsideCircle(
          carMarker.position.latitude,
          carMarker.position.longitude,
          pressedPoint.latitude,
          pressedPoint.longitude);
    });

    print(isInsideCircle(circle.center.latitude, circle.center.longitude,
        pressedPoint.latitude, pressedPoint.longitude));
  }

  _clearMarkers(LatLng foo) {
    setState(() {
      myMarker = [];
      circles = [];
      polylineCoordinates = [];
      polylines = {};
      pressedPointStorage = null;
    });
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
      carMarker = Marker(
          markerId: MarkerId("car"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          consumeTapEvents: true,
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
    var permission = await Permission.location.isGranted;
    debugPrint("Permission" + permission.toString());

    if (permission) {
      permissions = true;
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
            }
            updateMarkerAndCircle(newLocalData, imageData);
          }
          isInside = isInsideCircle(
              carMarker.position.latitude,
              carMarker.position.longitude,
              pressedPointStorage.latitude,
              pressedPointStorage.longitude);
        });
      } on PlatformException catch (e) {
        if (e.code == 'PERMISSION_DENIED') {
          setState(() {
            permissions = false;
          });

          debugPrint("Permission Denied");
        }
      } on PermissionDeniedException catch (e) {
        setState(() {
          permissions = false;
        });
      }
    } else {
      permissions = false;
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  void requestPermissions() {
    Permission.locationWhenInUse.request().then((value) => {
          if (value.isGranted)
            {
              setState(() {
                permissions = true;
              })
            }
        });
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
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Image.asset(Kassets.logo),
                ),
                SizedBox(
                  height: 20,
                ),
                ListTile(
                        minVerticalPadding: 20,
                        title: Text('Where did I park?', style: kdrawerStyle),
                        onTap: () {
                          if (lastparking.length != 0) {
                            _clearMarkers(pressedPointStorage);
                            myMarker.add(Marker(
                              markerId: MarkerId("mycar"),
                              infoWindow: InfoWindow(title: 'I parked here!'),
                              position: lastparking.last.parkLocation,
                            ));
                            polylineCoordinates = [];
                            polylines = {};
                            _createPolylines(
                              carMarker.position.latitude,
                              carMarker.position.longitude,
                              lastparking.last.parkLocation.latitude,
                              lastparking.last.parkLocation.longitude);
                            Navigator.pop(context);
                          } else {
                            showErrorToast('No last parking position detected');
                            Navigator.pop(context);
                          }
                        }),
                Divider(
                  height: 6,
                  thickness: 1,
                  color: Colors.black,
                  endIndent: 30,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 65, bottom: 20, top: 6),
                  child: Text('Saved Parkings', style: kdrawerStyle),
                ),
                Expanded(
                  flex: 6,
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 16),
                      itemBuilder: (_, index) =>
                        Text('Location $index', style: klistStyle, textScaleFactor: 1.5),
                        itemCount: 15,
                        //itemCount: lastparking.length,
                    ),
                ),
                Divider(
                  height: 6,
                  thickness: 1,
                  color: Colors.black,
                  endIndent: 30,
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: FractionalOffset.bottomLeft,
                    child: ListTile(
                      contentPadding: EdgeInsets.only(bottom: 10, left: 10),
                      leading: Icon(
                        Icons.account_circle,
                        size: 60,
                      ),
                      title: Text('My Account', style: TextStyle(fontSize: 16)),
                      // onTap: () {
                      //   Navigator.push(context,
                      //       MaterialPageRoute(builder: (context) => LoginPage()));
                      // },
                    ),
                  ),
                ),
              ]),
        ),
        appBar: AppBar(
          title: (permissions) ? Text('Find Parking') : Text('Enable Location'),
          actions: [
            (permissions)
                ? PopupMenuButton(
                    tooltip: 'Filters',
                    icon: Icon(Icons.filter_alt_rounded),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                          PopupMenuItem(
                            child: TextButton.icon(
                                icon: Icon(Icons.garage_rounded),
                                label: Text('Parking icons On/Off'),
                                onPressed: () {
                                  setState(() {
                                    toggleMarkers = !toggleMarkers;
                                  });
                                }),
                          ),
                          PopupMenuItem(
                            child: TextButton.icon(
                                icon: Icon(Icons.location_off),
                                label: Text('Places icons On/Off'),
                                onPressed: () {
                                  setState(() {
                                    togglePOI
                                        ? _controller.setMapStyle(
                                            '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]')
                                        : _controller.setMapStyle(
                                            '[{"featureType": "poi","stylers": [{"visibility": "on"}]}]');
                                    togglePOI = !togglePOI;
                                  });
                                }),
                          ),
                          PopupMenuItem(
                            child: TextButton.icon(
                                icon: Icon(Icons.traffic),
                                label: Text('Traffic Map On/Off'),
                                onPressed: () {
                                  setState(() {
                                    toggleTraffic = !toggleTraffic;
                                  });
                                }),
                          ),
                        ])
                : Container(),
          ],
        ),
        body: (permissions)
            ? (currentPosition != null)
                ? Consumer<List<Place>>(builder: (_, places, __) {
                    markers = (places != null)
                        ? markerService.getMarkers(places)
                        : List<Marker>();
                    return (places != null)
                        ? Stack(children: [
                            Container(
                              child: GoogleMap(
                                mapType: MapType.normal,
                                initialCameraPosition: initialLocation,
                                markers: toggleMarkers
                                    ? Set<Marker>.of(
                                        [...myMarker, ...markers, carMarker])
                                    : Set<Marker>.of([...myMarker, carMarker]),
                                circles: Set<Circle>.of([...circles, circle]),
                                polylines: Set<Polyline>.of(polylines.values),
                                onMapCreated: (GoogleMapController controller) {
                                  toggleCamLock = true;
                                  getCurrentLocation();
                                  _controller = controller;
                                },
                                onLongPress: handlePress,
                                onTap: _clearMarkers,
                                trafficEnabled: toggleTraffic,
                                zoomControlsEnabled: false,
                                mapToolbarEnabled: false,
                              ),
                            ),
                            Container(
                              alignment: Alignment.topCenter,
                              padding: EdgeInsets.only(top: 15),
                              child: (pressedPointStorage != null &&
                                      parkedSuccessfully == false)
                                  ? /*Positioned(
                                      top: 20.0,
                                      child:*/ Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 6.0, horizontal: 12.0),
                                        decoration: BoxDecoration(
                                          color: Colors.yellowAccent,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 2),
                                              blurRadius: 6.0,
                                            )
                                          ],
                                        ),
                                        child: Text(
                                          'Possibility to find parking is $percent%',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    //)
                                  : Container(),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              padding: EdgeInsets.only(bottom: 80, right: 16),
                                    child: FloatingActionButton(
                                        heroTag: null,
                                        backgroundColor: Colors.white,
                                        elevation: 10.0,
                                        child: Icon(Icons.my_location_outlined, color: Colors.blue),
                                        onPressed: () { 
                                          _controller.animateCamera(CameraUpdate.newCameraPosition(
                                              new CameraPosition(
                                                  bearing: 0,
                                                  target:
                                                      LatLng(carMarker.position.latitude, carMarker.position.longitude),
                                                  tilt: 0,
                                                  zoom: 17.60)));
                                        }),
                                  ),
                            Container(
                              alignment: Alignment.bottomRight,
                              padding: EdgeInsets.only(bottom: 145, right: 16),
                                    child: FloatingActionButton(
                                        heroTag: null,
                                        tooltip: 'Lock camera on car',
                                        backgroundColor: toggleCamLock ? Colors.green : Colors.white,
                                        elevation: toggleCamLock ? 5.0 : 10.0,
                                        child: Icon(toggleCamLock ? Icons.lock : Icons.lock_open, color: toggleCamLock ? Colors.white : Colors.blue),
                                        onPressed: () {
                                           toggleCamLock = !toggleCamLock;
                                        }),
                            ),
                          ])
                        : Center(
                            child: CircularProgressIndicator(),
                          );
                  })
                : null
            : Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('You need to enable location access!',
                          style: TextStyle(fontSize: 18)),
                      OutlinedButton(
                        onPressed: requestPermissions,
                        child: Text('Enable location'),
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.black45)),
                      ),
                    ]),
              ),
        floatingActionButton: (permissions)
            ? isInside
                ? FloatingActionButton(
                    heroTag: null,
                    elevation: 8.0,
                    child: Icon(Icons.local_parking_rounded),
                    onPressed: () {
                      if (pressedPointStorage != null) {
                        foundParkingAlert(context);
                      } else {
                        showErrorToast("No area is selected");
                      }
                    })
                : FloatingActionButton.extended(
                    heroTag: null,
                    elevation: 8.0,
                    label: Text('Navigate'),
                    icon: Icon(Icons.local_parking_rounded),
                    onPressed: () {
                      if (pressedPointStorage != null) {
                        polylineCoordinates = [];
                        polylines = {};
                        _createPolylines(
                            carMarker.position.latitude,
                            carMarker.position.longitude,
                            pressedPointStorage.latitude,
                            pressedPointStorage.longitude);
                      } else {
                        showErrorToast("Please select an area");
                      }
                    })
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
