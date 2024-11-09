import 'package:financialratios/models/finance_entry.dart';
import 'package:financialratios/models/user.dart';
import 'package:financialratios/repositories/finance_entry_repository.dart';
import 'package:financialratios/screens/dashboard/dashboard_model.dart';
import 'package:financialratios/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:flushbar/flushbar.dart';
import 'dart:io' show Platform;

import '../../app_model.dart';

class FinanceEntryScreen extends StatefulWidget {
  final String groupName;
  final num valueModifier;
  FinanceEntryScreen(this.groupName, this.valueModifier);

  @override
  State<FinanceEntryScreen> createState() => _FinanceEntryScreen();
}

class _FinanceEntryScreen extends State<FinanceEntryScreen> {
  Future<List<FinanceEntry>> feList;
  AppModel appModel;
  DashboardModel dashboardModel;
  User user;
  EntryFilter filter;
  num groupTotal;
  FinanceEntry emptyFE;
  ScrollController pageScrollController;
  OverlayEntry overlayEntry;
  bool isKeyboardVisible = false;

  @override
  void initState() {
    pageScrollController = ScrollController(keepScrollOffset: true);
    super.initState();
    if (Platform.isIOS) {
      KeyboardVisibilityNotification().addNewListener(
        onHide: () {
          removeOverlay();
        },
        onChange: (bool visible) {
          if (visible) {
            setState(() {
              isKeyboardVisible = true;
            });
          } else {
            setState(() {
              isKeyboardVisible = false;
            });
          }
        },
      );
    } else {
      KeyboardVisibilityNotification().addNewListener(
        onChange: (bool visible) {
          if (visible) {
            setState(() {
              isKeyboardVisible = true;
            });
          } else {
            setState(() {
              isKeyboardVisible = false;
            });
          }
        },
      );
    }
  }

