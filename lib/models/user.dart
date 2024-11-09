import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
import 'package:financialratios/models/finance_entry.dart';
import 'package:financialratios/repositories/finance_entry_repository.dart';

class User with ChangeNotifier {
  final String loginID;
  final String displayName;
  List<FinanceEntry> financeEntries = [];

  User(this.loginID, this.displayName);

  factory User.fromFirebase(FirebaseUser firebaseUser) =>
      User(firebaseUser.email, firebaseUser.displayName);

  FinanceEntry getByFEID(String financeEntryID) {
    return null;
  }

  void upsertFinanceEntry(FinanceEntry fe) {
    int feIndex;
    feIndex = financeEntries.indexWhere((entry) {
      return (entry.id == fe.id) ? true : false;
    });

    if (feIndex == -1) {
      financeEntries.add(fe);
    } else {
      financeEntries[feIndex] = fe;
    }
  }

  num _sumAmount(List<FinanceEntry> feList) {
    num sum = 0;
    feList.map((entry) {
      sum = sum + entry.amount;
    }).toList();
    return sum;
  }

  List<FinanceEntry> getEntriesByPath(String path, EntryFilter filter) {
    List<FinanceEntry> result = [];
    financeEntries.map((entry) {
      switch (filter) {
        case EntryFilter.PERSONAL:
          if (entry.groupPath.contains(path) && (entry.isSpouse == 0)) {
            result.add(entry);
          }
          break;
        case EntryFilter.SPOUSE:
          if (entry.groupPath.contains(path) && (entry.isSpouse == 1)) {
            result.add(entry);
          }
          break;
        case EntryFilter.COMBINED:
          if (entry.groupPath.contains(path)) {
            result.add(entry);
          }
          break;
      }
    }).toList();
    return result;
  }

  //Map<String, num> getGroupSumByPath(String path, EntryFilter filter) {
  //  Map<String, num> result = {};
  //  List<FinanceEntry> entries = getEntriesByPath(path, filter);
  //  entries.map((entry) {
  //    if (result[entry.groupName] == null) {
  //      result[entry.groupName] = entry.amount;
  //    } else {
  //      result[entry.groupName] += entry.amount;
  //    }
  //  }).toList();
  //  return result;
  //}

  Future<Map<String, num>> getGroupSubtotals(
      String path, EntryFilter filter) async {
    return await FinanceEntryRepo.instance
        .getGroupSumByPath(loginID, path, filter);
  }

  num getSumByPath(String path, EntryFilter filter) {
    List<FinanceEntry> feList = getEntriesByPath(path, filter);
    return _sumAmount(feList);
  }

  num getValueByName(String name, EntryFilter filter) {
    num result = 0;
    financeEntries.map((entry) {
      if (entry.name.contains(name)) {
        result = entry.amount;
      }
    }).toList();
    return result;
  }
}
