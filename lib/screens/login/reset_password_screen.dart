import 'package:financialratios/exceptions/FirebaseException.dart';
import 'package:financialratios/services/authorization_service.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController _emailText = TextEditingController();
  bool submitting = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
                          onPressed: submitting ? null : _doResetPassword,
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.0)),
                          child: new Text(
                            "Reset Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil.getInstance().setSp(20),
                            ),
                          ),
                        ),
                )
              ],
            ),
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  Future _doResetPassword() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      submitting = true;
    });
    await Future.delayed(Duration(seconds: 1), () {});
    String email = _emailText.text;

    try {
      if (email.isEmpty) {
        throw FirebaseException("Email is required");
      }
      await AuthorizationService.instance.resetPassword(email);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'System Info',
                style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(18),
                ),
              ),
              content: Text(
                'Password reset link has been sent to your email, please check your inbox and follow the instruction',
                textAlign: TextAlign.justify,
              ),
              actions: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  color: Theme.of(context).primaryColor,
                  child: FlatButton(
                    child: Text("OK", style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              ],
            );
          });
    } on PlatformException catch (e) {
      String errorMessage =
          'Please check your internet connection.\nIf the error persist please contact developer team';
      switch (e.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage = "Invalid email.";
          break;
        case "ERROR_USER_NOT_FOUND":
          errorMessage = "User not found.";
          break;
      }
      Flushbar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: "Reset Password Error",
        message: errorMessage,
        duration: Duration(seconds: 2),
      )..show(context);
      setState(() {
        submitting = false;
      });
    } on FirebaseException catch (e) {
      Flushbar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: "Reset Password Error",
        message: e.msg,
        duration: Duration(seconds: 2),
      )..show(context);
      setState(() {
        submitting = false;
      });
    }
  }
}
