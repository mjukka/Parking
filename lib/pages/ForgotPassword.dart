import 'package:flutter/material.dart';
import 'package:mPark/resources/ConstantMethods.dart';
import 'package:mPark/resources/Resources.dart';
import 'package:mPark/widgets/ReusableRoundedButton.dart';
import 'package:mPark/widgets/TopBar.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({Key key}) : super(key: key);

  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  FocusScopeNode currentFocus;

unfocus() {
    currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unfocus,
      child: Scaffold(
        appBar: TopBar(
          title: Kstrings.reset_password,
          child: kBackBtn,
          onPressed: () {
            kbackBtn(context);
          },
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 25.0, left: 25.0, right: 25.0, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0, ),
                child: Text(
                  Kstrings.enter_registered_email,
                  // textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                obscureText: true,
                onChanged: (email) {},
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                decoration: kTextFieldDecoration.copyWith(
                  hintText: Kstrings.email_hint,
                  labelText: Kstrings.email,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    ReusableRoundedButton(
                      elevation: 5,
                      child: Text(
                        Kstrings.send_recovery_mail,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () {
                        //Sent Password reset link logic
                      },
                      height: 50,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
