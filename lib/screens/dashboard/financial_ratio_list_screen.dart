import 'package:financialratios/models/finance_entry.dart';
import 'package:financialratios/screens/dashboard/dasboard_screen.dart';
import 'package:financialratios/screens/dashboard/dashboard_model.dart';
import 'package:financialratios/screens/dashboard/financial_ratio_description_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class FinancialRatioListScreen extends StatefulWidget {
  final List<FinancialRatioValue> frData;
  FinancialRatioListScreen(this.frData);
  @override
  State<FinancialRatioListScreen> createState() =>
      _FinancialRatioListScreenState();
}

class _FinancialRatioListScreenState extends State<FinancialRatioListScreen> {
  @override
  Widget build(BuildContext context) {
    EntryFilter filter = Provider.of<DashboardModel>(context).filter;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Financial Ratios (${filter.name})",
          style: TextStyle(fontSize: ScreenUtil.instance.setSp(15)),
        ),
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
          margin: EdgeInsets.all(5),
          child: Column(
            children: _buildFinancialRatioList(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFinancialRatioList() {
    List<Widget> result = List<Widget>();
    widget.frData.forEach((frv) {
      result.add(_buildFinancialRatioItem(frv));
    });
    return result;
  }

  Widget _buildFinancialRatioItem(FinancialRatioValue frv) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FinancialRatioDescriptionScreen(
                  frv.name, frv.valueString, frv.color)),
        );
      },
      child: Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.only(
          bottom: ScreenUtil.getInstance().setHeight(10),
          top: ScreenUtil.getInstance().setHeight(10),
          left: ScreenUtil.getInstance().setWidth(10),
          right: ScreenUtil.getInstance().setWidth(10),
        ),
        margin: EdgeInsets.only(
          bottom: ScreenUtil.getInstance().setHeight(3),
        ),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                bottom: ScreenUtil.getInstance().setWidth(10),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Text(
                      frv.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil.getInstance().setSp(15),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.navigate_next,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Container(),
                ),
                Container(
                  height: ScreenUtil.getInstance().setHeight(20),
                  width: ScreenUtil.getInstance().setWidth(20),
                  margin: EdgeInsets.only(
                      right: ScreenUtil.getInstance().setWidth(10)),
                  decoration:
                      BoxDecoration(color: frv.color, shape: BoxShape.circle),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    frv.valueString,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil.getInstance().setSp(20),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
