import 'package:financialratios/exceptions/FirebaseException.dart';
import 'package:financialratios/exceptions/InvalidInputException.dart';
import 'package:financialratios/models/user.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../app_model.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController password0Controller = TextEditingController();
  final TextEditingController password1Controller = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();
  final FocusNode password0FocusNode = FocusNode();
  final FocusNode password1FocusNode = FocusNode();
  final FocusNode password2FocusNode = FocusNode();
  bool isFormSubmitting = false;

  void _validateInput() {
    if (password0Controller.text.isEmpty) {
      throw InvalidInputException("Current password is required");
    }

    if (password1Controller.text.length < 6) {
      throw InvalidInputException(
          "Your new password are too short (Minimum 6 character");
    }
    if (password1Controller.text != password2Controller.text) {
      throw InvalidInputException("Your new password must equal");
    }
  }

  void _updatePassword() async {
    setState(() {
      isFormSubmitting = true;
    });
    try {
      User currentUser = Provider.of<AppModel>(context, listen: false).user;
      _validateInput();
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'Updating Password...',
                style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(18),
                ),
              ),
              content: SpinKitCubeGrid(
                  color: Theme.of(context).primaryColor, size: 30),
            );
          });
      await Provider.of<AppModel>(context, listen: false).changePassword(
          currentUser.loginID,
          password0Controller.text,
          password1Controller.text);
      Navigator.of(context).pop();
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
                'Your password has been changed, please relogin with new password',
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
                      Provider.of<AppModel>(context).userLoggedOut();
                    },
                  ),
                ),
              ],
            );
          });
    } on InvalidInputException catch (e) {
      Flushbar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: "Invalid Input",
        message: e.msg,
        duration: Duration(seconds: 2),
      )..show(context);
      setState(() {
        isFormSubmitting = false;
      });
    } on FirebaseException catch (e) {
      Navigator.of(context).pop();
      setState(() {
        isFormSubmitting = false;
      });
      Flushbar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: "Change Password Failed",
        message: e.msg,
        duration: Duration(seconds: 2),
      )..show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text("Change Password")),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.only(
              top: ScreenUtil.getInstance().setHeight(30),
              left: ScreenUtil.getInstance().setWidth(20),
              right: ScreenUtil.getInstance().setWidth(20),
            ),
            padding: EdgeInsets.only(
              top: ScreenUtil.getInstance().setHeight(10),
              bottom: ScreenUtil.getInstance().setHeight(10),
              left: ScreenUtil.getInstance().setWidth(10),
              right: ScreenUtil.getInstance().setWidth(10),
            ),
            child: Column(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Current Password:",
                      style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(5),
                    ),
                    TextField(
                      controller: password0Controller,
                      focusNode: password0FocusNode,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColorLight,
                              width: 3.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey[500], width: 2.0),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.getInstance().setHeight(15),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "New Password (min 6 characters):",
                      style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(5),
                    ),
                    TextField(
                      controller: password1Controller,
                      focusNode: password1FocusNode,
                      textAlign: TextAlign.center,
                      obscureText: true,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColorLight,
                              width: 3.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey[500], width: 2.0),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.getInstance().setHeight(15),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Re-type New Password:",
                      style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(15),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: ScreenUtil.getInstance().setHeight(5),
                    ),
                    TextField(
                      focusNode: password2FocusNode,
                      textAlign: TextAlign.center,
                      obscureText: true,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColorLight,
                              width: 3.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey[500], width: 2.0),
                        ),
                      ),
                      controller: password2Controller,
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.getInstance().setHeight(15),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(10),
                      color: Colors.red,
                      child: FlatButton(
                        child: Text("Cancel",
                            style: TextStyle(color: Colors.white)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      color: Theme.of(context).primaryColorDark,
                      child: FlatButton(
                        child:
                            Text("Save", style: TextStyle(color: Colors.white)),
                        onPressed: isFormSubmitting ? null : _updatePassword,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