  showOverlay(BuildContext context) {
    if (overlayEntry != null) return;
    OverlayState overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0.0,
          left: 0.0,
          child: IOSKeyboardDoneButton());
    });

    overlayState.insert(overlayEntry);
  }

  removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }

  @override
  void dispose() {
    removeOverlay();
    pageScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    appModel = Provider.of<AppModel>(context);
    dashboardModel = Provider.of<DashboardModel>(context);
    user = appModel.user;
    filter = dashboardModel.filter;
    feList = FinanceEntryRepo.instance
        .getFinanceEntriesGroupName(user, widget.groupName, filter);
    super.didChangeDependencies();
  }

  num _calculateGroupSum(List<FinanceEntry> feList) {
    num result = 0;
    feList.map((fe) {
        num amount = fe.typeID == "020100004" ? fe.amount * -1 : fe.amount;
      result = result + amount;
    }).toList();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Financial Entries"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.navigate_before),
          color: Colors.white,
          iconSize: 40,
        ),
      ),
      floatingActionButton: isKeyboardVisible
          ? SizedBox()
          : FlatButton(
              onPressed: () {
                pageScrollController
                    .jumpTo(pageScrollController.position.maxScrollExtent);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return NewEntryDialog(emptyFE, showOverlay);
                  },
                );
              },
              child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
      body: FutureBuilder<List<FinanceEntry>>(
        future: feList,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                child: Container(
                  child: SpinKitCubeGrid(
                    color: Theme.of(context).primaryColorDark,
                    size: 100,
                  ),
                ),
              );
              break;
            case ConnectionState.done:
              return SingleChildScrollView(
                key: PageStorageKey(widget.groupName),
                controller: pageScrollController,
                child: _buildMainContainer(snapshot.data),
              );
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMainContainer(List<FinanceEntry> feList) {
    groupTotal = _calculateGroupSum(feList);
    return Container(
      child: Column(
        children: <Widget>[
          _buildHeaderContainer(feList),
          Column(
            children: _buildEntryItem(feList),
          ),
          SizedBox(height: ScreenUtil.instance.setHeight(100)),
        ],
      ),
    );
  }

  Widget _buildHeaderContainer(List<FinanceEntry> feList) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil.getInstance().setSp(10)),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(ScreenUtil.getInstance().setSp(5)),
            child: Text(
              widget.groupName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil.getInstance().setSp(20),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(ScreenUtil.getInstance().setSp(10)),
            child: Text(
              Utils.moneyFormatter.format(groupTotal),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil.getInstance().setSp(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEntryItem(List<FinanceEntry> feList) {
    List<Widget> items = List<Widget>();
    emptyFE = null;
    RegExp otherRegex =
        new RegExp(r"999$", caseSensitive: true, multiLine: false);
    feList.map((fe) {
      if (otherRegex.hasMatch(fe.typeID)) {
        if (emptyFE == null) {
          emptyFE = FinanceEntry(null, fe.typeID, fe.rootName, fe.subRootName,
              fe.groupName, "Others", null, 0, null, fe.isSpouse);
        }
        if (fe.id == null) {
          return;
        }
      }
      items.add(
        FinanceEntryItem(fe, pageScrollController, showOverlay),
      );
    }).toList();
    return items;
  }
}

class FinanceEntryItem extends StatefulWidget {
  final FinanceEntry financeEntry;
  final ScrollController pageScrollController;
  final Function showOverlay;
  FinanceEntryItem(
      this.financeEntry, this.pageScrollController, this.showOverlay);

  @override
  State<FinanceEntryItem> createState() => _FinanceEntryItemState();
}

class _FinanceEntryItemState extends State<FinanceEntryItem> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  num initialAmount;

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _amountController.text =
        Utils.moneyFormatter.format(widget.financeEntry.amount);
    _amountFocusNode.addListener(_onFocusChange);

    super.initState();
  }

  void _onFocusChange() {
    if (_amountFocusNode.hasFocus) {
      if (Platform.isIOS) {
        widget.showOverlay(context);
      }
      widget.pageScrollController.position.saveScrollOffset();
      initialAmount = Utils.moneyFormatter.parse(_amountController.text);
      _amountController.selection = TextSelection(
          baseOffset: 0, extentOffset: _amountController.text.length);
      return;
    } else {
      _saveAmount();
    }
  }

  void _deleteEntry() async {
    Provider.of<DashboardModel>(context)
        .deleteFinanceEntry(widget.financeEntry.id);
  }

  void _saveAmount() async {
    if (_amountController.text.isEmpty) {
      _amountController.text = Utils.moneyFormatter.format(initialAmount);
    }
    double newAmount = Utils.moneyFormatter.parse(_amountController.text);
    _amountController.text = Utils.moneyFormatter.format(newAmount);
    if (initialAmount != newAmount) {
      widget.financeEntry.amount = newAmount;
      await Provider.of<DashboardModel>(context)
          .upsertFinanceEntry(widget.financeEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget inputField = Container(
      padding: EdgeInsets.only(
          top: ScreenUtil.getInstance().setSp(10),
          bottom: ScreenUtil.getInstance().setSp(10),
          left: ScreenUtil.getInstance().setSp(15),
          right: ScreenUtil.getInstance().setSp(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.financeEntry.name,
            style: TextStyle(
                fontSize: ScreenUtil.getInstance().setSp(15),
                fontWeight: FontWeight.bold),
          ),
          widget.financeEntry.description == null
              ? Container()
              : Text(
                  widget.financeEntry.description,
                  style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(12),                      
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700]),
                ),
          SizedBox(
            height: ScreenUtil.getInstance().setHeight(5),
          ),
          TextField(
            focusNode: _amountFocusNode,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColorLight, width: 3.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[500], width: 2.0),
              ),
            ),
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            inputFormatters: [
              WhitelistingTextInputFormatter(RegExp(r'[0-9.]+')),
            ],
            onEditingComplete: _saveAmount,
            scrollPadding:
                Platform.isIOS ? EdgeInsets.only(bottom: 80) : EdgeInsets.zero,
          )
        ],
      ),
    );
    if (widget.financeEntry.name.contains("(Others)")) {
      return Stack(children: <Widget>[
        inputField,
        Positioned(
            top: 0.0,
            right: 0.0,
            child: IconButton(
              onPressed: () async {
                _deleteEntry();
              },
              icon: Icon(
                Icons.cancel,
                color: Colors.red,
                size: 20,
              ),
            )),
      ]);
    }
    return inputField;
  }
}

