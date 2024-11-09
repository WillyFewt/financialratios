import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:financialratios/models/finance_entry.dart';
import 'package:financialratios/models/user.dart';
import 'package:financialratios/screens/dashboard/dashboard_model.dart';
import 'package:financialratios/screens/dashboard/finance_entry_screen.dart';
import 'package:financialratios/services/utils.dart';

class NetWorthScreen extends StatefulWidget {
  @override
  State<NetWorthScreen> createState() => _NetWorthScreenState();
}

class _NetWorthScreenState extends State<NetWorthScreen> {
  User user;
  EntryFilter filter;
  num netWorthTotal;
  num assetsSubTotal;
  num liabilitiesSubTotal;
  TypeManager typeManager;
  //Future<Map<String, num>> groupSubTotals;

  @override
  void didChangeDependencies() {
    user = Provider.of<DashboardModel>(context).user;
    filter = Provider.of<DashboardModel>(context).filter;
    typeManager = Provider.of<DashboardModel>(context).typeManager;
    assetsSubTotal = user.getSumByPath("Net Worth##Assets", filter);
    liabilitiesSubTotal = user.getSumByPath("Net Worth##Liabilities", filter);
    netWorthTotal = assetsSubTotal + liabilitiesSubTotal;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Net Worth Details"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.navigate_before),
          color: Colors.white,
          iconSize: 40,
        ),
      ),
      body: _buildMainContainer(),
    );
  }

  Widget _buildMainContainer() {
    return SingleChildScrollView(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.all(ScreenUtil.getInstance().setHeight(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: ScreenUtil.getInstance().setHeight(15),
            ),
            Text(
              Utils.moneyFormatter.format(netWorthTotal),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil.getInstance().setSp(30),
              ),
            ),
            SizedBox(
              height: ScreenUtil.getInstance().setHeight(15),
            ),
            Container(
              child: _buildAssetContainer(),
            ),
            SizedBox(
              height: ScreenUtil.getInstance().setHeight(25),
            ),
            Container(
              child: _buildLiabilitiesContainer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetContainer() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Total Assets",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil.getInstance().setSp(20),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Text(
              Utils.moneyFormatter.format(assetsSubTotal),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil.getInstance().setSp(20),
              ),
            ),
          ],
        ),
        SizedBox(
          height: ScreenUtil.getInstance().setHeight(5),
        ),
        Container(
          child: Column(
            children: _buildAssetsItems(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAssetsItems() {
    List<Widget> result = [];
    List<String> groupNames = [
      typeManager.getTypeByPath("Net Worth##Assets"),
    ].expand((x) => x).toList();

    groupNames.forEach((groupName) {
      num value = user.getSumByPath(groupName, filter);
      PageStorageBucket _bucket = PageStorageBucket();
      result.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PageStorage(
                  child: FinanceEntryScreen(groupName, 1),
                  bucket: _bucket,
                ),
              ),
            );
          },
          child: Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.all(ScreenUtil.getInstance().setHeight(5)),
            margin:
                EdgeInsets.only(bottom: ScreenUtil.getInstance().setHeight(5)),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Text(
                        groupName,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(15),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.navigate_next,
                          size: 40,
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil.getInstance().setWidth(20)),
                  ],
                ),
                SizedBox(height: ScreenUtil.getInstance().setHeight(5)),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Sub Total",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(12),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        Utils.moneyFormatter.format(value),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: value.isNegative ? Colors.red : Colors.green,
                          fontSize: ScreenUtil.getInstance().setSp(12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil.getInstance().setWidth(20)),
                  ],
                ),
                SizedBox(height: ScreenUtil.getInstance().setHeight(5)),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text(
                        "% of Total Assets",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(12),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        assetsSubTotal == 0
                            ? "0.00%"
                            : Utils.percentageFormatter
                                .format((value / assetsSubTotal)),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil.getInstance().setWidth(20)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
    return result;
  }

  Widget _buildLiabilitiesContainer() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Total Liabilities",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil.getInstance().setSp(20),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Text(
              Utils.moneyFormatter.format(liabilitiesSubTotal),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil.getInstance().setSp(20),
              ),
            ),
          ],
        ),
        SizedBox(
          height: ScreenUtil.getInstance().setHeight(5),
        ),
        Container(
          child: Column(
            children: _buildLiabilitiesItems(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLiabilitiesItems() {
    List<Widget> result = [];
    List<String> groupNames = [
      typeManager.getTypeByPath("Net Worth##Liabilities"),
    ].expand((x) => x).toList();

    groupNames.forEach((groupName) {
      num value = user.getSumByPath(groupName, filter);
      result.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FinanceEntryScreen(groupName, -1),
              ),
            );
          },
          child: Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.all(ScreenUtil.getInstance().setHeight(5)),
            margin:
                EdgeInsets.only(bottom: ScreenUtil.getInstance().setHeight(5)),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Text(
                        groupName,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(15),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.navigate_next,
                          size: 40,
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil.getInstance().setWidth(20)),
                  ],
                ),
                SizedBox(height: ScreenUtil.getInstance().setHeight(5)),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Sub Total",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(12),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        Utils.moneyFormatter.format(value),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: value.isNegative ? Colors.red : Colors.green,
                          fontSize: ScreenUtil.getInstance().setSp(12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil.getInstance().setWidth(20)),
                  ],
                ),
                SizedBox(height: ScreenUtil.getInstance().setHeight(5)),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text(
                        "% of Total Liabilities",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(12),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        liabilitiesSubTotal == 0
                            ? "0.00%"
                            : Utils.percentageFormatter
                                .format((value / liabilitiesSubTotal)),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: ScreenUtil.getInstance().setSp(12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil.getInstance().setWidth(20)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
    return result;
  }
}
