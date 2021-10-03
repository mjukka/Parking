import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mPark/models/place.dart';
import 'package:mPark/screens/home.dart';
import 'package:mPark/screens/mainRouter.dart';
import 'package:mPark/services/geolocator_service.dart';
import 'package:mPark/services/places_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final locatorService = GeoLocatorService();
  final placesService = PlacesService();

  MultiProvider myapp() {
    return MultiProvider(
      providers: [
        FutureProvider(create: (context) => locatorService.getLocation()),
        FutureProvider(create: (context) {
          ImageConfiguration configuration =
              createLocalImageConfiguration(context);
          return BitmapDescriptor.fromAssetImage(
              configuration, 'assets/images/parking-icon.png');
        }),
        ProxyProvider2<Position, BitmapDescriptor, Future<List<Place>>>(
          update: (context, position, icon, places) {
            return (position != null)
                ? placesService.getPlaces(
                    position.latitude, position.longitude, icon)
                : null;
          },
        )
      ],
      child: MaterialApp(
        title: 'ParkEZ App',
        debugShowCheckedModeBanner : false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Home(),
      ),
    );
  }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print("--------------------------");

          print(snapshot.error);
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return myapp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return CircularProgressIndicator();
      },
    );
  }
}
