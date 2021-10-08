import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

kbackBtn(BuildContext context) {
  Navigator.of(context).pop();
}

kopenPage(BuildContext context, Widget page) {
  return Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) => page,
    ),
  );
}

kopenPageBottom(BuildContext context, Widget page) {
  Navigator.of(context).push(
    CupertinoPageRoute<bool>(
      fullscreenDialog: true,
      builder: (BuildContext context) => page,
    ),
  );
}

showErrorToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 18.0);
}

showSuccessToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 18.0);
}

Widget kBackBtn = Icon(
  Icons.arrow_back_ios,
  // color: Colors.black54,
);

Widget kLoginBtn = Icon(
  EvaIcons.logIn,
);

Widget kLogoutBtn = Icon(
  EvaIcons.logOut,
);

Widget kAccountBtn = Icon(
  EvaIcons.person,
);

var kTextFieldDecoration = InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  labelStyle: ksubtitleStyle.copyWith(
    color: Colors.black,
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black,
      width: 2,
      style: BorderStyle.solid,
    ),
    borderRadius: BorderRadius.circular(18),
  ),
  hintStyle: TextStyle(height: 1.5, fontWeight: FontWeight.w300),
  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
  errorStyle: TextStyle(height: 1.5, color: Colors.red),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.red,
      width: 2,
      style: BorderStyle.solid,
    ),
  ),
);

var kTextFieldDecorationAddress = InputDecoration(
  labelStyle: ksubtitleStyle.copyWith(
    color: Colors.black,
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black,
      width: 2,
      style: BorderStyle.solid,
    ),
    borderRadius: BorderRadius.circular(10),
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  ),
  hintStyle: TextStyle(
    height: 1.5,
    fontWeight: FontWeight.w300,
  ),
  contentPadding: EdgeInsets.symmetric(
    vertical: 20.0,
    horizontal: 20.0,
  ),
);

TextStyle ktitleStyle = TextStyle(fontWeight: FontWeight.w800);
TextStyle ksubtitleStyle = TextStyle(fontWeight: FontWeight.w600);
TextStyle kdrawerStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w400, wordSpacing: 3);
TextStyle klistStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w400);

SnackBar ksnackBar(BuildContext context, String message) {
  return SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
    backgroundColor: Theme.of(context).primaryColor,
  );
}

ShapeBorder kRoundedButtonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(50)),
);

ShapeBorder kBackButtonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    topRight: Radius.circular(30),
  ),
);
