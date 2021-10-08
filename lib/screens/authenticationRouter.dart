import 'dart:ui';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mPark/widgets/TopBar.dart';
import 'package:mPark/resources/ConstantMethods.dart';
import 'package:mPark/screens/parking.dart';
import 'package:mPark/pages/LoginPage.dart';

class HomeLogged extends StatefulWidget {
  @override
  _HomeLoggedState createState() => _HomeLoggedState();
}

class _HomeLoggedState extends State<HomeLogged> {

  final pages = [
    HomeLogged(),
    LoginPage(),  // My Account(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        title: 'ParkEZ App',
        child: Container(),
        onPressed: () {
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bgnd.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.0)), // Blur effect
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                scale: 2.3,
                image: AssetImage('assets/images/icon/combo-parkez.png'),
                fit: BoxFit.none,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Parking()));
        },
        label: Text('Find parking!'),
        icon: Icon(EvaIcons.navigation),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // iconSize: 28,
        selectedFontSize: 15,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            activeIcon: Icon(EvaIcons.home),
            icon: Icon(EvaIcons.homeOutline),
            label: ('Home'),
            backgroundColor: Colors.white,
          ),
        
          BottomNavigationBarItem(
            icon: Icon(EvaIcons.person),
            label: ('Profile'),
            backgroundColor: Colors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            if (index != 0) {
              Navigator.push(
                context, CupertinoPageRoute(builder: (context) => pages[index]));
            }
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// Other way of setting background image

// Positioned.fill(
//   child: Image(
//     image: AssetImage('assets/images/parking-icon.png'),
//     fit: BoxFit.none,
//   ),
// ),
