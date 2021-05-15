import 'package:flutter/material.dart';
import 'package:mPark/resources/ConstantMethods.dart';

class NewParking extends StatelessWidget {
  // final BuildContext context;

  // NewParking({this.context});
  
  Future<String> createAlertDialog(BuildContext context) {

    TextEditingController customController = TextEditingController();

    return showDialog(context: context,builder: (context){
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
                  Scaffold.of(context).showSnackBar(mySnackbar);
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
