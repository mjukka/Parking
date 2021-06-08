import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:mPark/models/location.dart';
import 'dart:async';
import 'package:mPark/resources/ConstantMethods.dart';
import 'package:mPark/resources/Resources.dart';

class NewParking extends StatefulWidget {
  // final BuildContext context;

  // NewParking({this.context});

  @override
  _NewParkingState createState() => _NewParkingState();
}

class _NewParkingState extends State<NewParking> {
  Future<String> createAlertDialog(BuildContext context) {
    TextEditingController customController = TextEditingController();
    
    AlertDialog alert = AlertDialog(
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

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      createAlertDialog(context).then((onValue) {
        SnackBar mySnackbar =
            SnackBar(content: Text('Location $onValue saved'));
        ScaffoldMessenger.of(context).showSnackBar(mySnackbar);
      });
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
