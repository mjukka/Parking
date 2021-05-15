import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:mPark/main.dart';
import './MobileLoginPage.dart';
import '../resources/ConstantMethods.dart';
import '../resources/Resources.dart';
import '../widgets/TopBar.dart';
import 'ForgotPassword.dart';
import 'package:flutter/material.dart';

enum ButtonType { LOGIN, REGISTER }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // String idHint = string.student_id;
  bool isRegistered = false;
  String notYetRegisteringText = Kstrings.not_registered;
  ButtonType buttonType = ButtonType.LOGIN;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: TopBar(
        title: !isRegistered ? Kstrings.login : Kstrings.register,
        child: kBackBtn,
        onPressed: () {
          kbackBtn(context);
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 31),
            child: FloatingActionButton.extended(
              heroTag: 'abc',
              label: Container(),
              onPressed: () {
                kopenPageBottom(context, MobileLoginPage());
              },
              icon: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Icon(EvaIcons.phone),
              ),
            ),
          ),
          FloatingActionButton.extended(
              label: Text(
                buttonType == ButtonType.LOGIN
                    ? Kstrings.login
                    : Kstrings.register,
                style: ktitleStyle,
              ),
              onPressed: () {
                kopenPage(context, MyApp());
              },
              icon: !isRegistered ? Icon(EvaIcons.logIn) : Icon(EvaIcons.checkmarkCircle)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Hero(
              tag: 'imageee',
              child: Image.asset(
                Kassets.group,
                width: MediaQuery.of(context).size.width - 50,
                alignment: Alignment.topCenter,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 5),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    onChanged: (email) {},
                    keyboardType: TextInputType.emailAddress,
                    style: ksubtitleStyle.copyWith(fontSize: 18),
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: Kstrings.email_hint,
                      labelText: Kstrings.email,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    obscureText: true,
                    onChanged: (password) {},
                    keyboardType: TextInputType.emailAddress,
                    style: ksubtitleStyle.copyWith(fontSize: 18),
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: Kstrings.password_hint,
                      labelText: Kstrings.password,
                    ),
                  ),
                  isRegistered
                      ? SizedBox(
                          height: 15,
                        )
                      : Container(),
                  isRegistered
                      ? TextField(
                          obscureText: true,
                          onChanged: (password) {},
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: Kstrings.confirm_password_hint,
                            labelText: Kstrings.confirm_password,
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 15,
                  ),
                  // Hero(
                  // tag: 'otpForget',
                  // child:
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FloatingActionButton.extended(
                          heroTag: 'needHelp',
                          label: Text(
                            notYetRegisteringText,
                            style: ktitleStyle,
                          ),
                          onPressed: () {
                            setState(() {
                              if (buttonType == ButtonType.LOGIN) {
                                buttonType = ButtonType.REGISTER;
                              } else {
                                buttonType = ButtonType.LOGIN;
                              }
                              isRegistered = !isRegistered;
                              notYetRegisteringText = isRegistered
                                  ? Kstrings.registered
                                  : Kstrings.not_registered;
                            });
                          },
                          // height: 40,
                        ),
                        !isRegistered
                          ? MaterialButton(
                          // heroTag: 'needHelp',
                          child: Text(
                            Kstrings.forgot_password,
                            style: ktitleStyle,
                          ),
                          textColor: Colors.blue,
                          onPressed: () {
                            //Forget Password Logic
                            kopenPage(context, ForgotPasswordPage());
                          },
                          // height: 40,
                        )
                        : Container(),
                      ],
                    ),
                  ),
                  // ),
                  SizedBox(
                    height: 250,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
