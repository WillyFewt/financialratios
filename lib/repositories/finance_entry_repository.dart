import 'package:ulid/ulid.dart';
import 'package:financialratios/models/finance_entry.dart';
import 'package:financialratios/models/user.dart';
//import 'package:financialratios/models/user.dart';
import 'package:financialratios/repositories/storage.dart';
import 'package:sqflite/sqflite.dart' show Database;

//Financial Entry Type Repository
class FinanceEntryRepo {
  static FinanceEntryRepo _instance;

  FinanceEntryRepo._init();

  static FinanceEntryRepo get instance {
    if (_instance == null) {
      _instance = FinanceEntryRepo._init();
    }
    return _instance;
  }

  Future<List<FinanceEntry>> getUserFinanceEntries(String userID) async {
    final String sqlQuery = """    
    SELECT 
      ue.id as id, 
      ue.typeID as typeID,
      et.rootName as rootName,
      et.subRootName as subRootName,
      et.groupName as groupName,      
      et.name as name,
      ue.customName as customName,
      CASE WHEN et.isCredit THEN (ue.amount * -1) ELSE ue.amount END as amount,
      et.description as description,      
      ue.isSpouse as isSpouse
    FROM user_entry AS ue
    LEFT JOIN entry_type AS et 
    ON ue.typeID = et.id 
    WHERE ue.userID = ?
    ORDER BY ue.typeID ASC
    """;

    final Database db = await Storage.instance.getDatabase();
    List<FinanceEntry> financeEntries = [];

    List<Map<String, dynamic>> queryResult =
        await db.rawQuery(sqlQuery, [userID]);
    queryResult.map((r) {
      financeEntries.add(FinanceEntry.fromDBMap(r));
    }).toList();
    return financeEntries;
  }

  Future<Map<String, num>> getGroupSumByPath(
      String userID, String path, EntryFilter filter) async {
    final String sqlQuery = """
    SELECT et.groupName AS name,
          COALESCE(SUM(ue.amount), 0) AS subTotal
      FROM user_entry AS ue
          LEFT JOIN
          entry_type AS et ON ue.typeID = et.id
    WHERE ue.userID = ? AND 
          et.rootName || '##' || et.subRootName LIKE ? AND 
          (ue.isSpouse = ? OR 
            ue.isSpouse = ?) 
    GROUP BY et.groupName
    UNION
    SELECT et.groupName AS groupName,
          0 AS groupValue
      FROM entry_type AS et
    WHERE et.rootName || '##' || et.subRootName LIKE ? AND 
          et.groupName NOT IN (
              SELECT et.groupName
                FROM user_entry AS ue
                      LEFT JOIN
                      entry_type AS et ON ue.typeID = et.id
                WHERE ue.userID = ? AND 
                      et.rootName || '##' || et.subRootName LIKE ? AND 
                      (ue.isSpouse = ? OR 
                      ue.isSpouse = ?) 
                GROUP BY et.groupName
          )
    GROUP BY et.groupName;    
    """;

    final Database db = await Storage.instance.getDatabase();
    Map<String, num> result = {};
    int isSpouse;
    int isSpouse2;
    switch (filter) {
      case EntryFilter.PERSONAL:
        isSpouse = 0;
        isSpouse2 = 0;
        break;
      case EntryFilter.SPOUSE:
        isSpouse = 1;
        isSpouse2 = 1;
        break;
      default:
        isSpouse = 0;
        isSpouse2 = 1;
    }
    List<Map<String, dynamic>> queryResult = await db.rawQuery(
      sqlQuery,
      [
        userID,
        "$path%",
        isSpouse,
        isSpouse2,
        "$path%",
        userID,
        "$path%",
        isSpouse,
        isSpouse2,
      ],
    );

    queryResult.map((row) {
      result[row["name"]] = row["subTotal"];
    }).toList();

    return result;
  }

  Future<List<FinanceEntry>> getFinanceEntriesGroupName(
      User user, String groupName, EntryFilter filter) async {
    final sqlQuery = """
    SELECT ue.id AS id,
          ue.typeID AS typeID,
          et.rootName AS rootName,
          et.subRootName AS subRootName,
          et.groupName AS groupName,
          et.name AS name,
          ue.customName AS customName,
          ue.amount AS amount,
          et.description,
          ue.isSpouse AS isSpouse
    FROM user_entry AS ue
    LEFT JOIN entry_type AS et 
        ON ue.typeID = et.id
    WHERE ue.userID = ?
          AND et.groupName = ?
          AND ue.isSpouse = ?
    UNION ALL
    SELECT 
        NULL AS id,
        et.id AS typeID,
        et.rootName AS rootName,
        et.subRootName AS subRootName,
        et.groupName AS groupName,
        et.name AS name,
        NULL AS customName,
        0 AS amount,
        et.description,
        ? AS isSpouse
    FROM entry_type AS et
    WHERE et.name NOT IN 
        (
            SELECT et.name AS name
            FROM user_entry AS ue
            LEFT JOIN entry_type AS et 
            ON ue.typeID = et.id
            WHERE ue.userID = ?
                AND et.groupName = ? 
                AND ue.isSpouse = ?
        )
    AND et.groupName = ?
    ORDER BY et.id ASC;
    """;

    final Database db = await Storage.instance.getDatabase();
    List<FinanceEntry> result = List<FinanceEntry>();
    List<Map<String, dynamic>> queryResult = await db.rawQuery(
      sqlQuery,
      [
        user.loginID,
        "$groupName",
        filter.value,
        filter.value,
        user.loginID,
        "$groupName",
        filter.value,
        "$groupName",
      ],
    );

    queryResult.map((row) {
      result.add(FinanceEntry.fromDBMap(row));
    }).toList();

    return result;
  }

  Future upsertFinanceEntry(User user, FinanceEntry fe) async {
    final Database db = await Storage.instance.getDatabase();

    if (fe.id != null) {
      await db.update('user_entry', fe.toDBMap(user.loginID),
          where: "id = ?", whereArgs: [fe.id]);
    } else {
      fe.id = Ulid().toUuid();
      await db.insert('user_entry', fe.toDBMap(user.loginID));
    }
  }

  Future deleteFinanceEntry(String feID) async {
    String sqlQuery = """
    DELETE FROM user_entry WHERE id = ? 
    """;

    Database db = await Storage.instance.getDatabase();
    await db.rawQuery(sqlQuery, [feID]);
  }
}
