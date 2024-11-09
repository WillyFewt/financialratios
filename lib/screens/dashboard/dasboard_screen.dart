import 'package:financialratios/app_model.dart';
import 'package:financialratios/models/finance_entry.dart';
import 'package:financialratios/screens/dashboard/cashflow_screen.dart';
import 'package:financialratios/screens/dashboard/change_password_screen.dart';
import 'package:financialratios/screens/dashboard/dashboard_model.dart';
import 'package:financialratios/screens/dashboard/financial_ratio_list_screen.dart';
import 'package:financialratios/screens/dashboard/networth_screen.dart';
import 'package:financialratios/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:financialratios/models/user.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardModel dashboardModel;
  User user;
  EntryFilter filter;
  TypeManager typeManager;
  num netWorthTotal;
  num assetsSubTotal;
  num liabilitiesSubTotal;
  num inflowSubTotal;
  num outflowSubTotal;
  num cpfOutflowSubTotal;
  num cashflowTotal;

  @override
  void didChangeDependencies() {
    ScreenUtil.instance =
        ScreenUtil(width: 392, height: 738, allowFontScaling: true)
          ..init(context);
    user = Provider.of<DashboardModel>(context).user;
    filter = Provider.of<DashboardModel>(context).filter;
    typeManager = Provider.of<DashboardModel>(context).typeManager;
    assetsSubTotal = user.getSumByPath("Net Worth##Assets", filter);
    liabilitiesSubTotal = user.getSumByPath("Net Worth##Liabilities", filter);
    netWorthTotal = assetsSubTotal + liabilitiesSubTotal;
    inflowSubTotal = user.getSumByPath("Cash Flow##Inflow (Yearly)", filter);
    outflowSubTotal = user.getSumByPath("Cash Flow##Outflow (Monthly)", filter);
    cpfOutflowSubTotal =
        user.getSumByPath("Cash Flow##CPF Outflow (Monthly)", filter);
    cashflowTotal =
        inflowSubTotal + (outflowSubTotal * 12) + (cpfOutflowSubTotal * 12);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //Provider.of<DashboardModel>(context).dispose();
    super.dispose();
  }

  void _popUpMenuAction(int itemValue) {
    switch (itemValue) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChangePasswordScreen()));
        break;
      case 1:
        Navigator.of(context).popUntil((route) => route.isFirst);
        Provider.of<AppModel>(context).userLoggedOut();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DASHBOARD"),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          PopupMenuButton<int>(
            offset: Offset(0, 150),
            onSelected: _popUpMenuAction,
            icon: Icon(Icons.settings),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Text("Change Password"),
              ),
              PopupMenuItem(
                value: 1,
                child: Text("Sign Out"),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _builtBottomBars(),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
            top: ScreenUtil.getInstance().setHeight(2),
            bottom: ScreenUtil.getInstance().setHeight(2),
            left: ScreenUtil.getInstance().setWidth(2),
            right: ScreenUtil.getInstance().setWidth(2),
          ),
          child: Column(
            children: <Widget>[
              //NET WORTH CONTAINER
              GestureDetector(
                onTap: filter == EntryFilter.COMBINED
                    ? null
                    : () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NetWorthScreen()));
                      },
                child: Container(
                  color: Theme.of(context).cardColor,
                  padding:
                      EdgeInsets.all(ScreenUtil.getInstance().setHeight(10)),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            "Net Worth (${filter.name})",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil.getInstance().setSp(16)),
                          ),
                          SizedBox(
                            child: Container(),
                            width: ScreenUtil.getInstance().setWidth(10),
                          ),
                          Expanded(
                            child: filter == EntryFilter.COMBINED
                                ? Container(
                                    height:
                                        ScreenUtil.getInstance().setHeight(40))
                                : Align(
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
                      Text(
                        Utils.moneyFormatter
                            .format(netWorthTotal),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil.getInstance().setSp(20),
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: ScreenUtil.getInstance().setHeight(5)),
                      Column(
                        children: _buildNetWorthItems(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil.getInstance().setHeight(10)),
              //CASH FLOW CONTAINER
              GestureDetector(
                onTap: filter == EntryFilter.COMBINED
                    ? null
                    : () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CashFlowScreen()));
                      },
                child: Container(
                  color: Theme.of(context).cardColor,
                  padding:
                      EdgeInsets.all(ScreenUtil.getInstance().setHeight(10)),
                  //color: Colors.grey[200],
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            "Cash Flow (${filter.name})",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil.getInstance().setSp(16)),
                          ),
                          SizedBox(
                            child: Container(),
                            width: ScreenUtil.getInstance().setWidth(10),
                          ),
                          Expanded(
                            child: filter == EntryFilter.COMBINED
                                ? Container(
                                    height:
                                        ScreenUtil.getInstance().setHeight(40))
                                : Align(
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
                      Text(
                        Utils.moneyFormatter
                            .format(cashflowTotal),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil.getInstance().setSp(20),
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: ScreenUtil.getInstance().setHeight(5)),
                      Column(
                        children: _buildCashFlowItems(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil.getInstance().setHeight(10)),
              //FINANCIAL RATIO Container
              _buildFinancialRatioContainer(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNetWorthItems() {
    List<Widget> result = [];
    List<String> paths = [
      typeManager.getTypeByPath("Net Worth##Assets"),
      typeManager.getTypeByPath("Net Worth##Liabilities")
    ].expand((x) => x).toList();

    paths.forEach((path) {
      num value = user.getSumByPath(path, filter);
      result.add(
        Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Text(
                path,
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
      );
    });

    return result;
  }

  List<Widget> _buildCashFlowItems() {
    List<Widget> result = [];
    List<String> paths = [
      typeManager.getTypeByPath("Cash Flow##Inflow (Yearly)"),
      typeManager.getTypeByPath("Cash Flow##Outflow (Monthly)"),
      typeManager.getTypeByPath("Cash Flow##CPF Outflow (Monthly)"),
    ].expand((x) => x).toList();

    paths.forEach((path) {
      num value = user.getSumByPath("##$path", filter);
      result.add(
        Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Text(
                path,
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
      );
    });

    return result;
  }

  Widget _buildFinancialRatioContainer() {
    List<FinancialRatioValue> frList = _generateFinancialRatioValues();
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FinancialRatioListScreen(frList)));
      },
      child: Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.all(ScreenUtil.getInstance().setHeight(10)),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  "Financial Ratios (${filter.name})",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil.getInstance().setSp(16)),
                ),
                SizedBox(
                  child: Container(),
                  width: ScreenUtil.getInstance().setWidth(10),
                ),
                Expanded(
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
            SizedBox(height: ScreenUtil.getInstance().setHeight(25)),
            Column(
              children: _buildFinancialRatioItems(frList),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFinancialRatioItems(List<FinancialRatioValue> data) {
    List<Widget> result = [];
    data.forEach((frv) {
      result.add(
        Container(
          padding:
              EdgeInsets.only(bottom: ScreenUtil.getInstance().setHeight(3)),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 12,
                child: Text(
                  frv.name,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: ScreenUtil.getInstance().setSp(12),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil.getInstance().setWidth(20)),
              Container(
                height: ScreenUtil.getInstance().setHeight(12),
                width: ScreenUtil.getInstance().setWidth(12),
                margin: EdgeInsets.only(
                    right: ScreenUtil.getInstance().setWidth(5)),
                decoration: BoxDecoration(
                  color: frv.color,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  frv.valueString,
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
        ),
      );
    });

    return result;
  }

  List<FinancialRatioValue> _generateFinancialRatioValues() {
    List<FinancialRatioValue> frList = [];

    num cashAndCashEquivalent = user
        .getSumByPath("Net Worth##Assets##Cash & Cash Equivalent", filter)
        .abs();
    num monthlyExpenses =
        user.getSumByPath("Cash Flow##Outflow (Monthly)##", filter).abs();
    num totalNetWorth = user.getSumByPath("Net Worth", filter);
    num totalAssets = user.getSumByPath("Net Worth##Assets", filter).abs();
    num totalDebts = user.getSumByPath("Net Worth##Liabilities", filter).abs();
    num totalMonthlyLoanRepayments =
        user.getValueByName("Loan Repayment - Cash", filter).abs();
    num monthlyTakeHomePay =
        (user.getSumByPath("Cash Flow##Inflow (Yearly)", filter) / 12).abs();
    num totalInvestedAssets =
        user.getSumByPath("Net Worth##Assets##Invested Assets", filter).abs();
    num saving =
        user.getValueByName("Regular Savings & Investments", filter).abs();
    num grossIncome = monthlyTakeHomePay;

    FinancialRatioValue blr = FinancialRatioValue();
    blr.name = "Basic Liquidity Ratio";
    if (monthlyExpenses != 0) {
      blr.value = cashAndCashEquivalent / monthlyExpenses;
      blr.valueString = blr.value.toStringAsFixed(1);
      if (blr.value < 3.0) {
        blr.color = Colors.red;
      } else if (blr.value <= 6.0) {
        blr.color = Colors.green;
      } else {
        blr.color = Colors.yellow;
      }
    }
    frList.add(blr);

    FinancialRatioValue sr = FinancialRatioValue();
    sr.name = "Solvency Ratio";
    if (totalAssets != 0) {
      sr.value = totalNetWorth / totalAssets;
      sr.valueString = Utils.percentageFormatter.format(sr.value);
      if (sr.value <= 0.35) {
        sr.color = Colors.yellow;
      } else {
        sr.color = Colors.green;
      }
    }
    frList.add(sr);

    FinancialRatioValue dtar = FinancialRatioValue();
    dtar.name = "Debt To Asset Ratio";
    if (totalAssets != 0) {
      dtar.value = totalDebts / totalAssets;
      dtar.valueString = Utils.percentageFormatter.format(dtar.value);
      if (dtar.value < 0.5) {
        dtar.color = Colors.green;
      } else if (blr.value == 0.5) {
        dtar.color = Colors.yellow;
      } else {
        dtar.color = Colors.red;
      }
    }
    frList.add(dtar);

    FinancialRatioValue dsr = FinancialRatioValue();
    dsr.name = "Debt Service Ratio";
    if (monthlyTakeHomePay != 0) {
      dsr.value = totalMonthlyLoanRepayments / monthlyTakeHomePay;
      dsr.valueString = Utils.percentageFormatter.format(dsr.value);
      if (dsr.value <= 0.35) {
        dsr.color = Colors.green;
      } else {
        dsr.color = Colors.yellow;
      }
    }
    frList.add(dsr);

    FinancialRatioValue latnwr = FinancialRatioValue();
    latnwr.name = "Liquid Assets to Net Worth Ratio";
    if (totalNetWorth != 0) {
      latnwr.value = cashAndCashEquivalent / totalNetWorth;
      latnwr.valueString = Utils.percentageFormatter.format(latnwr.value);
      if (latnwr.value < 0.15) {
        latnwr.color = Colors.red;
      } else if (latnwr.value <= 0.20) {
        latnwr.color = Colors.green;
      } else {
        latnwr.color = Colors.yellow;
      }
    }
    frList.add(latnwr);

    FinancialRatioValue niastnwr = FinancialRatioValue();
    niastnwr.name = "Net Investment Asset to Net Worth Ratio";
    if (totalNetWorth != 0) {
      niastnwr.value = totalInvestedAssets / totalNetWorth;
      niastnwr.valueString = Utils.percentageFormatter.format(niastnwr.value);
      if (niastnwr.value < 0.5) {
        niastnwr.color = Colors.yellow;
      } else {
        niastnwr.color = Colors.green;
      }
    }
    frList.add(niastnwr);

    FinancialRatioValue svr = FinancialRatioValue();
    svr.name = "Savings Ratio";
    if (grossIncome != 0) {
      svr.value = saving / grossIncome;
      svr.valueString = Utils.percentageFormatter.format(svr.value);
      if (svr.value < 0.1) {
        svr.color = Colors.yellow;
      } else {
        svr.color = Colors.green;
      }
    }
    frList.add(svr);

    return frList;
  }

  Widget _builtBottomBars() {
    final TextStyle _buttonStyle = TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: ScreenUtil.getInstance().setSp(15));

    return Container(
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.only(
        top: ScreenUtil.getInstance().setHeight(10),
        bottom: ScreenUtil.getInstance().setHeight(10),
        left: ScreenUtil.getInstance().setWidth(10),
        right: ScreenUtil.getInstance().setWidth(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            color: filter == EntryFilter.PERSONAL
                ? Theme.of(context).primaryColorDark
                : Colors.grey,
            child: Text("Personal", style: _buttonStyle),
            onPressed: () {
              Provider.of<DashboardModel>(context)
                  .setCurrentFilter(EntryFilter.PERSONAL);
            },
          ),
          FlatButton(
            color: filter == EntryFilter.SPOUSE
                ? Theme.of(context).primaryColorDark
                : Colors.grey,
            child: Text(
              "Spouse",
              style: _buttonStyle,
            ),
            onPressed: () {
              Provider.of<DashboardModel>(context)
                  .setCurrentFilter(EntryFilter.SPOUSE);
            },
          ),
          FlatButton(
            color: filter == EntryFilter.COMBINED
                ? Theme.of(context).primaryColorDark
                : Colors.grey,
            child: Text("Combined", style: _buttonStyle),
            onPressed: () {
              Provider.of<DashboardModel>(context)
                  .setCurrentFilter(EntryFilter.COMBINED);
            },
          ),
        ],
      ),
    );
  }
}

class FinancialRatioValue {
  String name;
  num value;
  String valueString = '--';
  Color color = Colors.grey[400];
}
