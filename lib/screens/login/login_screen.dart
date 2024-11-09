import 'package:financialratios/app_model.dart';
import 'package:financialratios/exceptions/FirebaseException.dart';
import 'package:financialratios/models/user.dart';
import 'package:financialratios/screens/login/reset_password_screen.dart';
import 'package:financialratios/services/authorization_service.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:provider/provider.dart';

enum LoginState { Initial, Submitting }

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AppModel appModel;
  TextEditingController _emailText = TextEditingController();
  TextEditingController _passwordText = TextEditingController();
  bool submitting = false;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance =
        ScreenUtil(width: 392, height: 738, allowFontScaling: true)
          ..init(context);
    appModel = Provider.of<AppModel>(context);
    return new Scaffold(
      //resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: new Center(
        child: SingleChildScrollView(
          child: new Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Image.asset('assets/images/logo.png'),
                  height: ScreenUtil.getInstance().setHeight(225),
                  width: ScreenUtil.getInstance().setWidth(195),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: new TextField(
                    controller: _emailText,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.email),
                      hintText: "Enter your e-mail",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: new TextField(
                    controller: _passwordText,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.vpn_key),
                      hintText: "Enter your password",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ),
                SizedBox(
                  child: Container(),
                  height: ScreenUtil.getInstance().setHeight(10),
                ),
                Container(
                  height: ScreenUtil.getInstance().setHeight(50),
                  child: submitting
                      ? Center(
                          child: SpinKitCubeGrid(
                              color: Theme.of(context).primaryColorDark,
                              size: 30))
                      : FlatButton(
                          color: Theme.of(context).primaryColorDark,
                          key: null,
                          onPressed: submitting ? null : _doLogin,
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.0)),
                          child: new Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil.getInstance().setSp(20),
                            ),
                          ),
                        ),
                ),
                SizedBox(
                  height: 30,
                  child: Container(),
                ),
                Container(
                    child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Forgot password? Click here.",
                    style: TextStyle(color: Colors.black),
                  ),
                ))
              ],
            ),
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  Future _doLogin() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      submitting = true;
    });
    await Future.delayed(Duration(seconds: 1), () {});
    String email = _emailText.text;
    String password = _passwordText.text;
    try {
      if (email.isEmpty || password.isEmpty) {
        throw FirebaseException("Email and password are required");
      }
      User user = await AuthorizationService.instance.login(email, password);
      appModel.userLoggedIn(user);
    } on PlatformException catch (e) {
      String errorMessage =
          'Please check your internet connection.\nIf the error persist please contact developer team';
      switch (e.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage = "Invalid email address.";
          break;
        case "ERROR_WRONG_PASSWORD":
          errorMessage = "Wrong password.";
          break;
        case "ERROR_USER_NOT_FOUND":
          errorMessage = "User not found";
          break;
        case "ERROR_USER_DISABLED":
          errorMessage = "User was disabled, please contact admin";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          errorMessage =
              "Too many failed login attempt, please try again after few minutes";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage = "Operation not allowed";
          break;
      }
      Flushbar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: "Login Error",
        message: errorMessage,
        duration: Duration(seconds: 2),
      )..show(context);
      setState(() {
        submitting = false;
      });
    } on FirebaseException catch (e) {
      Flushbar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: "Login Error",
        message: e.msg,
        duration: Duration(seconds: 2),
      )..show(context);
      setState(() {
        submitting = false;
      });
    }
  }
}
