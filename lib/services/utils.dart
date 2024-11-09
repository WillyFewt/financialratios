import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class Utils {
  static final NumberFormat moneyFormatter = new NumberFormat.currency(
      locale: "en_SG", symbol: "\$ ", decimalDigits: 2);
  static final NumberFormat decimalFormatter =
      new NumberFormat.decimalPattern("en_SG");
  static final NumberFormat percentageFormatter = new NumberFormat("#,##0.00%");

  static Future<Map<String, dynamic>> parseJsonFromAssets(
      String assetsPath) async {
    return rootBundle
        .loadString(assetsPath)
        .then((jsonStr) => jsonDecode(jsonStr));
  }
}

class IOSKeyboardDoneButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey[700],
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(
              top: ScreenUtil.getInstance().setHeight(5),
              bottom: ScreenUtil.getInstance().setHeight(5)),
          child: CupertinoButton(
            padding: EdgeInsets.only(
                right: ScreenUtil.getInstance().setWidth(24),
                top: ScreenUtil.getInstance().setHeight(8),
                bottom: ScreenUtil.getInstance().setHeight(8)),
            onPressed: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Text("Done",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
