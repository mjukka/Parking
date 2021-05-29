import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:mPark/models/location.dart';
import 'dart:async';
import 'package:mPark/resources/ConstantMethods.dart';
import 'package:mPark/resources/Resources.dart';

class NewParking extends StatefulWidget {
  final BuildContext context;

  NewParking({this.context});
  
  @override
  _NewParkingState createState() => _NewParkingState();
}

class _NewParkingState extends State<NewParking> {
  Future<String> createAlertDialog(BuildContext context) {

    TextEditingController customController = TextEditingController();

    return showDialog(context: context,builder: (BuildContext context){
      return AlertDialog(
        title: Text('Enter your location'),
        content: TextField(
          controller: customController,
        ),
        actions: [
          MaterialButton(
            elevation: 5.0,
            child: Text('Submit'),
            onPressed: () {
              Navigator.of(context).pop(customController.text.toString());
            },
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
        return Center(
            child: FlatButton(
              padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () {
                createAlertDialog(context).then((onValue) {
                  SnackBar mySnackbar = SnackBar(content: Text('Location $onValue saved'));
                  ScaffoldMessenger.of(context).showSnackBar(mySnackbar);
                });
              },
              child: Text('Alert',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
        );
    });
  }
}



Future<String> showAlertDialog(BuildContext context) {

  // TextEditingController customController = TextEditingController();

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Is there available parking here?"),
    actions: [
      MaterialButton(
          elevation: 5.0,
          child: Text('Yes'),
          onPressed: () {
            Navigator.of(context).pop();
          },
      ),
      MaterialButton(
          elevation: 5.0,
          child: Text('No'),
          onPressed: () {
            Navigator.of(context).pop();
          },
      ),
    ],
    elevation: 20,
  );

  // show the dialog
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}