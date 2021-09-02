import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mPark/models/place.dart';
import 'package:mPark/screens/home.dart';
import 'package:mPark/services/geolocator_service.dart';
import 'package:mPark/services/places_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final locatorService = GeoLocatorService();
  final placesService = PlacesService();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider(create: (context) => locatorService.getLocation()),
        FutureProvider(create: (context) {
          ImageConfiguration configuration = createLocalImageConfiguration(context);
          return BitmapDescriptor.fromAssetImage(configuration, 'assets/images/parking-icon.png');
        }),
        ProxyProvider2<Position,BitmapDescriptor,Future<List<Place>>>( 
          update: (context,position,icon,places){
            return (position !=null) ? placesService.getPlaces(position.latitude, position.longitude,icon) :null;
          },
        )
      ],
      child: MaterialApp(
        title: 'Parking App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Home(),
      ),
    );
  }
}
