import 'package:financialratios/models/finance_entry.dart';
import 'package:financialratios/repositories/finance_entry_repository.dart';
import 'package:financialratios/repositories/finance_entry_type_repository.dart';
import 'package:financialratios/repositories/storage.dart';
import 'package:financialratios/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:financialratios/models/user.dart';

class DashboardModel with ChangeNotifier {
  User user;
  EntryFilter _filter = EntryFilter.PERSONAL;
  Map<String, dynamic> frDescriptionData;
  EntryFilter get filter => _filter;
  TypeManager typeManager;

  DashboardModel({this.user}) {
    Utils.parseJsonFromAssets('assets/cfg/fr_desc.json').then((map) {
      frDescriptionData = map;
    });
    FinanceEntryTypeRepo.instance
        .buildTypeTree()
        .then((map) => typeManager = TypeManager(map));
  }

  @override
  void dispose() {
    //close database when dashboard closed;
    var db = Storage.instance.getDatabase();
    db.close();
    super.dispose();
  }

  void setCurrentFilter(EntryFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  Future upsertFinanceEntry(FinanceEntry fe) async {
    await FinanceEntryRepo.instance.upsertFinanceEntry(user, fe);
    //user.upsertFinanceEntry(fe);
    user.financeEntries =
        await FinanceEntryRepo.instance.getUserFinanceEntries(user.loginID);
    notifyListeners();
  }

  Future deleteFinanceEntry(String feID) async {
    await FinanceEntryRepo.instance.deleteFinanceEntry(feID);
    user.financeEntries =
        await FinanceEntryRepo.instance.getUserFinanceEntries(user.loginID);
    notifyListeners();
  }
}

class TypeManager {
  Map<String, dynamic> _typeMap;
  TypeManager(this._typeMap);

  List<String> getTypeByPath(String pathString) {
    List<String> result;
    if (pathString == null) {
      result = _typeMap?.keys?.toList();
    } else {
      List<String> paths = pathString.split("##");
      switch (paths.length) {
        case 1:
          result = _typeMap[paths[0]]?.keys?.toList();
          break;
        case 2:
          result = _typeMap[paths[0]][paths[1]]?.keys?.toList();
          break;
        case 3:
          result = _typeMap[paths[0]][paths[1]][paths[2]]?.values?.toList();
          break;
      }
    }
    return result ?? [];
  }

  List<String> getTypeIDByPath(String pathString) {
    List<String> paths = pathString.split("##");
    if (paths.length != 3) {
      return [];
    }
    return _typeMap[paths[0]][paths[1]][paths[2]]?.keys;
  }
}
