import 'package:financialratios/screens/dashboard/dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class FinancialRatioDescriptionScreen extends StatelessWidget {
  final String name;
  final String valueString;
  final Color color;
  FinancialRatioDescriptionScreen(this.name, this.valueString, this.color);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> frData =
        Provider.of<DashboardModel>(context).frDescriptionData;
    return Scaffold(
      appBar: AppBar(
        title: Text("Description",
            style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(20))),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.navigate_before),
          color: Colors.white,
          iconSize: 40,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(ScreenUtil.getInstance().setSp(30)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: ScreenUtil.getInstance().setSp(25),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil.getInstance().setHeight(10)),
              Row(
                children: <Widget>[
                  Expanded(child: Container()),
                  Container(
                    height: ScreenUtil.getInstance().setHeight(30),
                    width: ScreenUtil.getInstance().setWidth(30),
                    margin: EdgeInsets.only(
                        right: ScreenUtil.getInstance().setWidth(15)),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    valueString,
                    style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(30),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(ScreenUtil.getInstance().setSp(20)),
                child: Text(
                  "What is this ?",
                  style: TextStyle(
                    fontSize: ScreenUtil.getInstance().setSp(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  frData[name]["description"],
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: ScreenUtil.getInstance().setSp(15),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(ScreenUtil.getInstance().setSp(20)),
                alignment: Alignment.center,
                child: Text(
                  "How to calculate ?",
                  style: TextStyle(
                    fontSize: ScreenUtil.getInstance().setSp(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 2)),
                ),
                child: Text(
                  frData[name]["operand1"],
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil.getInstance().setSp(15)),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  frData[name]["operand2"],
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil.getInstance().setSp(15)),
                ),
              ),
              Container(
                  margin:
                      EdgeInsets.only(top: ScreenUtil.getInstance().setSp(20)),
                  padding: EdgeInsets.all(ScreenUtil.getInstance().setSp(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: _buildInterpretationItem(
                        frData[name]["interpretation"]),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildInterpretationItem(Map<String, dynamic> data) {
    List<Widget> items = List<Widget>();
    data.forEach((k, v) {
      Color color;
      switch (k) {
        case "green":
          color = Colors.green;
          break;
        case "yellow":
          color = Colors.yellow;
          break;
        case "red":
          color = Colors.red;
          break;
      }
      items.add(Container(
        padding: EdgeInsets.all(ScreenUtil.getInstance().setHeight(10)),
        //margin: EdgeInsets.only(bottom: ScreenUtil.getInstance().setHeight(5)),
        color: color,
        child: Text(
          v,
          style: TextStyle(
              fontSize: ScreenUtil.getInstance().setSp(10),
              fontWeight: FontWeight.bold),
        ),
      ));
    });

    return items;
  }
}
