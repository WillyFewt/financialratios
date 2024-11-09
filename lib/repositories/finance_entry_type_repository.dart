import 'package:financialratios/models/finance_entry_type.dart';
import 'package:financialratios/repositories/storage.dart';
import 'package:sqflite/sqflite.dart';

class FinanceEntryTypeRepo {
  static FinanceEntryTypeRepo _instance;

  FinanceEntryTypeRepo._internal();

  static FinanceEntryTypeRepo get instance {
    if (_instance == null) {
      _instance = FinanceEntryTypeRepo._internal();
    }
    return _instance;
  }

  Future<List<FinanceEntryType>> getEntryTypeByPath(String path) async {
    String sqlQuery = """
    SELECT id, name, root, sub1, sub2, isCredit, description 
    FROM entry_type
    WHERE sub2 LIKE ?  
    ORDER BY id ASC
    """;

    Database db = await Storage.instance.getDatabase();
    List<FinanceEntryType> entryTypeList = [];

    List<Map<String, dynamic>> queryResult =
        await db.rawQuery(sqlQuery, ["$path%"]);

    queryResult.map((row) {
      entryTypeList.add(FinanceEntryType.fromDBMap(row));
    }).toList();
    return entryTypeList;
  }

  Future<List<String>> getGroupNamesByPath(String path) async {
    String sqlQuery = """
    SELECT DISTINCT et.groupName as groupName
    FROM entry_type as et
    WHERE et.rootName || '##' || et.subRootName || LIKE ? 
    ORDER BY et.id
    """;

    Database db = await Storage.instance.getDatabase();
    List<String> groupNameList = [];
    List<Map<String, dynamic>> queryResult =
        await db.rawQuery(sqlQuery, ["$path%"]);
    queryResult.map((row) {
      groupNameList.add(row["groupName"]);
    }).toList();
    return groupNameList;
  }

  Future<Map<String, dynamic>> buildTypeTree() async {
    String sqlQuery = """
    SELECT rootName, subRootName, groupName, id, name FROM entry_type    
    ORDER BY id
    """;

    Map<String, Map<String, Map<String, Map<String, String>>>> allTypes = {};

    Database db = await Storage.instance.getDatabase();
    List<Map<String, dynamic>> queryResult = await db.rawQuery(sqlQuery);
    queryResult.map((row) {
      allTypes[row["rootName"]] ??= {};
      allTypes[row["rootName"]][row["subRootName"]] ??= {};
      allTypes[row["rootName"]][row["subRootName"]]
          [row["groupName"]] ??= {row["id"]: row["name"]};
    }).toList();
    return allTypes;
  }
}
