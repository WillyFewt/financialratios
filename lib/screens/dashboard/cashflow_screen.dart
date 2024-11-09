import 'package:financialratios/models/finance_entry.dart';
import 'package:financialratios/models/user.dart';
import 'package:financialratios/screens/dashboard/dashboard_model.dart';
import 'package:financialratios/screens/dashboard/finance_entry_screen.dart';
import 'package:financialratios/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CashFlowScreen extends StatefulWidget {
  @override
  State<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends State<CashFlowScreen> {
  User user;
  EntryFilter filter;
  num inflowSubTotal;
  num outflowSubTotal;
  num cpfOutflowSubTotal;
  num cashflowTotal;
  TypeManager typeManager;

  @override
  void didChangeDependencies() {
    user = Provider.of<DashboardModel>(context).user;
    filter = Provider.of<DashboardModel>(context).filter;
    typeManager = Provider.of<DashboardModel>(context).typeManager;
    inflowSubTotal = user.getSumByPath("Cash Flow##Inflow (Yearly)", filter);
    outflowSubTotal = user.getSumByPath("Cash Flow##Outflow (Monthly)", filter);
    cpfOutflowSubTotal =
        user.getSumByPath("Cash Flow##CPF Outflow (Monthly)", filter);
    cashflowTotal =
        inflowSubTotal + (outflowSubTotal * 12) + (cpfOutflowSubTotal * 12);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cash Flow Details"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.navigate_before),
          color: Colors.white,
          iconSize: 40,
        ),
      ),
      body: _buildMainContainer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  Widget _buildMainContainer() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(ScreenUtil.getInstance().setHeight(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: ScreenUtil.getInstance().setHeight(15),
            ),
            Text(
              Utils.moneyFormatter.format(cashflowTotal),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil.getInstance().setSp(25),
              ),
            ),
            SizedBox(
              height: ScreenUtil.getInstance().setHeight(30),
            ),
            Container(
              child: _buildInflowContainer(),
            ),
            SizedBox(
              height: ScreenUtil.getInstance().setHeight(25),
            ),
            Container(
              child: _buildOutflowContainer(),
            ),
            SizedBox(
              height: ScreenUtil.getInstance().setHeight(25),
            ),
            Container(
              child: _buildCPFOutflowContainer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInflowContainer() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Total Inflow",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil.getInstance().setSp(20),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Text(
              Utils.moneyFormatter.format(inflowSubTotal),
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
          child: _buildInflowItems(),
        ),
      ],
    );
  }

  Widget _buildInflowItems() {
    String groupName = "Inflow (Yearly)";
    num value = user.getSumByPath("Cash Flow##Inflow (Yearly)", filter);
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FinanceEntryScreen(groupName, 1)));
      },
      child: Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.all(ScreenUtil.getInstance().setHeight(10)),
        margin: EdgeInsets.only(bottom: ScreenUtil.getInstance().setHeight(5)),
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOutflowContainer() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Total Outflow",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil.getInstance().setSp(20),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Text(
              Utils.moneyFormatter.format(outflowSubTotal),
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
          child: _buildOutflowItems(),
        ),
      ],
    );
  }

  Widget _buildOutflowItems() {
    num monthly = user.getSumByPath("Cash Flow##Outflow (Monthly)", filter);
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    FinanceEntryScreen("Outflow (Monthly)", -1)));
      },
      child: Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.all(ScreenUtil.getInstance().setHeight(10)),
        margin: EdgeInsets.only(bottom: ScreenUtil.getInstance().setHeight(5)),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Text(
                    "Outflow (Monthly)",
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
                    Utils.moneyFormatter.format(monthly),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: monthly.isNegative ? Colors.red : Colors.green,
                      fontSize: ScreenUtil.getInstance().setSp(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil.getInstance().setWidth(20)),
              ],
            ),
            SizedBox(height: ScreenUtil.getInstance().setWidth(10)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Outflow (Yearly)",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(15),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil.getInstance().setWidth(10)),
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
                    Utils.moneyFormatter.format(monthly * 12),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: monthly.isNegative ? Colors.red : Colors.green,
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
    );
  }

  Widget _buildCPFOutflowContainer() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Total CPF Outflow",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil.getInstance().setSp(20),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Text(
              Utils.moneyFormatter.format(cpfOutflowSubTotal),
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
          child: _buildCPFOutflowItems(),
        ),
      ],
    );
  }

  Widget _buildCPFOutflowItems() {
    num monthly = user.getSumByPath("Cash Flow##CPF Outflow (Monthly)", filter);
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    FinanceEntryScreen("CPF Outflow (Monthly)", -1)));
      },
      child: Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.all(ScreenUtil.getInstance().setHeight(10)),
        margin: EdgeInsets.only(bottom: ScreenUtil.getInstance().setHeight(5)),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Text(
                    "CPF Outflow (Monthly)",
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
                    Utils.moneyFormatter.format(monthly),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: monthly.isNegative ? Colors.red : Colors.green,
                      fontSize: ScreenUtil.getInstance().setSp(12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil.getInstance().setWidth(20)),
              ],
            ),
            SizedBox(height: ScreenUtil.getInstance().setHeight(10)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "CPF Outflow (Yearly)",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: ScreenUtil.getInstance().setSp(15),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(width: ScreenUtil.getInstance().setWidth(20)),
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
                    Utils.moneyFormatter.format(monthly * 12),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: monthly.isNegative ? Colors.red : Colors.green,
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
    );
  }
}
