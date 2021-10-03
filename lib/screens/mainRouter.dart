import 'dart:ui';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mPark/screens/home.dart';
import 'package:mPark/widgets/TopBar.dart';
import 'package:mPark/resources/ConstantMethods.dart';
import 'package:mPark/pages/LoginPage.dart';

class MainRouter extends StatefulWidget {
  @override
  _MainRouterState createState() => _MainRouterState();
}

class _MainRouterState extends State<MainRouter> {
  final pages = [
    Home(),
    LoginPage(), // My Account(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        title: 'ParkEZ App',
        child: kLoginBtn,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
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
                image: AssetImage('assets/icon/combo-parkez.png'),
                fit: BoxFit.none,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        // type: BottomNavigationBarType.shifting,
        // iconSize: 28,
        selectedFontSize: 15,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(EvaIcons.home),
            activeIcon: Icon(EvaIcons.homeOutline),
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
          if (index != 0) {
            showToast('You need to sign in first!');
            setState(() {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => pages[index]));
            });
          }
        },
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