class NewEntryDialog extends StatefulWidget {
  final FinanceEntry fe;
  final Function showOverlay;
  NewEntryDialog(this.fe, this.showOverlay);

  @override
  State<NewEntryDialog> createState() => _NewEntryDialogState();
}

class _NewEntryDialogState extends State<NewEntryDialog> {
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _customNameFocusNode = FocusNode();
  num _initialAmount = 0;
  String _initialCustomName = '';

  @override
  void dispose() {
    _customNameController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    _customNameFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _customNameController.text = _initialCustomName;
    _customNameFocusNode.addListener(_onCustomNameFocusChange);
    _amountController.text = Utils.moneyFormatter.format(_initialAmount);
    _amountFocusNode.addListener(_onAmountFocusChange);

    super.initState();
  }

  void _onAmountFocusChange() {
    if (_amountFocusNode.hasFocus) {
      if (Platform.isIOS) {
        widget.showOverlay(context);
      }
      _amountController.selection = TextSelection(
          baseOffset: 0, extentOffset: _amountController.text.length);
    }
  }

  void _onCustomNameFocusChange() {
    if (_customNameFocusNode.hasFocus) {
      _customNameController.selection = TextSelection(
          baseOffset: 0, extentOffset: _customNameController.text.length);
    }
  }

  void _saveEntry() async {
    String errMessage = '';
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_amountController.text.isEmpty) {
      _amountController.text = '0';
    }
    if (_customNameController.text.isEmpty) {
      errMessage = errMessage + "- New entry name is required \n";
    }
    if (_amountController.text == '0') {
      errMessage = errMessage + "- New entry amount can't be empty or zero";
    }

    if (errMessage != '') {
      Flushbar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: "Input Error",
        message: errMessage,
        duration: Duration(seconds: 2),
      )..show(context);
      return;
    }

    widget.fe.customName = _customNameController.text;
    widget.fe.amount = Utils.moneyFormatter.parse(_amountController.text);
    await Provider.of<DashboardModel>(context).upsertFinanceEntry(widget.fe);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          padding: EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Add New Entry",
                  style: TextStyle(
                      fontSize: ScreenUtil.getInstance().setSp(20),
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: ScreenUtil.getInstance().setHeight(30)),
              Text(
                "Specify new entry name: ",
                style: TextStyle(
                    fontSize: ScreenUtil.getInstance().setSp(15),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: ScreenUtil.getInstance().setHeight(5)),
              TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColorLight, width: 3.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[500], width: 2.0),
                  ),
                ),
                controller: _customNameController,
                inputFormatters: [
                  new BlacklistingTextInputFormatter(new RegExp('[#"\']')),
                ],
                focusNode: _customNameFocusNode,
              ),
              SizedBox(height: ScreenUtil.getInstance().setHeight(10)),
              Text(
                "Amount",
                style: TextStyle(
                    fontSize: ScreenUtil.getInstance().setSp(15),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: ScreenUtil.getInstance().setHeight(5)),
              TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColorLight, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[500], width: 2.0),
                  ),
                ),
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp(r'[0-9.]+')),
                ],
                focusNode: _amountFocusNode,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10),
                    color: Colors.redAccent,
                    child: FlatButton(
                      child:
                          Text("Cancel", style: TextStyle(color: Colors.white)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    color: Theme.of(context).primaryColorDark,
                    child: FlatButton(
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _saveEntry,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
